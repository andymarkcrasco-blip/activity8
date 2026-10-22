"""Database connection and schema setup for the Activity 10 REST API.

Uses PostgreSQL (IT 108). Connection settings come from environment
variables so the same code runs on a lab machine and on a server.
"""
import os

import psycopg2
from psycopg2.extras import RealDictCursor

DB_HOST = os.getenv("PGHOST", "localhost")
DB_PORT = os.getenv("PGPORT", "5432")
DB_NAME = os.getenv("PGDATABASE", "eventvenue_db")
DB_USER = os.getenv("PGUSER", "eventvenue")
DB_PASS = os.getenv("PGPASSWORD", "eventvenue_dev")


def get_connection():
    """Return a new PostgreSQL connection."""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        cursor_factory=RealDictCursor,
    )


def get_cursor():
    """Return (connection, cursor). The caller closes the connection."""
    conn = get_connection()
    return conn, conn.cursor()


def init_database():
    """Create the database if it is missing, then apply schema.sql."""
    # 1. connect to the maintenance database to check for our database
    admin = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname="postgres",
        user=DB_USER,
        password=DB_PASS,
    )
    admin.autocommit = True
    with admin.cursor() as cur:
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (DB_NAME,))
        if cur.fetchone() is None:
            cur.execute(f'CREATE DATABASE "{DB_NAME}"')
            print(f"[db] created database {DB_NAME}")
        else:
            print(f"[db] database {DB_NAME} already exists")
    admin.close()

    # 2. apply the schema
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "schema.sql"), "r", encoding="utf-8") as f:
        sql = f.read()

    conn, cur = get_cursor()
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()
    print("[db] schema applied")
