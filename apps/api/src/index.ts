import dotenv from "dotenv";
dotenv.config(); // ✅ must be first — before using process.env

import express from "express";
import cors from "cors";
import { PrismaClient } from "@prisma/client";

const app = express();
app.use(cors());
app.use(express.json());

const prisma = new PrismaClient();

// Health check (to prevent Render errors)
app.get("/", (req, res) => {
  res.send("✅ Flowbit API is running!");
});

// Stats endpoint
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

// Top vendors
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

// Chat with Data
app.post("/chat-with-data", async (req, res) => {
  try {
    const { prompt } = req.body;
    const VANNA_API = process.env.VANNA_API_BASE_URL;
    if (!VANNA_API) {
      return res.status(500).json({ error: "VANNA_API_BASE_URL not configured" });
    }

    const resp = await fetch(`${VANNA_API}/generate-sql`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt })
    });

    if (!resp.ok) throw new Error(`Vanna error: ${resp.statusText}`);

    const data = await resp.json();
    res.json(data);
  } catch (error: any) {
    console.error("❌ Chat-with-data error:", error.message);
    res.status(500).json({ error: error.message });
  }
});

// Start server
const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`✅ API running on port ${port}`));
