'use client'

import { useWallet } from '@/contexts/WalletContext'
import { useEffect, useState } from 'react'

export function WalletButton() {
  const { address, isConnected, connectWallet, disconnectWallet, isLoading } = useWallet()
  const [displayAddress, setDisplayAddress] = useState<string>('')

  useEffect(() => {
    if (address) {
      const shortAddress = `${address.slice(0, 6)}...${address.slice(-4)}`
      setDisplayAddress(shortAddress)
    }
  }, [address])

  if (isLoading) {
    return (
      <button
        disabled
        className="px-6 py-2 bg-gray-700 text-gray-400 rounded-lg cursor-not-allowed"
      >
        Cargando...
      </button>
    )
  }

  if (isConnected && address) {
    return (
      <div className="flex items-center gap-4">
        <div className="px-4 py-2 bg-green-500/20 text-green-400 rounded-lg border border-green-500/30">
          {displayAddress}
        </div>
        <button
          onClick={disconnectWallet}
          className="px-6 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition-colors"
        >
          Desconectar
        </button>
      </div>
    )
  }

  return (
    <button
      onClick={connectWallet}
      className="px-6 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg transition-colors font-semibold"
    >
      Conectar Wallet
    </button>
  )
}

