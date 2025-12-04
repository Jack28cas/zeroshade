import { Contract, AccountInterface, ProviderInterface } from 'starknet'
import { CONTRACTS, NETWORK } from './constants'

// TokenFactory ABI (simplificado - solo funciones necesarias)
export const TOKEN_FACTORY_ABI = [
  {
    type: 'function',
    name: 'create_token',
    inputs: [
      { name: 'name', type: 'felt252' },
      { name: 'symbol', type: 'felt252' },
      { name: 'initial_supply', type: 'u256' },
    ],
    outputs: [{ name: 'token_address', type: 'ContractAddress' }],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'get_token_count',
    inputs: [],
    outputs: [{ name: 'count', type: 'u256' }],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'get_token_at',
    inputs: [{ name: 'index', type: 'u256' }],
    outputs: [{ name: 'token_address', type: 'ContractAddress' }],
    state_mutability: 'view',
  },
] as const

// Launchpad ABI (simplificado)
export const LAUNCHPAD_ABI = [
  {
    type: 'function',
    name: 'launch_token',
    inputs: [
      { name: 'token_address', type: 'ContractAddress' },
      { name: 'initial_price', type: 'u256' },
      { name: 'k', type: 'u256' },
      { name: 'n', type: 'u256' },
      { name: 'fee_rate', type: 'u256' },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'buy_tokens',
    inputs: [
      { name: 'token_address', type: 'ContractAddress' },
      { name: 'payment_amount', type: 'u256' }, // Cambiado de eth_amount a payment_amount
    ],
    outputs: [{ name: 'tokens_received', type: 'u256' }],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'sell_tokens',
    inputs: [
      { name: 'token_address', type: 'ContractAddress' },
      { name: 'token_amount', type: 'u256' },
    ],
    outputs: [{ name: 'eth_received', type: 'u256' }],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'get_price',
    inputs: [{ name: 'token_address', type: 'ContractAddress' }],
    outputs: [{ name: 'price', type: 'u256' }],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'get_launch_info',
    inputs: [{ name: 'token_address', type: 'ContractAddress' }],
    outputs: [
      {
        type: 'struct',
        name: 'LaunchInfo',
        members: [
          { name: 'token_address', type: 'ContractAddress' },
          { name: 'creator', type: 'ContractAddress' },
          { name: 'initial_price', type: 'u256' },
          { name: 'current_price', type: 'u256' },
          { name: 'total_supply', type: 'u256' },
          { name: 'liquidity', type: 'u256' },
          { name: 'k', type: 'u256' },
          { name: 'n', type: 'u256' },
          { name: 'fee_rate', type: 'u256' },
          { name: 'launch_time', type: 'u64' },
          { name: 'is_active', type: 'bool' },
        ],
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'get_liquidity',
    inputs: [{ name: 'token_address', type: 'ContractAddress' }],
    outputs: [{ name: 'liquidity', type: 'u256' }],
    state_mutability: 'view',
  },
] as const

// Token ABI (simplificado)
export const TOKEN_ABI = [
  {
    type: 'function',
    name: 'approve',
    inputs: [
      { name: 'spender', type: 'ContractAddress' },
      { name: 'amount', type: 'u256' },
    ],
    outputs: [{ name: 'success', type: 'bool' }],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'balance_of',
    inputs: [{ name: 'account', type: 'ContractAddress' }],
    outputs: [{ name: 'balance', type: 'u256' }],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'name',
    inputs: [],
    outputs: [{ name: 'name', type: 'felt252' }],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'symbol',
    inputs: [],
    outputs: [{ name: 'symbol', type: 'felt252' }],
    state_mutability: 'view',
  },
] as const

// Helper functions
export function getTokenFactoryContract(account: AccountInterface): Contract {
  return new Contract(TOKEN_FACTORY_ABI, CONTRACTS.TOKEN_FACTORY, account)
}

export function getLaunchpadContract(account: AccountInterface): Contract {
  return new Contract(LAUNCHPAD_ABI, CONTRACTS.LAUNCHPAD, account)
}

export function getTokenContract(tokenAddress: string, account: AccountInterface): Contract {
  return new Contract(TOKEN_ABI, tokenAddress, account)
}

// PausableERC20 ABI (mismo que TOKEN_ABI, es un ERC20 estándar)
export const PAUSABLE_ERC20_ABI = TOKEN_ABI

export function getPausableERC20Contract(account: AccountInterface): Contract {
  return new Contract(PAUSABLE_ERC20_ABI, CONTRACTS.PAUSABLE_ERC20, account)
}

// Convert string to felt252 (simple hash)
// For hackathon: use a simple numeric conversion
// In production, use proper hash (Pedersen, Poseidon, etc.)
export function stringToFelt252(str: string): bigint {
  // Starknet felt252 max: 2^251 + 17 * 2^192 + 1
  // For simplicity, use a hash that generates smaller values
  let hash = BigInt(0)
  const MOD = BigInt('0x800000000000011000000000000000000000000000000000000000000000001')
  
  // Simple hash: sum of char codes with multiplier
  for (let i = 0; i < str.length; i++) {
    const charCode = BigInt(str.charCodeAt(i))
    hash = (hash * BigInt(256) + charCode) % MOD
  }
  
  // Ensure it's a valid felt252 (positive and less than prime)
  if (hash < BigInt(0)) {
    hash = (hash % MOD + MOD) % MOD
  }
  
  return hash
}

// Convert u256 to low/high
export function u256ToLowHigh(value: bigint): { low: bigint; high: bigint } {
  const mask = BigInt(2 ** 128) - BigInt(1)
  return {
    low: value & mask,
    high: value >> BigInt(128),
  }
}

// Convert low/high to u256
export function lowHighToU256(low: bigint, high: bigint): bigint {
  return (high << BigInt(128)) + low
}

// Format number with decimals
export function formatWithDecimals(value: bigint, decimals: number = 6): string {
  const divisor = BigInt(10 ** decimals)
  const whole = value / divisor
  const fraction = value % divisor
  const fractionStr = fraction.toString().padStart(decimals, '0')
  return `${whole}.${fractionStr}`.replace(/\.?0+$/, '')
}

// Parse number to u256 (with decimals)
export function parseToU256(value: string, decimals: number = 6): bigint {
  const parts = value.split('.')
  const whole = parts[0] || '0'
  const fraction = (parts[1] || '').padEnd(decimals, '0').slice(0, decimals)
  return BigInt(whole) * BigInt(10 ** decimals) + BigInt(fraction)
}

