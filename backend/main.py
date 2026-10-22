"""Event Venue and Micro-Vendor Finder - REST API (Activity 10).

Framework : FastAPI   (instructor-approved backend example)
Database  : PostgreSQL (IT 108)

Run:
    pip install -r requirements.txt
    python main.py            # starts on http://localhost:8000

Docs:
    http://localhost:8000/docs
"""
import hashlib
import os
import secrets
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from database import get_cursor, init_database
from models import (
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    ReportCreateResponse,
    ReportIn,
    ReportListResponse,
    ReportOut,
    UserOut,
)

app = FastAPI(
    title="Event Venue and Micro-Vendor Finder API",
    description=(
        "IT 110 - Activity 10. REST API for the Caraga region event venue "
        "and micro-vendor finder. Flask-free FastAPI service backed by PostgreSQL."
    ),
    version="1.0.0",
)

# Flutter Web runs on a different port than the API, so CORS is needed.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

TOKEN_STORE: dict = {}


def hash_password(password: str, salt: str | None = None) -> str:
    """PBKDF2 hash so plain passwords are never stored."""
    salt = salt or secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode(), 100_000)
    return f"{salt}${digest.hex()}"


def verify_password(password: str, stored: str) -> bool:
    try:
        salt, _ = stored.split("$", 1)
    except ValueError:
        return False
    return secrets.compare_digest(hash_password(password, salt), stored)


def make_reference() -> str:
    """EV- + timestamp suffix, e.g. EV-481387."""
    return "EV-" + str(int(datetime.now(timezone.utc).timestamp() * 1000))[-6:]


# ---------------------------------------------------------------- startup
@app.on_event("startup")
def on_startup():
    try:
        init_database()
    except Exception as exc:  # keep the API up even if the DB is not ready
        print(f"[warn] database init failed: {exc}")


# ------------------------------------------------------------------ misc
@app.get("/api/health")
def health():
    """Used by the Flutter app to check that the API is reachable."""
    try:
        conn, cur = get_cursor()
        cur.execute("SELECT 1 AS ok")
        cur.fetchone()
        cur.close()
        conn.close()
        return {"ok": True, "service": "eventvenue-api", "database": "connected"}
    except Exception as exc:
        return {"ok": False, "service": "eventvenue-api", "database": str(exc)}


# ------------------------------------------------------------------ auth
@app.post("/api/auth/register", response_model=LoginResponse)
def register(body: RegisterRequest):
    conn, cur = get_cursor()
    try:
        cur.execute(
            """INSERT INTO users (username, password, full_name, email, role)
               VALUES (%s, %s, %s, %s, %s) RETURNING user_id, username, full_name, email, role""",
            (body.username, hash_password(body.password), body.full_name,
             body.email, body.role),
        )
        row = cur.fetchone()
        conn.commit()
    except Exception as exc:
        conn.rollback()
        if "duplicate key" in str(exc).lower() or "unique" in str(exc).lower():
            raise HTTPException(status_code=409, detail="Username or email already exists.")
        raise HTTPException(status_code=400, detail=str(exc))
    finally:
        cur.close()
        conn.close()

    user = UserOut(**dict(row))
    token = secrets.token_hex(16)
    TOKEN_STORE[token] = user.user_id
    return LoginResponse(ok=True, message="Account created.", token=token, user=user)


@app.post("/api/auth/login", response_model=LoginResponse)
def login(body: LoginRequest):
    conn, cur = get_cursor()
    try:
        cur.execute(
            """SELECT user_id, username, password, full_name, email, role
               FROM users WHERE username = %s""",
            (body.username,),
        )
        row = cur.fetchone()
    finally:
        cur.close()
        conn.close()

    if row is None or not verify_password(body.password, row["password"]):
        raise HTTPException(status_code=401, detail="Invalid username or password.")

    user = UserOut(
        user_id=row["user_id"],
        username=row["username"],
        full_name=row["full_name"],
        email=row["email"],
        role=row["role"],
    )
    token = secrets.token_hex(16)
    TOKEN_STORE[token] = user.user_id
    return LoginResponse(ok=True, message=f"Welcome, {user.full_name}!", token=token, user=user)


# --------------------------------------------------------------- reports
@app.get("/api/reports", response_model=ReportListResponse)
def list_reports():
    """Return every report. An empty list drives the EMPTY state in Flutter."""
    conn, cur = get_cursor()
    try:
        cur.execute(
            """SELECT report_id, reference, title, category, location, description,
                      contact, status, created_at
               FROM reports ORDER BY created_at DESC"""
        )
        rows = cur.fetchall()
    finally:
        cur.close()
        conn.close()

    reports = [ReportOut(**dict(r)) for r in rows]
    return ReportListResponse(ok=True, count=len(reports), reports=reports)


@app.post("/api/reports", response_model=ReportCreateResponse)
def create_report(body: ReportIn):
    """Insert a report. The Flutter form calls this on submit."""
    conn, cur = get_cursor()
    try:
        cur.execute(
            """INSERT INTO reports (reference, title, category, location, description, contact)
               VALUES (%s, %s, %s, %s, %s, %s)
               RETURNING report_id, reference, title, category, location, description,
                         contact, status, created_at""",
            (make_reference(), body.title, body.category, body.location,
             body.description, body.contact),
        )
        row = cur.fetchone()
        conn.commit()
    except Exception as exc:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(exc))
    finally:
        cur.close()
        conn.close()

    report = ReportOut(**dict(row))
    return ReportCreateResponse(
        ok=True, message=f"Report {report.reference} saved to PostgreSQL.", report=report
    )


@app.get("/api/reports/{reference}")
def get_report(reference: str):
    conn, cur = get_cursor()
    try:
        cur.execute(
            """SELECT report_id, reference, title, category, location, description,
                      contact, status, created_at
               FROM reports WHERE reference = %s""",
            (reference,),
        )
        row = cur.fetchone()
    finally:
        cur.close()
        conn.close()
    if row is None:
        raise HTTPException(status_code=404, detail="Report not found.")
    return ReportOut(**dict(row))


@app.delete("/api/reports/{reference}")
def delete_report(reference: str):
    conn, cur = get_cursor()
    try:
        cur.execute("DELETE FROM reports WHERE reference = %s", (reference,))
        deleted = cur.rowcount
        conn.commit()
    finally:
        cur.close()
        conn.close()
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Report not found.")
    return {"ok": True, "message": f"Report {reference} deleted."}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        reload=bool(os.getenv("RELOAD", "0") == "1"),
    )
