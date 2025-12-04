# ZumpFun Backend

Backend Node.js/Express para monitorear tokens de ZumpFun en Starknet.

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus valores

# Ejecutar en desarrollo
npm run dev
```

El servidor estará disponible en `http://localhost:3001`

## 📋 Requisitos

- Node.js 18+
- npm o yarn

## 🛠️ Scripts

- `npm run dev` - Desarrollo con hot reload
- `npm run build` - Compilar TypeScript
- `npm start` - Ejecutar build de producción
- `npm run lint` - Linter

## 📁 Estructura

```
backend/
├── src/
│   ├── index.ts          # Entry point
│   ├── routes/           # API Routes
│   │   └── tokens.ts
│   ├── services/         # Servicios
│   │   └── tokenMonitor.ts
│   ├── db/              # Base de datos
│   │   └── database.ts
│   ├── config/          # Configuración
│   │   └── constants.ts
│   └── abis/            # ABIs de contratos
│       ├── tokenFactory.ts
│       └── token.ts
└── data/                # SQLite database (generado)
```

## 🔧 Configuración

### Variables de Entorno

```env
PORT=3001
RPC_URL=https://starknet-sepolia-rpc.publicnode.com
NODE_ENV=development
```

## 📡 API Endpoints

### GET /api/tokens
Obtiene todos los tokens registrados.

**Response:**
```json
[
  {
    "address": "0x...",
    "name": "Token Name",
    "symbol": "TKN",
    "creator": "0x...",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

### GET /api/tokens/:address
Obtiene un token por su dirección.

### GET /api/tokens/creator/:creator
Obtiene tokens creados por una dirección específica.

### GET /health
Health check del servidor.

## 🔍 Monitoreo

El backend monitorea automáticamente el contrato TokenFactory cada 30 segundos para detectar nuevos tokens. Los tokens encontrados se guardan en SQLite.

## 📝 Notas

- La base de datos SQLite se crea automáticamente en `data/tokens.db`
- El monitoreo se inicia automáticamente al iniciar el servidor
- Los tokens se indexan por dirección (único)

