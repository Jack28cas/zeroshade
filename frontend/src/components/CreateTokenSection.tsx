'use client'

import { useState } from 'react'
import { useWallet } from '@/contexts/WalletContext'
import { getTokenFactoryContract, getLaunchpadContract, stringToFelt252, u256ToLowHigh, parseToU256 } from '@/lib/starknet'
import { CONTRACTS, DECIMALS_MULTIPLIER } from '@/lib/constants'

export function CreateTokenSection() {
  const { account, isConnected, provider } = useWallet()
  const [step, setStep] = useState<'create' | 'launch'>('create')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  
  // Form state for token creation
  const [tokenName, setTokenName] = useState('')
  const [tokenSymbol, setTokenSymbol] = useState('')
  const [initialSupply, setInitialSupply] = useState('')
  const [createdTokenAddress, setCreatedTokenAddress] = useState<string | null>(null)
  
  // Form state for token launch
  const [initialPrice, setInitialPrice] = useState('')
  const [k, setK] = useState('1000000')
  const [n, setN] = useState('1')
  const [feeRate, setFeeRate] = useState('100') // 1% = 100 basis points

  const handleCreateToken = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!isConnected || !account) {
      setError('Por favor conecta tu wallet primero')
      return
    }

    setLoading(true)
    setError(null)
    setSuccess(null)

    try {
      const factory = getTokenFactoryContract(account)
      
      // Convert inputs
      // Try to parse as number first, if not, use hash
      let nameFelt: bigint
      let symbolFelt: bigint
      
      // Check if input is a number
      if (/^\d+$/.test(tokenName.trim())) {
        nameFelt = BigInt(tokenName.trim())
      } else {
        nameFelt = stringToFelt252(tokenName)
      }
      
      if (/^\d+$/.test(tokenSymbol.trim())) {
        symbolFelt = BigInt(tokenSymbol.trim())
      } else {
        symbolFelt = stringToFelt252(tokenSymbol)
      }
      const supply = parseToU256(initialSupply, 6) // 6 decimals
      const { low, high } = u256ToLowHigh(supply)

      // Validate felt252 values are within range
      const STARKNET_PRIME = BigInt('0x800000000000011000000000000000000000000000000000000000000000001')
      if (nameFelt >= STARKNET_PRIME || nameFelt < BigInt(0)) {
        throw new Error(`Invalid token name value: ${nameFelt.toString()}`)
      }
      if (symbolFelt >= STARKNET_PRIME || symbolFelt < BigInt(0)) {
        throw new Error(`Invalid token symbol value: ${symbolFelt.toString()}`)
      }

      // Ensure values are within felt252 range (mod prime)
      // felt252 max is STARKNET_PRIME - 1
      nameFelt = nameFelt % STARKNET_PRIME
      symbolFelt = symbolFelt % STARKNET_PRIME
      
      // Ensure they're positive
      if (nameFelt < BigInt(0)) {
        nameFelt = nameFelt + STARKNET_PRIME
      }
      if (symbolFelt < BigInt(0)) {
        symbolFelt = symbolFelt + STARKNET_PRIME
      }

      // Debug logs
      console.log('Calling create_token with:', {
        name: nameFelt.toString(),
        nameHex: '0x' + nameFelt.toString(16),
        symbol: symbolFelt.toString(),
        symbolHex: '0x' + symbolFelt.toString(16),
        supply: { low: low.toString(), high: high.toString() }
      })
      
      // Call create_token using invoke directly
      // Convert bigint to decimal string for felt252 (starknet.js expects decimal strings)
      const result = await account.execute({
        contractAddress: CONTRACTS.TOKEN_FACTORY,
        entrypoint: 'create_token',
        calldata: [
          nameFelt.toString(),
          symbolFelt.toString(),
          low.toString(),
          high.toString()
        ]
      })
      
      // Show success immediately (don't wait for transaction confirmation)
      // TokenFactory retorna 0x0 (versión simulada), así que usamos 0x0 como placeholder
      setCreatedTokenAddress('0x0')
      setSuccess(`Token creado! (Versión simulada - retorna 0x0). Transaction: ${result.transaction_hash}`)
      setStep('launch')
    } catch (err: any) {
      setError(err.message || 'Error al crear el token')
      console.error('Error creating token:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleLaunchToken = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!isConnected || !account) {
      setError('Por favor conecta tu wallet')
      return
    }
    if (!createdTokenAddress || createdTokenAddress.trim() === '') {
      setError('Por favor ingresa la dirección del token')
      return
    }
    
    // Validate that it's a valid contract address (not a transaction hash)
    // Transaction hashes are 66 chars (0x + 64 hex), contract addresses are typically shorter
    // But in Starknet, both can be 66 chars, so we check if it looks like a valid address
    const address = createdTokenAddress.trim()
    if (!address.startsWith('0x') || address.length < 10) {
      setError('Por favor ingresa una dirección de contrato válida (debe empezar con 0x)')
      return
    }
    
    // Check if it's likely a transaction hash (starts with 0x2 or 0x3 typically)
    // For hackathon: if it looks like a transaction hash, warn but allow
    if (address.length === 66 && (address.startsWith('0x2') || address.startsWith('0x3'))) {
      console.warn('⚠️ Parece que estás usando un transaction hash como dirección. El contrato puede rechazarlo.')
      // For hackathon, we'll try anyway, but show a warning
    }
    
    setLoading(true)
    setError(null)
    setSuccess(null)

    try {
      const launchpad = getLaunchpadContract(account)
      
      // Convert inputs (all in 6 decimals)
      const price = parseToU256(initialPrice, 6)
      const kValue = parseToU256(k, 6)
      const nValue = parseToU256(n, 0) // n is typically small
      const feeRateValue = parseToU256(feeRate, 0) // basis points

      const priceU256 = u256ToLowHigh(price)
      const kU256 = u256ToLowHigh(kValue)
      const nU256 = u256ToLowHigh(nValue)
      const feeRateU256 = u256ToLowHigh(feeRateValue)

      // For hackathon: if address looks like a transaction hash, use 0x0 as placeholder
      // (TokenFactory has TODO and returns 0x0)
      let tokenAddress = address
      if (address.length === 66 && (address.startsWith('0x2') || address.startsWith('0x3'))) {
        console.warn('⚠️ Usando 0x0 como placeholder (TokenFactory tiene TODO)')
        tokenAddress = '0x0' // Use 0x0 as placeholder for hackathon
        setError('⚠️ Nota: El TokenFactory retorna 0x0 (tiene TODO). Usando 0x0 como placeholder. El Launchpad puede rechazarlo si valida la dirección.')
      }
      
      // Call launch_token using account.execute for better control
      const result = await account.execute({
        contractAddress: CONTRACTS.LAUNCHPAD,
        entrypoint: 'launch_token',
        calldata: [
          tokenAddress, // token_address
          priceU256.low.toString(),
          priceU256.high.toString(),
          kU256.low.toString(),
          kU256.high.toString(),
          nU256.low.toString(),
          nU256.high.toString(),
          feeRateU256.low.toString(),
          feeRateU256.high.toString()
        ]
      })
      
      // Show success immediately (don't wait for transaction)
      setSuccess(`Token lanzado exitosamente! Transaction: ${result.transaction_hash}`)
      
      // Try to wait in background
      account.waitForTransaction(result.transaction_hash)
        .then(() => {
          console.log('Transaction confirmed:', result.transaction_hash)
        })
        .catch((err) => {
          console.warn('Could not wait for transaction (RPC issue, but tx was sent):', err)
        })
      // Reset form
      setStep('create')
      setCreatedTokenAddress(null)
      setTokenName('')
      setTokenSymbol('')
      setInitialSupply('')
      setInitialPrice('')
    } catch (err: any) {
      setError(err.message || 'Error al lanzar el token')
      console.error('Error launching token:', err)
    } finally {
      setLoading(false)
    }
  }

  if (!isConnected) {
    return (
      <div className="bg-gray-800 rounded-lg p-8 text-center">
        <p className="text-gray-400 mb-4">Conecta tu wallet para crear tokens</p>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Create Token Form */}
      {step === 'create' && (
        <div className="bg-gray-800 rounded-lg p-8">
          <h2 className="text-2xl font-bold text-white mb-6">Crear tu Token</h2>
          
          <form onSubmit={handleCreateToken} className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Nombre del Token (felt252 - valor numérico)
              </label>
              <input
                type="text"
                value={tokenName}
                onChange={(e) => setTokenName(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
                placeholder="Ej: 123456789 (o texto, se convertirá a número)"
              />
              <p className="mt-1 text-xs text-gray-400">
                Puedes usar texto o un número. El texto se convertirá automáticamente.
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Símbolo del Token (felt252 - valor numérico)
              </label>
              <input
                type="text"
                value={tokenSymbol}
                onChange={(e) => setTokenSymbol(e.target.value.toUpperCase())}
                required
                maxLength={10}
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
                placeholder="Ej: 987654321 (o texto, se convertirá a número)"
              />
              <p className="mt-1 text-xs text-gray-400">
                Puedes usar texto o un número. El texto se convertirá automáticamente.
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Suministro Inicial (6 decimales)
              </label>
              <input
                type="text"
                value={initialSupply}
                onChange={(e) => setInitialSupply(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
                placeholder="Ej: 1000000 (para 1M tokens)"
              />
              <p className="mt-1 text-sm text-gray-400">
                El token siempre usa 6 decimales
              </p>
            </div>

            {error && (
              <div className="p-4 bg-red-500/20 border border-red-500/50 rounded-lg text-red-400">
                {error}
              </div>
            )}

            {success && (
              <div className="p-4 bg-green-500/20 border border-green-500/50 rounded-lg text-green-400">
                {success}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full px-6 py-3 bg-primary-600 hover:bg-primary-700 disabled:bg-gray-700 disabled:cursor-not-allowed text-white rounded-lg font-semibold transition-colors"
            >
              {loading ? 'Creando...' : 'Crear Token'}
            </button>
          </form>
        </div>
      )}

      {/* Launch Token Form */}
      {step === 'launch' && (
        <div className="bg-gray-800 rounded-lg p-8">
          <h2 className="text-2xl font-bold text-white mb-6">Lanzar Token en Launchpad</h2>
          
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Dirección del Token (ContractAddress)
            </label>
            <input
              type="text"
              value={createdTokenAddress || ''}
              onChange={(e) => setCreatedTokenAddress(e.target.value)}
              required
              className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
              placeholder="0x... (ingresa la dirección del token desplegado)"
            />
            <p className="mt-1 text-xs text-yellow-400">
              ⚠️ <strong>Nota:</strong> El TokenFactory retorna 0x0 (versión simulada para hackathon). 
              Debes desplegar el token manualmente usando el script <code className="bg-gray-800 px-1 rounded">scripts/deploy_token.sh</code> 
              y luego ingresar la dirección aquí.
            </p>
            {createdTokenAddress && createdTokenAddress !== '0x0' && (
              <p className="mt-1 text-xs text-green-400">
                ✓ Token: {createdTokenAddress.slice(0, 10)}...
              </p>
            )}
          </div>

          <form onSubmit={handleLaunchToken} className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Precio Inicial (escalado a 1e6)
              </label>
              <input
                type="text"
                value={initialPrice}
                onChange={(e) => setInitialPrice(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
                placeholder="Ej: 1000000 (para 1.0)"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                K (Constante de la curva)
              </label>
              <input
                type="text"
                value={k}
                onChange={(e) => setK(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                N (Exponente)
              </label>
              <input
                type="text"
                value={n}
                onChange={(e) => setN(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Fee Rate (basis points, 100 = 1%)
              </label>
              <input
                type="text"
                value={feeRate}
                onChange={(e) => setFeeRate(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-700 text-white rounded-lg border border-gray-600 focus:border-primary-500 focus:outline-none"
              />
            </div>

            {error && (
              <div className="p-4 bg-red-500/20 border border-red-500/50 rounded-lg text-red-400">
                {error}
              </div>
            )}

            {success && (
              <div className="p-4 bg-green-500/20 border border-green-500/50 rounded-lg text-green-400">
                {success}
              </div>
            )}

            <div className="flex gap-4">
              <button
                type="button"
                onClick={() => setStep('create')}
                className="flex-1 px-6 py-3 bg-gray-700 hover:bg-gray-600 text-white rounded-lg font-semibold transition-colors"
              >
                Volver
              </button>
              <button
                type="submit"
                disabled={loading}
                className="flex-1 px-6 py-3 bg-primary-600 hover:bg-primary-700 disabled:bg-gray-700 disabled:cursor-not-allowed text-white rounded-lg font-semibold transition-colors"
              >
                {loading ? 'Lanzando...' : 'Lanzar Token'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}

