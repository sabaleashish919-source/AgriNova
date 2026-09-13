# AgroSurplus backend

## Run locally on Windows

```powershell
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

API base: http://localhost:8000/api/v1
Docs: http://localhost:8000/docs

The MVP uses SQLite so manual testing needs no separate database server. Before production, move to PostgreSQL and change SECRET_KEY.
