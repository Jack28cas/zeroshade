use starknet::ContractAddress;
use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use starknet::{get_block_timestamp, get_caller_address, get_contract_address};

//
// =============================
//      INTERFACES
// =============================
//

// USDC ERC20 Dispatcher
#[starknet::interface]
trait IERC20<TContractState> {
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    ) -> bool;

    fn transfer(
        ref self: TContractState,
        recipient: ContractAddress,
        amount: u256,
    ) -> bool;

    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
}

// Token Dispatcher
#[starknet::interface]
trait ITokenDispatcher<TContractState> {
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    ) -> bool;
    fn mint(ref self: TContractState, to: ContractAddress, amount: u256);
}

//
// =============================
//      DATA STRUCTS
// =============================
//

#[derive(Drop, Serde, starknet::Store)]
struct LaunchInfo {
    token_address: ContractAddress,
    creator: ContractAddress,
    initial_price: u256,    // escalar 1e6
    current_price: u256,    // escalar 1e6
    total_supply: u256,     // tokens * 1e6
    liquidity: u256,        // USDC * 1e6
    k: u256,
    n: u256,
    fee_rate: u256,
    launch_time: u64,
    is_active: bool,
}

//
// =============================
//          CONTRACT
// =============================
//

#[starknet::contract]
mod Launchpad {
    use super::{
        LaunchInfo,
        ITokenDispatcherDispatcher,
        IERC20Dispatcher,
        calculate_price,
        calculate_tokens_for_usdc,
        calculate_usdc_for_tokens
    };
    use starknet::*;

    const DECIMALS: u256 = 1_000_000; // 6 decimales

    #[storage]
    struct Storage {
        launches: Map<ContractAddress, LaunchInfo>,
        launchpad_fee_recipient: ContractAddress,
        usdc_address: ContractAddress,
        user_avg_price: Map<(ContractAddress, ContractAddress), u256>, // precio en 6 decimales
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        fee_recipient: ContractAddress,
        usdc_address: ContractAddress
    ) {
        self.launchpad_fee_recipient.write(fee_recipient);
        self.usdc_address.write(usdc_address);
    }

    //
    // =============================
    //         PUBLIC METHODS
    // =============================
    //

    #[abi(embed_v0)]
    impl LaunchpadImpl for ContractState {

        //
        // ----- LAUNCH TOKEN -----
        //
        fn launch_token(
            ref self: ContractState,
            token_address: ContractAddress,
            initial_price: u256,   // DEBE venir ya escalado *1e6
            k: u256,
            n: u256,
            fee_rate: u256
        ) {
            let caller = get_caller_address();
            assert(!self.launches.read(token_address).is_active, 'Already launched');

            let token = ITokenDispatcherDispatcher { contract_address: token_address };
            let supply = token.total_supply();

            let launch = LaunchInfo {
                token_address,
                creator: caller,
                initial_price,
                current_price: initial_price,
                total_supply: supply,
                liquidity: 0,
                k,
                n,
                fee_rate,
                launch_time: get_block_timestamp(),
                is_active: true,
            };

            self.launches.write(token_address, launch);
        }

        //
        // ----- BUY TOKENS WITH USDC -----
        //
        fn buy_tokens(
            ref self: ContractState,
            token_address: ContractAddress,
            usdc_amount: u256 // en 6 decimales
        ) -> u256 {
            let caller = get_caller_address();
            assert(usdc_amount > 0, 'Invalid amount');

            let mut info = self.launches.read(token_address);
            assert(info.is_active, 'Inactive token');

            let usdc = IERC20Dispatcher { contract_address: self.usdc_address.read() };

            //
            // -------- 1% total fee: 0.5% creator + 0.5% protocolo --------
            //
            let creator_fee = usdc_amount / 200;   // 0.5%
            let protocol_fee = usdc_amount / 200;  // 0.5%
            let net_amount = usdc_amount - creator_fee - protocol_fee;

            // USDC reales moviéndose
            usdc.transfer_from(caller, info.creator, creator_fee);
            usdc.transfer_from(caller, self.launchpad_fee_recipient.read(), protocol_fee);
            usdc.transfer_from(caller, get_contract_address(), net_amount);

            // aumenta liquidez real
            info.liquidity += net_amount;

            //
            // -------- bonding curve: calcular tokens recibidos --------
            //
            let tokens_out = calculate_tokens_for_usdc(
                info.current_price,
                info.total_supply,
                net_amount,
                info.k,
                info.n
            );

            info.total_supply += tokens_out;

            // actualizar precio
            info.current_price = calculate_price(
                info.initial_price,
                info.total_supply,
                info.k,
                info.n
            );

            self.launches.write(token_address, info);

            // mint real tokens
            let token = ITokenDispatcherDispatcher { contract_address: token_address };
            token.mint(caller, tokens_out);

            //
            // ----- actualizar precio promedio del usuario -----
            //
            let prev = self.user_avg_price.read((token_address, caller));
            let new_avg = if prev == 0 {
                info.current_price
            } else {
                (prev + info.current_price) / 2
            };
            self.user_avg_price.write((token_address, caller), new_avg);

            tokens_out
        }

        //
        // ----- SELL TOKENS -----
        //
        fn sell_tokens(
            ref self: ContractState,
            token_address: ContractAddress,
            token_amount: u256 // 6 dec
        ) -> u256 {
            let caller = get_caller_address();
            assert(token_amount > 0, 'Invalid amount');

            let mut info = self.launches.read(token_address);
            assert(info.is_active, 'Inactive token');

            let token = ITokenDispatcherDispatcher { contract_address: token_address };
            let bal = token.balance_of(caller);
            assert(bal >= token_amount, 'Insufficient balance');

            let usdc = IERC20Dispatcher { contract_address: self.usdc_address.read() };

            //
            // ---- valor según curva (USDC) ----
            //
            let usdc_value = calculate_usdc_for_tokens(
                info.current_price,
                info.total_supply,
                token_amount,
                info.k,
                info.n
            );

            let mut payout = usdc_value;

            //
            // ========== Penalidad 1% si precio no subió ==========
            //
            let entry = self.user_avg_price.read((token_address, caller));
            let current = info.current_price;

            if current <= entry {
                let penalty = usdc_value / 100; // 1%
                payout -= penalty;

                let creator_cut = penalty / 2;
                let protocol_cut = penalty / 2;

                usdc.transfer(get_contract_address(), info.creator, creator_cut);
                usdc.transfer(get_contract_address(), self.launchpad_fee_recipient.read(), protocol_cut);
            }

            //
            // ------ actualizar liquidez real ------
            //
            info.liquidity -= usdc_value;

            //
            // ------ supply curva ------
            //
            info.total_supply -= token_amount;

            //
            // ------ actualizar precio ------
            //
            info.current_price = calculate_price(
                info.initial_price,
                info.total_supply,
                info.k,
                info.n
            );

            self.launches.write(token_address, info);

            //
            // ------ burn tokens ------
            //
            token.transfer_from(caller, zero_address(), token_amount);

            //
            // ------ pagar USDC real al usuario ------
            //
            usdc.transfer(get_contract_address(), caller, payout);

            payout
        }

        fn get_price(self: @ContractState, token_address: ContractAddress) -> u256 {
            let info = self.launches.read(token_address);
            if !info.is_active { return 0; }
            info.current_price
        }

        fn get_launch_info(self: @ContractState, token_address: ContractAddress) -> LaunchInfo {
            self.launches.read(token_address)
        }

        fn get_liquidity(self: @ContractState, token_address: ContractAddress) -> u256 {
            self.launches.read(token_address).liquidity
        }
    }

    //
    // =============================
    //       INTERNAL MATH
    // =============================
    //

    fn calculate_price(initial: u256, supply: u256, k: u256, n: u256) -> u256 {
        if supply == 0 { return initial; }
        let ratio = (supply * DECIMALS) / k;
        (initial * (DECIMALS + ratio)) / DECIMALS
    }

    fn calculate_tokens_for_usdc(
        price: u256,
        supply: u256,
        amount: u256,
        k: u256,
        n: u256
    ) -> u256 {
        let next_price = calculate_price(
            price,
            supply + (amount * DECIMALS / price), // escala correcta
            k,
            n
        );

        let avg_price = (price + next_price) / 2;

        // tokens_out = (amount * DECIMALS) / avg_price
        (amount * DECIMALS) / avg_price
    }

    fn calculate_usdc_for_tokens(
        price: u256,
        supply: u256,
        tokens: u256,
        k: u256,
        n: u256
    ) -> u256 {
        let prev_price = calculate_price(
            price,
            supply - tokens,
            k,
            n
        );

        let avg_price = (price + prev_price) / 2;

        // usdc = tokens * avg_price / DECIMALS
        (tokens * avg_price) / DECIMALS
    }

    fn zero_address() -> ContractAddress {
        0.into()
    }
}
