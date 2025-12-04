import { Router } from 'express'
import { db } from '../db/database'
import { Provider, Contract, RpcProvider } from 'starknet'
import { TOKEN_ABI } from '../abis/token'
import { NETWORK } from '../config/constants'

const router = Router()
const provider = new RpcProvider({ nodeUrl: NETWORK.RPC_URL })

// Get all tokens
router.get('/tokens', async (req, res) => {
  try {
    const tokens = await db.getAllTokens()
    res.json(tokens)
  } catch (error) {
    console.error('Error fetching tokens:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Add token manually (for tokens deployed outside factory)
router.post('/tokens', async (req, res) => {
  try {
    const { address, name, symbol } = req.body
    
    if (!address) {
      return res.status(400).json({ error: 'Token address is required' })
    }

    // Check if token already exists
    const existing = await db.getTokenByAddress(address)
    if (existing) {
      return res.json(existing)
    }

    // Try to get name and symbol from contract if not provided
    let tokenName = name || 'Unknown'
    let tokenSymbol = symbol || 'UNK'

    try {
      const tokenContract = new Contract(TOKEN_ABI, address, provider)
      
      // Helper function to parse felt252
      const parseFelt252 = (value: any): string => {
        if (value === null || value === undefined) return 'Unknown'
        if (typeof value === 'bigint') return value.toString()
        if (typeof value === 'string') return value
        if (typeof value === 'number') return value.toString()
        if (typeof value === 'object') {
          // Handle starknet.js response format: { name: bigint } or { symbol: bigint }
          if ('name' in value && typeof value.name === 'bigint') {
            return value.name.toString()
          }
          if ('symbol' in value && typeof value.symbol === 'bigint') {
            return value.symbol.toString()
          }
          if ('value' in value) {
            const val = value.value
            if (typeof val === 'bigint') return val.toString()
            if (typeof val === 'string') return val
            return String(val)
          }
          if ('low' in value && value.low !== undefined) {
            return value.low.toString()
          }
          if (Array.isArray(value) && value.length > 0) {
            return parseFelt252(value[0])
          }
          // Try to find any meaningful value
          for (const key in value) {
            if (typeof value[key] === 'bigint' || typeof value[key] === 'string' || typeof value[key] === 'number') {
              return parseFelt252(value[key])
            }
          }
        }
        return String(value)
      }

      if (!name) {
        const nameResult = await tokenContract.name()
        console.log(`🔍 Raw name result:`, nameResult, typeof nameResult)
        tokenName = parseFelt252(nameResult)
        console.log(`✅ Parsed name: ${tokenName}`)
      }

      if (!symbol) {
        const symbolResult = await tokenContract.symbol()
        console.log(`🔍 Raw symbol result:`, symbolResult, typeof symbolResult)
        tokenSymbol = parseFelt252(symbolResult)
        console.log(`✅ Parsed symbol: ${tokenSymbol}`)
      }
    } catch (err) {
      console.warn(`Could not fetch token info for ${address}:`, err)
    }

    // Save to database
    const token = await db.saveToken({
      address,
      name: tokenName,
      symbol: tokenSymbol,
      creator: '',
      createdAt: new Date().toISOString(),
    })

    res.json(token)
  } catch (error) {
    console.error('Error adding token:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get token by address
router.get('/tokens/:address', async (req, res) => {
  try {
    const { address } = req.params
    const token = await db.getTokenByAddress(address)
    
    if (!token) {
      return res.status(404).json({ error: 'Token not found' })
    }
    
    res.json(token)
  } catch (error) {
    console.error('Error fetching token:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get tokens by creator
router.get('/tokens/creator/:creator', async (req, res) => {
  try {
    const { creator } = req.params
    const tokens = await db.getTokensByCreator(creator)
    res.json(tokens)
  } catch (error) {
    console.error('Error fetching tokens by creator:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Update token info (re-fetch from contract)
router.post('/tokens/:address/refresh', async (req, res) => {
  try {
    const { address } = req.params
    
    const tokenContract = new Contract(TOKEN_ABI, address, provider)
    
    // Helper function to parse felt252 (same as in POST /tokens)
    const parseFelt252 = (value: any): string => {
      if (value === null || value === undefined) return 'Unknown'
      if (typeof value === 'bigint') return value.toString()
      if (typeof value === 'string') return value
      if (typeof value === 'number') return value.toString()
      if (typeof value === 'object') {
        // Handle starknet.js response format: { name: bigint } or { symbol: bigint }
        if ('name' in value && typeof value.name === 'bigint') {
          return value.name.toString()
        }
        if ('symbol' in value && typeof value.symbol === 'bigint') {
          return value.symbol.toString()
        }
        if ('value' in value) {
          const val = value.value
          if (typeof val === 'bigint') return val.toString()
          if (typeof val === 'string') return val
          return String(val)
        }
        if ('low' in value && value.low !== undefined) {
          return value.low.toString()
        }
        if (Array.isArray(value) && value.length > 0) {
          return parseFelt252(value[0])
        }
        // Try to find any bigint, string, or number property
        for (const key in value) {
          if (typeof value[key] === 'bigint' || typeof value[key] === 'string' || typeof value[key] === 'number') {
            return parseFelt252(value[key])
          }
        }
      }
      return String(value)
    }

    let tokenName = 'Unknown'
    let tokenSymbol = 'UNK'

    try {
      const nameResult = await tokenContract.name()
      console.log(`🔍 Refreshing name for ${address}:`, nameResult, typeof nameResult)
      tokenName = parseFelt252(nameResult)
      console.log(`✅ Refreshed name: ${tokenName}`)
    } catch (e) {
      console.warn(`Could not refresh name for token ${address}:`, e)
    }

    try {
      const symbolResult = await tokenContract.symbol()
      console.log(`🔍 Refreshing symbol for ${address}:`, symbolResult, typeof symbolResult)
      tokenSymbol = parseFelt252(symbolResult)
      console.log(`✅ Refreshed symbol: ${tokenSymbol}`)
    } catch (e) {
      console.warn(`Could not refresh symbol for token ${address}:`, e)
    }

    // Get existing token to preserve creator and createdAt
    const existing = await db.getTokenByAddress(address)
    
    // Update token in database
    await db.saveToken({
      address,
      name: tokenName,
      symbol: tokenSymbol,
      creator: existing?.creator || '',
      createdAt: existing?.createdAt || new Date().toISOString(),
    })

    // Get the updated token from database
    const updatedToken = await db.getTokenByAddress(address)
    
    if (!updatedToken) {
      return res.status(500).json({ error: 'Failed to retrieve updated token' })
    }

    res.json(updatedToken)
  } catch (error) {
    console.error('Error refreshing token:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

export { router as tokenRoutes }

