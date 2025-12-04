#!/bin/bash

# Script para declarar el contrato Launchpad (actualizado con payment_token)

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Scarb genera .contract_class.json que contiene sierra y casm
CONTRACT_FILE="target/dev/zeroshade_Launchpad.contract_class.json"

echo "📋 Declarando contrato Launchpad (v2 con payment_token)..."
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
echo "📋 Declarando Launchpad v2..."
echo ""

# Usar --casm-hash si hay un mismatch (hash esperado por la red)
starkli declare "$CONTRACT_FILE" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    --casm-hash 0x7f42d2b79fb91ceed1388a405731bf5c7d270c331cc6e0c1354470b67d06b75

echo ""
echo "✅ Contrato declarado exitosamente"
echo ""
echo "💡 Copia el class hash que aparece arriba y actualízalo en:"
echo "   - scripts/deploy_launchpad.sh (línea 15)"
echo "   - backend/src/config/constants.ts (LAUNCHPAD_CLASS_HASH)"

