#!/bin/bash

# Script para limpiar y recompilar desde cero

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧹 Limpiando artefactos anteriores..."
cd "$PROJECT_ROOT"

# Limpiar target
if [ -d "target" ]; then
    echo "Eliminando directorio target..."
    rm -rf target
fi

echo ""
echo "🔨 Recompilando contratos..."
scarb build

echo ""
echo "✅ Recompilación completada"
echo ""
echo "Ahora intenta declarar de nuevo:"
echo "  ./scripts/declare_simple.sh"

