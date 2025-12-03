#!/bin/bash

# Setup script for the project
# This script helps set up the development environment

echo "🚀 Setting up ZeroShade project..."

# Check if Scarb is installed
if ! command -v scarb &> /dev/null; then
    echo "❌ Scarb not found. Please install it first."
    echo ""
    echo "📥 Installation options:"
    echo "   Windows (Scoop): scoop install scarb"
    echo "   Or visit: https://docs.swmansion.com/scarb/"
    exit 1
fi

echo "✅ Scarb found: $(scarb --version)"

# Build the project
echo ""
echo "📦 Building project..."
scarb build

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Check the errors above."
    exit 1
fi

echo "✅ Build successful!"

# Format code
echo ""
echo "✨ Formatting code..."
scarb fmt

# Check Python dependencies (optional)
if command -v python &> /dev/null || command -v python3 &> /dev/null; then
    echo ""
    echo "🐍 Python found. Install dependencies? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        pip install -r requirements.txt
        echo "✅ Python dependencies installed!"
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Review PROJECT_IDEAS.md to choose your hackathon project"
echo "   2. Start developing your contracts in src/contracts/"
echo "   3. Use 'scarb build' to compile"
echo "   4. Use 'scarb fmt' to format"
echo "   5. Use 'scarb test' to test"
echo ""
echo "💡 Useful commands:"
echo "   scarb build    - Compile contracts"
echo "   scarb fmt      - Format code"
echo "   scarb test     - Run tests"
echo "   scarb add <pkg>@<ver> - Add dependency"

