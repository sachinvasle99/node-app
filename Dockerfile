# Stage 1: Build
FROM node:16 AS build
WORKDIR /app
COPY package.json ./
RUN npm install
# Stage 2: Production
FROM node:16-alpine
WORKDIR /app
COPY --from=build /app /app
COPY . .
RUN addgroup -g 1001 -S nodejs && \
    adduser -u 1001 -S nodejs -G nodejs
USER nodejs
# Expose the port and set the environment
EXPOSE 3000
ENV NODE_ENV=production
# Start the application
CMD ["node", "index.js"]
