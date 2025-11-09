🌐 Flowbit Internship Project — Full Stack Developer (AI-Powered Analytics Dashboard) 🚀

This project is a production-grade, full-stack web application built as part of the Flowbit Internship assignment.
It demonstrates end-to-end full stack + AI integration skills — including:

⚛️ Frontend: Next.js 14 (App Router) + TailwindCSS

🧠 AI Layer: Python (FastAPI + Vanna + Groq LLM)

🗄️ Backend: Node.js (Express + Prisma ORM)

🛢️ Database: PostgreSQL

☁️ Deployment: Vercel (Frontend + Backend) + Render (Vanna AI Service)

🧩 Features
📊 Analytics Dashboard

Real-time overview of business metrics:

Total Spend (YTD)

Total Invoices Processed

Average Invoice Value

Dynamic charts and graphs using Chart.js

Responsive layout with TailwindCSS

💬 Chat with Data (AI Layer)

Natural-language query interface powered by Vanna AI + Groq LLM

Converts plain questions → SQL → executes on PostgreSQL

Returns SQL + query results → visualized in dashboard

Enables AI-Powered Data Insights directly from the UI

⚙️ Tech Stack Overview
Layer	Technology
Frontend	Next.js 14 (App Router), React, TailwindCSS, Chart.js
Backend API	Node.js, Express.js, Prisma ORM
Database	PostgreSQL (Docker or local)
AI Layer	Python, FastAPI (Vanna), psycopg2, Groq API
Deployment	Vercel (web + api), Render (AI service)
📂 Project Structure
flowbite-intern/
├── apps/
│   ├── api/                # Node.js + Express + Prisma backend
│   ├── web/                # Next.js 14 frontend dashboard (Analytics + Chat)
│
├── services/
│   └── vanna/              # Python FastAPI (AI Layer)
│       ├── main.py
│       ├── .env
│       └── requirements.txt
│
├── prisma/                 # Prisma schema & migrations
├── data/                   # Sample or seed data (JSON)
├── docker-compose.yml       # PostgreSQL setup via Docker
└── README.md                # Project documentation

🧠 Architecture Overview
Frontend (Next.js) 
    ↓ fetches 
Backend (Express + Prisma)
    ↓ queries 
PostgreSQL Database
    ↓ used by 
AI Layer (FastAPI + Groq)
    ↓ returns 
JSON → Rendered in Dashboard UI

🧱 Local Setup & Run
🪜 Prerequisites

Node.js ≥ 18

Python ≥ 3.9

Docker (for PostgreSQL)

Git

🧰 1. Clone the Repository
git clone https://github.com/<your-github-username>/flowbite-intern.git
cd flowbite-intern

🗃️ 2. Setup Database (PostgreSQL via Docker)
docker run -d --name flowbitdb ^
  -e POSTGRES_USER=postgres ^
  -e POSTGRES_PASSWORD=postgres ^
  -e POSTGRES_DB=flowbitdb ^
  -p 5432:5432 postgres

⚙️ 3. Apply Prisma Migrations & Seed Data
cd apps/api
npx prisma migrate dev --name init --schema=../../prisma/schema.prisma
npx tsx scripts/seed.ts

🧩 4. Start Backend Server (Express API)
npm run dev


➡️ Runs at: http://localhost:4000

🧠 5. Start AI Service (Vanna FastAPI)
cd ../../services/vanna
.venv\Scripts\activate      # (Windows)
# or source .venv/bin/activate (Mac/Linux)

uvicorn main:app --host 127.0.0.1 --port 8000 --reload


➡️ Runs at: http://localhost:8000

💻 6. Start Frontend (Next.js)
cd ../../apps/web
npm run dev


➡️ Runs at: http://localhost:3000

🌐 Environment Variables
🔹 apps/api/.env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/flowbitdb
VANNA_API_BASE_URL=http://localhost:8000

🔹 apps/web/.env.local
NEXT_PUBLIC_API_BASE=http://localhost:4000

🔹 services/vanna/.env
VANNA_DATABASE_URL=postgresql://postgres:postgres@localhost:5432/flowbitdb
GROQ_API_KEY=<your_groq_api_key>

🧪 API Endpoints
Endpoint	Method	Description
/stats	GET	Overview metrics
/vendors/top10	GET	Top 10 vendors by spend
/category-spend	GET	Spend by category
/invoice-trends	GET	Monthly invoice stats
/chat-with-data	POST	Query forwarding to AI layer
🖥️ Frontend Pages
Path	Description
/	Analytics Dashboard (cards + charts)
/chat-with-data	AI-powered Chat with Data interface
📸 Screenshots
📊 Dashboard

(show cards, metrics, and charts)

💬 Chat with Data

(show query → SQL → table results)

☁️ Deployment
🔹 Frontend + Backend → Vercel

Push repo to GitHub

Import repository on Vercel

Add environment variables:

DATABASE_URL
NEXT_PUBLIC_API_BASE
VANNA_API_BASE_URL


Deploy 🎉

🔹 AI Layer (FastAPI) → Render

Create new Web Service on Render

Connect repo → services/vanna

Start command:

uvicorn main:app --host 0.0.0.0 --port 8000


Add env vars:

VANNA_DATABASE_URL
GROQ_API_KEY


Deploy 🎉

🧾 Demo Video Script (3–5 mins)

Intro: “Hi, I’m Raj Yadav. This is my Flowbit AI Dashboard project.”

Dashboard Demo: Show overview cards & charts.

Chat with Data: Ask “Top 5 vendors by spend” → show SQL + table.

Architecture Explanation: Frontend → Backend → AI → DB.

Wrap Up: Show deployed link & thank Flowbit team.

✅ Submission Checklist
Task	Status
Database + Prisma	✅
Backend APIs	✅
AI Layer (FastAPI)	✅
Frontend (Next.js)	✅
Integration (Chat with Data)	✅
Deployment	🔜
Demo Video	🔜
README	✅
👨‍💻 Author

Raj Yadav
💼 Full Stack Developer Intern Candidate — Flowbit Private Limited
📧 Email: [your-email-here]
🔗 GitHub: https://github.com/<your-github-username>
