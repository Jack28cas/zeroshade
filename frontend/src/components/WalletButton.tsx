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
        <div className="px-4 py-2 bg-[#6365ff]/20 text-[#dfdfff] rounded-lg border border-[#6365ff]/30">
          {displayAddress}
        </div>
        <button
          onClick={disconnectWallet}
          className="px-6 py-2 bg-red-600/80 hover:bg-red-600 text-white rounded-lg transition-colors font-semibold uppercase tracking-wide"
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <button
      onClick={connectWallet}
      className="px-6 py-2 bg-gradient-to-r from-[#a694ff] to-[#6365ff] hover:from-[#6365ff] hover:to-[#a694ff] text-white rounded-lg transition-all duration-300 font-bold uppercase tracking-wider shadow-lg shadow-[#6365ff]/50"
    >
      CONNECT WALLET
    </button>
  )
}

