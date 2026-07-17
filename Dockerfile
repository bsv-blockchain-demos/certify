# Use Node.js 20 Alpine as base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files (.npmrc routes the @bsv-blockchain-demos scope to
# GitHub Packages for the float-balance-route dependency)
COPY package.json package-lock.json .npmrc ./

# Install dependencies. The registry token is a BuildKit secret so it never
# lands in an image layer; the auth line is appended for the install and
# stripped again within the same layer.
RUN --mount=type=secret,id=github_token \
    echo "//npm.pkg.github.com/:_authToken=$(cat /run/secrets/github_token)" >> .npmrc && \
    npm install --frozen-lockfile && \
    sed -i '/_authToken/d' .npmrc

# Install TypeScript and tsx globally for building and running
RUN npm install -g typescript tsx

# Copy source code
COPY . .

# Build the TypeScript code
RUN npm run build

# Expose port 8080
EXPOSE 8080

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory to nodejs user
RUN chown -R nodejs:nodejs /app
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# Start the application
CMD ["node", "dist/index.js"]
