import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import { tokenMonitor } from './services/tokenMonitor'
import { tokenRoutes } from './routes/tokens'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3001

// Middleware
app.use(cors())
app.use(express.json())

// Routes
app.use('/api', tokenRoutes)

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Backend server running on port ${PORT}`)
  
  // Start token monitor
  tokenMonitor.start()
})

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully')
  tokenMonitor.stop()
  process.exit(0)
})

