'use client'

import { useState } from 'react'
import Image from 'next/image'
import { WalletButton } from '@/components/WalletButton'
import { CreateTokenSection } from '@/components/CreateTokenSection'
import { TradingSection } from '@/components/TradingSection'
import { TokenList } from '@/components/TokenList'

export default function Home() {
  const [activeSection, setActiveSection] = useState<'home' | 'create' | 'trade'>('home')

  return (
    <main className="min-h-screen bg-black text-white">
      {/* Header */}
      <header className="w-full px-6 py-4 flex items-center justify-center">
        <div className="flex items-center gap-4 max-w-7xl w-full justify-between">
          <div className="flex items-center">
            <Image
              src="/logo-figura.png"
              alt="Zero Shade Logo"
              width={350}
              height={40}
              className="object-contain"
            />
          </div>
          <div className="flex items-center gap-4">
            <span className="text-white uppercase font-semibold tracking-wider">LAUNCHPAD</span>
            <WalletButton />
          </div>
        </div>
      </header>

      {/* Main Hero Section - Only shown when activeSection is 'home' */}
      {activeSection === 'home' && (
        <div className="w-full flex justify-center px-6">
          <div className="flex flex-col lg:flex-row min-h-[calc(100vh-80px)] max-w-7xl w-full">
            {/* Left Side - Face Graphic */}
            <div className="w-full lg:w-1/2 flex items-start justify-start pt-0 lg:pt-0 pl-0 lg:pl-0 pr-4 lg:pr-8 overflow-hidden">
              <div className="relative w-full h-[calc(100vh-80px)] lg:h-[calc(100vh-80px)] min-h-[500px] -mt-12 lg:-mt-12">
                <Image
                  src="/cara.png"
                  alt="Abstract Face"
                  fill
                  className="object-contain object-top object-left"
                  priority
                  sizes="(max-width: 1024px) 100vw, 50vw"
                  style={{ width: '100%', height: '100%' }}
                />
              </div>
            </div>

            {/* Right Side - Content */}
            <div className="w-full lg:w-1/2 flex flex-col justify-center px-0 lg:px-0 py-8 lg:py-16 items-end lg:items-end">
              <div className="max-w-lg text-right lg:text-right pr-0 lg:pr-0">
                {/* Headlines */}
                <h2 className="text-6xl font-bold uppercase mb-4 leading-tight">
                  LAUNCH YOUR MEMECOIN
                </h2>
                <h3 className="text-3xl font-bold uppercase mb-6 text-[#dfdfff]">
                  CODE-FREE. PRIVATE.
                </h3>
                <p className="text-xl uppercase mb-12 text-gray-300 tracking-wide">
                  CREATE, TRADE & GROW ON STARKNET IN SECONDS
                </p>

                {/* Create Token Button */}
                <div className="flex justify-end">
                  <button
                    onClick={() => setActiveSection('create')}
                    className="relative px-8 py-4 bg-gradient-to-r from-[#a694ff] via-[#6365ff] to-[#a694ff] rounded-lg font-bold text-lg uppercase tracking-wider shadow-lg shadow-[#6365ff]/50 hover:shadow-[#6365ff]/70 transition-all duration-300 hover:scale-105 flex items-center gap-3 group"
                  >
                    <span className="text-2xl">✦</span>
                    <span>CREATE TOKEN</span>
                    <span className="text-2xl">✦</span>
                  </button>
                </div>

                {/* Navigation to Trading */}
                <div className="mt-8 flex justify-end">
                  <button
                    onClick={() => setActiveSection('trade')}
                    className="text-[#a694ff] hover:text-[#6365ff] uppercase font-semibold tracking-wide transition-colors"
                  >
                    → View Tokens & Trade
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Features Section */}
      {activeSection === 'home' && (
        <div className="w-full flex justify-center px-6 py-16 lg:py-24">
          <div className="max-w-7xl w-full">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8">
              {/* Feature Card 1 */}
              <div className="group bg-gradient-to-r from-[#a694ff] to-[#6365ff] rounded-xl p-[2px] hover:p-0 transition-all duration-300">
                <div className="bg-black group-hover:bg-gradient-to-r group-hover:from-[#a694ff] group-hover:to-[#6365ff] rounded-xl p-6 lg:p-8 h-full transition-all duration-300">
                  <div className="flex items-start gap-6 lg:gap-8 mb-6">
                    <div className="bg-gradient-to-r from-[#a694ff] to-[#6365ff] group-hover:from-black group-hover:to-black rounded-xl w-14 h-14 lg:w-16 lg:h-16 flex items-center justify-center flex-shrink-0 transition-all duration-300">
                      <span className="text-white font-bold text-xl lg:text-2xl">01</span>
                    </div>
                    <div className="flex-1 pt-1">
                      <h3 className="text-lg lg:text-xl font-bold uppercase text-white group-hover:text-black leading-tight tracking-wider max-w-[140px] lg:max-w-[160px] transition-all duration-300">
                        INSTANT<br />DEPLOYEMENT
                      </h3>
                    </div>
                  </div>
                  <p className="text-sm lg:text-base text-[#dfdfff] group-hover:text-black uppercase tracking-wide pl-[88px] lg:pl-[104px] transition-all duration-300">
                    MINT YOUR ERC20 WITH ZERO CODE
                  </p>
                </div>
              </div>

              {/* Feature Card 2 */}
              <div className="group bg-gradient-to-r from-[#a694ff] to-[#6365ff] rounded-xl p-[2px] hover:p-0 transition-all duration-300">
                <div className="bg-black group-hover:bg-gradient-to-r group-hover:from-[#a694ff] group-hover:to-[#6365ff] rounded-xl p-6 lg:p-8 h-full transition-all duration-300">
                  <div className="flex items-start gap-6 lg:gap-8 mb-6">
                    <div className="bg-gradient-to-r from-[#a694ff] to-[#6365ff] group-hover:from-black group-hover:to-black rounded-xl w-14 h-14 lg:w-16 lg:h-16 flex items-center justify-center flex-shrink-0 transition-all duration-300">
                      <span className="text-white font-bold text-xl lg:text-2xl">02</span>
                    </div>
                    <div className="flex-1 pt-1">
                      <h3 className="text-lg lg:text-xl font-bold uppercase text-white group-hover:text-black leading-tight tracking-wider max-w-[140px] lg:max-w-[160px] transition-all duration-300">
                        STABLE<br />TRADING
                      </h3>
                    </div>
                  </div>
                  <p className="text-sm lg:text-base text-[#dfdfff] group-hover:text-black uppercase tracking-wide pl-[88px] lg:pl-[104px] transition-all duration-300">
                    BUY/SELL USING PAUSABLEERC20
                  </p>
                </div>
              </div>

              {/* Feature Card 3 */}
              <div className="group bg-gradient-to-r from-[#a694ff] to-[#6365ff] rounded-xl p-[2px] hover:p-0 transition-all duration-300">
                <div className="bg-black group-hover:bg-gradient-to-r group-hover:from-[#a694ff] group-hover:to-[#6365ff] rounded-xl p-6 lg:p-8 h-full transition-all duration-300">
                  <div className="flex items-start gap-6 lg:gap-8 mb-6">
                    <div className="bg-gradient-to-r from-[#a694ff] to-[#6365ff] group-hover:from-black group-hover:to-black rounded-xl w-14 h-14 lg:w-16 lg:h-16 flex items-center justify-center flex-shrink-0 transition-all duration-300">
                      <span className="text-white font-bold text-xl lg:text-2xl">03</span>
                    </div>
                    <div className="flex-1 pt-1">
                      <h3 className="text-lg lg:text-xl font-bold uppercase text-white group-hover:text-black leading-tight tracking-wider max-w-[140px] lg:max-w-[160px] transition-all duration-300">
                        FULL<br />PRIVACY
                      </h3>
                    </div>
                  </div>
                  <p className="text-sm lg:text-base text-[#dfdfff] group-hover:text-black uppercase tracking-wide pl-[88px] lg:pl-[104px] transition-all duration-300">
                    POWERED BY GARAGA ON STARKNET
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Content Sections (Shown when navigating) */}
      {(activeSection === 'create' || activeSection === 'trade') && (
        <div className="fixed inset-0 bg-black z-50 overflow-y-auto">
          <div className="container mx-auto px-6 py-8 max-w-6xl">
            {/* Back Button */}
            <button
              onClick={() => setActiveSection('home')}
              className="mb-6 text-[#a694ff] hover:text-[#6365ff] uppercase font-medium text-sm tracking-wider transition-colors flex items-center gap-2"
            >
              <span>←</span>
              <span>BACK TO HOME</span>
            </button>

            {/* Navigation Tabs */}
            <div className="flex gap-4 border-b border-gray-800 mb-8">
              <button
                onClick={() => setActiveSection('create')}
                className={`px-6 py-3 font-semibold uppercase tracking-wider transition-all ${
                  activeSection === 'create'
                    ? 'text-[#a694ff] border-b-2 border-[#a694ff]'
                    : 'text-[#a694ff]/60 hover:text-[#a694ff]'
                }`}
              >
                CREATE TOKEN
              </button>
              <button
                onClick={() => setActiveSection('trade')}
                className={`px-6 py-3 font-semibold uppercase tracking-wider transition-all ${
                  activeSection === 'trade'
                    ? 'text-[#a694ff] border-b-2 border-[#a694ff]'
                    : 'text-[#a694ff]/60 hover:text-[#a694ff]'
                }`}
              >
                BUY / SELL
              </button>
            </div>

            {/* Content */}
            <div className="mt-8">
              {activeSection === 'create' ? (
                <CreateTokenSection />
              ) : (
                <TokenList />
              )}
            </div>
          </div>
        </div>
      )}
    </main>
  )
}
