#!/usr/bin/env python3
"""
Script para interactuar con los contratos de ZumpFun
Requiere: starknet.py y una cuenta configurada
"""

import os
import sys
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract
from starknet_py.net.networks import TESTNET, MAINNET
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configuración
NETWORK = TESTNET  # Cambiar a MAINNET para producción
CONTRACT_ADDRESSES = {
    "token": os.getenv("TOKEN_CONTRACT_ADDRESS"),
    "launchpad": os.getenv("LAUNCHPAD_CONTRACT_ADDRESS"),
    "factory": os.getenv("FACTORY_CONTRACT_ADDRESS"),
}

async def get_account():
    """Obtiene la cuenta de Starknet configurada"""
    private_key = os.getenv("STARKNET_PRIVATE_KEY")
    account_address = os.getenv("STARKNET_ACCOUNT_ADDRESS")
    
    if not private_key or not account_address:
        print("❌ Error: Configura STARKNET_PRIVATE_KEY y STARKNET_ACCOUNT_ADDRESS en .env")
        sys.exit(1)
    
    key_pair = KeyPair.from_private_key(int(private_key, 16))
    client = GatewayClient(net=NETWORK)
    account = AccountClient(
        address=account_address,
        client=client,
        key_pair=key_pair,
        chain=NETWORK.chain_id,
    )
    return account

async def interact_with_token():
    """Ejemplo de interacción con el contrato de tokens"""
    account = await get_account()
    
    if not CONTRACT_ADDRESSES["token"]:
        print("❌ Error: Configura TOKEN_CONTRACT_ADDRESS en .env")
        return
    
    print(f"📝 Interactuando con Token Contract: {CONTRACT_ADDRESSES['token']}")
    
    # Cargar el contrato
    # contract = await Contract.from_address_sync(
    #     address=CONTRACT_ADDRESSES["token"],
    #     provider=account
    # )
    
    # Ejemplo de llamadas
    # name = await contract.functions["name"].call()
    # symbol = await contract.functions["symbol"].call()
    # total_supply = await contract.functions["total_supply"].call()
    # print(f"Token: {name} ({symbol}) - Supply: {total_supply}")
    
    print("✅ Script de interacción configurado")
    print("💡 Descomenta y adapta según tus necesidades")

async def interact_with_launchpad():
    """Ejemplo de interacción con el launchpad"""
    account = await get_account()
    
    if not CONTRACT_ADDRESSES["launchpad"]:
        print("❌ Error: Configura LAUNCHPAD_CONTRACT_ADDRESS en .env")
        return
    
    print(f"📝 Interactuando con Launchpad Contract: {CONTRACT_ADDRESSES['launchpad']}")
    
    # Cargar el contrato
    # contract = await Contract.from_address_sync(
    #     address=CONTRACT_ADDRESSES["launchpad"],
    #     provider=account
    # )
    
    # Ejemplo: Obtener precio de un token
    # token_address = "0x..."
    # price = await contract.functions["get_price"].call(token_address)
    # print(f"Precio del token: {price}")
    
    print("✅ Script de interacción configurado")
    print("💡 Descomenta y adapta según tus necesidades")

async def main():
    """Función principal"""
    print("🚀 ZumpFun Contract Interaction Script")
    print("=" * 50)
    
    # Aquí puedes agregar tus interacciones
    # await interact_with_token()
    # await interact_with_launchpad()
    
    print("\n💡 Para usar este script:")
    print("   1. Configura las variables en .env")
    print("   2. Descomenta las funciones que necesites")
    print("   3. Ejecuta: python scripts/interact_contracts.py")

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())

