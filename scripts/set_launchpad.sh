#!/bin/bash

# Script para configurar el Launchpad en un token existente

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Direcciones
LAUNCHPAD_ADDRESS="0x07843bcead611008cd7f15525c5399f9d80adef9e775bf3427435547a1ca7ddf"

echo "🔧 Configurando Launchpad en Token..."
echo ""

# Pedir dirección del token
read -p "Token address (0x...): " TOKEN_ADDRESS

if [ -z "$TOKEN_ADDRESS" ]; then
    echo "❌ Error: Se requiere la dirección del token"
    exit 1
fi

echo ""
echo "Configurando Launchpad:"
echo "  Token: $TOKEN_ADDRESS"
echo "  Launchpad: $LAUNCHPAD_ADDRESS"
echo ""

# Invocar set_launchpad
starkli invoke "$TOKEN_ADDRESS" \
    set_launchpad \
    "$LAUNCHPAD_ADDRESS" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC"

echo ""
echo "✅ Launchpad configurado exitosamente"

