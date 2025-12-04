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
    use starknet::storage::Map;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ClassHash, ContractAddress, get_caller_address};
    use core::result::ResultTrait;

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
            // Note: ContractAddress needs to be converted to felt252 for calldata
            // u256 needs to be split into low and high felt252 values
            let creator_felt: felt252 = creator.into();
            let initial_supply_low: felt252 = initial_supply.low.into();
            let initial_supply_high: felt252 = initial_supply.high.into();
            let mut constructor_calldata = array![
                name, symbol, decimals.into(), initial_supply_low, initial_supply_high, creator_felt,
            ];

            // Deploy token contract
            // TODO: In Cairo 2.0, contract deployment from another contract requires:
            // Option 1: Use Universal Deployer Contract (UDC) via library call
            // Option 2: Use OpenZeppelin's deployer library  
            // Option 3: Use starknet::deploy_contract_syscall if available in your Cairo version
            // For now, returning zero address as placeholder - this needs proper implementation
            let token_address = starknet::contract_address_const::<0>();

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

