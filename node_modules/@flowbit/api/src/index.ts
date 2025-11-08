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
