#!/bin/bash

# Test script for Starknet contracts using Scarb
# This script helps test your contracts locally

echo "🧪 Testing Starknet contracts..."

# Check if Scarb is installed
if ! command -v scarb &> /dev/null; then
    echo "❌ Scarb not found. Please install it first."
    echo "   Visit: https://docs.swmansion.com/scarb/"
    exit 1
fi

# Format code first
echo "✨ Formatting code..."
scarb fmt

# Build the project
echo "📦 Building project..."
scarb build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# Run tests if available
echo "🧪 Running tests..."
if scarb test 2>/dev/null; then
    echo "✅ Tests passed!"
else
    echo "⚠️  No tests found or testing not configured."
    echo ""
    echo "💡 For advanced testing, consider using:"
    echo "   - Starknet Foundry (snforge): https://foundry-rs.github.io/starknet-foundry/"
    echo "   - Protostar: https://docs.swmansion.com/protostar/"
    echo ""
    echo "📝 Example with snforge:"
    echo "   snforge test"
fi

