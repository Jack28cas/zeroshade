# ZeroShade Backend

A Node.js/Express backend service for monitoring and indexing tokens deployed on the ZeroShade platform. Provides a REST API for token discovery and metadata management.

## Features

- **Automatic Token Monitoring**: Scans TokenFactory contract for new token deployments
- **Token Indexing**: Stores token metadata in SQLite database
- **REST API**: Provides endpoints for token discovery and querying
- **Metadata Parsing**: Handles felt252 and u256 data types from contracts
- **Real-time Updates**: Continuously monitors blockchain for new tokens

## Tech Stack

- **Node.js** - Runtime environment
- **Express** - Web framework
- **TypeScript** - Type-safe development
- **starknet.js** - Starknet blockchain interaction
- **SQLite** - Lightweight database for token storage
- **tsx** - TypeScript execution

## Getting Started

### Prerequisites

- Node.js 18 or higher
- npm or yarn package manager
- Access to Starknet Sepolia RPC endpoint

### Installation

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start development server
npm run dev
```

The API will be available at `http://localhost:3001`

### Environment Variables

Create a `.env` file in the backend directory (optional, defaults are provided):

```env
PORT=3001
RPC_URL=https://starknet-sepolia-rpc.publicnode.com
NODE_ENV=development
```

## Project Structure

```
backend/
├── src/
│   ├── index.ts              # Application entry point
│   ├── routes/
│   │   └── tokens.ts         # Token API routes
│   ├── services/
│   │   └── tokenMonitor.ts   # Token monitoring service
│   ├── db/
│   │   └── database.ts       # SQLite database setup
│   ├── config/
│   │   └── constants.ts      # Contract addresses and config
│   └── abis/
│       ├── tokenFactory.ts   # TokenFactory ABI
│       └── token.ts           # Token ABI
├── data/                      # SQLite database files (generated)
└── package.json
```

## API Endpoints

### GET /api/tokens

Retrieves all tokens indexed in the database.

**Response:**
```json
[
  {
    "address": "0x0001be7154d1142684a8585e44c5efbe6ad98dc6fb70a70ef4c1de5cd03d1738",
    "name": "My Token",
    "symbol": "MTK",
    "creator": "0xb6d3f96ebc06732b5c549baa71e9eede25f432b805b98de2b351e82223c586",
    "createdAt": "2024-12-04T12:00:00.000Z"
  }
]
```

### GET /api/tokens/:address

Retrieves a specific token by its contract address.

**Parameters:**
- `address` - Token contract address (hex string)

**Response:**
```json
{
  "address": "0x0001be7154d1142684a8585e44c5efbe6ad98dc6fb70a70ef4c1de5cd03d1738",
  "name": "My Token",
  "symbol": "MTK",
  "creator": "0xb6d3f96ebc06732b5c549baa71e9eede25f432b805b98de2b351e82223c586",
  "createdAt": "2024-12-04T12:00:00.000Z"
}
```

### GET /api/tokens/creator/:creator

Retrieves all tokens created by a specific address.

**Parameters:**
- `creator` - Creator address (hex string)

**Response:** Array of token objects (same format as `/api/tokens`)

### GET /api/tokens/:address/refresh

Forces a refresh of token metadata from the blockchain.

**Parameters:**
- `address` - Token contract address (hex string)

**Response:** Updated token object

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-04T12:00:00.000Z"
}
```

## Token Monitoring

The backend includes an automatic token monitoring service that:

1. **Scans TokenFactory**: Queries the `token_count` function every 30 seconds
2. **Detects New Tokens**: Compares current count with stored count
3. **Fetches Token Data**: Retrieves name, symbol, and creator for each new token
4. **Stores in Database**: Saves token metadata to SQLite
5. **Handles Errors**: Gracefully handles missing contracts (e.g., simulated tokens at 0x0)

### Monitoring Configuration

The monitoring interval and contract addresses are configured in:
- `src/services/tokenMonitor.ts` - Monitoring logic
- `src/config/constants.ts` - Contract addresses

## Database Schema

The SQLite database uses the following schema:

```sql
CREATE TABLE tokens (
  address TEXT PRIMARY KEY,
  name TEXT,
  symbol TEXT,
  creator TEXT,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

The database file is created automatically at `data/tokens.db` on first run.

## Data Type Handling

### felt252 Parsing

Token names and symbols are returned as felt252 from contracts. The service handles various formats:
- BigInt values
- String representations
- Objects with `value`, `low`, or `high` properties

The `parseFelt252` utility function normalizes these formats to readable strings.

### u256 Handling

Supply and balance values are handled as u256 (low, high). The service converts these to BigInt for JavaScript compatibility.

## Error Handling

The service includes robust error handling:

- **Contract Not Found**: Skips tokens at invalid addresses (e.g., 0x0)
- **RPC Errors**: Logs errors but continues monitoring
- **Database Errors**: Handles constraint violations gracefully
- **Network Issues**: Retries on transient failures

## Development

### Available Scripts

```bash
npm run dev          # Start development server with hot reload
npm run build        # Compile TypeScript to JavaScript
npm start            # Start production server
npm run lint         # Run ESLint
```

### Adding New Endpoints

1. Create route handler in `src/routes/`
2. Import and register in `src/index.ts`
3. Add TypeScript types for request/response
4. Update this README with endpoint documentation

### Database Management

The database is automatically initialized on startup. To reset:

```bash
# Delete database file
rm data/tokens.db

# Restart server (database will be recreated)
npm run dev
```

## Configuration

### Contract Addresses

Update contract addresses in `src/config/constants.ts`:

```typescript
export const CONTRACTS = {
  TOKEN_FACTORY: '0x07ee147bfd2037bcbfe96196689a3ba52e47271a7c5517880ed0f6c88d218c98',
  LAUNCHPAD: '0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b',
  PAUSABLE_ERC20: '0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778',
}
```

### RPC Configuration

The RPC endpoint can be configured via:
- Environment variable: `RPC_URL`
- Default: `https://starknet-sepolia-rpc.publicnode.com`

## Monitoring and Logging

The service logs important events:

- Token count changes
- New token discoveries
- Database operations
- Error conditions
- API requests

Logs are output to console in development. For production, consider integrating a logging service.

## Performance Considerations

- **Polling Interval**: 30 seconds balances responsiveness with RPC rate limits
- **Database Queries**: Indexed by address for fast lookups
- **RPC Calls**: Batched where possible to reduce network overhead
- **Error Recovery**: Continues operation even if individual token fetches fail

## Security Considerations

- **Input Validation**: All address inputs are validated
- **SQL Injection**: Uses parameterized queries
- **CORS**: Configure CORS appropriately for production
- **Rate Limiting**: Consider adding rate limiting for production use

## Troubleshooting

### Database Lock Errors

If you encounter database lock errors:
- Ensure only one instance of the server is running
- Check file permissions on `data/tokens.db`
- Verify SQLite is properly installed

### RPC Connection Issues

If RPC calls fail:
- Verify RPC endpoint is accessible
- Check network connectivity
- Consider using a different RPC provider
- Review rate limiting on RPC endpoint

### Missing Tokens

If tokens aren't being detected:
- Verify TokenFactory address is correct
- Check RPC endpoint is returning correct data
- Review logs for error messages
- Ensure monitoring service is running

## Production Deployment

For production deployment:

1. Set `NODE_ENV=production`
2. Configure proper RPC endpoint
3. Set up process manager (PM2, systemd, etc.)
4. Configure logging service
5. Set up database backups
6. Add rate limiting and security headers
7. Configure CORS for frontend domain

## Future Enhancements

Potential improvements:
- WebSocket support for real-time updates
- Token price tracking from Launchpad
- Historical data and analytics
- GraphQL API option
- Multi-chain support
- Caching layer for improved performance

## License

MIT
