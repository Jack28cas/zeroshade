#!/bin/bash

# Script para generar proof completo con Noir + Barretenberg + Garaga
# Uso: ./generate_proof.sh <circuit_name>

set -e

# Activar venv de Garaga si existe
if [ -d "garaga/venv" ]; then
    source garaga/venv/bin/activate
    echo "✅ Venv de Garaga activado"
elif [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Venv activado"
fi

if [ -z "$1" ]; then
    echo "❌ Error: Especifica el nombre del circuito"
    echo "   Uso: ./generate_proof.sh <circuit_name>"
    exit 1
fi

CIRCUIT_NAME=$1
CIRCUIT_DIR="src/noir/$CIRCUIT_NAME"

if [ -z "$CIRCUIT_NAME" ]; then
    echo "❌ Error: Especifica el nombre del circuito"
    echo "   Uso: ./generate_proof.sh <circuit_name>"
    echo "   Ejemplo: ./generate_proof.sh private_trading"
    exit 1
fi

if [ ! -d "$CIRCUIT_DIR" ]; then
    echo "❌ Error: Circuito no encontrado en $CIRCUIT_DIR"
    exit 1
fi

echo "🔐 Generando proof para $CIRCUIT_NAME..."
echo ""

cd "$CIRCUIT_DIR"

# 1. Compilar circuito
echo "📦 Compilando circuito..."
nargo compile

# 2. Generar witness
echo "📦 Generando witness..."
nargo execute witness

# 3. Obtener nombre del archivo JSON compilado
COMPILED_JSON=$(find ./target -name "*.json" -type f | head -1)
if [ -z "$COMPILED_JSON" ]; then
    echo "❌ Error: No se encontró el archivo JSON compilado"
    echo "   Buscando en: $(pwd)/target"
    ls -la ./target/ || true
    exit 1
fi

echo "   Usando circuito: $COMPILED_JSON"

# 4. Generar proof con Barretenberg
echo "📦 Generando proof con Barretenberg..."
bb prove_ultra_keccak_honk \
    -b "$COMPILED_JSON" \
    -w ./target/witness.gz \
    -o ./target/proof.bin

# 5. Generar verification key
echo "📦 Generando verification key..."
bb write_vk_ultra_keccak_honk \
    -b "$COMPILED_JSON" \
    -o ./target/vk.bin

# 6. Generar calldata con Garaga
echo "📦 Generando calldata con Garaga..."
garaga calldata \
    --system ultra_keccak_honk \
    --vk ./target/vk.bin \
    --proof ./target/proof.bin \
    --format starkli > ./target/calldata.txt

echo ""
echo "✅ Proof generado exitosamente!"
echo ""
echo "📁 Archivos generados:"
echo "   - Proof: ./target/proof.bin"
echo "   - VK: ./target/vk.bin"
echo "   - Calldata: ./target/calldata.txt"
echo ""
echo "💡 Próximo paso: Deploy verifier contract y llamar verify_ultra_keccak_honk_proof con el calldata"

