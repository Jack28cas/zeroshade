use starknet::ContractAddress;

// ZumpFun Launchpad Contract
// Manages token launches with bonding curve pricing

// Interface for PausableERC20 (payment token)
#[starknet::interface]
trait IPaymentToken<TContractState> {
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
}

#[starknet::interface]
trait ILaunchpad<TContractState> {
    fn launch_token(
        ref self: TContractState,
        token_address: ContractAddress,
        initial_price: u256,
        k: u256,
        n: u256,
        fee_rate: u256,
    );
    fn buy_tokens(
        ref self: TContractState, token_address: ContractAddress, payment_amount: u256,
    ) -> u256;
    fn sell_tokens(
        ref self: TContractState, token_address: ContractAddress, token_amount: u256,
    ) -> u256;
    fn get_price(self: @TContractState, token_address: ContractAddress) -> u256;
    fn get_launch_info(self: @TContractState, token_address: ContractAddress) -> LaunchInfo;
    fn get_liquidity(self: @TContractState, token_address: ContractAddress) -> u256;
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
#[feature("deprecated-starknet-consts")]
mod Launchpad {
    use starknet::storage::Map;
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use super::{LaunchInfo, IPaymentTokenDispatcher, IPaymentTokenDispatcherTrait};
    use crate::contracts::token::{ITokenDispatcher, ITokenDispatcherTrait};

    #[storage]
    struct Storage {
        launches: Map<ContractAddress, LaunchInfo>,
        launchpad_fee_recipient: ContractAddress,
        payment_token: ContractAddress, // PausableERC20 address
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TokenLaunched: TokenLaunched,
        TokensBought: TokensBought,
        TokensSold: TokensSold,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenLaunched {
        token_address: ContractAddress,
        creator: ContractAddress,
        initial_price: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct TokensBought {
        token_address: ContractAddress,
        buyer: ContractAddress,
        eth_amount: u256,
        tokens_received: u256,
        new_price: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct TokensSold {
        token_address: ContractAddress,
        seller: ContractAddress,
        token_amount: u256,
        eth_received: u256,
        new_price: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, 
        fee_recipient: ContractAddress,
        payment_token: ContractAddress, // PausableERC20 address
    ) {
        self.launchpad_fee_recipient.write(fee_recipient);
        self.payment_token.write(payment_token);
    }

    #[abi(embed_v0)]
    impl LaunchpadImpl of super::ILaunchpad<ContractState> {
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

            // Verify token exists and get initial supply
            let token_dispatcher = ITokenDispatcher { contract_address: token_address };
            let total_supply: u256 = token_dispatcher.total_supply();

            let launch_info = LaunchInfo {
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

            self.launches.write(token_address, launch_info);
            self.emit(TokenLaunched { token_address, creator: caller, initial_price });
        }

        fn buy_tokens(
            ref self: ContractState, token_address: ContractAddress, payment_amount: u256,
        ) -> u256 {
            let caller = get_caller_address();
            assert(payment_amount > 0, 'Amount must be greater than 0');

            let launch_info = self.launches.read(token_address);
            assert(launch_info.is_active, 'Token not launched or inactive');

            // Transfer payment tokens from caller to Launchpad
            let payment_token_address = self.payment_token.read();
            let mut payment_dispatcher = IPaymentTokenDispatcher { contract_address: payment_token_address };
            payment_dispatcher.transfer_from(caller, get_contract_address(), payment_amount);

            // Calculate tokens to receive based on bonding curve
            let tokens_to_receive = InternalImpl::calculate_tokens_for_payment(
                launch_info.current_price,
                launch_info.total_supply,
                payment_amount,
                launch_info.k,
                launch_info.n,
            );

            // Calculate fees
            let fee = (payment_amount * launch_info.fee_rate) / 10000;
            let payment_after_fee = payment_amount - fee;

            // Update launch info
            let new_price = InternalImpl::calculate_price(
                launch_info.initial_price,
                launch_info.total_supply + tokens_to_receive,
                launch_info.k,
                launch_info.n,
            );
            let new_launch_info = LaunchInfo {
                token_address: launch_info.token_address,
                creator: launch_info.creator,
                initial_price: launch_info.initial_price,
                current_price: new_price,
                total_supply: launch_info.total_supply + tokens_to_receive,
                liquidity: launch_info.liquidity + payment_after_fee,
                k: launch_info.k,
                n: launch_info.n,
                fee_rate: launch_info.fee_rate,
                launch_time: launch_info.launch_time,
                is_active: launch_info.is_active,
            };

            self.launches.write(token_address, new_launch_info);

            // Mint tokens to buyer
            let mut token_dispatcher = ITokenDispatcher { contract_address: token_address };
            token_dispatcher.mint(caller, tokens_to_receive);

            self
                .emit(
                    TokensBought {
                        token_address,
                        buyer: caller,
                        eth_amount: payment_amount,
                        tokens_received: tokens_to_receive,
                        new_price,
                    },
                );

            tokens_to_receive
        }

        fn sell_tokens(
            ref self: ContractState, token_address: ContractAddress, token_amount: u256,
        ) -> u256 {
            let caller = get_caller_address();
            assert(token_amount > 0, 'Amount must be greater than 0');

            let mut launch_info = self.launches.read(token_address);
            assert(launch_info.is_active, 'Token not launched or inactive');

            // Verify user has enough tokens
            let token_dispatcher = ITokenDispatcher { contract_address: token_address };
            let user_balance: u256 = token_dispatcher.balance_of(caller);
            assert(user_balance >= token_amount, 'Insufficient token balance');

            // Calculate payment tokens to receive based on bonding curve
            let payment_to_receive = InternalImpl::calculate_payment_for_tokens(
                launch_info.current_price,
                launch_info.total_supply,
                token_amount,
                launch_info.k,
                launch_info.n,
            );

            // Calculate fees
            let fee = (payment_to_receive * launch_info.fee_rate) / 10000;
            let payment_after_fee = payment_to_receive - fee;

            // Update launch info
            let new_price = InternalImpl::calculate_price(
                launch_info.initial_price,
                launch_info.total_supply - token_amount,
                launch_info.k,
                launch_info.n,
            );
            let new_launch_info = LaunchInfo {
                token_address: launch_info.token_address,
                creator: launch_info.creator,
                initial_price: launch_info.initial_price,
                current_price: new_price,
                total_supply: launch_info.total_supply - token_amount,
                liquidity: launch_info.liquidity - payment_to_receive,
                k: launch_info.k,
                n: launch_info.n,
                fee_rate: launch_info.fee_rate,
                launch_time: launch_info.launch_time,
                is_active: launch_info.is_active,
            };

            self.launches.write(token_address, new_launch_info);

            // Burn tokens using burn function (solo el Launchpad puede hacer burn)
            let mut token_dispatcher = ITokenDispatcher { contract_address: token_address };
            token_dispatcher.burn(caller, token_amount);

            // Transfer payment tokens to seller
            let payment_token_address = self.payment_token.read();
            let mut payment_dispatcher = IPaymentTokenDispatcher { contract_address: payment_token_address };
            payment_dispatcher.transfer(caller, payment_after_fee);

            self
                .emit(
                    TokensSold {
                        token_address,
                        seller: caller,
                        token_amount,
                        eth_received: payment_after_fee,
                        new_price,
                    },
                );

            payment_after_fee
        }

        fn get_price(self: @ContractState, token_address: ContractAddress) -> u256 {
            let launch_info = self.launches.read(token_address);
            if !launch_info.is_active {
                return 0;
            }
            InternalImpl::calculate_price(
                launch_info.initial_price, launch_info.total_supply, launch_info.k, launch_info.n,
            )
        }

        fn get_launch_info(self: @ContractState, token_address: ContractAddress) -> LaunchInfo {
            self.launches.read(token_address)
        }

        fn get_liquidity(self: @ContractState, token_address: ContractAddress) -> u256 {
            let launch_info = self.launches.read(token_address);
            launch_info.liquidity
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        // Bonding curve formula: price = initial_price * (1 + supply / k)^n
        fn calculate_price(initial_price: u256, supply: u256, k: u256, n: u256) -> u256 {
            if supply == 0 {
                return initial_price;
            }
            // Simplified calculation: price = initial_price * (1 + supply / k)
            // For more precision, we'd need fixed-point math
            let ratio = (supply * 1000) / k;
            (initial_price * (1000 + ratio)) / 1000
        }

        // Calculate tokens received for payment amount
        fn calculate_tokens_for_payment(
            current_price: u256, current_supply: u256, payment_amount: u256, k: u256, n: u256,
        ) -> u256 {
            // Simplified: tokens = payment_amount / average_price
            // Average price between current and next price
            let next_price = Self::calculate_price(
                current_price, current_supply + (payment_amount / current_price), k, n,
            );
            let avg_price = (current_price + next_price) / 2;
            payment_amount / avg_price
        }

        // Calculate payment tokens received for token amount
        fn calculate_payment_for_tokens(
            current_price: u256, current_supply: u256, token_amount: u256, k: u256, n: u256,
        ) -> u256 {
            // Simplified: payment = tokens * average_price
            let prev_price = Self::calculate_price(current_price, current_supply - token_amount, k, n);
            let avg_price = (current_price + prev_price) / 2;
            token_amount * avg_price
        }
    }

    fn zero_address() -> ContractAddress {
        starknet::contract_address_const::<0>()
    }
}
