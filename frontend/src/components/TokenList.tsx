'use client'

import { useState, useEffect } from 'react'
import { useWallet } from '@/contexts/WalletContext'
import { getTokenFactoryContract } from '@/lib/starknet'
import { CONTRACTS } from '@/lib/constants'
import { TradingSection } from './TradingSection'
import axios from 'axios'
import { API_BASE_URL } from '@/lib/constants'

interface TokenInfo {
  address: string
  name: string
  symbol: string
  creator: string
  createdAt: string
}

export function TokenList() {
  const { account, isConnected } = useWallet()
  const [tokens, setTokens] = useState<TokenInfo[]>([])
  const [selectedToken, setSelectedToken] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    loadTokens()
  }, [isConnected, account])

  const loadTokens = async () => {
    setLoading(true)
    try {
      // Load from backend API
      const response = await axios.get(`${API_BASE_URL}/api/tokens`)
      setTokens(response.data)
    } catch (err) {
      console.error('Error loading tokens:', err)
      // Fallback: try to load from contract directly
      if (account) {
        try {
          const factory = getTokenFactoryContract(account)
          const count = await factory.get_token_count()
          const tokenList: TokenInfo[] = []
          
          for (let i = 0; i < Number(count.low); i++) {
            const address = await factory.get_token_at({ low: BigInt(i), high: BigInt(0) })
            // Get token info
            // TODO: Call token contract to get name/symbol
            tokenList.push({
              address,
              name: `Token ${i + 1}`,
              symbol: 'TKN',
              creator: '',
              createdAt: new Date().toISOString(),
            })
          }
          setTokens(tokenList)
        } catch (contractErr) {
          console.error('Error loading from contract:', contractErr)
        }
      }
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="bg-gray-800 rounded-lg p-8 text-center">
        <p className="text-gray-400">Cargando tokens...</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="bg-gray-800 rounded-lg p-8">
        <h2 className="text-2xl font-bold text-white mb-6">Tokens Disponibles</h2>
        
        {tokens.length === 0 ? (
          <p className="text-gray-400 text-center py-8">
            No hay tokens disponibles aún. Crea uno en la sección "Crear Token"
          </p>
        ) : (
          <div className="space-y-4">
            {tokens.map((token) => (
              <div
                key={token.address}
                className={`p-4 rounded-lg border cursor-pointer transition-colors ${
                  selectedToken === token.address
                    ? 'bg-primary-500/20 border-primary-500'
                    : 'bg-gray-700 border-gray-600 hover:border-gray-500'
                }`}
                onClick={() => setSelectedToken(token.address)}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-white">
                      {token.name} ({token.symbol})
                    </h3>
                    <p className="text-sm text-gray-400 font-mono">
                      {token.address.slice(0, 10)}...{token.address.slice(-8)}
                    </p>
                  </div>
                  <button className="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg text-sm font-semibold transition-colors">
                    {selectedToken === token.address ? 'Seleccionado' : 'Seleccionar'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {selectedToken && (
        <TradingSection
          tokenAddress={selectedToken}
          tokenName={tokens.find(t => t.address === selectedToken)?.name}
          tokenSymbol={tokens.find(t => t.address === selectedToken)?.symbol}
        />
      )}
    </div>
  )
}

