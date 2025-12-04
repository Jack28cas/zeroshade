#!/bin/bash

# Script para desplegar el contrato TokenFactory

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del TokenFactory (ya declarado)
FACTORY_CLASS_HASH="0x0474219f444d4707453604b268fbaf6184b0a653517de69a344827cac6a92120"

# Class hash del Token (necesario para el constructor)
TOKEN_CLASS_HASH="0x034a8ef7631c1919ff57a1132ddf1250d5ea562dd71cbbf3a7d0797e01a99a16"

echo "🚀 Desplegando TokenFactory Contract..."
echo ""

echo "Desplegando con parámetros:"
echo "  Token Class Hash: $TOKEN_CLASS_HASH"
echo ""

starkli deploy "$FACTORY_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    --constructor-calldata "$TOKEN_CLASS_HASH"

echo ""
echo "✅ TokenFactory desplegado exitosamente"

