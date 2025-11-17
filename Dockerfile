# Use Node.js LTS version
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy application code
COPY . .

# Create directory for token file if needed
RUN mkdir -p /app/config

# Expose the default proxy port
EXPOSE 4000

# Set environment variables defaults
ENV NODE_ENV=production \
    PROXY_PORT=4000 \
    PROXY_HOST=0.0.0.0

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + (process.env.PROXY_PORT || 3000) + '/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "--no-deprecation", "index.js"]
