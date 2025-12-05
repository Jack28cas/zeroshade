#!/bin/bash

# Script para declarar el contrato Token

# No usar set -e aquí porque necesitamos capturar errores manualmente

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Scarb genera .contract_class.json que contiene sierra y casm
CONTRACT_FILE="target/dev/zeroshade_zeroshade_contracts_token_Token.contract_class.json"

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

# Declarar sin --casm-hash primero para obtener el hash correcto
# Si falla, starkli calculará el CASM hash automáticamente
echo "📋 Declarando contrato (starkli calculará el CASM hash automáticamente)..."
echo ""

# Ejecutar declare y capturar output
echo "Ejecutando starkli declare..."
DECLARE_OUTPUT=$(starkli declare "$CONTRACT_FILE" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" 2>&1)
DECLARE_EXIT_CODE=$?

echo "$DECLARE_OUTPUT"

# Si hay error de mismatch, intentar con el CASM hash calculado
if [ $DECLARE_EXIT_CODE -ne 0 ] && echo "$DECLARE_OUTPUT" | grep -q "Mismatch compiled class hash"; then
    echo ""
    echo "⚠️  Detectado mismatch de CASM hash. Intentando con el hash calculado..."
    
    # Extraer el CASM hash actual del output
    ACTUAL_CASM_HASH=$(echo "$DECLARE_OUTPUT" | grep -oE "Actual: 0x[0-9a-fA-F]{60,}" | grep -oE "0x[0-9a-fA-F]{60,}")
    
    if [ -n "$ACTUAL_CASM_HASH" ]; then
        echo "📋 Usando CASM hash: $ACTUAL_CASM_HASH"
        echo ""
        
        DECLARE_OUTPUT=$(starkli declare "$CONTRACT_FILE" \
            --account "$ACCOUNT_EXPANDED" \
            --keystore "$KEYSTORE_EXPANDED" \
            --rpc "$RPC" \
            --casm-hash "$ACTUAL_CASM_HASH" 2>&1)
        DECLARE_EXIT_CODE=$?
        
        echo "$DECLARE_OUTPUT"
    fi
fi

if [ $DECLARE_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Error al declarar el contrato (exit code: $DECLARE_EXIT_CODE)"
    echo ""
    echo "💡 Si el error persiste, el contrato puede necesitar ser declarado con un salt diferente"
    echo "   o el class hash ya existe en la blockchain con una versión diferente."
    exit 1
fi

# Extraer el class hash del output (buscar en diferentes formatos)
NEW_CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -iE "(Class hash declared|class hash|Class hash:)" | grep -oE "0x[0-9a-fA-F]{60,}" | head -1)

# Si no se encontró, buscar cualquier línea que contenga un hash largo
if [ -z "$NEW_CLASS_HASH" ]; then
    NEW_CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -oE "0x[0-9a-fA-F]{60,}" | head -1)
fi

if [ -n "$NEW_CLASS_HASH" ]; then
    echo ""
    echo "✅ Contrato declarado exitosamente"
    echo "📍 Nuevo Class Hash: $NEW_CLASS_HASH"
    echo ""
    echo "🔄 Actualizando class hash en scripts..."
    
    # Actualizar en deploy_token.sh
    if [ -f "scripts/deploy_token.sh" ]; then
        sed -i "s/TOKEN_CLASS_HASH=\"0x[0-9a-fA-F]\{60,\}\"/TOKEN_CLASS_HASH=\"$NEW_CLASS_HASH\"/" scripts/deploy_token.sh
        echo "   ✅ scripts/deploy_token.sh actualizado"
    fi
    
    # Actualizar en deploy_and_setup_token.sh
    if [ -f "scripts/deploy_and_setup_token.sh" ]; then
        sed -i "s/TOKEN_CLASS_HASH=\"0x[0-9a-fA-F]\{60,\}\"/TOKEN_CLASS_HASH=\"$NEW_CLASS_HASH\"/" scripts/deploy_and_setup_token.sh
        echo "   ✅ scripts/deploy_and_setup_token.sh actualizado"
    fi
    
    echo ""
    echo "💡 Class hash actualizado automáticamente en los scripts"
else
    echo ""
    echo "⚠️  No se pudo extraer el class hash automáticamente"
    echo "💡 Copia el class hash que aparece arriba y actualízalo manualmente en:"
    echo "   - scripts/deploy_token.sh (línea 15)"
    echo "   - scripts/deploy_and_setup_token.sh (línea 15)"
fi

