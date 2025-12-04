use starknet::ContractAddress;

// Token Factory ZumpFun — siempre 6 decimales
#[starknet::interface]
trait ITokenFactory<TContractState> {
    fn create_token(
        ref self: TContractState,
        name: felt252,
        symbol: felt252,
        initial_supply: u256,   // siempre *1e6
    ) -> ContractAddress;

    fn get_token_count(self: @TContractState) -> u256;
    fn get_token_at(self: @TContractState, index: u256) -> ContractAddress;
}

#[starknet::contract]
mod TokenFactory {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::storage::Map;
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
            initial_supply: u256,   // SIEMPRE en 6 decimales
        ) -> ContractAddress {
            let creator = get_caller_address();
            let class_hash = self.token_class_hash.read();

            // preparamos calldata para constructor del token:
            // name
            // symbol
            // decimals (FIJO = 6)
            // initial_supply (low/high)
            // owner
            let creator_felt: felt252 = creator.into();
            let initial_supply_low: felt252 = initial_supply.low.into();
            let initial_supply_high: felt252 = initial_supply.high.into();

            let decimals_fixed: felt252 = 6.into(); // SIEMPRE 6 DECIMALES

            let mut constructor_calldata = array![
                name,
                symbol,
                decimals_fixed,
                initial_supply_low,
                initial_supply_high,
                creator_felt,
            ];

            // DEPLOY TOKEN (luego reemplazás esto por UDC o syscalls reales)
            let token_address = starknet::contract_address_const::<0>();

            // store token
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
