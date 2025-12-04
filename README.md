# ZeroShade - ZumpFun (Zypherpunk Hackathon)

Proyecto para la **Zypherpunk Hackathon: Pista Starknet** - Pump.fun privado sobre Ztarknet usando Noir, Garaga y Starknet.

## 🎯 Objetivo del Proyecto

**ZumpFun** es una plataforma de lanzamiento de tokens tipo Pump.fun con privacidad, permitiendo:
- Creación y lanzamiento de tokens meme
- Trading con bonding curve
- Privacidad mediante Zero-Knowledge Proofs (Noir + Garaga)
- Identidad del creador oculta

## ✅ Estado Actual

- ✅ **Contratos compilados** (Token, Launchpad, TokenFactory)
- ✅ **Contratos declarados** en Starknet Sepolia
- ✅ **Contratos desplegados** (Launchpad, TokenFactory)
- ✅ **Circuito Noir** para trading privado
- ✅ **Scripts de deployment e interacción**
- ⏳ Backend API (próximo)
- ⏳ Frontend UI (próximo)

## 📋 Contratos Desplegados

### Launchpad Contract ✅
- **Dirección**: `0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf`
- **Class Hash**: `0x004bd0128004c18f6303fcce444842db253f312ad4a6c84a16c81e6117d12841`
- **Transaction**: `0x07736e3c83d6d8a8f05334672e4ac163cc4ea8c02a7a830517c5fa727c617312`
- **Exploradores**:
  - [Starkscan](https://sepolia.starkscan.co/contract/0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf)
  - [Voyager](https://sepolia.voyager.online/contract/0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf)

### TokenFactory Contract ✅
- **Dirección**: `0x0755306b285a57fd4568b27bd77afed16c671b8896de6ed76542b5e6ba6b95e5`
- **Class Hash**: `0x008c7076311e0f842806c474162f13f9086791ec2c80ada96d3359def0f8c5bc`
- **Transaction**: `0x0599a001a8d7ebbddea5e54f2cd887b5bfb512276a5c4de326b36feafbf63a4b`
- **Exploradores**:
  - [Starkscan](https://sepolia.starkscan.co/contract/0x0755306b285a57fd4568b27bd77afed16c671b8896de6ed76542b5e6ba6b95e5)
  - [Voyager](https://sepolia.voyager.online/contract/0x0755306b285a57fd4568b27bd77afed16c671b8896de6ed76542b5e6ba6b95e5)

### Token Contract (Declarado, listo para desplegar)
- **Class Hash**: `0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960`
- **CASM Hash**: `0x2ecb9e5e904f6b8cf98e4a6e611a92d27f6d4c2436ef7b4623b67f6d980678c`

## 🚀 Configuración Inicial

### Prerrequisitos

1. **Scarb** (Cairo build tool):
   ```bash
   # Windows (con Scoop)
   scoop install scarb
   
   # O descarga desde: https://docs.swmansion.com/scarb/
   scarb --version  # Verificar: 2.9.2 o compatible
   ```

2. **Starkli** (CLI para Starknet):
   ```bash
   # Instalar desde: https://book.starkli.rs/
   ```

3. **Noir + Garaga** (para privacidad):
   - Ver sección [Setup Noir/Garaga](#-setup-noir--garaga) más abajo

### Instalación

```bash
# Clonar repositorio
git clone <tu-repo>
cd zeroshade

# Compilar contratos
scarb build

# Formatear código
scarb fmt

# Configurar variables de entorno
export RPC="https://starknet-sepolia-rpc.publicnode.com"
export ACCOUNT="~/.starkli/accounts/sepolia/my.json"
export KEYSTORE="~/.starkli/keystores/my_keystore.json"
```

## 📁 Estructura del Proyecto

```
zeroshade/
├── src/
│   ├── lib.cairo
│   ├── contracts/
│   │   ├── token.cairo         # Token ERC20-like
│   │   ├── launchpad.cairo     # Launchpad con bonding curve
│   │   └── token_factory.cairo # Factory para crear tokens
│   └── noir/
│       └── private_trading/    # Circuito Noir para privacidad
├── tests/
│   ├── token_test.cairo
│   └── launchpad_test.cairo
├── scripts/
│   ├── declare_with_expected_hash.sh  # Declarar contratos
│   ├── deploy_launchpad.sh            # Desplegar Launchpad
│   ├── deploy_token_factory.sh        # Desplegar Factory
│   ├── deploy_token.sh                 # Desplegar Token
│   ├── generate_proof.sh              # Generar pruebas ZK
│   └── setup_wsl.sh                   # Setup WSL
├── Scarb.toml
└── README.md
```

## 🔧 Uso de Contratos

### 1. Crear Token usando TokenFactory

```bash
starkli invoke 0x0755306b285a57fd4568b27bd77afed16c671b8896de6ed76542b5e6ba6b95e5 \
    create_token \
    --account "$ACCOUNT" \
    --keystore "$KEYSTORE" \
    --rpc "$RPC" \
    "123456789" \      # name (felt252)
    "987654321" \      # symbol (felt252)
    "1000000000000" \  # initial_supply low (u128)
    "0"                # initial_supply high (u128)
```

**Nota**: El TokenFactory actualmente tiene un TODO para implementar el despliegue real. En producción necesitaría usar Universal Deployer Contract (UDC).

### 2. Lanzar Token en Launchpad

```bash
starkli invoke 0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf \
    launch_token \
    --account "$ACCOUNT" \
    --keystore "$KEYSTORE" \
    --rpc "$RPC" \
    "<TOKEN_ADDRESS>" \    # Dirección del token
    "1000000000000000" \   # initial_price (u256 low)
    "0" \                  # initial_price (u256 high)
    "1000000" \            # k (u256 low)
    "0" \                  # k (u256 high)
    "1" \                  # n (u256 low)
    "0" \                  # n (u256 high)
    "100"                  # fee_rate (u256, basis points: 100 = 1%)
```

### 3. Comprar Tokens

```bash
starkli invoke 0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf \
    buy_tokens \
    --account "$ACCOUNT" \
    --keystore "$KEYSTORE" \
    --rpc "$RPC" \
    "<TOKEN_ADDRESS>" \
    "100000000000000000"   # eth_amount (u256 low, ej: 0.1 ETH)
```

### 4. Consultar Precio

```bash
starkli call 0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf \
    get_price \
    --rpc "$RPC" \
    "<TOKEN_ADDRESS>"
```

## 🔐 Setup Noir + Garaga

### Versiones Requeridas
- **Noir**: 1.0.0-beta.1
- **Barretenberg (bb)**: 0.67.0
- **Garaga**: 0.15.5
- **Scarb**: 2.9.2

### ⚠️ Problemas Conocidos

1. **Barretenberg NO funciona bien en macOS**
   - Crashes aleatorios, errores de símbolos
   - **Solución**: Usar GitHub Codespaces o WSL/Linux

2. **Garaga calldata es GRANDE**
   - Circuitos pequeños generan ~79KB de calldata
   - Considerar gas costs

### Setup en WSL (Recomendado para Windows)

```bash
# Ejecutar script de setup
bash scripts/setup_wsl.sh
```

El script instala:
- Barretenberg 0.67.0
- Noir 1.0.0-beta.1
- Garaga 0.15.5

### Flujo de Trabajo con Noir + Garaga

1. **Crear/Compilar Circuito Noir**:
   ```bash
   cd src/noir/private_trading
   nargo compile
   ```

2. **Generar Proof**:
   ```bash
   # Desde la raíz del proyecto
   ./scripts/generate_proof.sh private_trading
   ```

3. **Generar Verifier Contract con Garaga**:
   ```bash
   # El script generate_proof.sh genera automáticamente el verifier
   # En: src/noir/private_trading/zeroshade/
   ```

4. **Deploy Verifier**:
   ```bash
   cd src/noir/private_trading/zeroshade
   scarb build
   # Declarar y desplegar usando starkli
   ```

## 📝 Scripts Disponibles

Ver `scripts/README.md` para documentación completa de scripts.

### Scripts Principales

- **`declare_with_expected_hash.sh`** - Declara todos los contratos
- **`deploy_launchpad.sh`** - Despliega Launchpad
- **`deploy_token_factory.sh`** - Despliega TokenFactory
- **`deploy_token.sh`** - Despliega Token
- **`generate_proof.sh`** - Genera pruebas ZK (Noir + Garaga)
- **`clean_rebuild.sh`** - Limpia y recompila desde cero

## 🧪 Testing

### Compilar y Formatear

```bash
# Compilar
scarb build

# Formatear
scarb fmt

# Testing con Starknet Foundry
snforge test
```

## 📊 Información de Cuenta

**Cuenta de Desarrollo:**
- Dirección: `0x00b6d3f96ebc06732b5c549baa71e9eede25f432b805b98de2b351e82223c586`
- Red: Starknet Sepolia
- RPC: `https://starknet-sepolia-rpc.publicnode.com`

## 🔗 Recursos

- [Cairo Book](https://cairo-book.github.io/)
- [Starknet Docs](https://docs.starknet.io/)
- [Noir Documentation](https://noir-lang.org/)
- [Garaga GitHub](https://github.com/keep-starknet-strange/garaga)
- [Starkli Book](https://book.starkli.rs/)
- [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/)

## 📄 Licencia

MIT

---

**¡Buena suerte en la hackathon! 🚀**
