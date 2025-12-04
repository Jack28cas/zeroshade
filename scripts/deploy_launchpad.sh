#!/bin/bash

# Script para desplegar el contrato Launchpad

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del Launchpad (ya declarado - nuevo después de cambios)
LAUNCHPAD_CLASS_HASH="0x004bd0128004c18f6303fcce444842db253f312ad4a6c84a16c81e6117d12841"

echo "🚀 Desplegando Launchpad Contract..."
echo ""

# Obtener dirección del fee recipient (por defecto tu cuenta)
# Intentar múltiples métodos para obtener la dirección
FEE_RECIPIENT=""

# Método 1: Leer del JSON directamente
if command -v jq &> /dev/null; then
    FEE_RECIPIENT=$(jq -r '.address // .deployment.address // empty' "$ACCOUNT_EXPANDED" 2>/dev/null)
fi

# Método 2: Usar starkli account fetch
if [ -z "$FEE_RECIPIENT" ] || [ "$FEE_RECIPIENT" == "null" ]; then
    FEE_RECIPIENT=$(starkli account fetch "$ACCOUNT_EXPANDED" --output --rpc "$RPC" 2>/dev/null || echo "")
fi

# Método 3: Usar la dirección conocida
if [ -z "$FEE_RECIPIENT" ] || [ "$FEE_RECIPIENT" == "null" ]; then
    FEE_RECIPIENT="0x00b6d3f96ebc06732b5c549baa71e9eede25f432b805b98de2b351e82223c586"
fi

if [ -z "$FEE_RECIPIENT" ] || [ "$FEE_RECIPIENT" == "null" ]; then
    read -p "Fee recipient address: " FEE_RECIPIENT
fi

echo "Desplegando con parámetros:"
echo "  Fee Recipient: $FEE_RECIPIENT"
echo ""

starkli deploy "$LAUNCHPAD_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$FEE_RECIPIENT"

echo ""
echo "✅ Launchpad desplegado exitosamente"

