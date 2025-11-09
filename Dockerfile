# Use an official Node image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy root manifests (adjust if you use workspaces)
COPY package*.json ./
RUN npm ci

# Copy everything else
COPY . .

# Compile TypeScript (no Prisma yet)
WORKDIR /app/apps/api
RUN npx tsc -p tsconfig.json

# Expose port
EXPOSE 4000

# Run Prisma + start the API when the container boots
CMD npx prisma generate --schema=../../prisma/schema.prisma && \
    npx prisma migrate deploy --schema=../../prisma/schema.prisma && \
    node dist/index.js
