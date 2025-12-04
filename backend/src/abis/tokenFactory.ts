// TokenFactory ABI (simplificado)
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

