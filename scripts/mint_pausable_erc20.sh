#!/bin/bash

# Script para acuñar (mint) tokens de PausableERC20
# Solo el owner puede hacer mint

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Dirección del contrato PausableERC20 desplegado
PAUSABLE_ERC20_ADDRESS="0x03f07d3175ee42202dd88d409b15557625891be4d051ed797d663d63b55f2778"

echo "🪙 Acuñando tokens de PausableERC20..."
echo ""

# Obtener dirección del recipient (por defecto tu cuenta)
RECIPIENT=""

# Método 1: Leer del JSON directamente
if command -v jq &> /dev/null; then
    RECIPIENT=$(jq -r '.address // .deployment.address // empty' "$ACCOUNT_EXPANDED" 2>/dev/null)
fi

# Método 2: Usar starkli account fetch
if [ -z "$RECIPIENT" ] || [ "$RECIPIENT" == "null" ]; then
    RECIPIENT=$(starkli account fetch "$ACCOUNT_EXPANDED" --output --rpc "$RPC" 2>/dev/null || echo "")
fi

# Método 3: Usar starkli account show
if [ -z "$RECIPIENT" ] || [ "$RECIPIENT" == "null" ]; then
    RECIPIENT=$(starkli account show "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null | grep -i "address" | awk '{print $2}' || echo "")
fi

if [ -z "$RECIPIENT" ] || [ "$RECIPIENT" == "null" ]; then
    read -p "Recipient address (dirección que recibirá los tokens): " RECIPIENT
fi

if [ -z "$RECIPIENT" ]; then
    echo "❌ Error: No se pudo obtener la dirección del recipient"
    exit 1
fi

# Solicitar cantidad
read -p "Cantidad de USDC a acuñar (ej: 100000 para 100,000 USDC): " AMOUNT_INPUT

if [ -z "$AMOUNT_INPUT" ]; then
    echo "❌ Error: La cantidad es requerida"
    exit 1
fi

# Convertir a u256 (con 6 decimals)
# Ejemplo: 100000 USDC = 100000 * 10^6 = 100000000000
# Usar awk para multiplicar (más compatible que bc)
AMOUNT=$(awk "BEGIN {printf \"%.0f\", $AMOUNT_INPUT * 1000000}")

# Convertir u256 a formato low/high
# Para valores < 2^128, solo necesitamos low y high=0
U256_LOW="$AMOUNT"
U256_HIGH="0"

echo ""
echo "Acuñando con parámetros:"
echo "  Contract: $PAUSABLE_ERC20_ADDRESS"
echo "  Recipient: $RECIPIENT"
echo "  Amount: $AMOUNT_INPUT USDC ($AMOUNT con 6 decimals)"
echo "  Amount (u256): $U256_LOW $U256_HIGH"
echo ""

starkli invoke \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$PAUSABLE_ERC20_ADDRESS" \
    "mint" \
    "$RECIPIENT" \
    "$U256_LOW" \
    "$U256_HIGH"

echo ""
echo "✅ Mint exitoso!"
echo ""
echo "💡 Verifica tu balance con:"
echo "   starkli call $PAUSABLE_ERC20_ADDRESS balance_of $RECIPIENT --rpc $RPC"

