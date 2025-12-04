#!/bin/bash

# Script para desplegar contratos en Starknet

set -e

ACCOUNT_FILE="${STARKNET_ACCOUNT:-$HOME/.starkli/accounts/sepolia/my_account.json}"
KEYSTORE_PATH="${STARKNET_KEYSTORE:-$HOME/.starkli/keystores/my_keystore.json}"
RPC_URL="${STARKNET_RPC_URL:-https://starknet-sepolia.infura.io/v3/f0749a013da84616a6781fce432f2915}"

if [ -z "$1" ]; then
    echo "📋 Uso: $0 <class_hash> [constructor_calldata...]"
    echo ""
    echo "Ejemplo para Token Factory:"
    echo "  $0 0x1234... 0x5678..."
    echo ""
    echo "Ejemplo para Launchpad:"
    echo "  $0 0x1234... <fee_recipient_address>"
    exit 1
fi

CLASS_HASH="$1"
shift
CONSTRUCTOR_CALLDATA="$@"

echo "🚀 Desplegando contrato..."
echo "   Class Hash: $CLASS_HASH"
echo "   Cuenta: $ACCOUNT_FILE"
echo ""

if [ -z "$CONSTRUCTOR_CALLDATA" ]; then
    starkli deploy "$CLASS_HASH" \
        --account "$ACCOUNT_FILE" \
        --keystore "$KEYSTORE_PATH" \
        --rpc "$RPC_URL"
else
    starkli deploy "$CLASS_HASH" \
        --account "$ACCOUNT_FILE" \
        --keystore "$KEYSTORE_PATH" \
        --rpc "$RPC_URL" \
        --constructor-calldata $CONSTRUCTOR_CALLDATA
fi

echo ""
echo "✅ Contrato desplegado exitosamente!"
echo "   Guarda la dirección del contrato que apareció arriba"
echo ""

