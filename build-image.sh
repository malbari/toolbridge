#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="toolbridge"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${BLUE}🔨 Building Docker image: ${FULL_IMAGE_NAME}${NC}"
echo ""

# Build the image
docker build -t "${FULL_IMAGE_NAME}" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Image built successfully!${NC}"
    echo ""
    echo -e "${BLUE}Image details:${NC}"
    docker images "${IMAGE_NAME}" | grep "${IMAGE_TAG}"
    echo ""
    echo -e "${GREEN}To run the container, use:${NC}"
    echo -e "  ${BLUE}./start-image.sh${NC}"
else
    echo ""
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi
