// Token ABI (simplificado)
export const TOKEN_ABI = [
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
  {
    type: 'function',
    name: 'decimals',
    inputs: [],
    outputs: [{ name: 'decimals', type: 'u8' }],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'total_supply',
    inputs: [],
    outputs: [{ name: 'supply', type: 'u256' }],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'balance_of',
    inputs: [{ name: 'account', type: 'ContractAddress' }],
    outputs: [{ name: 'balance', type: 'u256' }],
    state_mutability: 'view',
  },
] as const

