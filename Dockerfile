# ---- Stage 1: Builder ----
FROM node:20-bullseye-slim AS builder

WORKDIR /app

# Copy only package manifests first
COPY package*.json ./

# Install dependencies (including TypeScript)
RUN npm ci && npm install typescript @types/node --save-dev

# Copy entire project
COPY . .

# Move into API app and compile
WORKDIR /app/apps/api

RUN chmod +x ../../node_modules/.bin/tsc
RUN npx tsc -p tsconfig.json

# ---- Stage 2: Runtime ----
FROM node:20-bullseye-slim

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 4000

# ✅ Use absolute schema path (fixes your current error)
CMD ["sh", "-c", "npx prisma generate --schema=/app/prisma/schema.prisma && npx prisma migrate deploy --schema=/app/prisma/schema.prisma && node apps/api/dist/index.js"]
