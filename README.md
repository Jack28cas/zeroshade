# ZeroShade

A decentralized token launchpad platform on Starknet, inspired by Pump.fun, featuring bonding curve mechanics and a seamless token creation experience.

## Overview

ZeroShade enables users to create, launch, and trade meme tokens on Starknet with an automated bonding curve pricing mechanism. The platform uses a custom payment token (PausableERC20) for all transactions, providing a unified trading experience.

## Features

- **Token Creation**: Deploy custom ERC20-like tokens with 6 decimals
- **Bonding Curve Trading**: Automated price discovery through mathematical curves
- **Payment Token Integration**: Unified payment system using PausableERC20
- **Token Factory**: Simplified token deployment workflow
- **Launchpad Management**: Centralized platform for token launches
- **Real-time Monitoring**: Backend service tracks all deployed tokens
- **Web Interface**: Next.js frontend for seamless user interaction

## Architecture

### Smart Contracts

The platform consists of four main contracts:

1. **TokenFactory** - Creates and manages token deployments
2. **Token** - ERC20-like token contract with mint/burn capabilities
3. **Launchpad** - Manages token launches and bonding curve mechanics
4. **PausableERC20** - Payment token used for buying/selling memecoins

### Security Model

- **Mint/Burn Restrictions**: Only the Launchpad contract can mint or burn tokens
- **Owner Protection**: Token owners cannot mint tokens to prevent inflation
- **Zero Initial Supply**: Tokens start with zero supply and are minted on-demand
- **Launchpad Configuration**: Tokens must be explicitly linked to the Launchpad

## Deployed Contracts (Starknet Sepolia)

### TokenFactory
- **Address**: `0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98`
- **Purpose**: Token creation and deployment management
- **Status**: Active

### Launchpad
- **Address**: `0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b`
- **Purpose**: Token launches, bonding curve pricing, buy/sell operations
- **Payment Token**: Uses PausableERC20 for all transactions
- **Status**: Active

### PausableERC20
- **Address**: `0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778`
- **Purpose**: Payment token for purchasing memecoins
- **Decimals**: 6
- **Status**: Active

### Token (Class Hash)
- **Class Hash**: `0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960`
- **Purpose**: Template for individual token deployments
- **Status**: Declared, ready for deployment

## Getting Started

### Prerequisites

- **Scarb** 2.9.2+ (Cairo build tool)
- **Starkli** (Starknet CLI)
- **Node.js** 18+ (for frontend/backend)
- **Git**

### Installation

```bash
# Clone the repository
git clone https://github.com/Jack28cas/zeroshade.git
cd zeroshade

# Compile contracts
scarb build

# Install frontend dependencies
cd frontend
npm install

# Install backend dependencies
cd ../backend
npm install
```

### Configuration

Set up your Starknet account and environment variables:

```bash
# Configure Starkli account (if not already done)
starkli account fetch <YOUR_ACCOUNT> --rpc https://starknet-sepolia-rpc.publicnode.com

# Set environment variables
export RPC="https://starknet-sepolia-rpc.publicnode.com"
export ACCOUNT="~/.starkli/accounts/sepolia/my.json"
export KEYSTORE="~/.starkli/keystores/my_keystore.json"
```

## Project Structure

```
zeroshade/
├── src/
│   ├── contracts/
│   │   ├── token.cairo              # Token contract (ERC20-like)
│   │   ├── token_factory.cairo       # Token factory
│   │   ├── launchpad.cairo           # Launchpad with bonding curve
│   │   └── PausableERC20.cairo       # Payment token
│   └── lib.cairo
├── scripts/
│   ├── declare_*.sh                  # Contract declaration scripts
│   ├── deploy_*.sh                   # Deployment scripts
│   ├── mint_pausable_erc20.sh        # Mint payment tokens
│   └── set_launchpad.sh              # Configure token launchpad
├── frontend/                         # Next.js frontend
│   ├── src/
│   │   ├── components/               # React components
│   │   ├── lib/                      # Utilities and constants
│   │   └── contexts/                 # React contexts
│   └── package.json
├── backend/                          # Node.js/Express backend
│   ├── src/
│   │   ├── routes/                   # API routes
│   │   ├── services/                 # Business logic
│   │   └── config/                   # Configuration
│   └── package.json
└── Scarb.toml                        # Cairo project config
```

## Usage

### Creating a Token

1. **Deploy Token Contract**:
   ```bash
   ./scripts/deploy_token.sh
   # Follow prompts for name, symbol, and initial supply
   ```

2. **Set Launchpad** (required for minting):
   ```bash
   ./scripts/set_launchpad.sh
   # Enter token address and launchpad address
   ```

3. **Launch Token on Launchpad**:
   ```bash
   starkli invoke 0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b \
     launch_token \
     --account "$ACCOUNT" \
     --keystore "$KEYSTORE" \
     --rpc "$RPC" \
     <TOKEN_ADDRESS> \
     <INITIAL_PRICE_LOW> <INITIAL_PRICE_HIGH> \
     <K_LOW> <K_HIGH> \
     <N_LOW> <N_HIGH> \
     <FEE_RATE>
   ```

### Trading Tokens

**Buy Tokens**:
```bash
# First, approve PausableERC20 spending
starkli invoke 0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778 \
  approve \
  --account "$ACCOUNT" \
  --keystore "$KEYSTORE" \
  --rpc "$RPC" \
  0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b \
  <AMOUNT_LOW> <AMOUNT_HIGH>

# Then buy tokens
starkli invoke 0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b \
  buy_tokens \
  --account "$ACCOUNT" \
  --keystore "$KEYSTORE" \
  --rpc "$RPC" \
  <TOKEN_ADDRESS> \
  <PAYMENT_AMOUNT_LOW> <PAYMENT_AMOUNT_HIGH>
```

**Sell Tokens**:
```bash
# Approve token spending
starkli invoke <TOKEN_ADDRESS> \
  approve \
  --account "$ACCOUNT" \
  --keystore "$KEYSTORE" \
  --rpc "$RPC" \
  0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b \
  <TOKEN_AMOUNT_LOW> <TOKEN_AMOUNT_HIGH>

# Sell tokens
starkli invoke 0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b \
  sell_tokens \
  --account "$ACCOUNT" \
  --keystore "$KEYSTORE" \
  --rpc "$RPC" \
  <TOKEN_ADDRESS> \
  <TOKEN_AMOUNT_LOW> <TOKEN_AMOUNT_HIGH>
```

### Minting Payment Tokens

To mint PausableERC20 tokens (for testing or initial liquidity):

```bash
./scripts/mint_pausable_erc20.sh
# Enter amount (e.g., 100000 for 100,000 USDC)
```

## Development

### Compiling Contracts

```bash
scarb build
```

### Formatting Code

```bash
scarb fmt
```

### Running Frontend

```bash
cd frontend
npm run dev
```

The frontend will be available at `http://localhost:3000`

### Running Backend

```bash
cd backend
npm run dev
```

The backend API will be available at `http://localhost:3001`

The backend automatically monitors the TokenFactory contract for new token deployments and indexes them in a SQLite database.

## Bonding Curve Mechanics

The Launchpad uses a bonding curve to determine token prices. The price calculation follows:

```
price = initial_price * (total_supply / k)^n
```

Where:
- `initial_price`: Starting price when supply is zero
- `k`: Scaling factor
- `n`: Curve exponent
- `total_supply`: Current token supply

When buying:
- Payment tokens are transferred to the Launchpad
- Tokens are minted based on the current price
- Price increases as supply increases

When selling:
- Tokens are burned
- Payment tokens are returned based on the new (lower) price
- Price decreases as supply decreases

## API Endpoints

The backend provides the following endpoints:

- `GET /api/tokens` - List all tokens
- `GET /api/tokens/:address` - Get token details
- `GET /api/tokens/creator/:creator` - Get tokens by creator
- `GET /api/tokens/:address/refresh` - Refresh token metadata
- `GET /health` - Health check

## Scripts Reference

### Deployment Scripts

- `declare_token.sh` - Declare Token contract
- `declare_launchpad.sh` - Declare Launchpad contract
- `declare_pausable_erc20.sh` - Declare PausableERC20 contract
- `deploy_token.sh` - Deploy a new Token instance
- `deploy_launchpad.sh` - Deploy Launchpad contract
- `deploy_pausable_erc20.sh` - Deploy PausableERC20 contract
- `deploy_all.sh` - Deploy all contracts in sequence

### Utility Scripts

- `mint_pausable_erc20.sh` - Mint payment tokens
- `set_launchpad.sh` - Configure launchpad for a token
- `clean_rebuild.sh` - Clean and rebuild contracts

## Testing

### Contract Testing

```bash
# Using Starknet Foundry (if installed)
snforge test
```

### Manual Testing

Use the provided scripts to deploy and interact with contracts on Sepolia testnet.

## Network Information

- **Network**: Starknet Sepolia Testnet
- **RPC**: `https://starknet-sepolia-rpc.publicnode.com`
- **Chain ID**: `SN_SEPOLIA`

## Troubleshooting

### Contract Declaration Errors

If you encounter "Mismatch compiled class hash" errors:
1. Ensure you're using the correct CASM hash
2. Rebuild contracts: `scarb build`
3. Check the contract hasn't been modified since last declaration

### Frontend Connection Issues

- Ensure the backend is running
- Check wallet is connected to Sepolia
- Verify contract addresses in `frontend/src/lib/constants.ts`

### Backend Monitoring Issues

- Check RPC endpoint is accessible
- Verify TokenFactory address is correct
- Ensure SQLite database has write permissions

## Contributing

Contributions are welcome! Please ensure:
- Code follows existing style conventions
- Contracts are tested before deployment
- Documentation is updated for new features

## License

MIT

## Resources

- [Cairo Documentation](https://cairo-book.github.io/)
- [Starknet Documentation](https://docs.starknet.io/)
- [Starkli Book](https://book.starkli.rs/)
- [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/)
