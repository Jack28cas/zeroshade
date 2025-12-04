#!/bin/bash

# Script para limpiar archivos innecesarios en target/dev
# Solo elimina archivos de ExampleContract que ya no se usan

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$PROJECT_ROOT/target/dev"

echo "🧹 Limpiando archivos innecesarios en target/dev..."
echo ""

# Archivos a eliminar (solo ExampleContract que es un ejemplo)
FILES_TO_REMOVE=(
    "zeroshade_ExampleContract.compiled_contract_class.json"
    "zeroshade_ExampleContract.contract_class.json"
    "zeroshade_ExampleContract.sierra.json"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    file_path="$TARGET_DIR/$file"
    if [ -f "$file_path" ]; then
        echo "Eliminando: $file"
        rm "$file_path"
    fi
done

echo ""
echo "✅ Limpieza completada"
echo ""
echo "Archivos que se mantienen (necesarios):"
echo "  - zeroshade_Token.*"
echo "  - zeroshade_Launchpad.*"
echo "  - zeroshade_TokenFactory.*"
echo "  - zeroshade.starknet_artifacts.json"
echo "  - incremental/ (caché de compilación)"

