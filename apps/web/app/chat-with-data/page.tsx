"use client";
import React, { useState } from "react";

export default function ChatPage() {
  const [prompt, setPrompt] = useState("");
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function handleAsk() {
    if (!prompt.trim()) return;
    setLoading(true);
    setError("");
    setResult(null);

    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE}/chat-with-data`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt }),
      });

      if (!res.ok) throw new Error("Request failed");

      const data = await res.json();
      setResult(data);
    } catch (err: any) {
      console.error(err);
      setError("Failed to fetch response. Check backend connection.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      <h2 className="text-xl font-semibold mb-4">Chat with Data</h2>
      <textarea
        className="w-full border p-3 mb-3 rounded-lg text-gray-700"
        rows={3}
        placeholder="Ask something like: Top 5 vendors by spend"
        value={prompt}
        onChange={(e) => setPrompt(e.target.value)}
      />

      <button
        className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:bg-gray-400"
        onClick={handleAsk}
        disabled={loading}
      >
        {loading ? "Thinking..." : "Ask"}
      </button>

      {error && <p className="text-red-500 mt-3">{error}</p>}

      {result && (
        <div className="mt-6">
          <h3 className="font-semibold text-lg mb-2">Generated SQL:</h3>
          <pre className="bg-gray-100 p-3 rounded text-sm overflow-x-auto">
            {result.sql}
          </pre>

          {result.rows && result.rows.length > 0 && (
            <div className="mt-6">
              <h3 className="font-semibold text-lg mb-2">Results:</h3>
              <div className="overflow-x-auto">
                <table className="min-w-full border text-sm">
                  <thead>
                    <tr>
                      {Object.keys(result.rows[0]).map((key) => (
                        <th key={key} className="border px-3 py-2 bg-gray-200 text-left">
                          {key}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {result.rows.map((row: any, i: number) => (
                      <tr key={i}>
                        {Object.values(row).map((val, j) => (
                          <td key={j} className="border px-3 py-2">
                            {String(val)}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
