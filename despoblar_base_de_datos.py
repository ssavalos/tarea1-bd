#!/usr/bin/env python3
"""despoblar_base_de_datos.py

Elimina los datos insertados por `poblar_base_de_datos.py`.

Modo seguro (por defecto): borra solo los rangos creados por el script de poblado.
Modo total: pasar --all para truncar todas las tablas (destructivo).

Asunciones:
- Los usuarios tienen user_rut 10000000..10000049
- Los ingenieros tienen ing_rut 20000000..20000049
- Funcionalidades id 1..200
- Errores id 1..300
- Topicos id 1..10

Ejecutar:
python despoblar_base_de_datos.py      # modo seguro
python despoblar_base_de_datos.py --all  # truncar todas las tablas
"""
import os
import sys
from dotenv import load_dotenv
import psycopg2


load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

if not all([DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT]):
    raise SystemExit("Faltan variables de entorno DB_*; revisa tu archivo .env")


def confirm(prompt="¿Continuar? (si/no): "):
    ans = input(prompt).strip().lower()
    return ans in ("s", "si", "y", "yes")


def despoblar_por_rangos(cur):
    # Borrar asignaciones primero por FK
    stmts = [
        ("DELETE FROM Asignacion_Error WHERE id_bug BETWEEN 1 AND 300;", "Asignacion_Error"),
        ("DELETE FROM Asignacion_Funcionalidad WHERE id_funcionalidad BETWEEN 1 AND 200;", "Asignacion_Funcionalidad"),
        ("DELETE FROM Criterio_Aceptacion WHERE id_funcionalidad BETWEEN 1 AND 200;", "Criterio_Aceptacion"),
        ("DELETE FROM ErrorBug WHERE id_bug BETWEEN 1 AND 300;", "ErrorBug"),
        ("DELETE FROM Funcionalidad WHERE id_funcionalidad BETWEEN 1 AND 200;", "Funcionalidad"),
        ("DELETE FROM Ingeniero_Especialidad WHERE ing_rut BETWEEN 20000000 AND 20000049;", "Ingeniero_Especialidad"),
        ("DELETE FROM Ingeniero WHERE ing_rut BETWEEN 20000000 AND 20000049;", "Ingeniero"),
        ("DELETE FROM Usuario WHERE user_rut BETWEEN 10000000 AND 10000049;", "Usuario"),
        ("DELETE FROM Topico WHERE id_topico BETWEEN 1 AND 10;", "Topico"),
    ]

    results = {}
    for sql, name in stmts:
        cur.execute(sql)
        results[name] = cur.rowcount
    return results


def truncar_todo(cur):
    # Trunca en cascada para manejar FKs automáticamente
    cur.execute(
        "TRUNCATE TABLE Asignacion_Error, Asignacion_Funcionalidad, Criterio_Aceptacion, ErrorBug, Funcionalidad, Ingeniero_Especialidad, Ingeniero, Usuario, Topico RESTART IDENTITY CASCADE;"
    )
    return {"truncated": True}


def main():
    force_all = "--all" in sys.argv
    assume_yes = "--yes" in sys.argv or "-y" in sys.argv

    print("Modo:", "TRUNCATE ALL tablas" if force_all else "Borrado por rangos (seguro)")
    if not assume_yes:
        ok = confirm("ESTO ES PELIGROSO: deseas continuar? (si/no): ")
        if not ok:
            print("Operación cancelada.")
            return

    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT,
    )
    cur = conn.cursor()

    try:
        if force_all:
            res = truncar_todo(cur)
            conn.commit()
            print("Truncado completo de tablas realizado.")
        else:
            res = despoblar_por_rangos(cur)
            conn.commit()
            print("Borrado por rangos completado. Filas afectadas por tabla:")
            for k, v in res.items():
                print(f"  {k}: {v}")

    except Exception as e:
        conn.rollback()
        print("Error durante el despoblado:", e)
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    main()
