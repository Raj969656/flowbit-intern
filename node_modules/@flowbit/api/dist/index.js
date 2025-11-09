"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const client_1 = require("@prisma/client");
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use((0, cors_1.default)());
app.use(express_1.default.json());
const prisma = new client_1.PrismaClient();
// /stats
app.get("/stats", async (req, res) => {
    const totalSpend = await prisma.invoice.aggregate({ _sum: { total: true } });
    const totalInvoices = await prisma.invoice.count();
    const avgInvoice = await prisma.invoice.aggregate({ _avg: { total: true } });
    res.json({
        totalSpend: totalSpend._sum.total ?? 0,
        totalInvoices,
        avgInvoiceValue: avgInvoice._avg.total ?? 0
    });
});
app.get("/vendors/top10", async (req, res) => {
    const result = await prisma.$queryRaw `
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
    const VANNA_API = process.env.VANNA_API_BASE_URL;
    const resp = await fetch(`${VANNA_API}/generate-sql`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt })
    });
    const data = await resp.json();
    res.json(data);
});
const port = process.env.PORT || 4000;
app.listen(port, () => console.log("✅ API running on port", port));
