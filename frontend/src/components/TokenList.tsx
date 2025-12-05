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
      <div className="bg-gray-900/50 rounded-lg p-8 text-center border border-gray-800">
        <p className="text-[#dfdfff]">Cargando tokens...</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="bg-gray-900/50 rounded-lg p-8 border border-gray-800">
        <h2 className="text-3xl font-bold uppercase mb-6 bg-gradient-to-r from-[#a694ff] to-[#6365ff] bg-clip-text text-transparent tracking-wider">
          Available Tokens
        </h2>
        
        {tokens.length === 0 ? (
          <p className="text-[#dfdfff] text-center py-8">
            No tokens available yet. Create one in the "Create Token" section
          </p>
        ) : (
          <div className="space-y-4">
            {tokens.map((token) => (
              <div
                key={token.address}
                className={`p-4 rounded-lg border cursor-pointer transition-all ${
                  selectedToken === token.address
                    ? 'bg-[#6365ff]/20 border-[#a694ff] shadow-lg shadow-[#6365ff]/30'
                    : 'bg-gray-800/50 border-gray-700 hover:border-[#6365ff]/50 hover:bg-gray-800'
                }`}
                onClick={() => setSelectedToken(token.address)}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-white uppercase">
                      {token.name} ({token.symbol})
                    </h3>
                    <p className="text-sm text-[#dfdfff] font-mono mt-1">
                      {token.address.slice(0, 10)}...{token.address.slice(-8)}
                    </p>
                  </div>
                  <button className={`px-4 py-2 rounded-lg text-sm font-bold uppercase tracking-wide transition-all ${
                    selectedToken === token.address
                      ? 'bg-gradient-to-r from-[#a694ff] to-[#6365ff] text-white'
                      : 'bg-gray-700 text-[#dfdfff] hover:bg-gray-600'
                  }`}>
                    {selectedToken === token.address ? 'Selected' : 'Select'}
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

