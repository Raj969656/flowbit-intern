# ---- Stage 1: Builder ----
FROM node:20-bullseye-slim AS builder

WORKDIR /app

# Copy root manifests first
COPY package*.json ./

# Install root-level dependencies
RUN npm ci

# Copy all project files
COPY . .

# Move into API app and install its dependencies
WORKDIR /app/apps/api
COPY apps/api/package*.json ./
RUN npm install

# Add TypeScript
RUN npm install typescript @types/node --save-dev

# Ensure TypeScript compiler is executable
RUN chmod +x ../../node_modules/.bin/tsc || true

# Compile TypeScript to JavaScript (dist/)
RUN npx tsc -p tsconfig.json


# ---- Stage 2: Runtime ----
FROM node:20-bullseye-slim AS runtime

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app /app

# Expose backend port
EXPOSE 4000

# ✅ Run Prisma + start backend server
CMD ["sh", "-c", "npx prisma generate --schema=/app/prisma/schema.prisma && npx prisma migrate deploy --schema=/app/prisma/schema.prisma && node apps/api/dist/index.js"]
