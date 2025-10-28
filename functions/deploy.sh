#!/bin/bash

# Firebase Cloud Functions Deployment Script
# This script handles the complete deployment process for Cloud Functions

set -e  # Exit on error

echo "=========================================="
echo "Firebase Cloud Functions Deployment"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Error: Firebase CLI is not installed${NC}"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Firebase${NC}"
    echo "Run: firebase login"
    exit 1
fi

# Get current project
CURRENT_PROJECT=$(firebase use | grep "Active Project" | awk '{print $3}' || echo "")
if [ -z "$CURRENT_PROJECT" ]; then
    CURRENT_PROJECT=$(firebase projects:list | grep "(current)" | awk '{print $3}')
fi

echo -e "${GREEN}Current Firebase Project: ${CURRENT_PROJECT}${NC}"
echo ""

# Confirm deployment
read -p "Do you want to deploy to this project? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo "Step 1: Running linter..."
npm run lint || {
    echo -e "${YELLOW}Warning: Linting found issues. Continue anyway? (y/n)${NC}"
    read -p "" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

echo ""
echo "Step 2: Building TypeScript..."
npm run build || {
    echo -e "${RED}Error: Build failed${NC}"
    exit 1
}

echo ""
echo "Step 3: Checking environment variables..."
echo -e "${YELLOW}Note: Make sure you've set the required environment variables:${NC}"
echo "  - firebase functions:config:set razorpay.key_id=\"your_key\""
echo "  - firebase functions:config:set razorpay.key_secret=\"your_secret\""
echo ""
read -p "Have you set the environment variables? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment will continue, but functions may fail without proper configuration${NC}"
fi

echo ""
echo "Step 4: Deploying Cloud Functions..."
firebase deploy --only functions || {
    echo -e "${RED}Error: Deployment failed${NC}"
    exit 1
}

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Successful!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Test the deployed functions"
echo "2. Monitor function logs: firebase functions:log"
echo "3. Check Firebase Console for function status"
echo ""
