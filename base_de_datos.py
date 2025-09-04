import psycopg2
from dotenv import load_dotenv
import os

# Cargar las variables de entorno desde el archivo .env
load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

# Crear la base de datos si no existe
try:
    conn = psycopg2.connect(
        dbname="postgres",
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )
    conn.autocommit = True
    cur = conn.cursor()

    cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{DB_NAME}'")
    exists = cur.fetchone()
    if not exists:
        cur.execute(f"CREATE DATABASE {DB_NAME}")
        print(f"Base de datos '{DB_NAME}' creada.")
    else:
        print(f"La base de datos '{DB_NAME}' ya existe.")

    cur.close()
    conn.close()

except Exception as e:
    print(f"Error creando la base de datos: {e}")
    exit()

# Crear las tablas usando el archivo Create_tables.sql
try:
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )
    cur = conn.cursor()

    with open("Create_tables.sql", "r", encoding="utf-8") as sql_file:
        cur.execute(sql_file.read())
    conn.commit()
    print("Tablas creadas desde 'Create_tables.sql'.")

except Exception as e:
    print(f"Error en la ejecución general: {e}")

finally:
    if 'cur' in locals():
        cur.close()
    if 'conn' in locals():
        conn.close()

if __name__ == "__main__":
    main()

