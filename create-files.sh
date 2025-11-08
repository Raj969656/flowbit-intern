#!/bin/bash
# Flowbit Internship Project Auto-Setup Script

echo "��� Creating Flowbit Internship project structure..."

mkdir -p {apps/api/src,services/vanna,prisma,data}

# Root package.json
cat > package.json <<'JSON'
{
  "name": "flowbit-intern",
  "private": true,
  "workspaces": ["apps/*", "services/*"],
  "scripts": {
    "dev:api": "npm --workspace=@flowbit/api run dev",
    "dev:vanna": "npm --workspace=@flowbit/vanna run dev"
  }
}
JSON

# .env
cat > .env <<'ENV'
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/flowbitdb
VANNA_DATABASE_URL=postgresql://postgres:postgres@localhost:5432/flowbitdb
VANNA_PORT=8000
VANNA_API_KEY=devkey
NEXT_PUBLIC_API_BASE=http://localhost:4000
ENV

# Docker Compose
cat > docker-compose.yml <<'YML'
version: "3.8"
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: flowbitdb
    ports:
      - "5432:5432"
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
YML

# Prisma schema
mkdir -p prisma
cat > prisma/schema.prisma <<'PRISMA'
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
generator client {
  provider = "prisma-client-js"
}
model Vendor {
  id        String    @id @default(uuid())
  name      String
  address   String?
  taxId     String?
  invoices  Invoice[]
}
model Invoice {
  id           String     @id @default(uuid())
  invoice_no   String
  invoice_date DateTime?
  vendor       Vendor     @relation(fields: [vendorId], references: [id])
  vendorId     String
  subtotal     Float?
  tax          Float?
  total        Float?
  currency     String?
  status       String?
  createdAt    DateTime   @default(now())
  lineItems    LineItem[]
  payments     Payment[]
}
model LineItem {
  id         String  @id @default(uuid())
  invoice    Invoice @relation(fields: [invoiceId], references: [id])
  invoiceId  String
  srNo       Int?
  description String?
  quantity   Float?
  unitPrice  Float?
  total      Float?
}
model Payment {
  id              String   @id @default(uuid())
  invoice         Invoice  @relation(fields:[invoiceId], references:[id])
  invoiceId       String
  bankAccount     String?
  dueDate         DateTime?
  netDays         Int?
  discountedTotal Float?
}
PRISMA

# API files
mkdir -p apps/api/src apps/api/scripts
cat > apps/api/package.json <<'JSON'
{
  "name": "@flowbit/api",
  "version": "1.0.0",
  "main": "src/index.ts",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "seed": "ts-node scripts/seed.ts"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "@prisma/client": "^5.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "ts-node-dev": "^2.0.0",
    "@types/express": "^4.17.13",
    "@types/node": "^20.0.0",
    "prisma": "^5.0.0"
  }
}
JSON

# API index.ts
cat > apps/api/src/index.ts <<'TS'
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { PrismaClient } from "@prisma/client";
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
const prisma = new PrismaClient();

// /stats
app.get("/stats", async (req, res) => {
  const totalSpend = await prisma.invoice.aggregate({ _sum: { total: true }});
  const totalInvoices = await prisma.invoice.count();
  const avgInvoice = await prisma.invoice.aggregate({ _avg: { total: true }});
  res.json({
    totalSpend: totalSpend._sum.total ?? 0,
    totalInvoices,
    avgInvoiceValue: avgInvoice._avg.total ?? 0
  });
});

app.get("/vendors/top10", async (req, res) => {
  const result = await prisma.$queryRaw`
    SELECT v.name, SUM(i.total) AS spend
    FROM "Invoice" i
    JOIN "Vendor" v ON i."vendorId" = v.id
    GROUP BY v.name
    ORDER BY spend DESC
    LIMIT 10;
  `;
  res.json(result);
});

app.post("/chat-with-data", async (req, res) => {
  const { prompt } = req.body;
  const resp = await fetch("http://localhost:8000/generate-sql", {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({ prompt })
  });
  const data = await resp.json();
  res.json(data);
});

const port = process.env.PORT || 4000;
app.listen(port, () => console.log("✅ API running on port", port));
TS

# Seed script
cat > apps/api/scripts/seed.ts <<'TS'
import fs from "fs";
import path from "path";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  const file = path.join(__dirname, "../../../data/Analytics_Test_Data.json");
  if (!fs.existsSync(file)) {
    console.error("❌ JSON data file not found in /data!");
    process.exit(1);
  }
  const raw = fs.readFileSync(file, "utf-8");
  const arr = JSON.parse(raw);
  let vendors = 0, invoices = 0;
  for (const doc of arr) {
    const vend = doc.extractedData?.llmData?.vendor?.value || {};
    const inv = doc.extractedData?.llmData?.invoice?.value || {};
    const summ = doc.extractedData?.llmData?.summary?.value || {};
    const vName = vend.vendorName?.value || "Unknown Vendor";
    const vendor = await prisma.vendor.upsert({ where: { name: vName }, update: {}, create: { name: vName }});
    vendors++;
    await prisma.invoice.create({
      data: {
        invoice_no: inv.invoiceId?.value || `INV-${Math.random().toString(36).slice(2,8)}`,
        vendorId: vendor.id,
        total: Number(summ.invoiceTotal?.value ?? 0)
      }
    });
    invoices++;
  }
  console.log(`✅ Seed complete. Vendors: ${vendors}, Invoices: ${invoices}`);
}
main().finally(()=>prisma.$disconnect());
TS

# Vanna AI
cat > services/vanna/main.py <<'PY'
from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2, os
from dotenv import load_dotenv
load_dotenv()
app = FastAPI()
DATABASE_URL = os.getenv("VANNA_DATABASE_URL")
class Query(BaseModel):
    prompt: str
@app.post("/generate-sql")
def generate_sql(q: Query):
    prompt = q.prompt.lower()
    sql = "SELECT v.name, SUM(i.total) AS spend FROM \"Invoice\" i JOIN \"Vendor\" v ON i.\"vendorId\"=v.id GROUP BY v.name ORDER BY spend DESC LIMIT 5;" if "vendor" in prompt else "SELECT * FROM \"Invoice\" LIMIT 5;"
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute(sql)
    cols = [d[0] for d in cur.description]
    data = [dict(zip(cols, r)) for r in cur.fetchall()]
    cur.close(); conn.close()
    return {"sql": sql, "rows": data}
PY

echo "✅ All files created!"
echo "Next:"
echo "1️⃣ docker run -d --name flowbitdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=flowbitdb -p 5432:5432 postgres"
echo "2️⃣ cd apps/api && npm install && npx prisma migrate dev --name init && npx prisma generate"
echo "3️⃣ Place Analytics_Test_Data.json inside ./data folder"
echo "4️⃣ npx ts-node scripts/seed.ts"
echo "5️⃣ npm run dev"
echo "6️⃣ In new terminal: cd ../../services/vanna && python3 -m venv .venv && source .venv/bin/activate && pip install fastapi uvicorn psycopg2-binary python-dotenv && uvicorn main:app --reload --port 8000"
