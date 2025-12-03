use starknet::ContractAddress;

// ZumpFun Token Factory
// Factory contract to create new tokens easily

#[starknet::interface]
trait ITokenFactory<TContractState> {
    fn create_token(
        ref self: TContractState,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        initial_supply: u256,
    ) -> ContractAddress;
    fn get_token_count(self: @TContractState) -> u256;
    fn get_token_at(self: @TContractState, index: u256) -> ContractAddress;
}

#[starknet::contract]
mod TokenFactory {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::syscalls::deploy_contract_syscall;
    use starknet::{ClassHash, ContractAddress, deploy_contract_syscall, get_caller_address};
    use super::ITokenDispatcher;

    #[storage]
    struct Storage {
        token_class_hash: ClassHash,
        tokens: Map<u256, ContractAddress>,
        token_count: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TokenCreated: TokenCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenCreated {
        token_address: ContractAddress,
        creator: ContractAddress,
        name: felt252,
        symbol: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_class_hash: ClassHash) {
        self.token_class_hash.write(token_class_hash);
        self.token_count.write(0);
    }

    #[abi(embed_v0)]
    impl TokenFactoryImpl of super::ITokenFactory<ContractState> {
        fn create_token(
            ref self: ContractState,
            name: felt252,
            symbol: felt252,
            decimals: u8,
            initial_supply: u256,
        ) -> ContractAddress {
            let creator = get_caller_address();
            let class_hash = self.token_class_hash.read();

            // Prepare constructor calldata
            let mut constructor_calldata = array![
                name.into(), symbol.into(), decimals.into(), initial_supply, creator.into(),
            ];

            // Deploy token contract
            let (token_address, _) = deploy_contract_syscall(
                class_hash, 0, constructor_calldata.span(), false,
            )
                .unwrap();

            // Store token address
            let count = self.token_count.read();
            self.tokens.write(count, token_address);
            self.token_count.write(count + 1);

            self.emit(TokenCreated { token_address, creator, name, symbol });

            token_address
        }

        fn get_token_count(self: @ContractState) -> u256 {
            self.token_count.read()
        }

        fn get_token_at(self: @ContractState, index: u256) -> ContractAddress {
            self.tokens.read(index)
        }
    }
}

