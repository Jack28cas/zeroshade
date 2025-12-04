# ZumpFun Frontend

Frontend Next.js para la plataforma ZumpFun - Pump.fun privado en Starknet.

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env.local
# Editar .env.local con tus valores

# Ejecutar en desarrollo
npm run dev
```

Abre [http://localhost:3000](http://localhost:3000) en tu navegador.

## 📋 Requisitos

- Node.js 18+
- npm o yarn
- Wallet de Starknet (ArgentX, Braavos, etc.)

## 🛠️ Scripts

- `npm run dev` - Desarrollo
- `npm run build` - Build de producción
- `npm start` - Ejecutar build de producción
- `npm run lint` - Linter
- `npm run type-check` - Verificar tipos TypeScript

## 📁 Estructura

```
frontend/
├── src/
│   ├── app/              # Next.js App Router
│   │   ├── layout.tsx     # Layout principal
│   │   ├── page.tsx       # Página principal
│   │   └── globals.css    # Estilos globales
│   ├── components/       # Componentes React
│   │   ├── WalletButton.tsx
│   │   ├── CreateTokenSection.tsx
│   │   ├── TradingSection.tsx
│   │   └── TokenList.tsx
│   ├── contexts/         # Contextos React
│   │   └── WalletContext.tsx
│   └── lib/              # Utilidades
│       ├── constants.ts
│       └── starknet.ts
└── public/              # Archivos estáticos
```

## 🔧 Configuración

### Variables de Entorno

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_NETWORK=sepolia
```

## 📝 Notas

- El frontend usa `get-starknet` para conexión de wallet
- Todos los valores se manejan con 6 decimales
- Las transacciones esperan confirmación antes de continuar

