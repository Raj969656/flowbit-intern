#!/bin/bash
# create-frontend.sh
# Creates a Next.js (App Router) + TypeScript + Tailwind + Chart.js scaffold inside apps/web

set -e

ROOT="$(pwd)"
WEB_DIR="$ROOT/apps/web"

echo "Creating frontend at $WEB_DIR ..."
mkdir -p "$WEB_DIR"

cat > "$WEB_DIR/package.json" <<'JSON'
{
  "name": "@flowbit/web",
  "private": true,
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.3.1",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "chart.js": "^4.4.0",
    "react-chartjs-2": "^5.2.0"
  },
  "devDependencies": {
    "typescript": "^5.5.2",
    "tailwindcss": "^3.5.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
JSON

cat > "$WEB_DIR/next.config.js" <<'JS'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: { appDir: true }
}
module.exports = nextConfig
JS

cat > "$WEB_DIR/tsconfig.json" <<'TS'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom","dom.iterable","esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": false,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
TS

cat > "$WEB_DIR/next-env.d.ts" <<'DTS'
/// <reference types="next" />
/// <reference types="next/types/global" />
/// <reference types="next/image-types/global" />
DTS

# Tailwind
cat > "$WEB_DIR/postcss.config.js" <<'PC'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
PC

cat > "$WEB_DIR/tailwind.config.js" <<'TW'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
TW

cat > "$WEB_DIR/styles/globals.css" <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

html,body,#__next { height: 100%; }
body { background: #f8fafc; }
CSS

# Create app structure (App Router)
mkdir -p "$WEB_DIR/app/(dashboard)"
mkdir -p "$WEB_DIR/components"

# app/layout.tsx
cat > "$WEB_DIR/app/layout.tsx" <<'LAY'
import './globals.css'
export const metadata = { title: 'Flowbit Analytics', description: 'Analytics Dashboard' }
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="p-6">
        <div className="max-w-6xl mx-auto">
          <header className="mb-6">
            <h1 className="text-2xl font-bold">Flowbit Analytics</h1>
          </header>
          <div>{children}</div>
        </div>
      </body>
    </html>
  )
}
LAY

# app/(dashboard)/page.tsx - Dashboard main
cat > "$WEB_DIR/app/(dashboard)/page.tsx" <<'PAGE'
"use client";
import React, { useEffect, useState } from "react";
import OverviewCard from "../../components/OverviewCard";
import InvoiceTrends from "../../components/InvoiceTrends";
import VendorsBar from "../../components/VendorsBar";
import CategoryPie from "../../components/CategoryPie";

export default function Page() {
  const [stats, setStats] = useState<any>(null);

  useEffect(() => {
    fetch(`${process.env.NEXT_PUBLIC_API_BASE}/stats`)
      .then(r => r.json())
      .then(setStats)
      .catch(console.error);
  }, []);

  return (
    <main>
      <div className="grid grid-cols-4 gap-4 mb-6">
        <OverviewCard title="Total Spend (YTD)" value={stats ? stats.totalSpend : '—'} />
        <OverviewCard title="Total Invoices" value={stats ? stats.totalInvoices : '—'} />
        <OverviewCard title="Documents Uploaded" value={stats ? stats.documentsUploaded ?? stats.totalInvoices : '—'} />
        <OverviewCard title="Average Invoice Value" value={stats ? stats.avgInvoiceValue : '—'} />
      </div>

      <div className="grid grid-cols-3 gap-6">
        <div className="col-span-2 bg-white p-4 rounded shadow">
          <h2 className="font-semibold mb-3">Invoice Volume + Value</h2>
          <InvoiceTrends />
        </div>
        <div className="bg-white p-4 rounded shadow">
          <h2 className="font-semibold mb-3">Top Vendors (Top 10)</h2>
          <VendorsBar />
        </div>
      </div>

      <div className="grid grid-cols-3 gap-6 mt-6">
        <div className="bg-white p-4 rounded shadow col-span-1">
          <h2 className="font-semibold mb-3">Spend by Category</h2>
          <CategoryPie />
        </div>
        <div className="bg-white p-4 rounded shadow col-span-2">
          <h2 className="font-semibold mb-3">Invoices</h2>
          <div id="invoices-table" />
          <a href="/chat-with-data" className="inline-block mt-4 text-blue-600">Go to Chat with Data →</a>
        </div>
      </div>
    </main>
  );
}
PAGE

# app/(dashboard)/chat/page.tsx - Chat UI
cat > "$WEB_DIR/app/(dashboard)/chat/page.tsx" <<'CHAT'
"use client";
import React, { useState } from "react";

export default function ChatPage() {
  const [prompt, setPrompt] = useState("");
  const [loading, setLoading] = useState(false);
  const [sql, setSql] = useState("");
  const [rows, setRows] = useState<any[]>([]);

  async function send() {
    setLoading(true);
    setSql(""); setRows([]);
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE}/chat-with-data`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt })
      });
      const data = await res.json();
      setSql(data.sql);
      setRows(data.rows || []);
    } catch (e) {
      console.error(e);
    } finally { setLoading(false); }
  }

  return (
    <div>
      <h2 className="text-xl font-semibold mb-3">Chat with Data</h2>
      <div className="mb-3">
        <textarea value={prompt} onChange={e=>setPrompt(e.target.value)} rows={3} className="w-full p-2 border rounded" placeholder="Ask something like: Top 5 vendors by spend"></textarea>
      </div>
      <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={send} disabled={loading || !prompt}>{loading ? "Thinking..." : "Ask"}</button>

      {sql && (
        <div className="mt-4">
          <h3 className="font-semibold">Generated SQL</h3>
          <pre className="bg-gray-100 p-2 rounded text-sm overflow-auto">{sql}</pre>
        </div>
      )}

      {rows.length > 0 && (
        <div className="mt-4">
          <h3 className="font-semibold">Results</h3>
          <div className="overflow-auto">
            <table className="min-w-full bg-white">
              <thead><tr>{Object.keys(rows[0]).map(k=> <th key={k} className="p-2 border">{k}</th>)}</tr></thead>
              <tbody>
                {rows.map((r,idx)=>(
                  <tr key={idx} className="hover:bg-gray-50">
                    {Object.values(r).map((v,i)=><td key={i} className="p-2 border">{String(v)}</td>)}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
CHAT

# Components - OverviewCard
cat > "$WEB_DIR/components/OverviewCard.tsx" <<'CARD'
export default function OverviewCard({ title, value }: { title: string; value: string | number }) {
  return (
    <div className="bg-white p-4 rounded shadow">
      <div className="text-sm text-gray-500">{title}</div>
      <div className="text-2xl font-semibold">{String(value)}</div>
    </div>
  );
}
CARD

# Components - InvoiceTrends (sample chart)
cat > "$WEB_DIR/components/InvoiceTrends.tsx" <<'IT'
"use client";
import React, { useEffect, useState } from "react";
import { Line } from "react-chartjs-2";
import { Chart, LineElement, PointElement, CategoryScale, LinearScale, Tooltip, Legend } from "chart.js";
Chart.register(LineElement, PointElement, CategoryScale, LinearScale, Tooltip, Legend);

export default function InvoiceTrends() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    fetch(`${process.env.NEXT_PUBLIC_API_BASE}/invoice-trends`)
      .then(r => r.json())
      .then(rows => {
        const labels = rows.map((r: any) => new Date(r.month).toLocaleString());
        const counts = rows.map((r: any) => Number(r.count));
        const totals = rows.map((r:any) => Number(r.total));
        setData({
          labels,
          datasets: [
            { label: "Count", data: counts, borderColor: "rgba(75,192,192,1)", tension: 0.3 },
            { label: "Total", data: totals, borderColor: "rgba(153,102,255,1)", tension: 0.3 },
          ]
        });
      }).catch(console.error);
  }, []);

  if (!data) return <div>Loading chart...</div>;
  return <Line data={data} />;
}
IT

# Components - VendorsBar
cat > "$WEB_DIR/components/VendorsBar.tsx" <<'VB'
"use client";
import React, { useEffect, useState } from "react";
import { Bar } from "react-chartjs-2";
import { Chart, BarElement, CategoryScale, LinearScale, Tooltip } from "chart.js";
Chart.register(BarElement, CategoryScale, LinearScale, Tooltip);

export default function VendorsBar() {
  const [data, setData] = useState<any>(null);
  useEffect(() => {
    fetch(`${process.env.NEXT_PUBLIC_API_BASE}/vendors/top10`).then(r=>r.json()).then(rows=>{
      setData({
        labels: rows.map((r:any)=>r.name),
        datasets: [{ label: "Spend", data: rows.map((r:any)=>Number(r.spend)) }]
      });
    }).catch(console.error);
  }, []);
  if (!data) return <div>Loading...</div>;
  return <Bar data={data} options={{ indexAxis: 'y' }} />;
}
VB

# Components - CategoryPie
cat > "$WEB_DIR/components/CategoryPie.tsx" <<'CP'
"use client";
import React, { useEffect, useState } from "react";
import { Pie } from "react-chartjs-2";
import { Chart, ArcElement, Tooltip } from "chart.js";
Chart.register(ArcElement, Tooltip);

export default function CategoryPie() {
  const [data, setData] = useState<any>(null);
  useEffect(() => {
    fetch(`${process.env.NEXT_PUBLIC_API_BASE}/category-spend`).then(r=>r.json()).then(rows=>{
      setData({
        labels: rows.map((r:any)=>r.category || r.name),
        datasets: [{ data: rows.map((r:any)=>Number(r.spend)) }]
      });
    }).catch(console.error);
  }, []);
  if (!data) return <div>Loading...</div>;
  return <Pie data={data} />;
}
CP

echo "Frontend scaffold created at $WEB_DIR"
echo "Now run:"
echo "cd apps/web && npm install"
echo "then: npm run dev  (open http://localhost:3000)"
