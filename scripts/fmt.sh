#!/bin/bash

# Format code using Scarb
echo "✨ Formatting code with Scarb..."

# Check if Scarb is installed
if ! command -v scarb &> /dev/null; then
    echo "❌ Scarb not found. Please install it first."
    echo "   Visit: https://docs.swmansion.com/scarb/"
    exit 1
fi

# Format all Cairo files
scarb fmt

if [ $? -eq 0 ]; then
    echo "✅ Code formatted successfully!"
else
    echo "❌ Formatting failed!"
    exit 1
fi

