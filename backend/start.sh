#!/bin/bash
# Quick start script for Guardian One backend
# For Dustin's Day 10 demo

set -e  # Exit on error

echo "🚀 Guardian One Backend - Quick Start"
echo "======================================"
echo ""

# Check if we're in the backend directory
if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: Please run this script from the backend/ directory"
    echo "   cd backend && ./start.sh"
    exit 1
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed"
    echo "   Install Python 3.11+ from https://www.python.org/downloads/"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo ""
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo ""
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo ""
echo "📥 Installing dependencies..."
pip install -q -r requirements.txt
echo "✅ Dependencies installed"

# Check for .env file
if [ ! -f ".env" ]; then
    echo ""
    echo "⚠️  No .env file found"
    echo "   Creating .env from .env.example..."
    cp .env.example .env
    echo ""
    echo "⚙️  Please edit .env and add your OpenAI API key:"
    echo "   nano .env"
    echo ""
    echo "   Required: OPENAI_API_KEY=sk-..."
    echo ""
    read -p "Press Enter after adding your API key..."
fi

# Verify OpenAI API key is set
if ! grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
    echo ""
    echo "⚠️  OpenAI API key not found in .env file"
    echo "   Please add: OPENAI_API_KEY=sk-..."
    echo ""
    read -p "Press Enter after adding your API key..."
fi

echo ""
echo "======================================"
echo "🎉 Setup complete! Starting backend..."
echo "======================================"
echo ""
echo "Backend URL: http://localhost:8000"
echo "Swagger UI:  http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
python main.py
