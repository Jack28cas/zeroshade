#!/bin/bash

# Script maestro para desplegar todos los contratos en el orden correcto
# Orden: PausableERC20 -> Launchpad -> Token (opcional) -> TokenFactory (opcional)

set -e

echo "🚀 Despliegue completo de contratos ZumpFun"
echo "=========================================="
echo ""

# Verificar que scarb build se haya ejecutado
if [ ! -f "target/dev/zeroshade_PausableERC20.contract_class.json" ]; then
    echo "❌ Error: No se encontraron archivos compilados"
    echo "   Ejecuta 'scarb build' primero"
    exit 1
fi

echo "📋 Paso 1: Declarar PausableERC20"
echo "-----------------------------------"
read -p "¿Declarar PausableERC20? (S/n): " DECLARE_PAUSABLE
if [ "$DECLARE_PAUSABLE" != "n" ] && [ "$DECLARE_PAUSABLE" != "N" ]; then
    ./scripts/declare_pausable_erc20.sh
    echo ""
    read -p "Ingresa el CLASS HASH de PausableERC20: " PAUSABLE_CLASS_HASH
    if [ -n "$PAUSABLE_CLASS_HASH" ]; then
        # Actualizar el script de deploy
        sed -i "s/PAUSABLE_ERC20_CLASS_HASH=\"0x0000000000000000000000000000000000000000000000000000000000000000\"/PAUSABLE_ERC20_CLASS_HASH=\"$PAUSABLE_CLASS_HASH\"/" scripts/deploy_pausable_erc20.sh
        echo "✅ Class hash actualizado en deploy_pausable_erc20.sh"
    fi
fi

echo ""
echo "📦 Paso 2: Desplegar PausableERC20"
echo "-----------------------------------"
read -p "¿Desplegar PausableERC20? (S/n): " DEPLOY_PAUSABLE
if [ "$DEPLOY_PAUSABLE" != "n" ] && [ "$DEPLOY_PAUSABLE" != "N" ]; then
    ./scripts/deploy_pausable_erc20.sh
    echo ""
    read -p "Ingresa la dirección del PausableERC20 desplegado: " PAUSABLE_ADDRESS
    if [ -z "$PAUSABLE_ADDRESS" ]; then
        echo "⚠️  Necesitarás la dirección del PausableERC20 para desplegar el Launchpad"
    fi
fi

echo ""
echo "📋 Paso 3: Declarar Launchpad (v2 con payment_token)"
echo "-----------------------------------------------------"
read -p "¿Declarar Launchpad? (S/n): " DECLARE_LAUNCHPAD
if [ "$DECLARE_LAUNCHPAD" != "n" ] && [ "$DECLARE_LAUNCHPAD" != "N" ]; then
    ./scripts/declare_launchpad.sh
    echo ""
    read -p "Ingresa el CLASS HASH de Launchpad: " LAUNCHPAD_CLASS_HASH
    if [ -n "$LAUNCHPAD_CLASS_HASH" ]; then
        # Actualizar el script de deploy
        sed -i "s/LAUNCHPAD_CLASS_HASH=\"0x0000000000000000000000000000000000000000000000000000000000000000\"/LAUNCHPAD_CLASS_HASH=\"$LAUNCHPAD_CLASS_HASH\"/" scripts/deploy_launchpad.sh
        echo "✅ Class hash actualizado en deploy_launchpad.sh"
    fi
fi

echo ""
echo "📦 Paso 4: Desplegar Launchpad"
echo "------------------------------"
if [ -z "$PAUSABLE_ADDRESS" ]; then
    read -p "Ingresa la dirección del PausableERC20: " PAUSABLE_ADDRESS
fi

if [ -n "$PAUSABLE_ADDRESS" ]; then
    read -p "¿Desplegar Launchpad con payment_token=$PAUSABLE_ADDRESS? (S/n): " DEPLOY_LAUNCHPAD
    if [ "$DEPLOY_LAUNCHPAD" != "n" ] && [ "$DEPLOY_LAUNCHPAD" != "N" ]; then
        # Pasar la dirección como variable de entorno
        export PAYMENT_TOKEN="$PAUSABLE_ADDRESS"
        echo "$PAUSABLE_ADDRESS" | ./scripts/deploy_launchpad.sh
    fi
else
    echo "⚠️  No se puede desplegar Launchpad sin la dirección de PausableERC20"
fi

echo ""
echo "✅ Proceso de despliegue completado"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Actualiza las direcciones en backend/src/config/constants.ts"
echo "   2. Actualiza las direcciones en frontend/src/lib/constants.ts"
echo "   3. (Opcional) Despliega Token y TokenFactory si es necesario"

