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
