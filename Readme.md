🌐 Flowbit Internship Project — Full Stack Developer (AI-Powered Analytics Dashboard)
🚀 Overview

This project is a production-grade, full-stack web application built as part of the Flowbit Internship assignment.
It demonstrates end-to-end engineering skills — including frontend (Next.js), backend (Express + Prisma), and AI-powered analytics (Vanna + Groq LLM).

🧩 Features
📊 Analytics Dashboard

Real-time overview of business metrics:

Total Spend (YTD)

Total Invoices Processed

Average Invoice Value

Dynamic charts and graphs using Chart.js.

Responsive layout built with TailwindCSS.

💬 Chat with Data (AI Layer)

Natural-language query interface.

Uses Vanna AI (FastAPI) + Groq LLM to convert questions into SQL.

Runs queries on PostgreSQL and displays results dynamically.

Shows generated SQL + data visualization in frontend.

⚙️ Tech Stack
Layer	Technology
Frontend	Next.js 14 (App Router), React, TailwindCSS, Chart.js
Backend	Node.js, Express.js, Prisma ORM
Database	PostgreSQL (Docker or Cloud)
AI Layer	Python, FastAPI (Vanna), psycopg2
Deployment	Vercel (Frontend + Backend), Render (Vanna AI)
📂 Project Structure
flowbite-intern/
├── apps/
│   ├── api/                  # Node.js + Express + Prisma backend
│   ├── web/                  # Next.js 14 (frontend dashboard + chat)
│   └── services/
│       └── vanna/            # Python FastAPI AI service
│
├── prisma/                   # Database schema & migrations
├── data/                     # JSON seed data
├── package.json
├── docker-compose.yml
└── README.md

🧠 Architecture Overview
Frontend (Next.js)
     ↓  fetches
Backend (Express + Prisma)
     ↓  queries
PostgreSQL Database
     ↓  used by
AI Layer (FastAPI + Groq)
     ↓  returns
JSON → Rendered in Dashboard UI

🧱 Local Setup & Run
🪜 Prerequisites

Node.js ≥ 18

Python ≥ 3.9

Docker (for PostgreSQL)

Git

🧰 1. Clone the Repository
git clone https://github.com/<your-username>/flowbit-intern.git
cd flowbit-intern

🗃️ 2. Setup Database (PostgreSQL via Docker)
docker run -d --name flowbitdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=flowbitdb -p 5432:5432 postgres

⚙️ 3. Apply Prisma Migrations & Seed Data
cd apps/api
npx prisma migrate dev --name init --schema=../../prisma/schema.prisma
npx tsx scripts/seed.ts

🧩 4. Start Backend Server (API)
npm run dev


➡️ Runs at: http://localhost:4000

🧠 5. Start AI Service (Vanna FastAPI)
cd ../../services/vanna
.venv\Scripts\activate    # or source .venv/bin/activate
uvicorn main:app --reload --port 8000


➡️ Runs at: http://localhost:8000

💻 6. Start Frontend (Next.js)
cd ../../web
npm run dev


➡️ Runs at: http://localhost:3000

🌐 Environment Variables
🔹 apps/api/.env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/flowbitdb
VANNA_API_BASE_URL=http://localhost:8000

🔹 apps/web/.env.local
NEXT_PUBLIC_API_BASE=http://localhost:4000

🔹 services/vanna/.env
VANNA_DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/flowbitdb
GROQ_API_KEY=<your_groq_key>

🧪 API Endpoints
Endpoint	Method	Description
/stats	GET	Overview metrics
/vendors/top10	GET	Top 10 vendors by spend
/category-spend	GET	Spend by category
/invoice-trends	GET	Monthly invoice stats
/chat-with-data	POST	Query forwarding to AI
🖥️ Frontend Pages
Path	Description
/	Analytics Dashboard (cards + charts)
/chat-with-data	AI-powered Chat with Data interface
📸 Screenshots
Dashboard

Chat with Data

☁️ Deployment
Frontend + Backend → Vercel

Push repo to GitHub

Import on Vercel

Add environment variables (DATABASE_URL, NEXT_PUBLIC_API_BASE, VANNA_API_BASE_URL)

Deploy 🎉

AI Layer → Render

Create new Web Service

Connect to your repo → services/vanna

Start command:

uvicorn main:app --host 0.0.0.0 --port 8000


Add env vars (VANNA_DATABASE_URL, GROQ_API_KEY)

Deploy 🎉

🧾 Demo Video Script (3–5 mins)

Intro → “Hi, I’m Raj Yadav. This is my Flowbit AI Dashboard project.”

Dashboard → show overview cards & charts.

Chat with Data → ask “Top 5 vendors by spend” → show SQL & table.

Architecture explanation → frontend → backend → AI → DB.

Wrap up → share deployed link.

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
📧 Email: [your email here]
🔗 GitHub: https://github.com/<your-username>

⭐ Acknowledgements

Special thanks to Flowbit Private Limited for the opportunity to work on this challenging, real-world full-stack AI project.