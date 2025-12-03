#!/bin/bash

# Setup para WSL (Windows Subsystem for Linux)
# Ejecutar dentro de WSL

set -e

echo "🐧 Configurando Noir y Garaga en WSL..."
echo ""

# Verificar que estamos en WSL
if [ -z "$WSL_DISTRO_NAME" ] && [ -z "$WSL_INTEROP" ]; then
    echo "⚠️  No parece que estés en WSL"
    echo "   Este script está optimizado para WSL"
    echo "   ¿Continuar de todas formas? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt-get update -qq

# Instalar dependencias básicas
echo "📦 Instalando dependencias..."
sudo apt-get install -y curl build-essential git

# Instalar Rust si no está
if ! command -v cargo &> /dev/null; then
    echo "📦 Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Instalar Barretenberg
echo ""
echo "📦 Instalando Barretenberg 0.67.0..."
if command -v bb &> /dev/null; then
    echo "   Barretenberg ya está instalado"
    bb --version
else
    curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/master/barretenberg/cpp/installation/install | bash
    # Cargar PATH actualizado
    export BB_HOME="${BB_HOME:-$HOME/.bb}"
    export PATH="$PATH:$BB_HOME"
    source ~/.bashrc 2>/dev/null || true
    # Instalar bb usando bbup
    if command -v bbup &> /dev/null || [ -f "$BB_HOME/bbup" ]; then
        if [ -f "$BB_HOME/bbup" ]; then
            "$BB_HOME/bbup"
        else
            bbup
        fi
    fi
    echo "   ✅ Barretenberg instalado"
    echo "   ⚠️  Si bb no funciona, reinicia la terminal o ejecuta: source ~/.bashrc"
fi

# Instalar Noir
echo ""
echo "📦 Instalando Noir 1.0.0-beta.1..."
if command -v nargo &> /dev/null; then
    echo "   Noir ya está instalado"
    nargo --version
else
    curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
    # Cargar PATH actualizado
    export PATH="$HOME/.noirup/bin:$PATH"
    source ~/.bashrc 2>/dev/null || true
    # Verificar que noirup está disponible
    if command -v noirup &> /dev/null || [ -f "$HOME/.noirup/bin/noirup" ]; then
        if [ -f "$HOME/.noirup/bin/noirup" ]; then
            "$HOME/.noirup/bin/noirup" --version 1.0.0-beta.1
        else
            noirup --version 1.0.0-beta.1
        fi
        echo "   ✅ Noir instalado"
    else
        echo "   ⚠️  noirup instalado pero no en PATH"
        echo "      Reinicia la terminal o ejecuta: source ~/.bashrc"
        echo "      Luego ejecuta: noirup --version 1.0.0-beta.1"
    fi
fi

# Instalar Garaga
echo ""
echo "📦 Instalando Garaga 0.15.5..."
if command -v garaga &> /dev/null; then
    echo "   Garaga ya está instalado"
    garaga --version
else
    cargo install --git https://github.com/keep-starknet-strange/garaga.git --tag v0.15.5 garaga
    echo "   ✅ Garaga instalado"
fi

# Verificar Scarb
echo ""
echo "📦 Verificando Scarb..."
if command -v scarb &> /dev/null; then
    scarb --version
    echo "   ⚠️  Recomendado: Scarb 2.9.2"
else
    echo "   ❌ Scarb no encontrado"
    echo "   Instala desde: https://docs.swmansion.com/scarb/"
fi

echo ""
echo "✅ Setup completado en WSL!"
echo ""
echo "📝 Verificar instalaciones:"
echo "   bb --version"
echo "   nargo --version"
echo "   garaga --version"
echo "   scarb --version"

