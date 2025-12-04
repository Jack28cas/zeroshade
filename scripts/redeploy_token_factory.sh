#!/bin/bash

# Script para recompilar y redesplegar TokenFactory con despliegue real de tokens

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del Token (necesario para el constructor)
TOKEN_CLASS_HASH="0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960"

echo "🔨 Recompilando TokenFactory..."
cd "$(dirname "$0")/.."
scarb build

echo ""
echo "📝 Declarando nueva clase de TokenFactory..."
FACTORY_CLASS_HASH=$(starkli class-hash target/dev/zeroshade_TokenFactory.sierra.json)

echo "   Class Hash: $FACTORY_CLASS_HASH"
echo ""

echo "🚀 Desplegando nuevo TokenFactory..."
starkli deploy "$FACTORY_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$TOKEN_CLASS_HASH"

echo ""
echo "✅ TokenFactory redesplegado exitosamente"
echo "⚠️  IMPORTANTE: Actualiza la dirección del TokenFactory en:"
echo "   - frontend/src/lib/constants.ts"
echo "   - backend/src/config/constants.ts"

