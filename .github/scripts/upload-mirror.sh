#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# URLs
MIRROR_URL="https://mirror.theflames.fun"
BACKEND_URL="http://161.118.191.145:4567"
API_KEY="your-super-secure-api-key-here"


show_help() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  upload <file> [folder]     Upload file"
    echo "  delete <file> [folder]     Delete file"
    echo ""
    echo "Environment Variables:"
    echo "  BACKEND_URL     Backend upload server URL"
    echo "  FLAMEOS_API_KEY API key for authentication"
    echo ""
    echo "Examples:"
    echo "  $0 upload flameos.iso FlameOS-Beta"
    echo "  $0 delete flameos.iso FlameOS-Beta"
}

upload_file() {
    local file="$1"
    local folder="$2"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File '$file' not found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Uploading $file to $BACKEND_URL...${NC}"
    
    # Create folder first
    if [ -n "$folder" ]; then
        echo -e "${YELLOW}Creating folder: $folder${NC}"
        curl -s -X POST \
            -H "X-API-Key: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"$folder\"}" \
            "$BACKEND_URL/folders" > /dev/null || echo "Folder may already exist"
        echo -e "${GREEN}✓ Folder ready${NC}"
    fi
    
    # Upload file
    if [ -n "$folder" ]; then
        response=$(curl -# -X POST \
            -H "X-API-Key: $API_KEY" \
            -F "iso=@$file" \
            -F "folder=$folder" \
            "$BACKEND_URL/upload" 2>&1)
    else
        response=$(curl -# -X POST \
            -H "X-API-Key: $API_KEY" \
            -F "iso=@$file" \
            "$BACKEND_URL/upload" 2>&1)
    fi
    
    echo ""
    if echo "$response" | grep -q "successfully"; then
        echo -e "${GREEN}✅ Upload successful!${NC}"
        echo -e "Available at: $MIRROR_URL"
        echo "$response"
    else
        echo -e "${RED}❌ Upload failed!${NC}"
        echo "$response"
        exit 1
    fi
}

delete_file() {
    local file="$1"
    local folder="$2"
    
    echo -e "${YELLOW}Deleting $file from $BACKEND_URL...${NC}"
    
    if [ -n "$folder" ]; then
        response=$(curl -s -X DELETE \
            -H "X-API-Key: $API_KEY" \
            "$BACKEND_URL/files/$folder/$file")
    else
        response=$(curl -s -X DELETE \
            -H "X-API-Key: $API_KEY" \
            "$BACKEND_URL/files/$file")
    fi
    
    if echo "$response" | grep -q "successfully"; then
        echo -e "${GREEN}✅ File deleted!${NC}"
    else
        echo -e "${RED}❌ Delete failed!${NC}"
        echo "$response"
        exit 1
    fi
}

case "$1" in
    upload)
        upload_file "$2" "$3"
        ;;
    delete)
        delete_file "$2" "$3"
        ;;
    *)
        show_help
        ;;
esac
