#!/bin/bash

# Script para desplegar el contrato Token

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del Token (ya declarado - nuevo después de cambios)
TOKEN_CLASS_HASH="0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960"

echo "🚀 Desplegando Token Contract..."
echo ""

# Parámetros del constructor (ajusta según necesites)
# Nota: decimals está hardcodeado a 6 en el contrato
# IMPORTANTE: felt252 debe ser un número válido (no puede exceder el rango)
read -p "Token name (felt252, número pequeño, ej: 123456789): " TOKEN_NAME
read -p "Token symbol (felt252, número pequeño, ej: 987654321): " TOKEN_SYMBOL
read -p "Initial supply (u256, ej: 1000000000000 para 1M tokens con 6 decimals): " INITIAL_SUPPLY

# Validar que los valores sean números válidos y no demasiado grandes
if ! [[ "$TOKEN_NAME" =~ ^[0-9]+$ ]] || [ ${#TOKEN_NAME} -gt 76 ]; then
    echo "❌ Error: Token name debe ser un número y no puede exceder 76 dígitos"
    exit 1
fi

if ! [[ "$TOKEN_SYMBOL" =~ ^[0-9]+$ ]] || [ ${#TOKEN_SYMBOL} -gt 76 ]; then
    echo "❌ Error: Token symbol debe ser un número y no puede exceder 76 dígitos"
    exit 1
fi

# Obtener dirección del owner (tu cuenta)
echo "🔍 Obteniendo dirección de la cuenta..."
OWNER=""

# Método 1: Intentar leer del archivo JSON directamente (más confiable)
if [ -f "$ACCOUNT_EXPANDED" ]; then
    # Intentar diferentes estructuras de archivo de cuenta
    OWNER=$(jq -r '.address // .deployment.address // .account_address // .contract_address // empty' "$ACCOUNT_EXPANDED" 2>/dev/null || echo "")
    
    # Si aún no se encontró, intentar leer el primer valor que parezca una dirección
    if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
        # Buscar cualquier campo que contenga "0x" y tenga más de 20 caracteres
        OWNER=$(jq -r 'paths(scalars) as $p | {($p | join(".")): getpath($p)} | to_entries[] | select(.value | type == "string" and startswith("0x") and length > 20) | .value' "$ACCOUNT_EXPANDED" 2>/dev/null | head -1 || echo "")
    fi
fi

# Método 2: Intentar con starkli account show (si jq no funcionó)
if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
    ACCOUNT_INFO=$(starkli account show "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null || echo "")
    if [ -n "$ACCOUNT_INFO" ]; then
        OWNER=$(echo "$ACCOUNT_INFO" | grep -iE "(address|contract)" | head -1 | grep -oE "0x[0-9a-fA-F]{60,}" | head -1 || echo "")
    fi
fi

# Método 3: Intentar con starkli account fetch
if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
    ACCOUNT_FETCH=$(starkli account fetch "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null || echo "")
    if [ -n "$ACCOUNT_FETCH" ]; then
        OWNER=$(echo "$ACCOUNT_FETCH" | grep -iE "(address|contract)" | head -1 | grep -oE "0x[0-9a-fA-F]{60,}" | head -1 || echo "")
    fi
fi

if [ -z "$OWNER" ] || [ "$OWNER" = "null" ] || [ "$OWNER" = "" ]; then
    echo "⚠️  No se pudo obtener la dirección del owner automáticamente"
    echo "   Intentando leer desde: $ACCOUNT_EXPANDED"
    if [ -f "$ACCOUNT_EXPANDED" ]; then
        echo "   Contenido del archivo:"
        cat "$ACCOUNT_EXPANDED" 2>/dev/null | head -10 || echo "   (No se pudo leer el archivo)"
    else
        echo "   (El archivo no existe)"
    fi
    echo ""
    read -p "💡 Ingresa manualmente tu dirección de cuenta (0x...): " OWNER
    if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
        echo "❌ Error: Se requiere una dirección de cuenta válida"
        exit 1
    fi
    # Validar formato básico de dirección
    if ! [[ "$OWNER" =~ ^0x[0-9a-fA-F]+$ ]] || [ ${#OWNER} -lt 10 ]; then
        echo "❌ Error: La dirección debe tener formato 0x seguido de caracteres hexadecimales"
        exit 1
    fi
fi

echo "✅ Owner: $OWNER"

echo ""
echo "Desplegando con parámetros:"
echo "  Name: $TOKEN_NAME"
echo "  Symbol: $TOKEN_SYMBOL"
echo "  Decimals: 6 (hardcoded)"
echo "  Initial Supply: $INITIAL_SUPPLY"
echo "  Owner: $OWNER"
echo ""

# Convertir u256 a low y high (felt252)
# Para simplificar, asumimos que INITIAL_SUPPLY cabe en u128
INITIAL_SUPPLY_LOW="$INITIAL_SUPPLY"
INITIAL_SUPPLY_HIGH="0"

starkli deploy "$TOKEN_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$TOKEN_NAME" \
    "$TOKEN_SYMBOL" \
    "$INITIAL_SUPPLY_LOW" \
    "$INITIAL_SUPPLY_HIGH" \
    "$OWNER"

echo ""
echo "✅ Token desplegado exitosamente"

