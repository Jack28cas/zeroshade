#!/bin/bash

# Deploy script for Starknet contracts
# Make sure you have starknet-cli installed and configured

echo "🚀 Deploying contract to Starknet..."

# Check if starknet-cli is installed
if ! command -v starknet &> /dev/null; then
    echo "❌ starknet-cli not found. Please install it first."
    echo "   Visit: https://www.starknet.io/en/developers/getting-started"
    exit 1
fi

# Build the contract first
echo "📦 Building contract..."
scarb build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""
echo "📝 Next steps:"
echo "   1. Deploy to testnet: starknet deploy --contract target/dev/zeroshade_example_contract.sierra.json"
echo "   2. Or use a deployment script with your preferred tool (Starkli, Protostar, etc.)"
echo ""
echo "💡 Tip: Make sure you have a Starknet account configured and funded!"

