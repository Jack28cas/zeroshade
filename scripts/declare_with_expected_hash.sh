#!/bin/bash

# Script para declarar usando el hash CASM esperado por la red
# Usa el hash que la red espera según el error anterior

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACTS_DIR="$PROJECT_ROOT/target/dev"

echo "📝 Declarando contratos con hash CASM esperado por la red..."
echo ""

# Hash esperado según el error anterior para Token
TOKEN_EXPECTED_CASM="0x5081fb5dd71d0dcf6a6e9ff94c8c6573c363daae3cefbeb202d3bf44cf2016a"

# 1. Token
echo "=== Token ==="
TOKEN_FILE="$CONTRACTS_DIR/zeroshade_Token.contract_class.json"
if [ -f "$TOKEN_FILE" ]; then
    echo "Usando hash CASM esperado: $TOKEN_EXPECTED_CASM"
    echo "Declarando Token..."
    starkli declare "$TOKEN_FILE" \
        --account "$ACCOUNT_EXPANDED" \
        --keystore "$KEYSTORE_EXPANDED" \
        --rpc "$RPC" \
        --casm-hash "$TOKEN_EXPECTED_CASM"
    echo ""
else
    echo "❌ No se encontró Token"
fi

# 2. Launchpad (con hash esperado según el error)
echo "=== Launchpad ==="
LAUNCHPAD_FILE="$CONTRACTS_DIR/zeroshade_Launchpad.contract_class.json"
LAUNCHPAD_EXPECTED_CASM="0x630b813c4c69b6d092887a778d61c0ec1b14517d4f353b70580f5e1f408cd5e"
if [ -f "$LAUNCHPAD_FILE" ]; then
    echo "Usando hash CASM esperado: $LAUNCHPAD_EXPECTED_CASM"
    echo "Declarando Launchpad..."
    starkli declare "$LAUNCHPAD_FILE" \
        --account "$ACCOUNT_EXPANDED" \
        --keystore "$KEYSTORE_EXPANDED" \
        --rpc "$RPC" \
        --casm-hash "$LAUNCHPAD_EXPECTED_CASM"
    echo ""
else
    echo "❌ No se encontró Launchpad"
fi

# 3. TokenFactory (sin hash esperado aún, intentar sin hash primero)
echo "=== TokenFactory ==="
FACTORY_FILE="$CONTRACTS_DIR/zeroshade_TokenFactory.contract_class.json"
if [ -f "$FACTORY_FILE" ]; then
    echo "Declarando TokenFactory (sin hash explícito)..."
    starkli declare "$FACTORY_FILE" \
        --account "$ACCOUNT_EXPANDED" \
        --keystore "$KEYSTORE_EXPANDED" \
        --rpc "$RPC"
    echo ""
else
    echo "❌ No se encontró TokenFactory"
fi

echo "✅ Declaración completada"
echo ""
echo "Si Launchpad o TokenFactory dan error de mismatch,"
echo "usa el hash 'Expected' del mensaje de error con --casm-hash"

