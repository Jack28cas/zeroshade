export const CONTRACTS = {
  TOKEN_FACTORY: '0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98',
  LAUNCHPAD: '0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf',
  TOKEN: '0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960',
} as const

export const NETWORK = {
  RPC_URL: process.env.RPC_URL || 'https://starknet-sepolia-rpc.publicnode.com',
  CHAIN_ID: 'SN_SEPOLIA',
} as const

