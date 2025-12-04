#!/bin/bash

# Script para clonar OpenZeppelin Cairo Contracts localmente
# Esto es necesario para usar PausableERC20

set -e

ZEROSHADE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENZEPPELIN_DIR="$ZEROSHADE_DIR/../cairo-contracts"

echo "📦 Configurando OpenZeppelin Cairo Contracts localmente..."
echo ""

if [ -d "$OPENZEPPELIN_DIR" ]; then
    echo "✅ Repositorio OpenZeppelin ya existe en: $OPENZEPPELIN_DIR"
    echo "   Actualizando..."
    cd "$OPENZEPPELIN_DIR"
    git pull origin main || git pull origin master
else
    echo "📥 Clonando repositorio OpenZeppelin..."
    cd "$ZEROSHADE_DIR/.."
    git clone https://github.com/OpenZeppelin/cairo-contracts.git
    cd cairo-contracts
    
    # Usar un tag específico compatible con Cairo 2.12.2
    echo "🔍 Buscando tag compatible con Cairo 2.12.2..."
    # Intentar con v0.14.0 primero
    if git tag | grep -q "v0.14.0"; then
        git checkout v0.14.0
        echo "✅ Usando tag v0.14.0"
    else
        echo "⚠️  Tag v0.14.0 no encontrado, usando main"
        git checkout main
    fi
fi

echo ""
echo "✅ OpenZeppelin configurado en: $OPENZEPPELIN_DIR"
echo ""
echo "💡 Ahora puedes compilar con: scarb build"

