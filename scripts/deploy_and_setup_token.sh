#!/bin/bash

# Script completo para desplegar token y configurar Launchpad automáticamente

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
RPC="${RPC:-https://starknet-sepolia-rpc.publicnode.com}"

ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

# Class hash del Token (ya declarado)
TOKEN_CLASS_HASH="0x0000c1da35e0ca183429db3e8fcb0425b9308e6cd50850412ce7aa899ce84960"

# Dirección del Launchpad (v2 con payment_token)
LAUNCHPAD_ADDRESS="0x04ea108d263eac17f70af11fef789816d39b2fdf96d051da10c1d27c0f50e67b"

echo "🚀 Desplegando y Configurando Token Completo..."
echo ""

# Función para convertir texto a felt252 (hash simple)
text_to_felt252() {
    local text="$1"
    # Si es numérico, usarlo directamente
    if [[ "$text" =~ ^[0-9]+$ ]]; then
        echo "$text"
    else
        # Convertir texto a hash numérico simple (suma de códigos ASCII)
        local hash=0
        for (( i=0; i<${#text}; i++ )); do
            hash=$((hash + $(printf '%d' "'${text:$i:1}")))
        done
        # Multiplicar por un factor para evitar colisiones
        hash=$((hash * 256))
        echo "$hash"
    fi
}

# Obtener dirección del owner (tu cuenta)
echo "🔍 Obteniendo dirección de la cuenta..."
OWNER=""

# Método 1: Intentar leer del archivo JSON directamente
if [ -f "$ACCOUNT_EXPANDED" ]; then
    OWNER=$(jq -r '.address // .deployment.address // .account_address // .contract_address // empty' "$ACCOUNT_EXPANDED" 2>/dev/null || echo "")
    
    if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
        OWNER=$(jq -r 'paths(scalars) as $p | {($p | join(".")): getpath($p)} | to_entries[] | select(.value | type == "string" and startswith("0x") and length > 20) | .value' "$ACCOUNT_EXPANDED" 2>/dev/null | head -1 || echo "")
    fi
fi

# Método 2: Intentar con starkli account show
if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
    ACCOUNT_INFO=$(starkli account show "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null || echo "")
    if [ -n "$ACCOUNT_INFO" ]; then
        OWNER=$(echo "$ACCOUNT_INFO" | grep -iE "(address|contract)" | head -1 | grep -oE "0x[0-9a-fA-F]{60,}" | head -1 || echo "")
    fi
fi

# Método 3: Intentar con starkli account fetch
if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
    ACCOUNT_FETCH=$(starkli account fetch "$ACCOUNT_EXPANDED" --rpc "$RPC" 2>/dev/null || echo "")
    if [ -n "$ACCOUNT_FETCH" ]; then
        OWNER=$(echo "$ACCOUNT_FETCH" | grep -iE "(address|contract)" | head -1 | grep -oE "0x[0-9a-fA-F]{60,}" | head -1 || echo "")
    fi
fi

if [ -z "$OWNER" ] || [ "$OWNER" = "null" ] || [ "$OWNER" = "" ]; then
    echo "⚠️  No se pudo obtener la dirección del owner automáticamente"
    read -p "💡 Ingresa manualmente tu dirección de cuenta (0x...): " OWNER
    if [ -z "$OWNER" ] || [ "$OWNER" = "null" ]; then
        echo "❌ Error: Se requiere una dirección de cuenta válida"
        exit 1
    fi
    if ! [[ "$OWNER" =~ ^0x[0-9a-fA-F]+$ ]] || [ ${#OWNER} -lt 10 ]; then
        echo "❌ Error: La dirección debe tener formato 0x seguido de caracteres hexadecimales"
        exit 1
    fi
fi

echo "✅ Owner: $OWNER"
echo ""

# Solicitar parámetros del token (o leer de variables de entorno)
if [ -z "$TOKEN_NAME_INPUT" ]; then
    read -p "Token name (texto o número, ej: zero o 123456789): " TOKEN_NAME_INPUT
fi
if [ -z "$TOKEN_SYMBOL_INPUT" ]; then
    read -p "Token symbol (texto o número, ej: ZRO o 987654321): " TOKEN_SYMBOL_INPUT
fi
if [ -z "$INITIAL_SUPPLY" ]; then
    read -p "Initial supply (u256, ej: 0 para empezar sin supply): " INITIAL_SUPPLY
fi

# Obtener contraseña del keystore (de variable de entorno o stdin)
KEYSTORE_PASSWORD="${KEYSTORE_PASSWORD:-${STARKNET_KEYSTORE_PASSWORD:-}}"
if [ -z "$KEYSTORE_PASSWORD" ]; then
    read -sp "Keystore password: " KEYSTORE_PASSWORD
    echo ""
fi

# Convertir a felt252
TOKEN_NAME=$(text_to_felt252 "$TOKEN_NAME_INPUT")
TOKEN_SYMBOL=$(text_to_felt252 "$TOKEN_SYMBOL_INPUT")

echo ""
echo "📋 Desplegando Token con parámetros:"
echo "  Name (original): $TOKEN_NAME_INPUT"
echo "  Name (felt252): $TOKEN_NAME"
echo "  Symbol (original): $TOKEN_SYMBOL_INPUT"
echo "  Symbol (felt252): $TOKEN_SYMBOL"
echo "  Decimals: 6 (hardcoded)"
echo "  Initial Supply: $INITIAL_SUPPLY"
echo "  Owner: $OWNER"
echo ""

# Convertir u256 a low y high
INITIAL_SUPPLY_LOW="$INITIAL_SUPPLY"
INITIAL_SUPPLY_HIGH="0"

# Desplegar token
echo "🚀 Desplegando Token..."

# Cargar el perfil de bash para tener acceso al PATH completo (incluyendo ~/.cargo/bin)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc 2>/dev/null || true
fi
if [ -f ~/.profile ]; then
    source ~/.profile 2>/dev/null || true
fi

# Agregar ~/.cargo/bin al PATH si no está ya (donde generalmente está starkli)
if [ -d ~/.cargo/bin ] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Verificar que starkli esté disponible
if ! command -v starkli &> /dev/null; then
    echo "❌ Error: starkli no está instalado o no está en el PATH"
    echo "   PATH actual: $PATH"
    echo "   Intentando buscar starkli..."
    STARKLI_PATH=$(find ~ -name starkli -type f 2>/dev/null | head -1)
    if [ -n "$STARKLI_PATH" ]; then
        echo "   ✅ Encontrado en: $STARKLI_PATH"
        export PATH="$(dirname "$STARKLI_PATH"):$PATH"
    else
        echo "   ❌ No se encontró starkli"
        echo "   Por favor, instala starkli: cargo install starkli"
        exit 1
    fi
fi

echo "✅ starkli encontrado en: $(which starkli)"

# Ejecutar starkli deploy con la contraseña pasada por stdin
TOKEN_DEPLOY_OUTPUT=$(echo "$KEYSTORE_PASSWORD" | starkli deploy "$TOKEN_CLASS_HASH" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" \
    "$TOKEN_NAME" \
    "$TOKEN_SYMBOL" \
    "$INITIAL_SUPPLY_LOW" \
    "$INITIAL_SUPPLY_HIGH" \
    "$OWNER" 2>&1)

DEPLOY_EXIT_CODE=$?

if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
    echo "❌ Error al desplegar el token (código de salida: $DEPLOY_EXIT_CODE)"
    echo "Output completo:"
    echo "$TOKEN_DEPLOY_OUTPUT"
    exit $DEPLOY_EXIT_CODE
fi

# Extraer dirección del token del output
# Buscar la línea que contiene "Contract deployed:" y extraer la dirección de las líneas siguientes
TOKEN_ADDRESS=$(echo "$TOKEN_DEPLOY_OUTPUT" | grep -A 2 -iE "Contract deployed:" | grep -oE "0x[0-9a-fA-F]{60,}" | head -1)

# Si no se encontró, intentar buscar cualquier dirección después de "deployed"
if [ -z "$TOKEN_ADDRESS" ]; then
    TOKEN_ADDRESS=$(echo "$TOKEN_DEPLOY_OUTPUT" | grep -iE "deployed" | grep -oE "0x[0-9a-fA-F]{60,}" | head -1)
fi

# Si aún no se encontró, buscar la última dirección en el output (debería ser la del token)
if [ -z "$TOKEN_ADDRESS" ]; then
    TOKEN_ADDRESS=$(echo "$TOKEN_DEPLOY_OUTPUT" | grep -oE "0x[0-9a-fA-F]{60,}" | tail -1)
fi

if [ -z "$TOKEN_ADDRESS" ]; then
    echo "❌ Error: No se pudo obtener la dirección del token desplegado"
    echo "Output completo:"
    echo "$TOKEN_DEPLOY_OUTPUT"
    exit 1
fi

echo ""
echo "✅ Token desplegado exitosamente"
echo "📍 Token Address: $TOKEN_ADDRESS"
echo ""

# Esperar un poco para que la transacción se confirme
echo "⏳ Esperando confirmación de transacción..."
sleep 5

# Configurar Launchpad
echo ""
echo "🔧 Configurando Launchpad en el Token..."
echo "  Token: $TOKEN_ADDRESS"
echo "  Launchpad: $LAUNCHPAD_ADDRESS"
echo ""

INVOKE_OUTPUT=$(echo "$KEYSTORE_PASSWORD" | starkli invoke "$TOKEN_ADDRESS" \
    set_launchpad \
    "$LAUNCHPAD_ADDRESS" \
    --account "$ACCOUNT_EXPANDED" \
    --keystore "$KEYSTORE_EXPANDED" \
    --rpc "$RPC" 2>&1)

INVOKE_EXIT_CODE=$?

if [ $INVOKE_EXIT_CODE -ne 0 ]; then
    echo "❌ Error al configurar Launchpad (código de salida: $INVOKE_EXIT_CODE)"
    echo "Output completo:"
    echo "$INVOKE_OUTPUT"
    exit $INVOKE_EXIT_CODE
fi

echo ""
echo "✅ Launchpad configurado exitosamente"
echo ""

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Token Desplegado y Configurado Completamente"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Token Address: $TOKEN_ADDRESS"
echo "🔧 Launchpad Address: $LAUNCHPAD_ADDRESS"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Lanzar el token en el Launchpad (desde el frontend o con starkli)"
echo "   2. Mint PausableERC20 tokens para comprar: ./scripts/mint_pausable_erc20.sh"
echo ""
echo "💡 Para lanzar el token en el Launchpad, usa estos parámetros:"
echo "   - Token address: $TOKEN_ADDRESS"
echo "   - Precio inicial: 1000000 (1 USDC con 6 decimals)"
echo "   - k: 1000000"
echo "   - n: 1"
echo "   - fee_rate: 100 (1%)"
echo ""

