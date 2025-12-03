# 🏗️ Arquitectura Técnica: ZumpFun

## Visión General

ZumpFun es un launchpad de meme-coins privado que combina:
- **Cairo** para lógica de negocio
- **Noir** para privacidad zero-knowledge
- **Garaga** para funcionalidades avanzadas
- **Ztarknet** como blockchain base

---

## 📐 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (React/Next.js)              │
│  - Launch Interface                                      │
│  - Trading Interface                                     │
│  - Portfolio View                                        │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Backend API (Node.js/Python)                │
│  - REST/GraphQL API                                      │
│  - Event Indexing (Starknet Indexer)                     │
│  - User Management                                       │
│  - Price Aggregation                                     │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Smart Contracts Layer                       │
│                                                          │
│  ┌──────────────────┐  ┌──────────────────┐           │
│  │  Token Contract  │  │ Launchpad       │           │
│  │  (Cairo)         │  │ Contract        │           │
│  │                  │  │ (Cairo)         │           │
│  │  - ERC20-like    │  │ - Bonding Curve │           │
│  │  - Minting       │  │ - Launches      │           │
│  │  - Transfers     │  │ - Liquidity     │           │
│  └────────┬─────────┘  └────────┬─────────┘           │
│           │                     │                       │
│           └──────────┬──────────┘                       │
│                      │                                   │
│           ┌──────────▼──────────┐                       │
│           │  Private Trading    │                       │
│           │  Contract (Noir)   │                       │
│           │  - ZK Proofs        │                       │
│           │  - Privacy Layer    │                       │
│           └──────────┬──────────┘                       │
│                      │                                   │
│           ┌──────────▼──────────┐                       │
│           │  Garaga Integration │                       │
│           │  - Market Making    │                       │
│           │  - Advanced Features│                       │
│           └─────────────────────┘                       │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Ztarknet / Starknet                       │
│  - Transaction Execution                                │
│  - State Management                                     │
│  - Event Emission                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🔐 Contratos Inteligentes

### 1. Token Contract (Cairo)

**Ubicación**: `src/contracts/token.cairo`

**Funcionalidades**:
```cairo
- create_token(name, symbol, initial_supply)
- mint(to, amount)
- transfer(from, to, amount)
- approve(spender, amount)
- transfer_from(from, to, amount)
- get_balance(address)
- get_total_supply()
```

**Storage**:
- `balances: Map<ContractAddress, u256>`
- `allowances: Map<(ContractAddress, ContractAddress), u256>`
- `total_supply: u256`
- `name: felt252`
- `symbol: felt252`
- `decimals: u8`

### 2. Launchpad Contract (Cairo)

**Ubicación**: `src/contracts/launchpad.cairo`

**Funcionalidades**:
```cairo
- launch_token(token_address, initial_price, curve_params)
- buy_tokens(token_address, amount)
- sell_tokens(token_address, amount)
- get_price(token_address) -> u256
- get_liquidity(token_address) -> u256
- get_launch_info(token_address) -> LaunchInfo
```

**Bonding Curve**:
- Formula: `price = initial_price * (1 + supply / k)^n`
- Donde `k` y `n` son parámetros configurables
- Similar a Pump.fun pero con privacidad

**Storage**:
- `launches: Map<ContractAddress, LaunchInfo>`
- `liquidity_pools: Map<ContractAddress, u256>`
- `creator_fees: Map<ContractAddress, u256>`

### 3. Private Trading Contract (Noir)

**Ubicación**: `src/noir/private_trading/`

**Requisitos**:
- Noir 1.0.0-beta.1
- Barretenberg 0.67.0
- Garaga 0.15.5

**Funcionalidades**:
```noir
- private_buy(token_address, amount, zk_proof)
- private_sell(token_address, amount, zk_proof)
- verify_balance(zk_proof) -> bool
- hide_transaction_details()
```

**ZK Proofs**:
- Ocultación de montos
- Ocultación de direcciones
- Validación de balance sin revelar
- Private state transitions

**Flujo de Proof Generation**:
1. Compilar circuito: `nargo compile`
2. Generar witness: `nargo execute witness`
3. Generar proof: `bb prove_ultra_keccak_honk`
4. Generar VK: `bb write_vk_ultra_keccak_honk`
5. Generar calldata: `garaga calldata`
6. Verificar en contrato: `verify_ultra_keccak_honk_proof(calldata)`

### 4. Garaga Integration

**Funcionalidades**:
- Market-making automático
- Price discovery avanzado
- Liquidity optimization
- Advanced trading strategies

---

## 🔄 Flujos Principales

### Flujo 1: Launch de Token

```
1. Usuario crea token (Token Contract)
   └─> Token minted con supply inicial

2. Usuario registra launch (Launchpad Contract)
   └─> Configura bonding curve
   └─> Deposita liquidity inicial

3. Launch activo
   └─> Usuarios pueden comprar/vender
   └─> Precio ajusta según curva
```

### Flujo 2: Trading Privado

```
1. Usuario quiere comprar privadamente
   └─> Genera ZK proof (Noir)
   └─> Proof valida balance sin revelar

2. Private Trading Contract verifica proof
   └─> Ejecuta trade sin revelar detalles
   └─> Actualiza estado privado

3. Event emitido (sin detalles sensibles)
   └─> Backend indexa
   └─> Frontend actualiza UI
```

### Flujo 3: Market Making (Garaga)

```
1. Garaga monitorea precios
   └─> Detecta oportunidades

2. Ejecuta trades automáticos
   └─> Mejora liquidity
   └─> Reduce slippage

3. Optimiza curva de precios
   └─> Mejor experiencia de usuario
```

---

## 🗄️ Estructura de Datos

### LaunchInfo
```cairo
struct LaunchInfo {
    token_address: ContractAddress,
    creator: ContractAddress,  // Oculto en versión privada
    initial_price: u256,
    current_price: u256,
    total_supply: u256,
    liquidity: u256,
    curve_params: CurveParams,
    launch_time: u64,
    status: LaunchStatus,
}
```

### CurveParams
```cairo
struct CurveParams {
    k: u256,  // Constante de curva
    n: u256,  // Exponente
    fee_rate: u256,  // Fee percentage
}
```

---

## 🔒 Privacidad (Noir)

### ZK Proofs Necesarios

1. **Balance Proof**
   - Prueba que tienes balance suficiente
   - Sin revelar el balance exacto
   - Sin revelar la dirección

2. **Trade Proof**
   - Prueba que el trade es válido
   - Ocultación de montos
   - Ocultación de direcciones

3. **Identity Proof**
   - Prueba de identidad sin revelar
   - Para anonymous launches
   - Para creator verification

---

## 📊 Backend Architecture

### API Endpoints

```
GET  /api/tokens              - Lista todos los tokens
GET  /api/tokens/:address     - Info de un token
POST /api/tokens/launch       - Crear nuevo launch
GET  /api/tokens/:address/price - Precio actual

GET  /api/trades              - Historial de trades (públicos)
POST /api/trades/private      - Ejecutar trade privado

GET  /api/user/portfolio      - Portfolio del usuario
GET  /api/user/launches       - Launches del usuario
```

### Event Indexing

- Indexar eventos de contratos
- Mantener estado actualizado
- Cachear precios y datos
- Sincronización con blockchain

---

## 🎨 Frontend Architecture

### Componentes Principales

1. **Launch Interface**
   - Formulario de creación
   - Configuración de curva
   - Preview de parámetros

2. **Trading Interface**
   - Buy/Sell forms
   - Price chart
   - Order book (si aplica)

3. **Portfolio View**
   - Tokens del usuario
   - P&L tracking
   - Trading history

4. **Token Explorer**
   - Lista de tokens
   - Filtros y búsqueda
   - Stats y gráficos

---

## 🧪 Testing Strategy

### Unit Tests
- Cada contrato individualmente
- Funciones específicas
- Edge cases

### Integration Tests
- Interacción entre contratos
- Flujos completos
- Error handling

### Privacy Tests
- Verificar ocultación de datos
- Validar ZK proofs
- Test de privacidad

### End-to-End Tests
- Flujos completos de usuario
- Frontend + Backend + Contracts
- Performance testing

---

## 🚀 Deployment Strategy

### Testnet
1. Deploy contratos a Ztarknet testnet
2. Testing exhaustivo
3. Integration testing

### Mainnet
1. Audit básico (si tiempo lo permite)
2. Deploy gradual
3. Monitoring

---

## 📈 Optimizaciones

### Gas Optimization
- Minimizar storage writes
- Batch operations
- Efficient data structures

### Privacy Optimization
- Minimizar datos en blockchain
- Efficient ZK proofs
- Off-chain computation cuando sea posible

### UX Optimization
- Fast loading
- Real-time updates
- Clear error messages

---

## 🔐 Security Considerations

1. **Reentrancy Protection**
   - Checks-Effects-Interactions pattern
   - Reentrancy guards

2. **Access Control**
   - Owner functions protegidas
   - Role-based access

3. **Input Validation**
   - Validar todos los inputs
   - Bounds checking
   - Overflow protection

4. **Privacy Leaks**
   - No revelar datos en eventos
   - Careful con logs
   - ZK proof validation

---

## 📚 Dependencias

### Cairo Contracts
- Starknet core
- OpenZeppelin (si necesario)

### Noir
- Noir standard library
- ZK proof libraries

### Garaga
- Garaga SDK
- Integration libraries

### Backend
- starknet.py / starknet-rs
- Web3 libraries
- Database (PostgreSQL/MongoDB)

### Frontend
- React/Next.js
- starknet.js
- Web3 wallet integration
- Chart libraries

---

## 🎯 MVP Scope

### Fase 1 (Core)
- ✅ Token creation
- ✅ Basic launchpad
- ✅ Simple bonding curve
- ✅ Public trading

### Fase 2 (Privacy)
- ✅ Private trading (Noir)
- ✅ Identity hiding
- ✅ ZK proofs

### Fase 3 (Advanced)
- ✅ Garaga integration
- ✅ Advanced features
- ✅ UI polish

---

**Esta arquitectura es escalable y modular. Podemos empezar simple y agregar complejidad gradualmente.**

