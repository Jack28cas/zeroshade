#!/bin/bash

# Script para inicializar/actualizar la cuenta con el keystore actual

set -e

ACCOUNT="${ACCOUNT:-~/.starkli/accounts/sepolia/my.json}"
KEYSTORE="${KEYSTORE:-~/.starkli/keystores/my_keystore.json}"
ACCOUNT_EXPANDED=$(eval echo "$ACCOUNT")
KEYSTORE_EXPANDED=$(eval echo "$KEYSTORE")

echo "🔧 Configurando cuenta con keystore..."
echo "Cuenta: $ACCOUNT_EXPANDED"
echo "Keystore: $KEYSTORE_EXPANDED"
echo ""

# Verificar que el keystore existe
if [ ! -f "$KEYSTORE_EXPANDED" ]; then
    echo "❌ ERROR: Keystore no encontrado: $KEYSTORE_EXPANDED"
    exit 1
fi

# Verificar si la cuenta ya existe
if [ -f "$ACCOUNT_EXPANDED" ]; then
    echo "⚠️  La cuenta ya existe."
    echo ""
    read -p "¿Quieres recrearla con el nuevo keystore? (s/n): " respuesta
    
    if [[ "$respuesta" =~ ^[Ss]$ ]]; then
        BACKUP_FILE="${ACCOUNT_EXPANDED}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Haciendo backup a: $BACKUP_FILE"
        cp "$ACCOUNT_EXPANDED" "$BACKUP_FILE"
        
        echo "Eliminando cuenta existente..."
        rm "$ACCOUNT_EXPANDED"
        
        echo "Creando nueva cuenta..."
        starkli account oz init "$ACCOUNT_EXPANDED" --keystore "$KEYSTORE_EXPANDED"
    else
        echo "Manteniendo cuenta existente."
        echo ""
        echo "Si quieres actualizar la cuenta manualmente:"
        echo "  starkli account oz init $ACCOUNT_EXPANDED --keystore $KEYSTORE_EXPANDED"
    fi
else
    echo "Creando nueva cuenta..."
    # Crear directorio si no existe
    mkdir -p "$(dirname "$ACCOUNT_EXPANDED")"
    
    starkli account oz init "$ACCOUNT_EXPANDED" --keystore "$KEYSTORE_EXPANDED"
fi

echo ""
echo "✅ Cuenta configurada"
echo ""
echo "Para obtener la dirección de la cuenta:"
echo "  starkli account fetch $ACCOUNT_EXPANDED --output"
echo ""
echo "Para desplegar la cuenta (si aún no está desplegada):"
echo "  starkli account deploy $ACCOUNT_EXPANDED --keystore $KEYSTORE_EXPANDED"

