"use client";
import React, { useEffect, useState } from "react";

export default function Dashboard() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`${process.env.NEXT_PUBLIC_API_BASE}/stats`)
      .then((r) => r.json())
      .then((data) => {
        setStats(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Error fetching stats:", err);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading dashboard data...</p>;

  return (
    <div>
      <h2 className="text-xl font-semibold mb-3">Overview</h2>
      {stats ? (
        <ul className="space-y-1 text-lg">
          <li>
            <strong>Total Spend:</strong> {stats.totalSpend.toFixed(2)}
          </li>
          <li>
            <strong>Total Invoices:</strong> {stats.totalInvoices}
          </li>
          <li>
            <strong>Average Invoice Value:</strong> {stats.avgInvoiceValue.toFixed(2)}
          </li>
        </ul>
      ) : (
        <p className="text-red-500">No stats available.</p>
      )}

      <a
        href="/chat-with-data"
        className="inline-block mt-6 text-blue-600 font-medium underline hover:text-blue-800"
      >
        Chat with Data →
      </a>
    </div>
  );
}
