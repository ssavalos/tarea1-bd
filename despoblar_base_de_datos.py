#!/usr/bin/env python3
# despoblar_base_de_datos.py
# Vacía todas las tablas de la BD (mantiene el esquema).

from dotenv import load_dotenv
import os
import psycopg2

load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

if not all([DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT]):
    raise SystemExit("Faltan variables de entorno DB_*; revisa tu archivo .env")

TABLES = [
    # Orden no crítico porque usamos CASCADE,
    # pero listamos todas por claridad/coincidir con Create_tables.sql
    "Asignacion_Error",
    "Asignacion_Funcionalidad",
    "Criterio_Aceptacion",
    "ErrorBug",
    "Funcionalidad",
    "Ingeniero_Especialidad",
    "Ingeniero",
    "Usuario",
    "Topico",
]

def main():
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT,
    )
    conn.autocommit = False
    cur = conn.cursor()
    try:
        # TRUNCATE rápido y seguro con CASCADE
        stmt = "TRUNCATE {} RESTART IDENTITY CASCADE;".format(", ".join(TABLES))
        cur.execute(stmt)
        conn.commit()
        print("Datos eliminados correctamente (TRUNCATE CASCADE).")
    except Exception as e:
        conn.rollback()
        print(f"Ocurrió un error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()
