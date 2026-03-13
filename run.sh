#!/usr/bin/env bash
# ZayCraft Legends Launcher Script
# This script ensures Love2D runs with the correct working directory

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}WARNING: $1${NC}"; }

# Get the directory where this script is located
get_script_dir()
{
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            SOURCE_PATH="$SYMLINK_DIR/$SOURCE_PATH"
        fi
    done
    
    # Get final script directory path from fully resolved source path
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}

# Change to the script\'s directory
SCRIPT_DIR=$(get_script_dir)
cd "$SCRIPT_DIR" || {
    print_error "Failed to change to script directory: $SCRIPT_DIR"
    exit 1
}

print_success "Changed to directory: $SCRIPT_DIR"

# Check if main.lua exists in current directory
if [ ! -f "main.lua" ] && [ ! -f "main.lua" ]; then
    print_error "main.lua not found in current directory!"
    print_error "Please make sure this script is in the same directory as your game files."
    exit 1
fi

# Check if conf.lua exists (optional but recommended)
if [ ! -f "conf.lua" ]; then
    print_warning "conf.lua not found - using Love2D defaults"
fi

# Find love executable
LOVE_PATH=""
if command -v love >/dev/null 2>&1; then
    LOVE_PATH=$(command -v love)
elif command -v love2d >/dev/null 2>&1; then
    LOVE_PATH=$(command -v love2d)
elif [ -f "/usr/bin/love" ]; then
    LOVE_PATH="/usr/bin/love"
elif [ -f "/usr/local/bin/love" ]; then
    LOVE_PATH="/usr/local/bin/love"
elif [ -f "/Applications/love.app/Contents/MacOS/love" ]; then
    LOVE_PATH="/Applications/love.app/Contents/MacOS/love"
elif [ -f "C:/Program Files/LOVE/love.exe" ]; then
    LOVE_PATH="C:/Program Files/LOVE/love.exe"
elif [ -f "C:/Program Files (x86)/LOVE/love.exe" ]; then
    LOVE_PATH="C:/Program Files (x86)/LOVE/love.exe"
fi

if [ -z "$LOVE_PATH" ]; then
    print_error "Love2D executable not found!"
    print_error "Please install Love2D from: https://love2d.org"
    exit 1
fi

print_success "Found Love2D at: $LOVE_PATH"

# Check if we should run in debug mode
DEBUG_MODE=0
for arg in "$@"; do
    if [ "$arg" = "--debug" ] || [ "$arg" = "-d" ]; then
        DEBUG_MODE=1
        break
    fi
done

# Run the game
if [ $DEBUG_MODE -eq 1 ]; then
    print_success "Starting ZayCraft Legends in DEBUG mode..."
    echo "========================================"
    "$LOVE_PATH" . --console
else
    print_success "Starting ZayCraft Legends..."
    # On Linux, we can still show console output in terminal
    "$LOVE_PATH" .
fi

# Check exit code
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    print_error "Game exited with error code: $EXIT_CODE"
    echo ""
    echo "Troubleshooting tips:"
    echo "  1. Make sure you have Love2D 11.4 or later installed"
    echo "  2. Try running with --debug flag for more information"
    echo "  3. Check if all game files are present in: $SCRIPT_DIR"
    exit $EXIT_CODE
fi

print_success "Game closed successfully."