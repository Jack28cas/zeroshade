# ZeroShade Frontend

A modern Next.js frontend for the ZeroShade token launchpad platform, providing an intuitive interface for creating, launching, and trading tokens on Starknet.

## Features

- **Wallet Integration**: Seamless connection with Starknet wallets (ArgentX, Braavos)
- **Token Creation**: Deploy new tokens with custom names and symbols
- **Token Discovery**: Browse all tokens deployed on the platform
- **Trading Interface**: Buy and sell tokens with real-time price updates
- **Balance Management**: View and manage your token and payment token balances
- **Transaction Status**: Real-time transaction tracking and confirmation

## Tech Stack

- **Next.js 14** - React framework with App Router
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **starknet.js** - Starknet blockchain interaction
- **get-starknet** - Wallet connection library

## Getting Started

### Prerequisites

- Node.js 18 or higher
- npm or yarn package manager
- A Starknet wallet (ArgentX or Braavos) installed in your browser

### Installation

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The application will be available at `http://localhost:3000`

### Environment Variables

Create a `.env.local` file in the frontend directory (optional, defaults are provided):

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_NETWORK=sepolia
```

## Project Structure

```
frontend/
├── src/
│   ├── app/
│   │   ├── layout.tsx           # Root layout with providers
│   │   ├── page.tsx             # Main page component
│   │   └── globals.css          # Global styles
│   ├── components/
│   │   ├── WalletButton.tsx     # Wallet connection button
│   │   ├── CreateTokenSection.tsx  # Token creation form
│   │   ├── TradingSection.tsx   # Buy/sell interface
│   │   └── TokenList.tsx        # Token discovery list
│   ├── contexts/
│   │   └── WalletContext.tsx    # Wallet state management
│   └── lib/
│       ├── constants.ts          # Contract addresses and config
│       └── starknet.ts          # Starknet utilities and ABIs
├── public/                       # Static assets
└── package.json
```

## Key Components

### WalletButton

Handles wallet connection and account display. Automatically detects installed wallets and provides connection UI.

### CreateTokenSection

Token creation interface that:
- Collects token name and symbol
- Handles felt252 encoding for contract parameters
- Deploys tokens via TokenFactory
- Provides transaction status feedback

### TradingSection

Trading interface featuring:
- Token selection and price display
- Buy/sell amount inputs
- Payment token balance display
- Approval handling for payment tokens
- Real-time price updates from Launchpad contract

### TokenList

Displays all tokens indexed by the backend:
- Token metadata (name, symbol, creator)
- Links to token details
- Refresh functionality

## Contract Integration

### Contract Addresses

All contract addresses are defined in `src/lib/constants.ts`:

```typescript
export const CONTRACTS = {
  TOKEN_FACTORY: '0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98',
  LAUNCHPAD: '0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b',
  PAUSABLE_ERC20: '0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778',
}
```

### ABI Definitions

Contract ABIs are defined in `src/lib/starknet.ts`:
- `TOKEN_ABI` - Token contract interface
- `TOKEN_FACTORY_ABI` - TokenFactory interface
- `LAUNCHPAD_ABI` - Launchpad interface
- `PAUSABLE_ERC20_ABI` - Payment token interface

## Usage Flow

### Creating a Token

1. Connect your wallet
2. Navigate to "Create Token" section
3. Enter token name and symbol
4. Click "Create Token"
5. Approve transaction in wallet
6. Wait for deployment confirmation
7. Token address will be displayed

### Buying Tokens

1. Select a token from the list
2. Navigate to "Trading" section
3. Enter amount of payment tokens to spend
4. Click "Approve" if needed (first time only)
5. Click "Buy Tokens"
6. Approve transaction in wallet
7. Tokens will be minted to your address

### Selling Tokens

1. Select a token you own
2. Navigate to "Trading" section
3. Enter amount of tokens to sell
4. Click "Approve Tokens" (first time only)
5. Click "Sell Tokens"
6. Approve transaction in wallet
7. Payment tokens will be returned to your address

## API Integration

The frontend communicates with the backend API for:
- Token discovery (`GET /api/tokens`)
- Token metadata refresh (`GET /api/tokens/:address/refresh`)

API base URL is configurable via `NEXT_PUBLIC_API_URL` environment variable.

## Data Format Handling

### felt252 Encoding

Token names and symbols are converted to felt252 format:
- Numeric strings are parsed directly
- Text strings are converted using `starknet.js` utilities

### u256 Handling

All amounts are handled as u256 (low, high):
- Frontend displays human-readable amounts
- Contract calls use low/high format
- Decimals are handled (6 decimals for all tokens)

## Styling

The project uses Tailwind CSS for styling. Key design principles:
- Responsive design for mobile and desktop
- Dark mode support (via system preference)
- Consistent spacing and typography
- Accessible color contrasts

## Development

### Available Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm start            # Start production server
npm run lint         # Run ESLint
npm run type-check   # TypeScript type checking
```

### Code Style

- Use TypeScript for all new files
- Follow React best practices (hooks, functional components)
- Use Tailwind utility classes for styling
- Keep components focused and reusable

## Troubleshooting

### Wallet Connection Issues

- Ensure wallet extension is installed and unlocked
- Check that you're on the correct network (Sepolia)
- Try refreshing the page and reconnecting

### Transaction Failures

- Verify you have sufficient balance for gas fees
- Check payment token balance for buy operations
- Ensure token approval is completed before trading
- Verify contract addresses are correct

### API Connection Errors

- Ensure backend is running on the configured port
- Check CORS settings if accessing from different origin
- Verify API URL in environment variables

## Browser Support

- Chrome/Edge (recommended)
- Firefox
- Brave

Wallet extensions may have additional browser requirements.

## Performance Considerations

- Token list is loaded from backend API (not on-chain)
- Price queries are made on-demand
- Wallet connection state is cached in context
- Transaction status is polled until confirmed

## Security Notes

- Never commit private keys or sensitive data
- Always verify contract addresses before transactions
- Use testnet for development and testing
- Review transaction details in wallet before approving

## Future Enhancements

Potential improvements:
- Token search and filtering
- Price charts and historical data
- Portfolio tracking
- Transaction history
- Multi-wallet support
- Mobile app version

## License

MIT
