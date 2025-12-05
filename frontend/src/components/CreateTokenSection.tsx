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
      setError('Please connect your wallet first')
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
      // TokenFactory retorna 0x0 (versión simulada), así que desplegamos automáticamente
      setSuccess(`Token created! Deploying token automatically...`)
      
      // Automatically deploy the token via backend API
      try {
        const deployResponse = await fetch('http://localhost:3001/api/tokens/deploy', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            tokenName,
            tokenSymbol,
            initialSupply,
            ownerAddress: account.address,
          }),
        })
        
        if (!deployResponse.ok) {
          const errorData = await deployResponse.json()
          throw new Error(errorData.error || 'Failed to deploy token')
        }
        
        const deployData = await deployResponse.json()
        setCreatedTokenAddress(deployData.address)
        setSuccess(`Token created and deployed successfully! Address: ${deployData.address}`)
        setStep('launch')
      } catch (deployError: any) {
        console.error('Error deploying token:', deployError)
        // If deployment fails, still allow manual entry
        setCreatedTokenAddress('0x0')
        setError(`Token created but auto-deployment failed: ${deployError.message}. Please deploy manually and enter the address.`)
        setStep('launch')
      }
    } catch (err: any) {
      setError(err.message || 'Error creating token')
      console.error('Error creating token:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleLaunchToken = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!isConnected || !account) {
      setError('Please connect your wallet')
      return
    }
    if (!createdTokenAddress || createdTokenAddress.trim() === '') {
      setError('Please enter the token address')
      return
    }
    
    // Validate that it's a valid contract address (not a transaction hash)
    // Transaction hashes are 66 chars (0x + 64 hex), contract addresses are typically shorter
    // But in Starknet, both can be 66 chars, so we check if it looks like a valid address
    const address = createdTokenAddress.trim()
    if (!address.startsWith('0x') || address.length < 10) {
      setError('Please enter a valid contract address (must start with 0x)')
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
      setSuccess(`Token launched successfully! Transaction: ${result.transaction_hash}`)
      
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
      setError(err.message || 'Error launching token')
      console.error('Error launching token:', err)
    } finally {
      setLoading(false)
    }
  }

  if (!isConnected) {
    return (
      <div className="bg-gray-900/50 rounded-lg p-12 text-center border border-gray-800">
        <p className="text-[#dfdfff] text-base font-medium uppercase tracking-wider">
          CONNECT YOUR WALLET TO CREATE TOKENS
        </p>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Create Token Form */}
      {step === 'create' && (
        <div className="bg-gray-900/50 rounded-xl p-8 lg:p-10 border border-gray-800">
          <h2 className="text-3xl font-bold uppercase mb-8 bg-gradient-to-r from-[#a694ff] to-[#6365ff] bg-clip-text text-transparent tracking-wider">
            Create Your Token
          </h2>
          
          <form onSubmit={handleCreateToken} className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                Token Name
              </label>
              <input
                type="text"
                value={tokenName}
                onChange={(e) => setTokenName(e.target.value)}
                required
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter token name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                Token Symbol
              </label>
              <input
                type="text"
                value={tokenSymbol}
                onChange={(e) => setTokenSymbol(e.target.value.toUpperCase())}
                required
                maxLength={10}
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter token symbol"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                Initial Supply
              </label>
              <input
                type="text"
                value={initialSupply}
                onChange={(e) => setInitialSupply(e.target.value)}
                required
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter initial supply (6 decimals)"
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

            <button
              type="submit"
              disabled={loading}
              className="w-full px-6 py-4 bg-gradient-to-r from-[#a694ff] to-[#6365ff] hover:from-[#6365ff] hover:to-[#a694ff] disabled:from-gray-700 disabled:to-gray-700 disabled:cursor-not-allowed text-white rounded-lg font-bold uppercase tracking-wider transition-all duration-300 shadow-lg shadow-[#6365ff]/50 hover:shadow-xl hover:shadow-[#6365ff]/60"
            >
              {loading ? 'Creating...' : 'Create Token'}
            </button>
          </form>
        </div>
      )}

      {/* Launch Token Form */}
      {step === 'launch' && (
        <div className="bg-gray-900/50 rounded-xl p-8 lg:p-10 border border-gray-800">
          <h2 className="text-3xl font-bold uppercase mb-8 bg-gradient-to-r from-[#a694ff] to-[#6365ff] bg-clip-text text-transparent tracking-wider">
            Launch Token on Launchpad
          </h2>
          
          <div className="mb-6">
            <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
              Token Address
            </label>
            <input
              type="text"
              value={createdTokenAddress || ''}
              onChange={(e) => setCreatedTokenAddress(e.target.value)}
              required
              className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
              placeholder="0x..."
            />
            {createdTokenAddress && createdTokenAddress !== '0x0' && (
              <p className="mt-2 text-xs text-green-400">
                ✓ Token: {createdTokenAddress.slice(0, 10)}...
              </p>
            )}
          </div>

          <form onSubmit={handleLaunchToken} className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                Initial Price
              </label>
              <input
                type="text"
                value={initialPrice}
                onChange={(e) => setInitialPrice(e.target.value)}
                required
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter initial price (scaled to 1e6)"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                K
              </label>
              <input
                type="text"
                value={k}
                onChange={(e) => setK(e.target.value)}
                required
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter K value"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                N
              </label>
              <input
                type="text"
                value={n}
                onChange={(e) => setN(e.target.value)}
                required
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter N value"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-[#dfdfff] mb-3 uppercase tracking-wide">
                Fee Rate
              </label>
              <input
                type="text"
                value={feeRate}
                onChange={(e) => setFeeRate(e.target.value)}
                required
                className="w-full px-4 py-3 bg-gray-800/50 text-white rounded-lg border border-gray-700 focus:border-[#a694ff] focus:outline-none focus:ring-2 focus:ring-[#a694ff]/50 transition-all"
                placeholder="Enter fee rate (basis points, 100 = 1%)"
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
                className="flex-1 px-6 py-3 bg-gray-800 hover:bg-gray-700 text-white rounded-lg font-bold uppercase tracking-wide transition-colors"
              >
                Back
              </button>
              <button
                type="submit"
                disabled={loading}
                className="flex-1 px-6 py-3 bg-gradient-to-r from-[#a694ff] to-[#6365ff] hover:from-[#6365ff] hover:to-[#a694ff] disabled:from-gray-700 disabled:to-gray-700 disabled:cursor-not-allowed text-white rounded-lg font-bold uppercase tracking-wide transition-all duration-300 shadow-lg shadow-[#6365ff]/50 hover:shadow-xl hover:shadow-[#6365ff]/60"
              >
                {loading ? 'Launching...' : 'Launch Token'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}

