import sqlite3 from 'sqlite3'
import { promisify } from 'util'
import path from 'path'

interface Token {
  address: string
  name: string
  symbol: string
  creator: string
  createdAt: string
}

class Database {
  private db: sqlite3.Database

  constructor() {
    const dbPath = path.join(__dirname, '../../data/tokens.db')
    const dbDir = path.dirname(dbPath)
    
    // Ensure data directory exists
    const fs = require('fs')
    if (!fs.existsSync(dbDir)) {
      fs.mkdirSync(dbDir, { recursive: true })
    }
    
    this.db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Error opening database:', err)
      } else {
        console.log('✅ Connected to SQLite database')
        this.initTables()
      }
    })
  }

  private initTables() {
    const createTable = `
      CREATE TABLE IF NOT EXISTS tokens (
        address TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        creator TEXT,
        created_at TEXT NOT NULL
      )
    `

    this.db.run(createTable, (err) => {
      if (err) {
        console.error('Error creating table:', err)
      } else {
        console.log('✅ Tokens table ready')
      }
    })
  }

  async saveToken(token: Token): Promise<void> {
    return new Promise((resolve, reject) => {
      const query = `
        INSERT OR REPLACE INTO tokens (address, name, symbol, creator, created_at)
        VALUES (?, ?, ?, ?, ?)
      `
      this.db.run(
        query,
        [token.address, token.name, token.symbol, token.creator, token.createdAt],
        (err) => {
          if (err) reject(err)
          else resolve()
        }
      )
    })
  }

  async getTokenByAddress(address: string): Promise<Token | null> {
    return new Promise((resolve, reject) => {
      const query = 'SELECT * FROM tokens WHERE address = ?'
      this.db.get(query, [address], (err, row: any) => {
        if (err) reject(err)
        else resolve(row || null)
      })
    })
  }

  async getAllTokens(): Promise<Token[]> {
    return new Promise((resolve, reject) => {
      const query = 'SELECT * FROM tokens ORDER BY created_at DESC'
      this.db.all(query, [], (err, rows: any[]) => {
        if (err) reject(err)
        else resolve(rows || [])
      })
    })
  }

  async getTokensByCreator(creator: string): Promise<Token[]> {
    return new Promise((resolve, reject) => {
      const query = 'SELECT * FROM tokens WHERE creator = ? ORDER BY created_at DESC'
      this.db.all(query, [creator], (err, rows: any[]) => {
        if (err) reject(err)
        else resolve(rows || [])
      })
    })
  }

  close() {
    return new Promise<void>((resolve, reject) => {
      this.db.close((err) => {
        if (err) reject(err)
        else resolve()
      })
    })
  }
}

export const db = new Database()

