'use client'

import { useState, useEffect } from 'react'
import { useWallet } from '@/contexts/WalletContext'
import { getLaunchpadContract, getTokenContract, parseToU256, formatWithDecimals, u256ToLowHigh, lowHighToU256 } from '@/lib/starknet'
import { CONTRACTS, DECIMALS, NETWORK } from '@/lib/constants'
import { RpcProvider } from 'starknet'

interface TradingSectionProps {
  tokenAddress: string
  tokenName?: string
  tokenSymbol?: string
}

export function TradingSection({ tokenAddress, tokenName, tokenSymbol }: TradingSectionProps) {
  const { account, isConnected, address } = useWallet()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  
  // Trading state
  const [buyAmount, setBuyAmount] = useState('')
  const [sellAmount, setSellAmount] = useState('')
  
  // Token info state
  const [currentPrice, setCurrentPrice] = useState<bigint | null>(null)
  const [liquidity, setLiquidity] = useState<bigint | null>(null)
  const [userBalance, setUserBalance] = useState<bigint | null>(null)
  const [userTokenBalance, setUserTokenBalance] = useState<bigint | null>(null)

  useEffect(() => {
    if (isConnected && account && tokenAddress) {
      loadTokenInfo()
    }
  }, [isConnected, account, tokenAddress])

  const loadTokenInfo = async () => {
    if (!account || !address) return

    try {
      // Use a separate RpcProvider for read calls to avoid CORS issues
      // This uses the public RPC that doesn't have CORS restrictions
      const readProvider = new RpcProvider({ nodeUrl: NETWORK.RPC_URL })

      // Load price using callContract directly
      try {
        const priceResult = await readProvider.callContract({
          contractAddress: CONTRACTS.LAUNCHPAD,
          entrypoint: 'get_price',
          calldata: [tokenAddress]
        })
        // Parse u256 result (low, high)
        const result = priceResult.result || priceResult
        if (result && Array.isArray(result) && result.length >= 2) {
          const price = lowHighToU256(
            BigInt(result[0]),
            BigInt(result[1] || '0')
          )
          setCurrentPrice(price)
        } else if (result && Array.isArray(result) && result.length === 1) {
          setCurrentPrice(BigInt(result[0]))
        }
      } catch (err: any) {
        console.warn('Error loading price (will show ---):', err.message || err)
        // Leave as null to show "---"
      }

      // Load liquidity using callContract directly
      try {
        const liqResult = await readProvider.callContract({
          contractAddress: CONTRACTS.LAUNCHPAD,
          entrypoint: 'get_liquidity',
          calldata: [tokenAddress]
        })
        console.log('🔍 Liquidity result:', liqResult)
        // Parse u256 result (low, high)
        const result = liqResult.result || liqResult
        console.log('🔍 Parsed liquidity result:', result)
        if (result && Array.isArray(result) && result.length >= 2) {
          const liq = lowHighToU256(
            BigInt(result[0]),
            BigInt(result[1] || '0')
          )
          console.log('✅ Liquidity parsed:', liq.toString())
          setLiquidity(liq)
        } else if (result && Array.isArray(result) && result.length === 1) {
          const liq = BigInt(result[0])
          console.log('✅ Liquidity parsed (single value):', liq.toString())
          setLiquidity(liq)
        } else if (result && result.length === 0) {
          // Empty result means liquidity is 0
          console.log('✅ Liquidity is 0 (empty result)')
          setLiquidity(BigInt(0))
        } else {
          console.warn('⚠️ Unexpected liquidity result format:', result)
        }
      } catch (err: any) {
        console.warn('Error loading liquidity (will show ---):', err.message || err)
        // Leave as null to show "---"
      }

      // Load user token balance using callContract directly
      try {
        const balanceResult = await readProvider.callContract({
          contractAddress: tokenAddress,
          entrypoint: 'balance_of',
          calldata: [address]
        })
        // Parse u256 result (low, high)
        const result = balanceResult.result || balanceResult
        if (result && Array.isArray(result) && result.length >= 2) {
          const balance = lowHighToU256(
            BigInt(result[0]),
            BigInt(result[1] || '0')
          )
          setUserTokenBalance(balance)
        } else if (result && Array.isArray(result) && result.length === 1) {
          setUserTokenBalance(BigInt(result[0]))
        } else {
          setUserTokenBalance(BigInt(0))
        }
      } catch (err: any) {
        console.warn('Error loading token balance (will show 0):', err.message || err)
        // Set to 0 on error
        setUserTokenBalance(BigInt(0))
      }
    } catch (err) {
      console.error('Error loading token info:', err)
    }
  }

  const handleApproveUSDC = async () => {
    if (!account || !isConnected) {
      setError('Conecta tu wallet primero')
      return
    }

    setLoading(true)
    setError(null)

    try {
      // TODO: Implementar aprobación de USDC
      // Por ahora el contrato usa ETH, no USDC
      setSuccess('Aprobación completada')
    } catch (err: any) {
      setError(err.message || 'Error al aprobar')
    } finally {
      setLoading(false)
    }
  }

  const handleBuyTokens = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!account || !isConnected || !address) {
      setError('Conecta tu wallet primero')
      return
    }

    setLoading(true)
    setError(null)
    setSuccess(null)

    try {
      const amount = parseToU256(buyAmount, DECIMALS)
      const { low, high } = u256ToLowHigh(amount)

      // Use account.execute directly to avoid validation issues
      const result = await account.execute({
        contractAddress: CONTRACTS.LAUNCHPAD,
        entrypoint: 'buy_tokens',
        calldata: [
          tokenAddress, // token_address
          low.toString(),
          high.toString()
        ]
      })

      setSuccess(`Compra exitosa! Transaction: ${result.transaction_hash}`)
      setBuyAmount('')
      
      // Try to wait for transaction in background
      account.waitForTransaction(result.transaction_hash)
        .then(() => {
          console.log('Buy transaction confirmed:', result.transaction_hash)
          loadTokenInfo()
        })
        .catch((err) => {
          console.warn('Could not wait for transaction:', err)
          // Still reload info
          loadTokenInfo()
        })
    } catch (err: any) {
      setError(err.message || 'Error al comprar tokens')
    } finally {
      setLoading(false)
    }
  }

  const handleApproveTokens = async () => {
    // NOTA: Ya no se necesita approve porque el Launchpad hace burn directamente
    // Esta función se mantiene por compatibilidad pero no hace nada
    setSuccess('No se requiere aprobación - el Launchpad hace burn directamente')
  }

  const handleSellTokens = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!account || !isConnected || !address) {
      setError('Conecta tu wallet primero')
      return
    }

    setLoading(true)
    setError(null)
    setSuccess(null)

    try {
      const amount = parseToU256(sellAmount, DECIMALS)
      const { low, high } = u256ToLowHigh(amount)

      // Use account.execute directly to avoid validation issues
      const result = await account.execute({
        contractAddress: CONTRACTS.LAUNCHPAD,
        entrypoint: 'sell_tokens',
        calldata: [
          tokenAddress, // token_address
          low.toString(),
          high.toString()
        ]
      })

      setSuccess(`Venta exitosa! Transaction: ${result.transaction_hash}`)
      setSellAmount('')
      
      // Try to wait for transaction in background
      account.waitForTransaction(result.transaction_hash)
        .then(() => {
          console.log('Sell transaction confirmed:', result.transaction_hash)
          loadTokenInfo()
        })
        .catch((err) => {
          console.warn('Could not wait for transaction:', err)
          // Still reload info
          loadTokenInfo()
        })
    } catch (err: any) {
      setError(err.message || 'Error al vender tokens')
    } finally {
      setLoading(false)
    }
  }

  if (!isConnected) {
    return (
      <div className="bg-gray-800 rounded-lg p-8 text-center">
        <p className="text-gray-400">Conecta tu wallet para comprar/vender tokens</p>
      </div>
    )
  }

  return (
    <div className="bg-gray-800 rounded-lg p-8">
      <h2 className="text-2xl font-bold text-white mb-6">
        {tokenName || 'Token'} ({tokenSymbol || 'TKN'})
      </h2>

      {/* Token Info */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <div className="bg-gray-700 rounded-lg p-4">
          <p className="text-sm text-gray-400 mb-1">Precio Actual</p>
          <p className="text-xl font-bold text-white">
            {currentPrice ? formatWithDecimals(currentPrice, DECIMALS) : '---'}
          </p>
        </div>
        <div className="bg-gray-700 rounded-lg p-4">
          <p className="text-sm text-gray-400 mb-1">Liquidez</p>
          <p className="text-xl font-bold text-white">
            {liquidity ? formatWithDecimals(liquidity, DECIMALS) : '---'}
          </p>
        </div>
        <div className="bg-gray-700 rounded-lg p-4">
          <p className="text-sm text-gray-400 mb-1">Tu Balance</p>
          <p className="text-xl font-bold text-white">
            {userTokenBalance ? formatWithDecimals(userTokenBalance, DECIMALS) : '0'}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Buy Section */}
        <div className="bg-gray-700 rounded-lg p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Comprar Tokens</h3>
          
          <form onSubmit={handleBuyTokens} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Cantidad (ETH)
              </label>
              <input
                type="text"
                value={buyAmount}
                onChange={(e) => setBuyAmount(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-600 text-white rounded-lg border border-gray-500 focus:border-primary-500 focus:outline-none"
                placeholder="0.0"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full px-6 py-3 bg-green-600 hover:bg-green-700 disabled:bg-gray-600 disabled:cursor-not-allowed text-white rounded-lg font-semibold transition-colors"
            >
              {loading ? 'Comprando...' : 'Comprar Tokens'}
            </button>
          </form>
        </div>

        {/* Sell Section */}
        <div className="bg-gray-700 rounded-lg p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Vender Tokens</h3>
          
          <form onSubmit={handleSellTokens} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Cantidad de Tokens
              </label>
              <input
                type="text"
                value={sellAmount}
                onChange={(e) => setSellAmount(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-600 text-white rounded-lg border border-gray-500 focus:border-primary-500 focus:outline-none"
                placeholder="0.0"
              />
              {userTokenBalance && (
                <button
                  type="button"
                  onClick={() => setSellAmount(formatWithDecimals(userTokenBalance, DECIMALS))}
                  className="mt-2 text-sm text-primary-400 hover:text-primary-300"
                >
                  Usar máximo: {formatWithDecimals(userTokenBalance, DECIMALS)}
                </button>
              )}
            </div>

            {/* NOTA: Ya no se necesita approve - el Launchpad hace burn directamente */}
            <div className="w-full px-4 py-2 bg-gray-600 text-gray-400 rounded-lg text-sm mb-2 text-center">
              ℹ️ No se requiere aprobación - el Launchpad quema tokens directamente
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full px-6 py-3 bg-red-600 hover:bg-red-700 disabled:bg-gray-600 disabled:cursor-not-allowed text-white rounded-lg font-semibold transition-colors"
            >
              {loading ? 'Vendiendo...' : 'Vender Tokens'}
            </button>
          </form>
        </div>
      </div>

      {error && (
        <div className="mt-6 p-4 bg-red-500/20 border border-red-500/50 rounded-lg text-red-400">
          {error}
        </div>
      )}

      {success && (
        <div className="mt-6 p-4 bg-green-500/20 border border-green-500/50 rounded-lg text-green-400">
          {success}
        </div>
      )}
    </div>
  )
}

