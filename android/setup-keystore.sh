#!/bin/bash

# PDF Chef Android - Keystore Setup Script
# This script helps you generate a keystore and prepare GitHub secrets

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}PDF Chef Android - Keystore Setup${NC}"
echo "===================================="
echo ""

# Check if keystore already exists
if [ -f "release-keystore.jks" ]; then
    echo -e "${YELLOW}Warning: release-keystore.jks already exists${NC}"
    read -p "Do you want to create a new one? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing keystore..."
        KEYSTORE_FILE="release-keystore.jks"
    fi
fi

if [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "${GREEN}Creating new keystore...${NC}"
    echo ""
    
    read -p "Enter keystore password: " KEYSTORE_PASSWORD
    read -p "Enter key alias (default: pdf-chef-key): " KEY_ALIAS
    KEY_ALIAS=${KEY_ALIAS:-pdf-chef-key}
    read -p "Enter key password: " KEY_PASSWORD
    read -p "Enter validity in days (default: 10000): " VALIDITY
    VALIDITY=${VALIDITY:-10000}
    
    keytool -genkey -v \
        -keystore release-keystore.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity $VALIDITY \
        -alias "$KEY_ALIAS" \
        -storepass "$KEYSTORE_PASSWORD" \
        -keypass "$KEY_PASSWORD"
    
    KEYSTORE_FILE="release-keystore.jks"
    echo -e "${GREEN}✓ Keystore created successfully${NC}"
fi

echo ""
echo -e "${GREEN}Encoding keystore to Base64...${NC}"

if command -v base64 &> /dev/null; then
    base64 -i release-keystore.jks -o keystore.b64 2>/dev/null || \
    base64 < release-keystore.jks > keystore.b64
    echo -e "${GREEN}✓ Keystore encoded to keystore.b64${NC}"
else
    echo -e "${RED}Error: base64 command not found${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}GitHub Secrets Setup${NC}"
echo "===================="
echo ""
echo "Add these secrets to your GitHub repository:"
echo ""
echo "1. Go to: GitHub.com → Your Repository → Settings → Secrets and variables → Actions"
echo ""
echo "2. Create these 4 secrets:"
echo ""

echo -e "${YELLOW}KEYSTORE_ENCODED${NC}:"
echo "   Copy the contents of keystore.b64:"
echo ""
head -c 50 keystore.b64
echo "..."
echo ""

echo -e "${YELLOW}KEYSTORE_PASSWORD${NC}:"
echo "   The password you entered above"
echo ""

echo -e "${YELLOW}KEY_ALIAS${NC}:"
echo "   The key alias you entered above (default: pdf-chef-key)"
echo ""

echo -e "${YELLOW}KEY_PASSWORD${NC}:"
echo "   The key password you entered above"
echo ""

echo -e "${GREEN}Security Reminders${NC}"
echo "=================="
echo ""
echo "⚠️  DO NOT commit the following files:"
echo "   - release-keystore.jks"
echo "   - keystore.b64"
echo ""
echo "✓ These files are listed in .gitignore"
echo ""

echo -e "${GREEN}Next Steps${NC}"
echo "=========="
echo ""
echo "1. Copy the keystore.b64 content to GitHub Secret: KEYSTORE_ENCODED"
echo "2. Add the other three secrets to GitHub"
echo "3. Tag a release: git tag v1.0.0 && git push origin v1.0.0"
echo "4. The GitHub Action will automatically build and release the APK"
echo ""

echo -e "${GREEN}Setup complete! ✓${NC}"
