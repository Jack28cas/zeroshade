use starknet::ContractAddress;
use starknet::testing::{set_caller_address, set_contract_address};
use zeroshade::contracts::token::{ITokenDispatcher, ITokenDispatcherTrait};

#[test]
fn test_token_creation() {
    let user = starknet::contract_address_const::<0x1>();
    set_caller_address(user);

    let mut calldata = array![
        'MyToken', 'MTK', 18, 1000000 * 10_u256.pow(18), user
    ];
    let (token_address, _) = Token::deploy(@calldata).unwrap();
    let token_dispatcher = ITokenDispatcherDispatcher { contract_address: token_address };

    let name = token_dispatcher.name();
    assert(name == 'MyToken', 'Wrong name');

    let symbol = token_dispatcher.symbol();
    assert(symbol == 'MTK', 'Wrong symbol');

    let decimals = token_dispatcher.decimals();
    assert(decimals == 18, 'Wrong decimals');

    let total_supply = token_dispatcher.total_supply();
    assert(total_supply == 1000000 * 10_u256.pow(18), 'Wrong total supply');
}

#[test]
fn test_token_transfer() {
    let user = starknet::contract_address_const::<0x1>();
    set_caller_address(user);

    let mut calldata = array![
        'MyToken', 'MTK', 18, 1000000 * 10_u256.pow(18), user
    ];
    let (token_address, _) = Token::deploy(@calldata).unwrap();
    let token_dispatcher = ITokenDispatcherDispatcher { contract_address: token_address };

    let recipient = starknet::contract_address_const::<0x123>();
    let amount = 1000 * 10_u256.pow(18);

    token_dispatcher.transfer(recipient, amount);

    let user_balance = token_dispatcher.balance_of(user);
    assert(
        user_balance == 1000000 * 10_u256.pow(18) - amount,
        'Wrong user balance after transfer',
    );

    let recipient_balance = token_dispatcher.balance_of(recipient);
    assert(recipient_balance == amount, 'Wrong recipient balance');
}

#[test]
fn test_token_approve() {
    let user = starknet::contract_address_const::<0x1>();
    set_caller_address(user);

    let mut calldata = array![
        'MyToken', 'MTK', 18, 1000000 * 10_u256.pow(18), user
    ];
    let (token_address, _) = Token::deploy(@calldata).unwrap();
    let token_dispatcher = ITokenDispatcherDispatcher { contract_address: token_address };

    let spender = starknet::contract_address_const::<0x456>();
    let amount = 500 * 10_u256.pow(18);

    token_dispatcher.approve(spender, amount);

    let allowance = token_dispatcher.allowance(user, spender);
    assert(allowance == amount, 'Wrong allowance');
}
