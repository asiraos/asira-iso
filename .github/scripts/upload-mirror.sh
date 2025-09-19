#!/bin/bash

API_KEY="your-api-key-here"
SERVER_URL="http://flame-production-flameosmirror-kwjazd-093119-161-118-191-145.traefik.me"

if [ $# -ne 2 ]; then
    echo "Usage: $0 <folder_path> <filename>"
    echo "Example: $0 documents myfile.zip"
    echo "Example: $0 . myfile.zip (for root)"
    exit 1
fi

FOLDER="$1"
FILENAME="$2"

if [ ! -f "$FILENAME" ]; then
    echo "Error: File '$FILENAME' not found"
    exit 1
fi

if [ "$FOLDER" = "." ]; then
    URL="$SERVER_URL/api/upload"
else
    URL="$SERVER_URL/api/upload/$FOLDER/"
fi

echo "Uploading $FILENAME to $FOLDER..."
curl -X POST -F "file=@$FILENAME" -H "Authorization: Bearer $API_KEY" "$URL"
echo ""
