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

# Hash esperado según el error (actualizado después de cambios en contratos)
TOKEN_EXPECTED_CASM="0x2ecb9e5e904f6b8cf98e4a6e611a92d27f6d4c2436ef7b4623b67f6d980678c"

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
LAUNCHPAD_EXPECTED_CASM="0x4f0eaf247b13df7144d9a77b748893d72a3658af9dc577613b59494c6446c99"
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

# 3. TokenFactory (con hash esperado según el error)
echo "=== TokenFactory ==="
FACTORY_FILE="$CONTRACTS_DIR/zeroshade_TokenFactory.contract_class.json"
FACTORY_EXPECTED_CASM="0x409bcc476c704ae07f1e50d520bf854b90e876745821c082130d9620a20c741"
if [ -f "$FACTORY_FILE" ]; then
    echo "Usando hash CASM esperado: $FACTORY_EXPECTED_CASM"
    echo "Declarando TokenFactory..."
    starkli declare "$FACTORY_FILE" \
        --account "$ACCOUNT_EXPANDED" \
        --keystore "$KEYSTORE_EXPANDED" \
        --rpc "$RPC" \
        --casm-hash "$FACTORY_EXPECTED_CASM"
    echo ""
else
    echo "❌ No se encontró TokenFactory"
fi

echo "✅ Declaración completada"
echo ""
echo "Si Launchpad o TokenFactory dan error de mismatch,"
echo "usa el hash 'Expected' del mensaje de error con --casm-hash"

