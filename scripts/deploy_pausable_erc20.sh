#!/bin/bash

# Script para desplegar el contrato PausableERC20

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del PausableERC20 (actualizar después de redeclarar)
# Hash anterior: 0x04b0da3a213bdc083753c430b2be8fb79fa77a49ff6a0612a3d0f2fcce3eb205
# Hash nuevo (con initial_supply): 0x0408aeb9f2b42dea3794ef2970d17b76cfc68976b9e25fc4575653506ae14198
PAUSABLE_ERC20_CLASS_HASH="0x0408aeb9f2b42dea3794ef2970d17b76cfc68976b9e25fc4575653506ae14198"

echo "🚀 Desplegando PausableERC20 Contract..."
echo ""

# Obtener dirección del owner (por defecto tu cuenta)
OWNER=""

# Método 1: Leer del JSON directamente
if command -v jq &> /dev/null; then
    OWNER=$(jq -r '.address // .deployment.address // empty' "$ACCOUNT_EXPANDED" 2>/dev/null)
fi

# Método 2: Usar starkli account fetch
if [ -z "$OWNER" ] || [ "$OWNER" == "null" ]; then
    OWNER=$(starkli account fetch "$ACCOUNT_EXPANDED" --output --rpc "$RPC" 2>/dev/null || echo "")
fi

# Método 3: Usar starkli account show
if [ -z "$OWNER" ] || [ "$OWNER" == "null" ]; then
    OWNER=$(starkli account show "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null | grep -i "address" | awk '{print $2}' || echo "")
fi

if [ -z "$OWNER" ] || [ "$OWNER" == "null" ]; then
    read -p "Owner address: " OWNER
fi

if [ -z "$OWNER" ]; then
    echo "❌ Error: No se pudo obtener la dirección del owner"
    exit 1
fi

# Función para convertir texto a felt252 (hash simple)
text_to_felt252() {
    local text="$1"
    # Si es numérico, usarlo directamente
    if [[ "$text" =~ ^[0-9]+$ ]]; then
        echo "$text"
    else
        # Convertir texto a hash numérico simple (suma de códigos ASCII)
        local hash=0
        for (( i=0; i<${#text}; i++ )); do
            hash=$((hash + $(printf '%d' "'${text:$i:1}")))
        done
        # Multiplicar por un factor para evitar colisiones
        hash=$((hash * 256))
        echo "$hash"
    fi
}

# Solicitar name y symbol
echo ""
read -p "Token name (texto o número, ej: USDC o 123456789): " TOKEN_NAME_INPUT
read -p "Token symbol (texto o número, ej: USDC o 987654321): " TOKEN_SYMBOL_INPUT
read -p "Initial supply (u256, ej: 1000000000000 para 1M con 6 decimals): " INITIAL_SUPPLY

# Convertir a felt252 si es texto
TOKEN_NAME=$(text_to_felt252 "$TOKEN_NAME_INPUT")
TOKEN_SYMBOL=$(text_to_felt252 "$TOKEN_SYMBOL_INPUT")

# Validar
if [ -z "$TOKEN_NAME" ] || [ -z "$TOKEN_SYMBOL" ] || [ -z "$INITIAL_SUPPLY" ]; then
    echo "❌ Error: name, symbol y initial_supply son requeridos"
    exit 1
fi

# Convertir u256 a formato low/high para starkli
# u256 se representa como dos u128: low y high
# Para valores < 2^128, high = 0
# Usar bc para cálculos grandes o simplificar para valores comunes
convert_u256() {
    local value="$1"
    # Para valores prácticos (< 2^128), solo necesitamos low y high=0
    # 2^128 = 340282366920938463463374607431768211456
    # Para la mayoría de casos, el supply será menor
    echo "$value 0"
}

U256_PARAMS=$(convert_u256 "$INITIAL_SUPPLY")

echo ""
echo "Desplegando con parámetros:"
echo "  Name (original): $TOKEN_NAME_INPUT"
echo "  Name (felt252): $TOKEN_NAME"
echo "  Symbol (original): $TOKEN_SYMBOL_INPUT"
echo "  Symbol (felt252): $TOKEN_SYMBOL"
echo "  Initial Supply: $INITIAL_SUPPLY (u256: $U256_PARAMS)"
echo "  Owner: $OWNER"
echo "  Class Hash: $PAUSABLE_ERC20_CLASS_HASH"
echo ""

starkli deploy "$PAUSABLE_ERC20_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$TOKEN_NAME" \
    "$TOKEN_SYMBOL" \
    $U256_PARAMS \
    "$OWNER"

echo ""
echo "✅ PausableERC20 desplegado exitosamente"
echo ""
echo "💡 Copia la dirección del contrato desplegado y actualízala en:"
echo "   - scripts/deploy_launchpad.sh (para el parámetro payment_token)"
echo "   - backend/src/config/constants.ts (PAUSABLE_ERC20_ADDRESS)"
echo "   - frontend/src/lib/constants.ts (PAUSABLE_ERC20_ADDRESS)"

