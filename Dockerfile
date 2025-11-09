# ---- Build stage ----
FROM node:20-bullseye-slim AS builder

WORKDIR /app

# Copy root manifests and install all dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the project files
COPY . .

# Move into the API app
WORKDIR /app/apps/api

# Ensure TypeScript is installed
RUN npm install typescript @types/node --save-dev

# Compile TypeScript
RUN npx tsc -p tsconfig.json

# ---- Runtime stage ----
FROM node:20-bullseye-slim

WORKDIR /app

# Copy compiled output from builder
COPY --from=builder /app /app

EXPOSE 4000

# Run Prisma + start server
CMD ["sh", "-c", "npx prisma generate --schema=../../prisma/schema.prisma && npx prisma migrate deploy --schema=../../prisma/schema.prisma && node apps/api/dist/index.js"]
