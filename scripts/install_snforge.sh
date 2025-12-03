#!/bin/bash

# Script para instalar Starknet Foundry (snforge)
# Para Windows, usa Git Bash o WSL

echo "🔧 Instalando Starknet Foundry..."

# Verificar si Rust está instalado
if command -v cargo &> /dev/null; then
    echo "✅ Rust/Cargo encontrado. Instalando snforge..."
    cargo install --locked --git https://github.com/foundry-rs/starknet-foundry.git --tag v0.18.0 snforge
    
    if [ $? -eq 0 ]; then
        echo "✅ snforge instalado correctamente!"
        echo ""
        echo "Verificar instalación:"
        snforge --version
    else
        echo "❌ Error al instalar snforge"
        echo ""
        echo "💡 Alternativa: Descarga el binario desde:"
        echo "   https://github.com/foundry-rs/starknet-foundry/releases"
    fi
else
    echo "❌ Rust/Cargo no encontrado"
    echo ""
    echo "📥 Opciones de instalación:"
    echo ""
    echo "Opción 1: Instalar Rust primero"
    echo "   Visita: https://rustup.rs/"
    echo "   Luego ejecuta este script nuevamente"
    echo ""
    echo "Opción 2: Descargar binario directamente"
    echo "   Visita: https://github.com/foundry-rs/starknet-foundry/releases"
    echo "   Descarga snforge para tu sistema"
    echo "   Agrega al PATH"
    echo ""
    echo "Opción 3: Usar Scoop (Windows)"
    echo "   scoop install starknet-foundry"
fi

