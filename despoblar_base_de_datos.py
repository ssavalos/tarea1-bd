#!/usr/bin/env python3
"""despoblar_base_de_datos.py

Script para eliminar los datos de la base de datos PostgreSQL definida en este repositorio.

Notas/Asunciones:
- Elimina todos los registros de las tablas, manteniendo la estructura de la base de datos intacta.
- Asegúrate de que el orden de eliminación respete las claves foráneas.
"""

from dotenv import load_dotenv
import os
import psycopg2
from psycopg2.extras import execute_batch

load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

if not all([DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT]):
    raise SystemExit("Faltan variables de entorno DB_*; revisa tu archivo .env")

def main():
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT,
    )
    cur = conn.cursor()

    try:
        # Eliminar datos en el orden correcto para evitar conflictos de claves foráneas.
        
        # 1. Eliminar registros de asignación de errores (hijos primero)
        cur.execute("DELETE FROM Asignacion_Error;")
        
        # 2. Eliminar registros de asignación de funcionalidades
        cur.execute("DELETE FROM Asignacion_Funcionalidad;")
        
        # 3. Eliminar los criterios de aceptación
        cur.execute("DELETE FROM Criterio_Aceptacion;")
        
        # 4. Eliminar los errores
        cur.execute("DELETE FROM ErrorBug;")
        
        # 5. Eliminar las funcionalidades
        cur.execute("DELETE FROM Funcionalidad;")
        
        # 6. Eliminar las especialidades de los ingenieros
        cur.execute("DELETE FROM Ingeniero_Especialidad;")
        
        # 7. Eliminar los ingenieros
        cur.execute("DELETE FROM Ingeniero;")
        
        # 8. Eliminar los usuarios
        cur.execute("DELETE FROM Usuario;")
        
        # 9. Finalmente, eliminar los tópicos
        cur.execute("DELETE FROM Topico;")

        conn.commit()

        print("Datos eliminados correctamente.")

    except Exception as e:
        conn.rollback()
        print(f"Ocurrió un error: {e}")
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    main()
