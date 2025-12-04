#!/bin/bash

# Script para desplegar el contrato Launchpad

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del Launchpad (v2 con payment_token - declarado exitosamente)
LAUNCHPAD_CLASS_HASH="0x04337ddaf89f9953c217a68a8a28fdc4a7ef17f4dd93423063eaa5a60aa9495b"

echo "🚀 Desplegando Launchpad Contract (v2 con payment_token)..."
echo ""

# Obtener dirección del fee recipient (por defecto tu cuenta)
FEE_RECIPIENT=""

# Método 1: Leer del JSON directamente
if command -v jq &> /dev/null; then
    FEE_RECIPIENT=$(jq -r '.address // .deployment.address // empty' "$ACCOUNT_EXPANDED" 2>/dev/null)
fi

# Método 2: Usar starkli account fetch
if [ -z "$FEE_RECIPIENT" ] || [ "$FEE_RECIPIENT" == "null" ]; then
    FEE_RECIPIENT=$(starkli account fetch "$ACCOUNT_EXPANDED" --output --rpc "$RPC" 2>/dev/null || echo "")
fi

# Método 3: Usar starkli account show
if [ -z "$FEE_RECIPIENT" ] || [ "$FEE_RECIPIENT" == "null" ]; then
    FEE_RECIPIENT=$(starkli account show "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null | grep -i "address" | awk '{print $2}' || echo "")
fi

if [ -z "$FEE_RECIPIENT" ] || [ "$FEE_RECIPIENT" == "null" ]; then
    read -p "Fee recipient address: " FEE_RECIPIENT
fi

# Obtener dirección del PausableERC20 (payment token)
# Dirección por defecto del PausableERC20 desplegado
PAYMENT_TOKEN="${PAYMENT_TOKEN:-0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778}"

if [ -z "$PAYMENT_TOKEN" ]; then
    read -p "PausableERC20 address (payment token): " PAYMENT_TOKEN
fi

if [ -z "$PAYMENT_TOKEN" ]; then
    echo "❌ Error: Se requiere la dirección del PausableERC20"
    echo "   Despliega primero el PausableERC20 con: ./scripts/deploy_pausable_erc20.sh"
    exit 1
fi

if [ "$LAUNCHPAD_CLASS_HASH" == "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
    echo "⚠️  ADVERTENCIA: Class hash no configurado. Actualiza LAUNCHPAD_CLASS_HASH en este script."
    echo ""
    read -p "¿Continuar de todas formas? (s/N): " CONTINUE
    if [ "$CONTINUE" != "s" ] && [ "$CONTINUE" != "S" ]; then
        exit 1
    fi
fi

echo "Desplegando con parámetros:"
echo "  Fee Recipient: $FEE_RECIPIENT"
echo "  Payment Token (PausableERC20): $PAYMENT_TOKEN"
echo "  Class Hash: $LAUNCHPAD_CLASS_HASH"
echo ""

starkli deploy "$LAUNCHPAD_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$FEE_RECIPIENT" \
    "$PAYMENT_TOKEN"

echo ""
echo "✅ Launchpad desplegado exitosamente"
echo ""
echo "💡 Copia la dirección del contrato desplegado y actualízala en:"
echo "   - backend/src/config/constants.ts (LAUNCHPAD_ADDRESS)"
echo "   - frontend/src/lib/constants.ts (LAUNCHPAD_ADDRESS)"

