#!/bin/bash
# macOS launcher for ZayCraft Legends

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check if main.lua exists
if [ ! -f "main.lua" ]; then
    osascript -e 'display dialog "main.lua not found!\nPlease make sure this script is in the same directory as your game files." buttons {"OK"} default button 1 with icon stop'
    exit 1
fi

# Find Love2D application
LOVE_APP="/Applications/love.app"
if [ ! -d "$LOVE_APP" ]; then
    osascript -e 'display dialog "Love2D not found!\nPlease install Love2D from https://love2d.org" buttons {"OK"} default button 1 with icon stop'
    exit 1
fi

# Run the game
open -a love "$SCRIPT_DIR"