#!/bin/bash

# Script para obtener los CASM hashes de los contratos compilados
# Estos hashes se pueden usar con --casm-hash en starkli declare

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACTS_DIR="$PROJECT_ROOT/target/dev"

echo "=== CASM Hashes de los Contratos ==="
echo ""

# Verificar si jq está instalado
if ! command -v jq &> /dev/null; then
    echo "Instalando jq para procesar JSON..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    fi
fi

# Función para obtener el CASM hash de un archivo compiled_contract_class.json
get_casm_hash() {
    local file="$1"
    if [ -f "$file" ]; then
        jq -r '.compiled_class_hash' "$file" 2>/dev/null || echo "No encontrado"
    else
        echo "Archivo no existe"
    fi
}

# Token
echo "Token:"
TOKEN_CASM=$(get_casm_hash "$CONTRACTS_DIR/zeroshade_Token.compiled_contract_class.json")
echo "  CASM Hash: $TOKEN_CASM"
echo ""

# Launchpad
echo "Launchpad:"
LAUNCHPAD_CASM=$(get_casm_hash "$CONTRACTS_DIR/zeroshade_Launchpad.compiled_contract_class.json")
echo "  CASM Hash: $LAUNCHPAD_CASM"
echo ""

# TokenFactory
echo "TokenFactory:"
FACTORY_CASM=$(get_casm_hash "$CONTRACTS_DIR/zeroshade_TokenFactory.compiled_contract_class.json")
echo "  CASM Hash: $FACTORY_CASM"
echo ""

echo "=== Comandos para declarar con CASM hash ==="
echo ""
echo "# Token"
echo "starkli declare target/dev/zeroshade_Token.contract_class.json \\"
echo "  --rpc \$RPC --account \$ACCOUNT --keystore \$KEYSTORE \\"
echo "  --casm-hash $TOKEN_CASM"
echo ""
echo "# Launchpad"
echo "starkli declare target/dev/zeroshade_Launchpad.contract_class.json \\"
echo "  --rpc \$RPC --account \$ACCOUNT --keystore \$KEYSTORE \\"
echo "  --casm-hash $LAUNCHPAD_CASM"
echo ""
echo "# TokenFactory"
echo "starkli declare target/dev/zeroshade_TokenFactory.contract_class.json \\"
echo "  --rpc \$RPC --account \$ACCOUNT --keystore \$KEYSTORE \\"
echo "  --casm-hash $FACTORY_CASM"

