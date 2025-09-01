#!/usr/bin/env python3
"""poblar_base_de_datos.py

Script para poblar la base de datos PostgreSQL definida en este repositorio.

Genera:
- 50 Usuarios
- 80 Ingenieros
- 300 ErrorBug
- 200 Funcionalidad
"""

from dotenv import load_dotenv
import os
import random
import datetime
from faker import Faker
import psycopg2
from psycopg2.extras import execute_batch
from collections import defaultdict, Counter

load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

if not all([DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT]):
    raise SystemExit("Faltan variables de entorno DB_*; revisa tu archivo .env")

faker = Faker('es_ES')
random.seed(42)

NUM_USERS = 50
NUM_ING = 80
NUM_BUGS = 300
NUM_FUNCS = 200
NUM_TOPICS = 3  # Backend, Seguridad, UX/UI
NUM_CRITERIA = 3


def random_date(start_year=2023, end_year=2025):
    start = datetime.date(start_year, 1, 1)
    end = datetime.date(end_year, 12, 31)
    days = (end - start).days
    return start + datetime.timedelta(days=random.randint(0, max(0, days)))


def generate_rut():
    """Genera un RUT chileno aleatorio en formato XXXXXXXX-X"""
    rut = random.randint(1_000_000, 25_000_000)
    dv_options = list(map(str, range(10))) + ["K"]
    dv = random.choice(dv_options)
    return f"{rut}-{dv}"


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
        # ======================
        # 1) Catálogo de tópicos
        # ======================
        topics = [
            (1, "Backend"),
            (2, "Seguridad"),
            (3, "UX/UI"),
        ]
        execute_batch(
            cur,
            "INSERT INTO Topico (id_topico, nombre_topico) VALUES (%s, %s) "
            "ON CONFLICT (id_topico) DO NOTHING",
            topics,
        )

        # ===============
        # 2) Usuarios
        # ===============
        user_ruts, users = [], []
        for _ in range(NUM_USERS):
            rut = generate_rut()
            user_ruts.append(rut)
            users.append((rut, faker.name(), faker.email()))
        execute_batch(
            cur,
            "INSERT INTO Usuario (user_rut, nombre, email) VALUES (%s, %s, %s) "
            "ON CONFLICT (user_rut) DO NOTHING",
            users,
        )

        # ===============
        # 3) Ingenieros
        # ===============
        ing_ruts, ings = [], []
        for _ in range(NUM_ING):
            rut = generate_rut()
            ing_ruts.append(rut)
            ings.append((rut, faker.name(), faker.email()))
        execute_batch(
            cur,
            "INSERT INTO Ingeniero (ing_rut, nombre_ing, email_ing) VALUES (%s, %s, %s) "
            "ON CONFLICT (ing_rut) DO NOTHING",
            ings,
        )

        # ==========================================
        # 4) Especialidades (1–2 por ingeniero)
        # ==========================================
        ing_especial = []
        for ing in ing_ruts:
            k = random.randint(1, min(2, NUM_TOPICS))  # máx 2 por trigger
            for t in random.sample(range(1, NUM_TOPICS + 1), k):
                ing_especial.append((t, ing))

        if ing_especial:
            execute_batch(
                cur,
                "INSERT INTO Ingeniero_Especialidad (id_topico, ing_rut) VALUES (%s, %s) "
                "ON CONFLICT (id_topico, ing_rut) DO NOTHING",
                ing_especial,
            )

        # ---- Asegurar ≥ 3 especialistas por cada tópico (para poder asignar 3) ----
        cur.execute("SELECT id_topico, COUNT(*) FROM Ingeniero_Especialidad GROUP BY id_topico")
        faltantes = {t: max(0, 3 - c) for t, c in cur.fetchall()}
        for t, faltan in faltantes.items():
            while faltan > 0:
                cand = random.choice(ing_ruts)
                # respeta el trigger de máx. 2 especialidades
                cur.execute("SELECT COUNT(*) FROM Ingeniero_Especialidad WHERE ing_rut = %s", (cand,))
                if cur.fetchone()[0] >= 2:
                    continue
                # evita duplicar misma especialidad
                cur.execute(
                    "SELECT 1 FROM Ingeniero_Especialidad WHERE ing_rut = %s AND id_topico = %s",
                    (cand, t),
                )
                if cur.fetchone():
                    continue
                cur.execute(
                    "INSERT INTO Ingeniero_Especialidad (id_topico, ing_rut) VALUES (%s, %s) "
                    "ON CONFLICT DO NOTHING",
                    (t, cand),
                )
                faltan -= 1

        # ===================================
        # 5) Funcionalidades (con tope 25/día)
        # ===================================
        estados_func = ["Abierto", "En Progreso", "Resuelto", "Cerrado"]
        cuenta_func_dia = defaultdict(int)  # (user_rut, fecha) -> conteo
        funcs = []
        for fid in range(1, NUM_FUNCS + 1):
            # respetar trigger: máx 25 por día/usuario
            while True:
                fecha = random_date(2023, 2025)
                user_rut = random.choice(user_ruts)
                if cuenta_func_dia[(user_rut, fecha)] < 25:
                    cuenta_func_dia[(user_rut, fecha)] += 1
                    break

            titulo = f"Funcionalidad {fid}"
            ambiente = random.choice(["Web", "Móvil"])
            resumen = faker.sentence(nb_words=10)
            estado = random.choice(estados_func)
            id_topico = random.randint(1, NUM_TOPICS)

            funcs.append(
                (fid, titulo, ambiente, resumen, estado, fecha, id_topico, user_rut)
            )

        execute_batch(
            cur,
            "INSERT INTO Funcionalidad "
            "(id_funcionalidad, titulo_funcion, ambiente, resumen, estado_funcion, fecha_funcion, id_topico, user_rut) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s) "
            "ON CONFLICT (id_funcionalidad) DO NOTHING",
            funcs,
        )

        # ===============================
        # 6) Criterios de aceptación (3)
        # ===============================
        criterios, criterio_id = [], 1
        for fid in range(1, NUM_FUNCS + 1):
            for _ in range(NUM_CRITERIA):
                criterios.append((criterio_id, faker.sentence(nb_words=6), fid))
                criterio_id += 1
        execute_batch(
            cur,
            "INSERT INTO Criterio_Aceptacion (id_criterio, descripcion_criterio, id_funcionalidad) "
            "VALUES (%s, %s, %s) ON CONFLICT (id_criterio) DO NOTHING",
            criterios,
        )

        # =================================
        # 7) Errores (con tope 25 por día)
        # =================================
        estados_bug = ["Abierto", "En Progreso", "Resuelto", "Cerrado"]
        cuenta_bug_dia = defaultdict(int)  # (user_rut, fecha) -> conteo
        bugs = []
        for bid in range(1, NUM_BUGS + 1):
            # respetar trigger: máx 25 por día/usuario
            while True:
                fecha = random_date(2023, 2025)
                user_rut = random.choice(user_ruts)
                if cuenta_bug_dia[(user_rut, fecha)] < 25:
                    cuenta_bug_dia[(user_rut, fecha)] += 1
                    break

            titulo = f"Error {bid}"
            descripcion = faker.paragraph(nb_sentences=2)
            estado = random.choice(estados_bug)
            id_topico = random.randint(1, NUM_TOPICS)

            bugs.append((bid, titulo, descripcion, fecha, estado, id_topico, user_rut))

        execute_batch(
            cur,
            "INSERT INTO ErrorBug "
            "(id_bug, titulo_error, descripcion, fecha_error, estado_error, id_topico, user_rut) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s) "
            "ON CONFLICT (id_bug) DO NOTHING",
            bugs,
        )

        # ===========================================================
        # 8) Asignaciones: exactamente 3 especialistas por solicitud
        # ===========================================================
        especialistas_por_topico = defaultdict(list)
        cur.execute("SELECT id_topico, ing_rut FROM Ingeniero_Especialidad")
        for t, r in cur.fetchall():
            especialistas_por_topico[t].append(r)

        conteo_asign = Counter()  # total (func + error) por ingeniero

        def elegir_3(topico):
            pool = [r for r in especialistas_por_topico[topico] if conteo_asign[r] < 20]
            if len(pool) < 3:
                pool = especialistas_por_topico[topico][:]  # fallback si el tope 20 aprieta
            elegidos = random.sample(pool, 3)
            for r in elegidos:
                conteo_asign[r] += 1
            return elegidos

        asign_funcs = []
        for (fid, _titulo, _amb, _res, _est, _fec, id_topico, _ur) in funcs:
            for ing in elegir_3(id_topico):
                asign_funcs.append((fid, ing))
        execute_batch(
            cur,
            "INSERT INTO Asignacion_Funcionalidad (id_funcionalidad, ing_rut) "
            "VALUES (%s, %s) ON CONFLICT (id_funcionalidad, ing_rut) DO NOTHING",
            asign_funcs,
        )

        asign_bugs = []
        for (bid, _tit, _desc, _fec, _est, id_topico, _ur) in bugs:
            for ing in elegir_3(id_topico):
                asign_bugs.append((bid, ing))
        execute_batch(
            cur,
            "INSERT INTO Asignacion_Error (id_bug, ing_rut) "
            "VALUES (%s, %s) ON CONFLICT (id_bug, ing_rut) DO NOTHING",
            asign_bugs,
        )

        conn.commit()

        print(
            f"Insertados: {len(topics)} tópicos, {len(users)} usuarios, {len(ings)} ingenieros, "
            f"{len(funcs)} funcionalidades, {len(bugs)} errores."
        )
        print(
            f"Criterios creados: {len(criterios)}. "
            f"Asign. funcionalidad: {len(asign_funcs)}. Asign. errores: {len(asign_bugs)}"
        )

    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    main()
