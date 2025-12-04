#!/bin/bash

# Script para desplegar el contrato TokenFactory

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del TokenFactory (ya declarado - nuevo después de cambios)
FACTORY_CLASS_HASH="0x008c7076311e0f842806c474162f13f9086791ec2c80ada96d3359def0f8c5bc"

# Class hash del Token (necesario para el constructor - nuevo después de cambios)
TOKEN_CLASS_HASH="0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960"

echo "🚀 Desplegando TokenFactory Contract..."
echo ""

echo "Desplegando con parámetros:"
echo "  Token Class Hash: $TOKEN_CLASS_HASH"
echo ""

starkli deploy "$FACTORY_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$TOKEN_CLASS_HASH"

echo ""
echo "✅ TokenFactory desplegado exitosamente"

