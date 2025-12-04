use starknet::ContractAddress;
use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use starknet::{get_block_timestamp, get_caller_address, get_contract_address};

// Dispatcher para USDC ERC20
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

// Token dispatcher actual
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

#[derive(Drop, Serde, starknet::Store)]
struct LaunchInfo {
    token_address: ContractAddress,
    creator: ContractAddress,
    initial_price: u256,
    current_price: u256,
    total_supply: u256,
    liquidity: u256,
    k: u256,
    n: u256,
    fee_rate: u256,
    launch_time: u64,
    is_active: bool,
}

#[starknet::contract]
mod Launchpad {
    use super::{
        LaunchInfo, ITokenDispatcherDispatcher, IERC20Dispatcher,
        calculate_price, calculate_tokens_for_eth, calculate_eth_for_tokens
    };
    use starknet::storage::*;
    use starknet::*;

    #[storage]
    struct Storage {
        launches: Map<ContractAddress, LaunchInfo>,
        launchpad_fee_recipient: ContractAddress,
        usdc_address: ContractAddress,
        user_avg_price: Map<(ContractAddress, ContractAddress), u256>,
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
    // ==============================
    //         LAUNCH TOKEN
    // ==============================
    //
    #[abi(embed_v0)]
    impl LaunchpadImpl for ContractState {
        fn launch_token(
            ref self: ContractState,
            token_address: ContractAddress,
            initial_price: u256,
            k: u256,
            n: u256,
            fee_rate: u256,
        ) {
            let caller = get_caller_address();
            assert(!self.launches.read(token_address).is_active, 'Token already launched');

            let token = ITokenDispatcherDispatcher { contract_address: token_address };
            let total_supply = token.total_supply();

            let launch = LaunchInfo {
                token_address,
                creator: caller,
                initial_price,
                current_price: initial_price,
                total_supply,
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
        // ==============================
        //         BUY TOKENS
        // ==============================
        //
        fn buy_tokens(
            ref self: ContractState,
            token_address: ContractAddress,
            usdc_amount: u256
        ) -> u256 {
            let caller = get_caller_address();
            assert(usdc_amount > 0, 'USDC amount must be > 0');

            let mut info = self.launches.read(token_address);
            assert(info.is_active, 'Token not launched');

            let usdc = IERC20Dispatcher { contract_address: self.usdc_address.read() };

            //
            // ---- FEES: 0.5% creator + 0.5% protocolo ----
            //
            let creator_fee = usdc_amount / 200;   // 0.5%
            let protocol_fee = usdc_amount / 200;  // 0.5%
            let amount_after_fee = usdc_amount - creator_fee - protocol_fee;

            // Transferencias reales de USDC
            usdc.transfer_from(caller, info.creator, creator_fee);
            usdc.transfer_from(caller, self.launchpad_fee_recipient.read(), protocol_fee);
            usdc.transfer_from(caller, get_contract_address(), amount_after_fee);

            //
            // ----- Aumenta la liquidez real en USDC -----
            //
            info.liquidity += amount_after_fee;

            //
            // ----------- Bonding curve mint -------------
            //
            let tokens_out = calculate_tokens_for_eth(
                info.current_price,
                info.total_supply,
                amount_after_fee,
                info.k,
                info.n
            );

            info.total_supply += tokens_out;

            // update price
            info.current_price = calculate_price(
                info.initial_price,
                info.total_supply,
                info.k,
                info.n
            );

            self.launches.write(token_address, info);

            // Mint real tokens
            let token = ITokenDispatcherDispatcher { contract_address: token_address };
            token.mint(caller, tokens_out);

            //
            // ======== Update user average entry price ========
            //
            let old_price = self.user_avg_price.read((token_address, caller));
            let new_avg = if old_price == 0 {
                info.current_price
            } else {
                (old_price + info.current_price) / 2
            };
            self.user_avg_price.write((token_address, caller), new_avg);

            tokens_out
        }

        //
        // ==============================
        //         SELL TOKENS
        // ==============================
        //
        fn sell_tokens(
            ref self: ContractState,
            token_address: ContractAddress,
            token_amount: u256
        ) -> u256 {
            let caller = get_caller_address();
            assert(token_amount > 0, 'Invalid amount');

            let mut info = self.launches.read(token_address);
            assert(info.is_active, 'Inactive token');

            let token = ITokenDispatcherDispatcher { contract_address: token_address };
            let balance = token.balance_of(caller);
            assert(balance >= token_amount, 'Insufficient balance');

            let usdc = IERC20Dispatcher { contract_address: self.usdc_address.read() };

            //
            // ------- Valor según bonding curve -------
            //
            let usdc_value = calculate_eth_for_tokens(
                info.current_price,
                info.total_supply,
                token_amount,
                info.k,
                info.n
            );

            let mut final_amount = usdc_value;

            let entry_price = self.user_avg_price.read((token_address, caller));
            let price_now = info.current_price;

            //
            // -------- Penalidad 1% si precio NO subió --------
            //
            if price_now <= entry_price {
                let penalty = usdc_value / 100; // 1%
                final_amount -= penalty;

                let creator_cut = penalty / 2;
                let protocol_cut = penalty / 2;

                // enviar penalidad desde liquidez
                usdc.transfer(get_contract_address(), info.creator, creator_cut);
                usdc.transfer(get_contract_address(), self.launchpad_fee_recipient.read(), protocol_cut);
            }

            //
            // ------ Actualiza liquidez real ------
            //
            info.liquidity -= usdc_value;

            //
            // ------ Reduce supply de bonding curve ------
            //
            info.total_supply -= token_amount;

            info.current_price = calculate_price(
                info.initial_price,
                info.total_supply,
                info.k,
                info.n
            );
            self.launches.write(token_address, info);

            //
            // ------ Burn tokens enviados a zero ------
            //
            token.transfer_from(caller, zero_address(), token_amount);

            //
            // ------ Pago real en USDC al usuario ------
            //
            usdc.transfer(get_contract_address(), caller, final_amount);

            final_amount
        }

        fn get_price(self: @ContractState, token_address: ContractAddress) -> u256 {
            let info = self.launches.read(token_address);
            if !info.is_active { return 0; }
            calculate_price(info.initial_price, info.total_supply, info.k, info.n)
        }

        fn get_launch_info(self: @ContractState, token_address: ContractAddress) -> LaunchInfo {
            self.launches.read(token_address)
        }

        fn get_liquidity(self: @ContractState, token_address: ContractAddress) -> u256 {
            self.launches.read(token_address).liquidity
        }
    }

    //
    // ==============================
    //      INTERNAL MATH
    // ==============================
    //
    fn calculate_price(initial_price: u256, supply: u256, k: u256, n: u256) -> u256 {
        if supply == 0 { return initial_price; }
        let ratio = (supply * 1000) / k;
        (initial_price * (1000 + ratio)) / 1000
    }

    fn calculate_tokens_for_eth(
        current_price: u256,
        current_supply: u256,
        eth_amount: u256,
        k: u256,
        n: u256
    ) -> u256 {
        let next_price = calculate_price(
            current_price,
            current_supply + (eth_amount / current_price),
            k,
            n
        );
        let avg_price = (current_price + next_price) / 2;
        eth_amount / avg_price
    }

    fn calculate_eth_for_tokens(
        current_price: u256,
        current_supply: u256,
        token_amount: u256,
        k: u256,
        n: u256
    ) -> u256 {
        let prev_price = calculate_price(
            current_price,
            current_supply - token_amount,
            k,
            n
        );
        let avg_price = (current_price + prev_price) / 2;
        token_amount * avg_price
    }

    fn zero_address() -> ContractAddress {
        0.into()
    }
}
