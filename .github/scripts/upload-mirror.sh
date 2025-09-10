#!/bin/bash

# FlameOS Mirror Upload Script
# Usage: ./upload-iso.sh <iso-file> [folder] [mirror-url]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
MIRROR_URL="${3:-https://mirror.theflames.fun}"
API_KEY="@rwafea9t7398"

show_help() {
    echo -e "${BLUE}🔥 FlameOS Mirror Upload Script${NC}"
    echo ""
    echo "Usage: $0 <iso-file> [folder] [mirror-url]"
    echo ""
    echo "Arguments:"
    echo "  iso-file    Path to ISO file to upload"
    echo "  folder      Target folder (optional)"
    echo "  mirror-url  Mirror server URL (optional, default: $MIRROR_URL)"
    echo ""
    echo "Environment Variables:"
    echo "  FLAMEOS_API_KEY  API key for authentication (required)"
    echo ""
    echo "Examples:"
    echo "  $0 flameos.iso"
    echo "  $0 flameos.iso releases"
    echo "  $0 flameos.iso releases https://mirror.flameos.com"
}

# Check arguments
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

ISO_FILE="$1"
FOLDER="$2"

# Validate inputs
if [ ! -f "$ISO_FILE" ]; then
    echo -e "${RED}Error: ISO file '$ISO_FILE' not found${NC}"
    exit 1
fi

if [ -z "$API_KEY" ]; then
    echo -e "${RED}Error: FLAMEOS_API_KEY environment variable not set${NC}"
    exit 1
fi

# Show upload info
echo -e "${YELLOW}🔥 FlameOS Mirror Upload${NC}"
echo -e "${BLUE}File:${NC} $ISO_FILE ($(ls -lh "$ISO_FILE" | awk '{print $5}'))"
echo -e "${BLUE}Mirror:${NC} $MIRROR_URL"
if [ -n "$FOLDER" ]; then
    echo -e "${BLUE}Folder:${NC} $FOLDER"
fi
echo ""

# Create folder if specified
if [ -n "$FOLDER" ]; then
    echo -e "${YELLOW}Creating folder: $FOLDER${NC}"
    
    folder_response=$(curl -s -X POST \
        -H "X-API-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$FOLDER\"}" \
        "$MIRROR_URL/api/folders")
    
    if echo "$folder_response" | grep -q "successfully\|already exists"; then
        echo -e "${GREEN}✓ Folder ready${NC}"
    else
        echo -e "${YELLOW}⚠ Folder creation response: $folder_response${NC}"
    fi
    echo ""
fi

# Upload file with progress bar
echo -e "${YELLOW}Uploading ISO file (no time limit for large files)...${NC}"

# Build curl command with progress bar
CURL_CMD="curl -X POST"
CURL_CMD="$CURL_CMD --max-time 0"
CURL_CMD="$CURL_CMD --retry 3"
CURL_CMD="$CURL_CMD --retry-delay 5"
CURL_CMD="$CURL_CMD --progress-bar"
CURL_CMD="$CURL_CMD -H 'X-API-Key: $API_KEY'"
CURL_CMD="$CURL_CMD -F 'iso=@$ISO_FILE'"

if [ -n "$FOLDER" ]; then
    CURL_CMD="$CURL_CMD -F 'folder=$FOLDER'"
fi

CURL_CMD="$CURL_CMD '$MIRROR_URL/api/upload'"

# Execute upload with progress bar
echo "Starting upload with progress indicator..."
echo ""
upload_response=$(eval $CURL_CMD 2>&1)
curl_exit_code=$?

echo ""

# Check curl exit code
if [ $curl_exit_code -ne 0 ]; then
    echo -e "${RED}❌ Upload failed with curl error code: $curl_exit_code${NC}"
    case $curl_exit_code in
        7)
            echo -e "${RED}Connection failed - check if server is running${NC}"
            ;;
        52)
            echo -e "${RED}Server returned empty response${NC}"
            ;;
        56)
            echo -e "${RED}Connection reset by server${NC}"
            ;;
        *)
            echo -e "${RED}Unknown curl error${NC}"
            ;;
    esac
    echo "Response: $upload_response"
    exit 1
fi

# Check response content
if echo "$upload_response" | grep -q "successfully"; then
    echo -e "${GREEN}✅ Upload successful!${NC}"
    
    # Extract download URL if available
    download_url=$(echo "$upload_response" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$download_url" ]; then
        echo -e "${BLUE}Download URL:${NC} $download_url"
    fi
    
    echo ""
    echo "$upload_response" | jq '.' 2>/dev/null || echo "$upload_response"
elif echo "$upload_response" | grep -q "Bad Gateway\|502\|504"; then
    echo -e "${RED}❌ Server error (Bad Gateway/Timeout)${NC}"
    echo -e "${YELLOW}Server needs configuration for large files${NC}"
    echo -e "${BLUE}Check SERVER_CONFIG.md for setup instructions${NC}"
    echo ""
    echo "Server response: $upload_response"
    exit 1
else
    echo -e "${RED}❌ Upload failed!${NC}"
    echo "$upload_response"
    exit 1
fi
