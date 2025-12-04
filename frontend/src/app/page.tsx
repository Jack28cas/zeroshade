'use client'

import { useState } from 'react'
import { WalletButton } from '@/components/WalletButton'
import { CreateTokenSection } from '@/components/CreateTokenSection'
import { TradingSection } from '@/components/TradingSection'
import { TokenList } from '@/components/TokenList'

export default function Home() {
  const [activeSection, setActiveSection] = useState<'create' | 'trade'>('create')

  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <header className="mb-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold text-white mb-2">
                ZumpFun
              </h1>
              <p className="text-gray-400">
                Pump.fun privado en Starknet
              </p>
            </div>
            <WalletButton />
          </div>

          {/* Navigation Tabs */}
          <div className="flex gap-4 border-b border-gray-700">
            <button
              onClick={() => setActiveSection('create')}
              className={`px-6 py-3 font-semibold transition-colors ${
                activeSection === 'create'
                  ? 'text-primary-400 border-b-2 border-primary-400'
                  : 'text-gray-400 hover:text-gray-300'
              }`}
            >
              Crear Token
            </button>
            <button
              onClick={() => setActiveSection('trade')}
              className={`px-6 py-3 font-semibold transition-colors ${
                activeSection === 'trade'
                  ? 'text-primary-400 border-b-2 border-primary-400'
                  : 'text-gray-400 hover:text-gray-300'
              }`}
            >
              Comprar / Vender
            </button>
          </div>
        </header>

        {/* Main Content */}
        <div className="mt-8">
          {activeSection === 'create' ? (
            <CreateTokenSection />
          ) : (
            <TokenList />
          )}
        </div>
      </div>
    </main>
  )
}

