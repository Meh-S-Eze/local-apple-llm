#!/bin/bash

# Create Python virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt

# Build Swift package
echo "Building Swift package..."
swift build

echo "Setup complete! To start the chat interface:"
echo "1. Activate the virtual environment: source venv/bin/activate"
echo "2. Run Chainlit: chainlit run chainlit_app.py -w" 