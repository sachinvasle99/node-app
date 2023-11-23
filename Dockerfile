# Stage 1: Build
FROM node:16 AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY index.js ./

# Stage 2: Production
FROM node:16-alpine

WORKDIR /app

# Copy only necessary files from the build stage
COPY --from=build /app/package*.json ./
COPY --from=build /app/index.js ./

# Create a non-root user for running the application
RUN addgroup -g 1001 -S nodejs && \
    adduser -u 1001 -S nodejs -G nodejs
USER nodejs

# Expose the port and set the environment
EXPOSE 3000
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD [ "node", "index.js", "healthcheck" ]

# Start the application
CMD ["node", "index.js"]
