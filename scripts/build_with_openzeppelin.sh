#!/bin/bash

# Script para compilar el proyecto con OpenZeppelin
# Usa --ignore-cairo-version para evitar conflictos de versión

set -e

echo "🔨 Compilando proyecto con OpenZeppelin..."
echo ""

scarb clean
scarb build --ignore-cairo-version

echo ""
echo "✅ Compilación completada"
echo ""
echo "💡 Si hay errores, verifica:"
echo "   1. Que OpenZeppelin esté correctamente configurado en Scarb.toml"
echo "   2. Que todos los contratos estén exportados en src/contracts.cairo"
echo "   3. Que la versión de OpenZeppelin sea compatible"

