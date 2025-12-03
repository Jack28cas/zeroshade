# 🚀 Guía de Deployment - ZumpFun

## Prerrequisitos

1. **Cuenta Starknet configurada**
   - Private key
   - Account address
   - Fondos en testnet/mainnet

2. **Herramientas instaladas**
   - Scarb ✅
   - Starknet CLI o Starkli
   - Python (para scripts de interacción)

---

## 📋 Pasos de Deployment

### 1. Compilar Contratos

```bash
# Compilar todos los contratos
scarb build

# Los archivos compilados estarán en:
# target/dev/zeroshade_<contract_name>.sierra.json
# target/dev/zeroshade_<contract_name>.casm.json
```

### 2. Declarar Clases de Contratos

```bash
# Declarar Token Contract
starknet declare \
  --contract target/dev/zeroshade_token.sierra.json \
  --account <tu_cuenta> \
  --network testnet

# Declarar Launchpad Contract
starknet declare \
  --contract target/dev/zeroshade_launchpad.sierra.json \
  --account <tu_cuenta> \
  --network testnet

# Declarar Token Factory
starknet declare \
  --contract target/dev/zeroshade_token_factory.sierra.json \
  --account <tu_cuenta> \
  --network testnet
```

### 3. Deploy de Contratos

#### Deploy Token Contract (si no usas Factory)

```bash
starknet deploy \
  --class_hash <token_class_hash> \
  --constructor_calldata \
    "<name>" \
    "<symbol>" \
    "18" \
    "<initial_supply>" \
    "<owner_address>" \
  --account <tu_cuenta> \
  --network testnet
```

#### Deploy Launchpad Contract

```bash
starknet deploy \
  --class_hash <launchpad_class_hash> \
  --constructor_calldata "<fee_recipient_address>" \
  --account <tu_cuenta> \
  --network testnet
```

#### Deploy Token Factory

```bash
starknet deploy \
  --class_hash <factory_class_hash> \
  --constructor_calldata "<token_class_hash>" \
  --account <tu_cuenta> \
  --network testnet
```

---

## 🔧 Configuración Post-Deploy

### 1. Guardar Direcciones

Crea un archivo `.env.deploy` con las direcciones:

```env
# Direcciones de contratos desplegados
TOKEN_CONTRACT_ADDRESS=0x...
LAUNCHPAD_CONTRACT_ADDRESS=0x...
FACTORY_CONTRACT_ADDRESS=0x...

# Class hashes
TOKEN_CLASS_HASH=0x...
LAUNCHPAD_CLASS_HASH=0x...
FACTORY_CLASS_HASH=0x...
```

### 2. Verificar Deployment

```bash
# Verificar que los contratos están desplegados
starknet get_contract_address \
  --network testnet \
  <contract_address>
```

---

## 🧪 Testing Post-Deploy

### 1. Crear un Token

```python
# Usando el script de interacción
python scripts/interact_contracts.py

# O manualmente:
# 1. Llamar factory.create_token(...)
# 2. Obtener dirección del token creado
```

### 2. Lanzar Token en Launchpad

```python
launchpad.launch_token(
    token_address=<token_address>,
    initial_price=1000000000000000,  # 0.001 ETH
    k=1000000,
    n=1,
    fee_rate=100  # 1%
)
```

### 3. Probar Trading

```python
# Comprar tokens
launchpad.buy_tokens(
    token_address=<token_address>,
    eth_amount=100000000000000000  # 0.1 ETH
)

# Consultar precio
price = launchpad.get_price(<token_address>)
print(f"Precio actual: {price}")
```

---

## 🌐 Deploy a Ztarknet

Ztarknet es compatible con Starknet, así que el proceso es similar:

1. Cambiar `--network testnet` por `--network ztarknet-testnet`
2. Asegurarse de tener fondos en Ztarknet
3. Seguir los mismos pasos

---

## 📝 Checklist de Deployment

- [ ] Contratos compilados sin errores
- [ ] Clases declaradas exitosamente
- [ ] Contratos desplegados
- [ ] Direcciones guardadas en `.env`
- [ ] Testing básico realizado
- [ ] Verificación de funcionalidad
- [ ] Documentación actualizada

---

## 🔒 Seguridad

### Antes de Deploy a Mainnet:

1. **Audit básico**
   - Revisar lógica de contratos
   - Verificar validaciones
   - Revisar access controls

2. **Testing exhaustivo**
   - Unit tests
   - Integration tests
   - Edge cases

3. **Configuración segura**
   - Fees razonables
   - Límites de parámetros
   - Emergency functions (si necesario)

---

## 🆘 Troubleshooting

### Error: "Class already declared"
- La clase ya fue declarada, usa el class_hash existente

### Error: "Insufficient balance"
- Asegúrate de tener fondos suficientes para deploy

### Error: "Contract deployment failed"
- Verifica los parámetros del constructor
- Revisa que la clase esté declarada

---

## 📚 Recursos

- [Starknet Deploy Guide](https://docs.starknet.io/documentation/architecture_and_concepts/Smart_Contracts/deploying-contracts/)
- [Starkli Documentation](https://book.starkli.rs/)
- [Starknet.py](https://github.com/software-mansion/starknet.py)

---

**¡Listo para deploy!** 🚀

