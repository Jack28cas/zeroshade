#!/bin/bash

# Script para desplegar el contrato Token

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del Token (ya declarado)
TOKEN_CLASS_HASH="0x034a8ef7631c1919ff57a1132ddf1250d5ea562dd71cbbf3a7d0797e01a99a16"

echo "🚀 Desplegando Token Contract..."
echo ""

# Parámetros del constructor (ajusta según necesites)
read -p "Token name (ej: ZumpFun Token): " TOKEN_NAME
read -p "Token symbol (ej: ZUMP): " TOKEN_SYMBOL
read -p "Decimals (ej: 18): " DECIMALS
read -p "Initial supply (ej: 1000000000000000000000000 para 1M tokens): " INITIAL_SUPPLY

# Obtener dirección del owner (tu cuenta)
OWNER=$(starkli account fetch "$ACCOUNT_EXPANDED" --output --rpc "$RPC" 2>/dev/null || jq -r '.address' "$ACCOUNT_EXPANDED" 2>/dev/null || echo "")

if [ -z "$OWNER" ]; then
    echo "❌ No se pudo obtener la dirección del owner"
    exit 1
fi

echo ""
echo "Desplegando con parámetros:"
echo "  Name: $TOKEN_NAME"
echo "  Symbol: $TOKEN_SYMBOL"
echo "  Decimals: $DECIMALS"
echo "  Initial Supply: $INITIAL_SUPPLY"
echo "  Owner: $OWNER"
echo ""

# Convertir name y symbol a felt252 (hash)
# Para simplificar, usaremos valores numéricos
# En producción, deberías convertir strings a felt252 correctamente

starkli deploy "$TOKEN_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    --constructor-calldata \
        "$TOKEN_NAME" \
        "$TOKEN_SYMBOL" \
        "$DECIMALS" \
        "$INITIAL_SUPPLY" \
        "$OWNER"

echo ""
echo "✅ Token desplegado exitosamente"

