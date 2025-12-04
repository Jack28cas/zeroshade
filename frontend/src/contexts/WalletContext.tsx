'use client'

import { createContext, useContext, useState, useEffect, ReactNode } from 'react'
import { connect, disconnect } from 'get-starknet'
import { AccountInterface, ProviderInterface } from 'starknet'

interface WalletContextType {
  account: AccountInterface | null
  provider: ProviderInterface | null
  address: string | null
  isConnected: boolean
  connectWallet: () => Promise<void>
  disconnectWallet: () => void
  isLoading: boolean
}

const WalletContext = createContext<WalletContextType | undefined>(undefined)

export function WalletProvider({ children }: { children: ReactNode }) {
  const [account, setAccount] = useState<AccountInterface | null>(null)
  const [provider, setProvider] = useState<ProviderInterface | null>(null)
  const [address, setAddress] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    checkConnection()
  }, [])

  const checkConnection = async () => {
    try {
      // Check if already connected via window.starknet
      const windowStarknet = (window as any).starknet as any
      if (windowStarknet?.isConnected && windowStarknet?.account) {
        setAccount(windowStarknet.account)
        setProvider(windowStarknet.provider || null)
        setAddress(windowStarknet.account.address)
      }
    } catch (error) {
      console.error('Error checking wallet connection:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const connectWallet = async () => {
    try {
      setIsLoading(true)
      
      // First, check if already connected
      const windowStarknet = (window as any).starknet as any
      if (windowStarknet?.isConnected && windowStarknet?.account) {
        setAccount(windowStarknet.account)
        setProvider(windowStarknet.provider || null)
        setAddress(windowStarknet.account.address)
        return
      }

      // Connect using get-starknet
      const starknet = await connect()
      
      if (!starknet) {
        throw new Error('No Starknet wallet found. Please install ArgentX or Braavos.')
      }

      // Enable the wallet
      await starknet.enable()
      
      if (starknet.account) {
        setAccount(starknet.account)
        setProvider(starknet.provider || null)
        setAddress(starknet.account.address)
      } else {
        throw new Error('Failed to get account from wallet. Please try again.')
      }
    } catch (error) {
      console.error('Error connecting wallet:', error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }

  const disconnectWallet = async () => {
    try {
      await disconnect()
    } catch (error) {
      console.error('Error disconnecting wallet:', error)
    } finally {
      setAccount(null)
      setProvider(null)
      setAddress(null)
    }
  }

  return (
    <WalletContext.Provider
      value={{
        account,
        provider,
        address,
        isConnected: !!account,
        connectWallet,
        disconnectWallet,
        isLoading,
      }}
    >
      {children}
    </WalletContext.Provider>
  )
}

export function useWallet() {
  const context = useContext(WalletContext)
  if (context === undefined) {
    throw new Error('useWallet must be used within a WalletProvider')
  }
  return context
}

