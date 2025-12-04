// Contract Addresses (Starknet Sepolia)
export const CONTRACTS = {
  TOKEN_FACTORY: '0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98',
  LAUNCHPAD: '0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b', // v2 con payment_token
  // PausableERC20 - Payment token (reemplaza USDC)
  PAUSABLE_ERC20: '0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778',
  // USDC address on Starknet Sepolia (legacy, usar PAUSABLE_ERC20)
  USDC: '0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778',
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

