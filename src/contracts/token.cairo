use starknet::ContractAddress;

#[starknet::interface]
pub trait IToken<TContractState> {
    // v2: Added burn and set_launchpad, only launchpad can mint
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn mint(ref self: TContractState, to: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, from: ContractAddress, amount: u256);
    fn set_launchpad(ref self: TContractState, launchpad_address: ContractAddress);
}

#[starknet::contract]
mod Token {
    use starknet::storage::Map;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress, get_caller_address};

    const DECIMALS: u8 = 6;

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>,
        owner: ContractAddress,
        launchpad: ContractAddress, // Launchpad address that can mint
        version: u8, // v2: Added for contract versioning
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        initial_supply: u256,   // NO se usa - solo para compatibilidad, no se acuña
        owner: ContractAddress,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(DECIMALS); // HARD-CODED = 6

        self.owner.write(owner);
        // NO acuñar tokens iniciales - solo el Launchpad puede acuñar cuando se compran
        self.total_supply.write(0);
        self.launchpad.write(zero_address()); // Initialize to zero, can be set later
        self.version.write(2); // v2: Security improvements

        // NO emitir Transfer porque no hay tokens acuñados
    }

    #[abi(embed_v0)]
    impl TokenImpl of super::IToken<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read() // siempre será 6
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            InternalImpl::_transfer(ref self, sender, recipient, amount);
            true
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            let caller = get_caller_address();
            let current_allowance = self.allowances.read((sender, caller));
            assert(current_allowance >= amount, 'Insufficient allowance');
            self.allowances.write((sender, caller), current_allowance - amount);
            InternalImpl::_transfer(ref self, sender, recipient, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let owner = get_caller_address();
            self.allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
            true
        }

        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let launchpad = self.launchpad.read();
            // SOLO el Launchpad puede acuñar - el owner NO puede para prevenir inflación
            assert(caller == launchpad, 'Only launchpad can mint');

            let supply = self.total_supply.read();
            let balance = self.balances.read(to);

            self.total_supply.write(supply + amount);
            self.balances.write(to, balance + amount);

            self.emit(Transfer { from: zero_address(), to, value: amount });
        }

        fn burn(ref self: ContractState, from: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let launchpad = self.launchpad.read();
            // SOLO el Launchpad puede quemar tokens
            assert(caller == launchpad, 'Only launchpad can burn');

            let supply = self.total_supply.read();
            let balance = self.balances.read(from);
            assert(balance >= amount, 'Insufficient balance to burn');

            self.total_supply.write(supply - amount);
            self.balances.write(from, balance - amount);

            self.emit(Transfer { from, to: zero_address(), value: amount });
        }

        fn set_launchpad(ref self: ContractState, launchpad_address: ContractAddress) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Only owner can set launchpad');
            self.launchpad.write(launchpad_address);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) {
            assert(sender != zero_address(), 'Transfer from zero address');
            assert(recipient != zero_address(), 'Transfer to zero address');

            let bal = self.balances.read(sender);
            assert(bal >= amount, 'Insufficient balance');

            self.balances.write(sender, bal - amount);

            let rec_bal = self.balances.read(recipient);
            self.balances.write(recipient, rec_bal + amount);

            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }
    }

    fn zero_address() -> ContractAddress {
        starknet::contract_address_const::<0>()
    }
}
