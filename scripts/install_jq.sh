#!/bin/bash

# Script para instalar jq en WSL/Ubuntu

echo "📦 Instalando jq..."

if command -v jq &> /dev/null; then
    echo "✅ jq ya está instalado"
    jq --version
else
    sudo apt-get update
    sudo apt-get install -y jq
    echo "✅ jq instalado correctamente"
    jq --version
fi

