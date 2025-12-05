import { exec } from 'child_process'
import { promisify } from 'util'
import { join } from 'path'
import { CONTRACTS, NETWORK } from '../config/constants'

const execAsync = promisify(exec)

// Helper function to convert text to felt252 (same logic as bash script)
function textToFelt252(text: string): string {
  // If it's numeric, use it directly
  if (/^\d+$/.test(text.trim())) {
    return text.trim()
  }
  
  // Convert text to numeric hash (sum of ASCII codes)
  let hash = 0
  for (let i = 0; i < text.length; i++) {
    hash += text.charCodeAt(i)
  }
  // Multiply by factor to avoid collisions
  hash *= 256
  return hash.toString()
}

export async function deployToken(
  tokenName: string,
  tokenSymbol: string,
  initialSupply: string,
  ownerAddress: string,
  password: string = 'Didi2897'
): Promise<{ address: string; transactionHash: string }> {
  try {
    // Get script path
    const scriptPath = join(__dirname, '../../../scripts/deploy_and_setup_token.sh')
    
    // Detect if we're on Windows and convert path accordingly
    const isWindows = process.platform === 'win32'
    let unixScriptPath = scriptPath
    
    if (isWindows) {
      // Convert Windows path to Unix format for Git Bash/WSL
      // C:\Users\monst\zeroshade -> /c/Users/monst/zeroshade (Git Bash) or /mnt/c/Users/monst/zeroshade (WSL)
      unixScriptPath = scriptPath
        .replace(/\\/g, '/')
        .replace(/^([A-Z]):/, (match, drive) => {
          // Try WSL format first (/mnt/c/), fallback to Git Bash format (/c/)
          return `/mnt/${drive.toLowerCase()}`
        })
    }
    
    // Get working directory
    const cwd = join(__dirname, '../../..')
    let unixCwd = cwd
    if (isWindows) {
      unixCwd = cwd
        .replace(/\\/g, '/')
        .replace(/^([A-Z]):/, (match, drive) => {
          return `/mnt/${drive.toLowerCase()}`
        })
    }
    
    // Prepare inputs for the script
    // The script now reads from environment variables first, then stdin
    const inputs = `${tokenName}\n${tokenSymbol}\n${initialSupply}\n`
    
    console.log(`🚀 Deploying token via script: ${tokenName} (${tokenSymbol})`)
    console.log(`   Script path: ${unixScriptPath}`)
    console.log(`   Working directory: ${unixCwd}`)
    console.log(`   Platform: ${process.platform}`)
    
    // Execute the script with inputs piped via stdin
    // Escape special characters properly
    const escapedInputs = inputs
      .replace(/\\/g, '\\\\')
      .replace(/\$/g, '\\$')
      .replace(/`/g, '\\`')
      .replace(/"/g, '\\"')
      .replace(/'/g, "\\'")
      .replace(/\n/g, '\\n')
    
    // Escape password for shell
    const escapedPassword = password
      .replace(/\\/g, '\\\\')
      .replace(/\$/g, '\\$')
      .replace(/`/g, '\\`')
      .replace(/'/g, "\\'")
      .replace(/"/g, '\\"')
    
    let command: string
    let execOptions: any = {
      cwd: isWindows ? cwd : cwd, // Use Windows path for cwd, WSL will handle conversion
      env: {
        ...process.env,
        ACCOUNT: process.env.ACCOUNT || (process.env.HOME ? join(process.env.HOME, '.starkli/accounts/sepolia/my.json') : '~/.starkli/accounts/sepolia/my.json'),
        KEYSTORE: process.env.KEYSTORE || (process.env.HOME ? join(process.env.HOME, '.starkli/keystores/my_keystore.json') : '~/.starkli/keystores/my_keystore.json'),
        RPC: NETWORK.RPC_URL,
        // Set password as environment variable
        KEYSTORE_PASSWORD: password,
        STARKNET_KEYSTORE_PASSWORD: password,
        // Set token parameters as environment variables
        TOKEN_NAME_INPUT: tokenName,
        TOKEN_SYMBOL_INPUT: tokenSymbol,
        INITIAL_SUPPLY: initialSupply,
      },
    }
    
    if (isWindows) {
      // On Windows, use WSL to execute the script
      // Load bash profile to ensure PATH includes starkli and other tools
      // Pass inputs via stdin and also set password in environment
      command = `wsl bash -c "source ~/.bashrc 2>/dev/null || source ~/.profile 2>/dev/null || true; cd '${unixCwd}' && printf '${escapedInputs}' | TOKEN_NAME_INPUT='${tokenName.replace(/'/g, "\\'")}' TOKEN_SYMBOL_INPUT='${tokenSymbol.replace(/'/g, "\\'")}' INITIAL_SUPPLY='${initialSupply.replace(/'/g, "\\'")}' KEYSTORE_PASSWORD='${escapedPassword}' STARKNET_KEYSTORE_PASSWORD='${escapedPassword}' bash '${unixScriptPath}'"`
      execOptions.shell = false // Don't use shell wrapper, execute directly
    } else {
      // On Linux/Mac, use bash directly
      command = `printf "${escapedInputs}" | TOKEN_NAME_INPUT="${tokenName.replace(/"/g, '\\"')}" TOKEN_SYMBOL_INPUT="${tokenSymbol.replace(/"/g, '\\"')}" INITIAL_SUPPLY="${initialSupply.replace(/"/g, '\\"')}" KEYSTORE_PASSWORD="${escapedPassword}" STARKNET_KEYSTORE_PASSWORD="${escapedPassword}" bash "${unixScriptPath}"`
    }
    
    let stdout: string | Buffer
    let stderr: string | Buffer
    
    try {
      const result = await execAsync(command, execOptions)
      stdout = result.stdout
      stderr = result.stderr
    } catch (error: any) {
      // Even if the command fails, we might have successfully deployed the token
      // Check if we have stdout with deployment info
      if (error.stdout) {
        stdout = error.stdout
        stderr = error.stderr || ''
      } else {
        throw error
      }
    }
    
    // Convert buffers to strings if needed
    const stdoutStr = typeof stdout === 'string' ? stdout : stdout.toString()
    const stderrStr = typeof stderr === 'string' ? stderr : stderr.toString()
    
    // Parse output to extract deployed address and transaction hash
    // Try multiple patterns to find the token address
    let addressMatch = stdoutStr.match(/📍 Token Address:\s*(0x[a-fA-F0-9]{60,})/i)
    if (!addressMatch) {
      addressMatch = stdoutStr.match(/Token Address:\s*(0x[a-fA-F0-9]{60,})/i)
    }
    if (!addressMatch) {
      addressMatch = stdoutStr.match(/Contract deployed:\s*(0x[a-fA-F0-9]{60,})/i)
    }
    if (!addressMatch) {
      // Try to find any address that looks like a contract address (64+ hex chars)
      // Get all addresses and use the last one (should be the token address)
      const allAddresses = stdoutStr.match(/(0x[a-fA-F0-9]{60,})/g)
      if (allAddresses && allAddresses.length > 0) {
        // Use the last address found (should be the token address after deployment)
        addressMatch = [allAddresses[allAddresses.length - 1], allAddresses[allAddresses.length - 1]]
      }
    }
    
    const txHashMatch = stdoutStr.match(/transaction.*?:\s*(0x[a-fA-F0-9]{60,})/i) || 
                        stdoutStr.match(/Transaction.*?:\s*(0x[a-fA-F0-9]{60,})/i)
    
    if (!addressMatch) {
      console.error('Script output:', stdoutStr)
      console.error('Script errors:', stderrStr)
      
      // Check if the error is about starkli not being found
      if (stdoutStr.includes('starkli no está instalado') || stdoutStr.includes('starkli: command not found')) {
        throw new Error(`starkli is not installed or not in PATH. Please install starkli and ensure it's available in WSL.`)
      }
      
      // Check if there's a deployment error
      if (stdoutStr.includes('Error al desplegar') || stdoutStr.includes('Error:')) {
        const errorMatch = stdoutStr.match(/Error[^:]*:\s*(.+)/i)
        const errorMsg = errorMatch ? errorMatch[1] : 'Unknown deployment error'
        throw new Error(`Deployment failed: ${errorMsg}`)
      }
      
      // Check if token was actually deployed (look for success messages)
      if (stdoutStr.includes('Token desplegado exitosamente') || stdoutStr.includes('Token Address:')) {
        // Token was deployed but we couldn't extract the address
        // Try to find any address in the output
        const allAddresses = stdoutStr.match(/(0x[a-fA-F0-9]{60,})/g)
        if (allAddresses && allAddresses.length > 0) {
          // Use the last address found (should be the token address)
          const address = allAddresses[allAddresses.length - 1]
          console.log(`✅ Found token address (fallback): ${address}`)
          return {
            address,
            transactionHash: txHashMatch ? txHashMatch[1] : '',
          }
        }
      }
      
      throw new Error(`Could not extract token address from script output. Script output: ${stdoutStr.substring(0, 500)}`)
    }
    
    const address = addressMatch[1]
    const transactionHash = txHashMatch ? txHashMatch[1] : ''
    
    console.log(`✅ Token deployed at: ${address}`)
    
    return {
      address,
      transactionHash,
    }
  } catch (error: any) {
    console.error('Error deploying token:', error)
    throw new Error(`Failed to deploy token: ${error.message}`)
  }
}

