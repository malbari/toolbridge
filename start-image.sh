#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="toolbridge"
IMAGE_TAG="latest"
CONTAINER_NAME="toolbridge-proxy"
HOST_PORT=4000
CONTAINER_PORT=4000

echo -e "${BLUE}🚀 Starting ToolBridge container${NC}"
echo ""

# Check if container is already running
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo -e "${YELLOW}⚠️  Container '${CONTAINER_NAME}' is already running${NC}"
    echo -e "${BLUE}Stopping existing container...${NC}"
    docker stop "${CONTAINER_NAME}"
    docker rm "${CONTAINER_NAME}"
fi

# Check if container exists but is stopped
if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
    echo -e "${BLUE}Removing stopped container...${NC}"
    docker rm "${CONTAINER_NAME}"
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found!${NC}"
    echo -e "${YELLOW}Please create a .env file with your configuration${NC}"
    exit 1
fi

# Check if tokens file exists (optional)
TOKENS_FILE=".tokens.txt"
TOKENS_MOUNT=""
if [ -f "${TOKENS_FILE}" ]; then
    echo -e "${GREEN}✓ Found tokens file: ${TOKENS_FILE}${NC}"
    TOKENS_MOUNT="-v $(pwd)/${TOKENS_FILE}:/app/.tokens.txt:ro"
else
    echo -e "${YELLOW}⚠️  No tokens file found (authentication will be disabled)${NC}"
fi

# Start the container
echo -e "${BLUE}Starting container on port ${HOST_PORT}...${NC}"
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    --env-file .env \
    ${TOKENS_MOUNT} \
    --restart unless-stopped \
    "${IMAGE_NAME}:${IMAGE_TAG}"

# Check if container started successfully
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Container started successfully!${NC}"
    echo ""
    echo -e "${BLUE}Container info:${NC}"
    docker ps -f name="${CONTAINER_NAME}"
    echo ""
    echo -e "${GREEN}Access the proxy at:${NC} http://localhost:${HOST_PORT}"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo -e "  View logs:    ${YELLOW}docker logs -f ${CONTAINER_NAME}${NC}"
    echo -e "  Stop:         ${YELLOW}docker stop ${CONTAINER_NAME}${NC}"
    echo -e "  Restart:      ${YELLOW}docker restart ${CONTAINER_NAME}${NC}"
    echo -e "  Remove:       ${YELLOW}docker rm -f ${CONTAINER_NAME}${NC}"
    echo ""
    echo -e "${GREEN}Container is running in background${NC}"
    echo -e "${BLUE}To view logs, run:${NC} docker logs -f ${CONTAINER_NAME}"
else
    echo ""
    echo -e "${RED}❌ Failed to start container!${NC}"
    exit 1
fi
