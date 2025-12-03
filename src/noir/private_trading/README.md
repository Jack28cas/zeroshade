# Private Trading Circuit - ZumpFun

Circuito Noir para trading privado en ZumpFun.

## Funcionalidad

Este circuito prueba que:
- El usuario tiene balance suficiente (sin revelar el balance)
- El trade amount es válido (sin revelar el monto exacto)
- El commitment es correcto (usando Poseidon hash)

## Inputs

### Private (Ocultos):
- `balance`: Balance del usuario
- `trade_amount`: Monto del trade
- `user_secret`: Secreto del usuario

### Public (Revelados):
- `commitment`: Hash de (balance, trade_amount, user_secret)
- `threshold`: Monto mínimo requerido

## Uso

```bash
# Compilar
nargo compile

# Generar witness
nargo execute witness

# Generar proof
bb prove_ultra_keccak_honk \
  -b ./target/private_trading.json \
  -w ./target/witness.gz \
  -o ./target/proof

# Generar VK
bb write_vk_ultra_keccak_honk \
  -b ./target/private_trading.json \
  -o ./target/vk
```

