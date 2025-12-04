// Contract Addresses (Starknet Sepolia)
export const CONTRACTS = {
  TOKEN_FACTORY: '0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98',
  LAUNCHPAD: '0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf',
  // USDC address on Starknet Sepolia (ajustar según sea necesario)
  USDC: '0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8',
} as const

// Network Configuration
export const NETWORK = {
  RPC_URL: 'https://starknet-sepolia-rpc.publicnode.com',
  CHAIN_ID: 'SN_SEPOLIA',
} as const

// Constants
export const DECIMALS = 6 // Todos los tokens usan 6 decimales
export const DECIMALS_MULTIPLIER = 1_000_000 // 10^6

// API Endpoints
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

