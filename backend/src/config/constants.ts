export const CONTRACTS = {
  TOKEN_FACTORY: '0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98',
  LAUNCHPAD: '0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b', // v2 con payment_token
  TOKEN: '0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960',
  PAUSABLE_ERC20: '0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778', // Payment token
} as const

export const NETWORK = {
  RPC_URL: process.env.RPC_URL || 'https://starknet-sepolia-rpc.publicnode.com',
  CHAIN_ID: 'SN_SEPOLIA',
} as const

