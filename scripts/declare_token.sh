#!/bin/bash

# Script para declarar el contrato Token

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Scarb genera .contract_class.json que contiene sierra y casm
CONTRACT_FILE="target/dev/zeroshade_Token.contract_class.json"

echo "📋 Declarando contrato Token..."
echo ""

if [ ! -f "$CONTRACT_FILE" ]; then
    echo "❌ Error: No se encontró el archivo $CONTRACT_FILE"
    echo "   Ejecuta 'scarb build' primero"
    exit 1
fi

echo "Archivo: $CONTRACT_FILE"
echo "Account: $ACCOUNT_EXPANDED"
echo "RPC: $RPC"
echo ""

# starkli declare puede usar directamente el .contract_class.json
# Usar el CASM hash actual que se genera
echo "📋 Declarando con nuevo Sierra hash (v2 con security improvements)..."
echo ""

starkli declare "$CONTRACT_FILE" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    --casm-hash 0x0332029b75036525544e29f5b269153e12cb5488b79749d78f2f44b514254f7a

echo ""
echo "✅ Contrato declarado exitosamente"
echo ""
echo "💡 Copia el class hash que aparece arriba y actualízalo en:"
echo "   - scripts/deploy_token.sh (línea 15)"
echo "   - backend/src/config/constants.ts (TOKEN class hash si lo usas)"

