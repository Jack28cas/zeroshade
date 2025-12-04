#!/bin/bash

# Script para declarar el contrato PausableERC20

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Scarb genera .contract_class.json que contiene sierra y casm
CONTRACT_FILE="target/dev/zeroshade_zeroshade_contracts_PausableERC20_Token.contract_class.json"

echo "📋 Declarando contrato PausableERC20..."
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
echo "📋 Declarando PausableERC20..."
echo ""
echo "⚠️  NOTA: Asegúrate de haber compilado con: scarb build --ignore-cairo-version"
echo ""

# Si hay un error de hash mismatch, usa el hash esperado con --casm-hash
# Hash actualizado después de modificar el constructor para usar initial_supply
starkli declare "$CONTRACT_FILE" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    --casm-hash 0x50c2a55fef4d3d24b8ef86e08291db22c186a8529a49218bae0ecab6254f5a

echo ""
echo "✅ Contrato declarado exitosamente"
echo ""
echo "💡 Copia el class hash que aparece arriba y actualízalo en:"
echo "   - scripts/deploy_pausable_erc20.sh (línea 15)"
echo "   - backend/src/config/constants.ts (PAUSABLE_ERC20_CLASS_HASH)"
echo "   - frontend/src/lib/constants.ts (PAUSABLE_ERC20_CLASS_HASH)"

