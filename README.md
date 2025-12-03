# ZeroShade - Zypherpunk Hackathon Project

Proyecto para la **Zypherpunk Hackathon: Pista Starknet** enfocado en privacidad y aplicaciones descentralizadas sobre Starknet.

## 🎯 Objetivo

Este proyecto sigue la metodología recomendada:
1. **Contratos inteligentes** (Cairo/Starknet) ✅
2. **Interacción con contratos** (testing y deploy) ✅
3. **Backend** (próximamente)
4. **Frontend** (próximamente)

## 📋 Pistas de la Hackathon

### Opciones de premios disponibles:

1. **Aplicaciones creativas de privacidad ($26,000)**
   - 🏆 Wildcard ($20,000): Innovación única (perps privados, préstamos privados, mercado de predicción)
   - 🪙 **ZumpFun ($5,000)**: Pump.fun privado sobre Ztarknet (Noir + Garaga) ⭐ **PROYECTO ELEGIDO**
   - 💰 Micropagos Zashi Wallet ($1,000)

2. **Infraestructura de privacidad ($6,000)**
   - 🛠️ Construyendo sobre Ztarknet ($3,000)
   - 🔗 Mensajería cross-chain ($3,000)

3. **Innovación en autocustodia ($3,000)**
   - 👛 Billetera Zec <> Starknet
   - 🔄 Atomic Swap (Zec <-> Starknet)

## 🔐 Circuito Noir (Private Trading)

Hemos implementado un circuito Noir para trading privado que permite:
- Probar balance suficiente sin revelar el balance exacto
- Validar trades sin revelar montos
- Generar commitments usando hash

**Ubicación**: `src/noir/private_trading/`

**Uso**:
```bash
# Generar proof completo
./scripts/generate_proof.sh private_trading
```

Ver `src/noir/private_trading/README.md` para más detalles.

## 🚀 Configuración Inicial

### Prerrequisitos

1. **Scarb** (build tool para Cairo):
   ```bash
   # Windows (con Scoop)
   scoop install scarb
   
   # O descarga desde: https://docs.swmansion.com/scarb/
   # Verificar instalación:
   scarb --version
   ```

2. **Starknet CLI** (opcional, para deploy):
   ```bash
   # Instalar desde: https://www.starknet.io/en/developers/getting-started
   ```

3. **Herramientas de testing** (recomendado):
   - **Starknet Foundry (snforge)**: https://foundry-rs.github.io/starknet-foundry/
   - **Protostar**: https://docs.swmansion.com/protostar/

### Setup rápido

```bash
# Ejecutar script de setup
bash scripts/setup.sh
```

### Instalación

```bash
# Clonar el repositorio (si aplica)
git clone <tu-repo>
cd zeroshade

# Verificar que Scarb esté instalado
scarb --version

# Las dependencias se instalan automáticamente con Scarb
# Compilar el proyecto
scarb build

# Formatear el código
scarb fmt

# Para scripts de Python (opcional)
pip install -r requirements.txt

# Configurar variables de entorno
# Crea un archivo .env con:
# STARKNET_PRIVATE_KEY=tu_private_key
# STARKNET_ACCOUNT_ADDRESS=tu_account_address
# NETWORK=testnet
```

### Comandos rápidos

```bash
# Inicializar proyecto (si empezaras de cero)
scarb init --name zeroshade

# Agregar dependencias
scarb add alexandria_math@0.1.0

# Build
scarb build

# Formatear
scarb fmt

# Test
scarb test
```

## 📁 Estructura del Proyecto

```
zeroshade/
├── src/
│   ├── lib.cairo              # Biblioteca principal
│   └── contracts/
│       ├── token.cairo         # Token Contract (ERC20-like)
│       ├── launchpad.cairo    # Launchpad con bonding curve
│       ├── token_factory.cairo # Factory para crear tokens
│       └── example_contract.cairo  # Contrato de ejemplo
├── tests/
│   ├── token_test.cairo       # Tests para Token Contract
│   └── launchpad_test.cairo   # Tests para Launchpad Contract
├── scripts/
│   ├── deploy.sh              # Script de deploy
│   ├── test.sh                # Script de testing
│   ├── fmt.sh                 # Formatear código
│   ├── setup.sh               # Setup inicial
│   ├── setup_wsl.sh           # Setup para WSL
│   ├── generate_proof.sh      # Generar proofs (Noir)
│   ├── install_snforge.sh     # Instalar Starknet Foundry
│   └── interact_contracts.py   # Interacción con contratos (Python)
├── docs/
│   ├── CONTRACTS_GUIDE.md     # Guía de uso de contratos
│   ├── ARCHITECTURE.md        # Arquitectura del sistema
│   ├── DEPLOYMENT.md          # Guía de deployment
│   ├── NOIR_GARAGA_SETUP.md   # Setup de Noir y Garaga
│   ├── RECOMMENDATION.md      # Análisis y recomendaciones
│   ├── PROJECT_IDEAS.md       # Ideas de proyectos
│   └── UPDATED_ROADMAP.md     # Roadmap actualizado
├── Scarb.toml                 # Configuración de Scarb
├── snforge.toml                # Configuración de testing
└── README.md                  # Este archivo
```

## 🛠️ Desarrollo

### Comandos básicos de Scarb

```bash
# Formatear código
scarb fmt

# Compilar contratos
scarb build

# Ejecutar tests (si están configurados)
scarb test

# Agregar dependencias
scarb add <package_name>@<version>
```

### Scripts útiles

```bash
# Formatear código
bash scripts/fmt.sh

# Testing completo (formato + build + test)
bash scripts/test.sh

# Deploy
bash scripts/deploy.sh
```

### Testing

```bash
# Instalar Starknet Foundry (si no está instalado)
# Opción 1: Con cargo (requiere Rust)
cargo install --locked --git https://github.com/foundry-rs/starknet-foundry.git --tag v0.18.0 snforge

# Opción 2: Descargar binario
# Visita: https://github.com/foundry-rs/starknet-foundry/releases

# Ejecutar todos los tests
snforge test

# Ejecutar test específico
snforge test test_token_creation

# Ver más detalles
snforge test --detailed-resources
```

**Ver `TESTING_SETUP.md` para más información sobre testing.**

## ✅ Estado Actual

- ✅ Proyecto configurado con Scarb
- ✅ **Token Contract** - Contrato ERC20-like para tokens
- ✅ **Launchpad Contract** - Gestión de launches con bonding curve
- ✅ **Token Factory** - Factory para crear tokens fácilmente
- ✅ **Tests creados** - Tests básicos para Token y Launchpad
- ✅ Scripts de desarrollo y interacción listos
- ✅ Documentación completa de contratos
- ✅ Estructura lista para testing y deploy

## 📝 Próximos Pasos

### ⚠️ IMPORTANTE: Requisitos de la Hackathon

ZumpFun requiere **Noir** y **Garaga** para privacidad. Ver `NOIR_GARAGA_SETUP.md` para setup completo.

**Versiones requeridas**:
- Noir: 1.0.0-beta.1
- Barretenberg: 0.67.0
- Garaga: 0.15.5
- Scarb: 2.9.2 (verificar compatibilidad)

**⚠️ Si estás en macOS**: Usa GitHub Codespaces (Barretenberg no funciona bien en Mac)

**🪟 Si estás en Windows**: 
- Opción 1: Windows nativo (ver `WINDOWS_SETUP.md`)
- Opción 2: WSL2 (recomendado, mejor compatibilidad)
- Opción 3: GitHub Codespaces (más fácil)

### Roadmap

1. ✅ **Contratos base** (COMPLETADO)
2. ✅ **Testing** (COMPLETADO)
3. 🔄 **Setup Noir + Garaga** (PRÓXIMO - CRÍTICO)
4. ⏳ **Backend API**
5. ⏳ **Frontend UI**
6. ⏳ **Privacidad con Noir**
7. ⏳ **Garaga Integration**

Ver `UPDATED_ROADMAP.md` para detalles completos.

## 🔗 Recursos Útiles

- [Documentación de Cairo](https://cairo-book.github.io/)
- [Starknet Docs](https://docs.starknet.io/)
- [OpenZeppelin Cairo Contracts](https://github.com/OpenZeppelin/cairo-contracts)
- [Ztarknet Documentation](https://ztarknet.com/) (si aplica)
- [Noir Documentation](https://noir-lang.org/) (para proyectos con Noir)
- [Garaga Documentation](https://garaga.xyz/) (para proyectos con Garaga)

## 💡 Ideas de Proyectos

### ZumpFun (Pump.fun privado)
- Contratos Noir para privacidad
- Integración con Garaga
- Trading y market-making privados
- Identidad del creador oculta

### Micropagos Zashi Wallet
- Integración con Zashi Wallet
- Transacciones que liquidan en Starknet
- Sistema de micropagos eficiente

### Mensajería Cross-Chain
- Orquestador que escucha transacciones
- Relay entre Starknet y Zcash
- Sincronización de estado

## 🤝 Contribución

Este es un proyecto para la hackathon. Siéntete libre de adaptar y extender según tus necesidades.

## 📄 Licencia

MIT (o la que prefieras para la hackathon)

---

**¡Buena suerte en la hackathon! 🚀**

