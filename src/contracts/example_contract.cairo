use starknet::ContractAddress;

// Example contract for Zypherpunk Hackathon
// This is a basic template that can be extended for your specific project

#[starknet::interface]
trait IExampleContract<TContractState> {
    fn get_value(self: @TContractState) -> u256;
    fn set_value(ref self: TContractState, value: u256);
    fn get_owner(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod ExampleContract {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        value: u256,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueChanged: ValueChanged,
    }

    #[derive(Drop, starknet::Event)]
    struct ValueChanged {
        old_value: u256,
        new_value: u256,
        caller: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u256) {
        self.value.write(initial_value);
        self.owner.write(get_caller_address());
    }

    #[abi(embed_v0)]
    impl ExampleContractImpl of super::IExampleContract<ContractState> {
        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }

        fn set_value(ref self: ContractState, value: u256) {
            let caller = get_caller_address();
            let old_value = self.value.read();
            self.value.write(value);
            self.emit(ValueChanged { old_value, new_value: value, caller });
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }
}
