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
