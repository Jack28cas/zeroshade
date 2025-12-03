# 📘 Guía de Contratos ZumpFun

## 📋 Contratos Disponibles

### 1. Token Contract (`token.cairo`)

Contrato ERC20-like para crear tokens de meme-coins.

#### Funcionalidades:
- ✅ Creación de tokens con nombre, símbolo y supply inicial
- ✅ Transferencias entre direcciones
- ✅ Sistema de aprobaciones (approve/transferFrom)
- ✅ Minting (solo owner)
- ✅ Consulta de balances y supply

#### Uso Básico:

```cairo
// Crear token
constructor(
    name: "MyToken",
    symbol: "MTK",
    decimals: 18,
    initial_supply: 1000000 * 10^18,
    owner: <tu_direccion>
)

// Transferir tokens
transfer(recipient: <direccion>, amount: 1000)

// Aprobar gasto
approve(spender: <direccion>, amount: 500)

// Consultar balance
balance_of(account: <direccion>) -> u256
```

---

### 2. Launchpad Contract (`launchpad.cairo`)

Contrato que gestiona los launches de tokens con bonding curve.

#### Funcionalidades:
- ✅ Launch de tokens con curva de precios
- ✅ Compra de tokens (buy_tokens)
- ✅ Venta de tokens (sell_tokens)
- ✅ Consulta de precios y liquidez
- ✅ Sistema de fees configurable

#### Parámetros de Launch:

- `initial_price`: Precio inicial del token (en wei/ETH)
- `k`: Constante de la curva (controla la pendiente)
- `n`: Exponente de la curva (controla la curvatura)
- `fee_rate`: Fee en basis points (100 = 1%)

#### Fórmula de Bonding Curve:

```
price = initial_price * (1 + supply / k)^n
```

Simplificada para eficiencia:
```
price = initial_price * (1 + supply / k)
```

#### Uso Básico:

```cairo
// 1. Crear token primero (usando Token Contract)
// 2. Lanzar token en el launchpad
launch_token(
    token_address: <direccion_token>,
    initial_price: 1000000000000000,  // 0.001 ETH
    k: 1000000,                        // Constante
    n: 1,                              // Exponente
    fee_rate: 100                      // 1% fee
)

// 3. Comprar tokens
buy_tokens(
    token_address: <direccion_token>,
    eth_amount: 100000000000000000     // 0.1 ETH
) -> tokens_received

// 4. Vender tokens
sell_tokens(
    token_address: <direccion_token>,
    token_amount: 1000
) -> eth_received

// 5. Consultar precio actual
get_price(token_address: <direccion_token>) -> u256
```

---

### 3. Token Factory (`token_factory.cairo`)

Factory para crear tokens fácilmente.

#### Funcionalidades:
- ✅ Creación de tokens en una sola transacción
- ✅ Tracking de todos los tokens creados
- ✅ Consulta de tokens por índice

#### Uso:

```cairo
// Crear nuevo token
create_token(
    name: "MyToken",
    symbol: "MTK",
    decimals: 18,
    initial_supply: 1000000 * 10^18
) -> token_address

// Obtener cantidad de tokens creados
get_token_count() -> u256

// Obtener token por índice
get_token_at(index: 0) -> ContractAddress
```

---

## 🔄 Flujo Completo de Uso

### Paso 1: Deploy de Contratos

1. **Deploy Token Contract** (o usar Factory)
2. **Deploy Launchpad Contract**
3. **Deploy Token Factory** (opcional)

### Paso 2: Crear un Token

**Opción A: Usando Factory**
```cairo
token_address = factory.create_token(
    name: "DogeCoin",
    symbol: "DOGE",
    decimals: 18,
    initial_supply: 1000000000 * 10^18
)
```

**Opción B: Deploy directo**
```cairo
// Deploy token contract directamente
// Luego usar la dirección
```

### Paso 3: Lanzar Token en Launchpad

```cairo
launchpad.launch_token(
    token_address: token_address,
    initial_price: 1000000000000000,  // 0.001 ETH
    k: 1000000,
    n: 1,
    fee_rate: 100                     // 1%
)
```

### Paso 4: Trading

```cairo
// Comprar tokens
tokens = launchpad.buy_tokens(
    token_address: token_address,
    eth_amount: 100000000000000000    // 0.1 ETH
)

// Vender tokens (primero aprobar launchpad)
token.approve(
    spender: launchpad_address,
    amount: 1000
)
eth = launchpad.sell_tokens(
    token_address: token_address,
    token_amount: 1000
)
```

---

## 📊 Estructura de Datos

### LaunchInfo

```cairo
struct LaunchInfo {
    token_address: ContractAddress,
    creator: ContractAddress,
    initial_price: u256,
    current_price: u256,
    total_supply: u256,
    liquidity: u256,
    k: u256,
    n: u256,
    fee_rate: u256,
    launch_time: u64,
    is_active: bool,
}
```

---

## ⚠️ Consideraciones Importantes

### 1. Aprobaciones para Venta
Antes de vender tokens, el usuario debe aprobar al launchpad:
```cairo
token.approve(spender: launchpad_address, amount: token_amount)
```

### 2. Precisión de Precios
La fórmula de bonding curve está simplificada para eficiencia. Para mayor precisión, considera usar fixed-point math.

### 3. Fees
Los fees se calculan en basis points:
- 100 = 1%
- 1000 = 10%
- 50 = 0.5%

### 4. Seguridad
- ✅ Reentrancy protection (checks-effects-interactions)
- ✅ Validación de inputs
- ✅ Access control (solo owner puede mint)

---

## 🧪 Testing

### Compilar Contratos
```bash
scarb build
```

### Formatear Código
```bash
scarb fmt
```

### Testing con Starknet Foundry
```bash
snforge test
```

---

## 📝 Próximos Pasos

1. ✅ Contratos base completados
2. ⏳ Testing exhaustivo
3. ⏳ Integración con Noir (privacidad)
4. ⏳ Integración con Garaga
5. ⏳ Backend API
6. ⏳ Frontend UI

---

## 🔗 Recursos

- [Cairo Book](https://cairo-book.github.io/)
- [Starknet Docs](https://docs.starknet.io/)
- [Starknet.py](https://github.com/software-mansion/starknet.py)

---

**¡Los contratos están listos para testing y deploy!** 🚀

