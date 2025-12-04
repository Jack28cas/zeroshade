import { Provider, Contract, RpcProvider } from 'starknet'
import { TOKEN_FACTORY_ABI } from '../abis/tokenFactory'
import { TOKEN_ABI } from '../abis/token'
import { db } from '../db/database'
import { CONTRACTS, NETWORK } from '../config/constants'

const TOKEN_FACTORY_ADDRESS = CONTRACTS.TOKEN_FACTORY
const RPC_URL = NETWORK.RPC_URL

class TokenMonitor {
  private provider: RpcProvider
  private factoryContract: Contract
  private intervalId: NodeJS.Timeout | null = null
  private isRunning = false

  constructor() {
    this.provider = new RpcProvider({ nodeUrl: RPC_URL })
    this.factoryContract = new Contract(
      TOKEN_FACTORY_ABI,
      TOKEN_FACTORY_ADDRESS,
      this.provider
    )
  }

  async start() {
    if (this.isRunning) {
      console.log('Token monitor already running')
      return
    }

    console.log('🔍 Starting token monitor...')
    this.isRunning = true

    // Initial scan
    await this.scanTokens()
    await this.scanLaunchpad()

    // Monitor every 30 seconds
    this.intervalId = setInterval(() => {
      this.scanTokens().catch(console.error)
      this.scanLaunchpad().catch(console.error)
    }, 30000)
  }

  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }
    this.isRunning = false
    console.log('Token monitor stopped')
  }

  private async scanTokens() {
    try {
      // Get token count
      const countResult = await this.factoryContract.get_token_count()
      
      // Debug: log the result to see its structure (handle BigInt)
      const debugResult = typeof countResult === 'object' && countResult !== null
        ? {
            ...countResult,
            low: countResult.low?.toString(),
            high: countResult.high?.toString(),
          }
        : countResult?.toString()
      console.log('Token count result:', debugResult)
      
      // Handle u256 result - starknet.js v5 returns u256 as { count: bigint } or { low: bigint, high: bigint }
      let count = 0
      if (countResult && typeof countResult === 'object') {
        // Check if it has a 'count' property (starknet.js v5 format)
        if ('count' in countResult && countResult.count !== undefined) {
          count = Number(countResult.count)
        }
        // Check if it's a u256 object with low/high
        else if ('low' in countResult && countResult.low !== undefined) {
          count = Number(countResult.low)
        } 
        // Check if it's an array [low, high]
        else if (Array.isArray(countResult) && countResult.length >= 1) {
          count = Number(countResult[0])
        }
        // Try to convert to string then number
        else if ('toString' in countResult) {
          count = Number(countResult.toString())
        }
      } else if (typeof countResult === 'bigint') {
        count = Number(countResult)
      } else if (typeof countResult === 'number') {
        count = countResult
      } else if (typeof countResult === 'string') {
        count = parseInt(countResult, 10)
      }

      if (isNaN(count) || count < 0) {
        console.warn('⚠️ Could not parse token count, result type:', typeof countResult)
        return
      }

      console.log(`📊 Found ${count} tokens in factory`)

      // Scan each token
      for (let i = 0; i < count; i++) {
        try {
          // get_token_at expects u256, which needs to be passed as { low, high }
          // For index i (which should be < 2^128), low = i, high = 0
          // Use callContract directly to ensure proper u256 serialization
          const tokenResult = await this.provider.callContract({
            contractAddress: TOKEN_FACTORY_ADDRESS,
            entrypoint: 'get_token_at',
            calldata: [
              BigInt(i).toString(), // low
              '0' // high
            ]
          })
          
          // Handle the result from callContract - returns array of felt252 values
          // First element should be the token address (ContractAddress)
          const tokenAddress = tokenResult.result && tokenResult.result.length > 0
            ? tokenResult.result[0]
            : ''
          
          // Skip tokens with address 0x0 (simulated version for hackathon)
          if (!tokenAddress || tokenAddress === '0x0' || tokenAddress === '0') {
            console.log(`⏭️  Skipping token at index ${i} (address is 0x0 - simulated version)`)
            continue
          }
          
          // Check if token already exists in DB
          const existing = await db.getTokenByAddress(tokenAddress)
          
          if (!existing) {
            // Get token info
            const tokenContract = new Contract(
              TOKEN_ABI,
              tokenAddress,
              this.provider
            )

            let name = 'Unknown'
            let symbol = 'UNK'

            try {
              const nameResult = await tokenContract.name()
              console.log(`🔍 Raw name result for ${tokenAddress}:`, nameResult, typeof nameResult)
              name = this.parseFelt252(nameResult)
              console.log(`✅ Parsed name: ${name}`)
            } catch (e) {
              console.warn(`Could not get name for token ${tokenAddress}:`, e)
            }

            try {
              const symbolResult = await tokenContract.symbol()
              console.log(`🔍 Raw symbol result for ${tokenAddress}:`, symbolResult, typeof symbolResult)
              symbol = this.parseFelt252(symbolResult)
              console.log(`✅ Parsed symbol: ${symbol}`)
            } catch (e) {
              console.warn(`Could not get symbol for token ${tokenAddress}:`, e)
            }

            // Save to database
            await db.saveToken({
              address: tokenAddress,
              name,
              symbol,
              creator: '', // Will be filled from events
              createdAt: new Date().toISOString(),
            })

            console.log(`✅ New token saved: ${name} (${symbol}) at ${tokenAddress}`)
          }
        } catch (err) {
          console.error(`Error scanning token at index ${i}:`, err)
        }
      }
    } catch (err) {
      console.error('Error scanning tokens:', err)
    }
  }

  async monitorEvents() {
    // TODO: Implement event monitoring for real-time updates
    // This would listen to TokenCreated events from the factory
  }

  // Scan Launchpad for launched tokens
  async scanLaunchpad() {
    try {
      const { CONTRACTS } = await import('../config/constants')
      const LAUNCHPAD_ABI = [
        {
          type: 'function',
          name: 'get_launch_info',
          inputs: [{ name: 'token_address', type: 'ContractAddress' }],
          outputs: [
            {
              type: 'struct',
              name: 'LaunchInfo',
              members: [
                { name: 'token_address', type: 'ContractAddress' },
                { name: 'creator', type: 'ContractAddress' },
                { name: 'initial_price', type: 'u256' },
                { name: 'current_price', type: 'u256' },
                { name: 'total_supply', type: 'u256' },
                { name: 'liquidity', type: 'u256' },
                { name: 'k', type: 'u256' },
                { name: 'n', type: 'u256' },
                { name: 'fee_rate', type: 'u256' },
                { name: 'launch_time', type: 'u64' },
                { name: 'is_active', type: 'bool' },
              ],
            },
          ],
          state_mutability: 'view',
        },
      ]

      const launchpadContract = new Contract(
        LAUNCHPAD_ABI,
        CONTRACTS.LAUNCHPAD,
        this.provider
      )

      console.log('🔍 Scanning Launchpad for launched tokens...')

      // Method 1: Get TokenLaunched events from Launchpad
      try {
        // Get events from the last 1000 blocks (or from block 0 if we don't have a stored last block)
        const currentBlock = await this.provider.getBlockNumber()
        const fromBlock = Math.max(0, currentBlock - 1000) // Scan last 1000 blocks
        
        const events = await this.provider.getEvents({
          from_block: { block_number: fromBlock },
          to_block: { block_number: currentBlock },
          address: CONTRACTS.LAUNCHPAD,
          keys: [], // Empty keys means get all events
          chunk_size: 100,
        })

        console.log(`📊 Found ${events.events.length} events from Launchpad`)

        // Process TokenLaunched events
        for (const event of events.events) {
          try {
            // TokenLaunched event structure: [token_address, creator, initial_price_low, initial_price_high]
            if (event.data && event.data.length >= 2) {
              const tokenAddress = event.data[0]
              
              if (!tokenAddress || tokenAddress === '0x0' || tokenAddress === '0') {
                continue
              }

              // Check if token already exists in DB
              const existing = await db.getTokenByAddress(tokenAddress)
              if (existing) {
                continue // Already in DB
              }

              // Get token info from contract
              const tokenContract = new Contract(TOKEN_ABI, tokenAddress, this.provider)
              
              let name = 'Unknown'
              let symbol = 'UNK'
              let creator = ''

              try {
                const nameResult = await tokenContract.name()
                console.log(`🔍 Raw name result for ${tokenAddress}:`, nameResult, typeof nameResult)
                name = this.parseFelt252(nameResult)
                console.log(`✅ Parsed name: ${name}`)
              } catch (e) {
                console.warn(`Could not get name for token ${tokenAddress}:`, e)
              }

              try {
                const symbolResult = await tokenContract.symbol()
                console.log(`🔍 Raw symbol result for ${tokenAddress}:`, symbolResult, typeof symbolResult)
                symbol = this.parseFelt252(symbolResult)
                console.log(`✅ Parsed symbol: ${symbol}`)
              } catch (e) {
                console.warn(`Could not get symbol for token ${tokenAddress}:`, e)
              }

              // Get creator from event data (second element)
              if (event.data.length >= 2) {
                creator = event.data[1] || ''
              }

              // Save to database
              await db.saveToken({
                address: tokenAddress,
                name,
                symbol,
                creator,
                createdAt: new Date().toISOString(),
              })

              console.log(`✅ Launched token added from event: ${name} (${symbol}) at ${tokenAddress}`)
            }
          } catch (err) {
            console.warn(`Error processing event:`, err)
          }
        }
      } catch (err) {
        console.warn('Could not get events from Launchpad, trying alternative method:', err)
      }

      // Method 2: Check known tokens in DB to see if they're launched
      const allTokens = await db.getAllTokens()
      
      for (const token of allTokens) {
        if (token.address === '0x0' || !token.address) continue

        try {
          const launchInfo = await launchpadContract.get_launch_info(token.address)
          
          // If token is launched (is_active = true), ensure it's in DB with correct info
          if (launchInfo && launchInfo.is_active) {
            // Update creator if we have it from launch info
            if (launchInfo.creator) {
              await db.saveToken({
                address: token.address,
                name: token.name,
                symbol: token.symbol,
                creator: launchInfo.creator?.toString() || token.creator,
                createdAt: token.createdAt,
              })
            }
          }
        } catch (err) {
          // Token not launched or error checking - skip silently
        }
      }
    } catch (err) {
      console.error('Error scanning launchpad:', err)
    }
  }

  private parseFelt252(value: any): string {
    // Handle null/undefined
    if (value === null || value === undefined) {
      return 'Unknown'
    }

    // Handle bigint (most common case for felt252)
    if (typeof value === 'bigint') {
      return value.toString()
    }

    // Handle string
    if (typeof value === 'string') {
      return value
    }

    // Handle number
    if (typeof value === 'number') {
      return value.toString()
    }

    // Handle object
    if (typeof value === 'object') {
      // Handle starknet.js response format: { name: bigint } or { symbol: bigint }
      if ('name' in value && typeof value.name === 'bigint') {
        return value.name.toString()
      }
      if ('symbol' in value && typeof value.symbol === 'bigint') {
        return value.symbol.toString()
      }
      
      // Check for common starknet.js response formats
      if ('value' in value) {
        const val = value.value
        if (typeof val === 'bigint') return val.toString()
        if (typeof val === 'string') return val
        return String(val)
      }

      // Check for u256 format { low, high }
      if ('low' in value && 'high' in value) {
        // For felt252, we typically only need low (felt252 fits in u128)
        if (value.low !== undefined) {
          return value.low.toString()
        }
      }

      // Check if it's an array
      if (Array.isArray(value)) {
        if (value.length > 0) {
          return this.parseFelt252(value[0])
        }
      }

      // Try to find any numeric or string property
      for (const key in value) {
        if (typeof value[key] === 'bigint' || typeof value[key] === 'string' || typeof value[key] === 'number') {
          return this.parseFelt252(value[key])
        }
      }

      // Last resort: try JSON.stringify to see structure
      try {
        const json = JSON.stringify(value, (key, val) => {
          if (typeof val === 'bigint') {
            return val.toString()
          }
          return val
        })
        // Try to extract first meaningful value
        const numberMatch = json.match(/:(\d+)/)
        if (numberMatch) {
          return numberMatch[1]
        }
        const stringMatch = json.match(/:"([^"]+)"/)
        if (stringMatch) {
          return stringMatch[1]
        }
      } catch {}

      // If all else fails, return a descriptive string
      return `Token_${JSON.stringify(value).slice(0, 20)}`
    }

    // Fallback
    return String(value)
  }
}

export const tokenMonitor = new TokenMonitor()

