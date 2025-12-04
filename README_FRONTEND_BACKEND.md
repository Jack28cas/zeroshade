# 🚀 Frontend y Backend - ZumpFun

## 📁 Estructura del Proyecto

```
zeroshade/
├── frontend/          # Next.js Frontend
│   ├── src/
│   │   ├── app/       # Next.js App Router
│   │   ├── components/ # Componentes React
│   │   ├── contexts/  # Contextos (Wallet)
│   │   └── lib/       # Utilidades y constantes
│   └── package.json
│
└── backend/           # Node.js/Express Backend
    ├── src/
    │   ├── routes/    # API Routes
    │   ├── services/  # Servicios (Token Monitor)
    │   ├── db/        # Base de datos
    │   └── config/    # Configuración
    └── package.json
```

## 🎨 Frontend (Next.js 14)

### Características

- ✅ **Next.js 14** con App Router
- ✅ **TypeScript** para type safety
- ✅ **Tailwind CSS** para estilos
- ✅ **get-starknet** para conexión de wallet
- ✅ **starknet.js** para interacción con contratos
- ✅ **React Hook Form** para formularios
- ✅ **UI moderna y responsive**

### Instalación

```bash
cd frontend
npm install
```

### Configuración

Crea un archivo `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_NETWORK=sepolia
```

### Ejecutar

```bash
npm run dev
```

El frontend estará disponible en `http://localhost:3000`

## 🔧 Backend (Node.js/Express)

### Características

- ✅ **Express.js** para API REST
- ✅ **SQLite** para base de datos
- ✅ **starknet.js** para monitoreo de contratos
- ✅ **Monitoreo automático** de tokens creados
- ✅ **API REST** para frontend

### Instalación

```bash
cd backend
npm install
```

### Configuración

Crea un archivo `.env`:

```env
PORT=3001
RPC_URL=https://starknet-sepolia-rpc.publicnode.com
NODE_ENV=development
```

### Ejecutar

```bash
# Desarrollo
npm run dev

# Producción
npm run build
npm start
```

El backend estará disponible en `http://localhost:3001`

## 📋 Funcionalidades Implementadas

### Frontend

#### Sección 1: Crear Token
- ✅ Formulario para crear token (name, symbol, initial_supply)
- ✅ Integración con TokenFactory contract
- ✅ Formulario para lanzar token en Launchpad
- ✅ Validación de inputs
- ✅ Manejo de errores y estados de carga

#### Sección 2: Comprar/Vender
- ✅ Lista de tokens disponibles (desde backend)
- ✅ Información del token (precio, liquidez, balance)
- ✅ Formulario para comprar tokens
- ✅ Formulario para vender tokens
- ✅ Aprobación de tokens antes de vender
- ✅ Actualización automática de información

### Backend

#### Monitoreo de Tokens
- ✅ Escaneo automático de TokenFactory
- ✅ Detección de nuevos tokens
- ✅ Obtención de información (name, symbol)
- ✅ Almacenamiento en SQLite
- ✅ API REST para consultar tokens

#### API Endpoints

- `GET /api/tokens` - Obtener todos los tokens
- `GET /api/tokens/:address` - Obtener token por dirección
- `GET /api/tokens/creator/:creator` - Obtener tokens por creador
- `GET /health` - Health check

## 🔌 Integración con Contratos

### Direcciones de Contratos (Starknet Sepolia)

```typescript
TOKEN_FACTORY: '0x0755306b285a57fd4568b27bd77afed16c671b8896de6ed76542b5e6ba6b95e5'
LAUNCHPAD: '0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf'
TOKEN: '0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960'
```

### Funciones Implementadas

#### TokenFactory
- `create_token(name, symbol, initial_supply)` ✅
- `get_token_count()` ✅
- `get_token_at(index)` ✅

#### Launchpad
- `launch_token(token_address, initial_price, k, n, fee_rate)` ✅
- `buy_tokens(token_address, eth_amount)` ✅
- `sell_tokens(token_address, token_amount)` ✅
- `get_price(token_address)` ✅
- `get_launch_info(token_address)` ✅
- `get_liquidity(token_address)` ✅

#### Token
- `approve(spender, amount)` ✅
- `balance_of(account)` ✅
- `name()` ✅
- `symbol()` ✅

## 🎯 Flujo de Uso

### 1. Crear Token

1. Usuario conecta wallet
2. Ingresa name, symbol, initial_supply
3. Frontend llama a `TokenFactory.create_token()`
4. Token se crea y se muestra dirección
5. Usuario puede lanzarlo en Launchpad

### 2. Lanzar Token

1. Usuario ingresa parámetros (initial_price, k, n, fee_rate)
2. Frontend llama a `Launchpad.launch_token()`
3. Token queda disponible para trading

### 3. Comprar Tokens

1. Usuario selecciona token de la lista
2. Ve información (precio, liquidez, balance)
3. Ingresa cantidad a comprar
4. Frontend llama a `Launchpad.buy_tokens()`
5. Recibe tokens automáticamente

### 4. Vender Tokens

1. Usuario selecciona token que posee
2. Aproba tokens para Launchpad
3. Ingresa cantidad a vender
4. Frontend llama a `Launchpad.sell_tokens()`
5. Recibe ETH automáticamente

## 📝 Notas Importantes

### Decimales

- **Todos los tokens usan 6 decimales** (hardcoded en el contrato)
- Los valores deben escalarse: `value * 1_000_000`
- El frontend maneja esto automáticamente

### Conversión de Strings a felt252

El frontend usa una conversión simple. En producción, deberías usar:
- Hash real (Poseidon, Pedersen, etc.)
- O usar una librería de conversión

### TokenFactory Deployment

El contrato TokenFactory actualmente tiene un TODO para el despliegue real. En producción necesitarías:
- Universal Deployer Contract (UDC)
- O implementar `deploy_contract_syscall` correctamente

## 🚀 Próximos Pasos

1. ✅ Frontend básico implementado
2. ✅ Backend de monitoreo implementado
3. ⏳ Mejorar UI/UX
4. ⏳ Agregar más validaciones
5. ⏳ Implementar monitoreo de eventos en tiempo real
6. ⏳ Agregar tests
7. ⏳ Optimizar para producción

## 📦 Dependencias Principales

### Frontend
- `next`: ^14.0.4
- `react`: ^18.2.0
- `get-starknet-core`: ^3.2.0
- `starknet`: ^6.2.0
- `tailwindcss`: ^3.4.0

### Backend
- `express`: ^4.18.2
- `starknet`: ^6.2.0
- `sqlite3`: ^5.1.6

---

**¡Código limpio y listo para la hackathon!** 🎉

