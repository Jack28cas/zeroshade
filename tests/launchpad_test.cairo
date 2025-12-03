use starknet::ContractAddress;
use starknet::testing::{set_caller_address, set_contract_address};
use zeroshade::contracts::launchpad::{ILaunchpadDispatcher, ILaunchpadDispatcherTrait};
use zeroshade::contracts::token::{ITokenDispatcher, ITokenDispatcherTrait};

#[test]
fn test_launch_token() {
    let user = starknet::contract_address_const::<0x1>();
    set_caller_address(user);

    // Deploy token first
    let mut token_calldata = array![
        'TestToken', 'TEST', 18, 1000000 * 10_u256.pow(18), user
    ];
    let (token_address, _) = Token::deploy(@token_calldata).unwrap();

    // Deploy launchpad
    let fee_recipient = starknet::contract_address_const::<0x999>();
    let mut launchpad_calldata = array![fee_recipient];
    let (launchpad_address, _) = Launchpad::deploy(@launchpad_calldata).unwrap();
    let launchpad_dispatcher = ILaunchpadDispatcherDispatcher { contract_address: launchpad_address };

    // Launch token
    let initial_price = 1000000000000000; // 0.001 ETH
    let k = 1000000;
    let n = 1;
    let fee_rate = 100; // 1%

    launchpad_dispatcher.launch_token(token_address, initial_price, k, n, fee_rate);

    let launch_info = launchpad_dispatcher.get_launch_info(token_address);
    assert(launch_info.is_active == true, 'Launch should be active');
    assert(launch_info.initial_price == initial_price, 'Wrong initial price');
    assert(launch_info.creator == user, 'Wrong creator');
}

#[test]
fn test_get_price() {
    let user = starknet::contract_address_const::<0x1>();
    set_caller_address(user);

    // Setup
    let mut token_calldata = array![
        'TestToken', 'TEST', 18, 1000000 * 10_u256.pow(18), user
    ];
    let (token_address, _) = Token::deploy(@token_calldata).unwrap();

    let fee_recipient = starknet::contract_address_const::<0x999>();
    let mut launchpad_calldata = array![fee_recipient];
    let (launchpad_address, _) = Launchpad::deploy(@launchpad_calldata).unwrap();
    let launchpad_dispatcher = ILaunchpadDispatcherDispatcher { contract_address: launchpad_address };

    // Launch token
    let initial_price = 1000000000000000;
    launchpad_dispatcher.launch_token(token_address, initial_price, 1000000, 1, 100);

    // Get price
    let price = launchpad_dispatcher.get_price(token_address);
    assert(price >= initial_price, 'Price should be at least initial price');
}
