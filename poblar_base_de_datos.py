#!/usr/bin/env python3
"""poblar_base_de_datos.py

Script para poblar la base de datos PostgreSQL definida en este repositorio.

Genera:
- 50 Usuarios
- 50 Ingenieros
- 300 ErrorBug
- 200 Funcionalidad

Notas/Asunciones:
- Usa variables de entorno: DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT (cargadas desde .env)
- No trunca tablas; usa INSERT ... ON CONFLICT DO NOTHING para evitar errores si ya hay datos.
- Requiere las dependencias listadas en requirements.txt (psycopg2-binary, python-dotenv, faker).
"""
from dotenv import load_dotenv
import os
import random
import datetime
from faker import Faker
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

faker = Faker('es_ES')
random.seed(42)

NUM_USERS = 50
NUM_ING = 50
NUM_BUGS = 300
NUM_FUNCS = 200
NUM_TOPICS = 3  # Tres tópicos específicos
NUM_CRITERIA = 3


def random_date(start_year=2023, end_year=2025):
    start = datetime.date(start_year, 1, 1)
    end = datetime.date(end_year, 12, 31)
    days = (end - start).days
    return start + datetime.timedelta(days=random.randint(0, max(0, days)))


def generate_rut():
    """Genera un RUT chileno aleatorio en formato XXXXXXXX-X"""
    rut = random.randint(10000000, 25000000)  # Genera un número aleatorio de RUT
    dv = random.randint(0, 9)  # Genera un dígito verificador aleatorio
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
        # Tópicos (categorías específicas)
        topics = [
            (1, "Backend"),
            (2, "Seguridad"),
            (3, "UX/UI")
        ]
        execute_batch(cur,
                      "INSERT INTO Topico (id_topico, nombre_topico) VALUES (%s, %s) ON CONFLICT (id_topico) DO NOTHING",
                      topics)

        # Usuarios
        user_ruts = []
        users = []
        for i in range(NUM_USERS):
            rut = generate_rut()
            user_ruts.append(rut)
            users.append((rut, faker.name(), faker.email()))

        execute_batch(cur,
                      "INSERT INTO Usuario (user_rut, nombre, email) VALUES (%s, %s, %s) ON CONFLICT (user_rut) DO NOTHING",
                      users)

        # Ingenieros
        ing_ruts = []
        ings = []
        for i in range(NUM_ING):
            rut = generate_rut()
            ing_ruts.append(rut)
            ings.append((rut, faker.name(), faker.email()))
        
        execute_batch(cur,
                      "INSERT INTO Ingeniero (ing_rut, nombre_ing, email_ing) VALUES (%s, %s, %s) ON CONFLICT (ing_rut) DO NOTHING",
                      [(ing[0], ing[1], ing[2]) for ing in ings])

        # Ingeniero_Especialidad: asignar 1-3 tópicos por ingeniero
        ing_especial = []
        especialidades = ["Backend", "Seguridad", "UI/UX"]
        for ing in ing_ruts:
            k = random.randint(1, 3)
            chosen = random.sample(range(1, NUM_TOPICS + 1), k)
            for t in chosen:
                especialidad = random.choice(especialidades)  # Elegir especialidad al azar
                ing_especial.append((t, ing, especialidad))  # Insertar en Ingeniero_Especialidad

        if ing_especial:
            execute_batch(cur,
                          "INSERT INTO Ingeniero_Especialidad (id_topico, ing_rut, especialidad) VALUES (%s, %s, %s) ON CONFLICT (id_topico, ing_rut) DO NOTHING",
                          ing_especial)

        # Funcionalidad
        estados_func = ["Abierto", "En Progreso", "Resuelto", "Cerrado"]
        funcs = []
        for fid in range(1, NUM_FUNCS + 1):
            titulo = f"Funcionalidad {fid}"  # Generar título de funcionalidad más acorde
            ambiente = random.choice(["Web", "Móvil"])  # Asignar ambiente "Web" o "Móvil"
            resumen = faker.sentence(nb_words=10)  # Generar un resumen más realista
            estado = random.choice(estados_func)  # Asignar estado aleatorio
            fecha = random_date(2023, 2025)
            id_topico = random.randint(1, NUM_TOPICS)
            user_rut = random.choice(user_ruts)
            funcs.append((fid, titulo, ambiente, resumen, estado, fecha, id_topico, user_rut))

        execute_batch(cur,
                      """INSERT INTO Funcionalidad (id_funcionalidad, titulo_funcion, ambiente, resumen, estado_funcion, fecha_funcion, id_topico, user_rut)
                      VALUES (%s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT (id_funcionalidad) DO NOTHING""",
                      funcs)

        # Criterios de aceptación: 1-3 por funcionalidad
        criterios = []
        criterio_id = 1
        for fid in range(1, NUM_FUNCS + 1):
            k = random.randint(1, NUM_CRITERIA)
            for _ in range(k):
                criterios.append((criterio_id, faker.sentence(nb_words=6), fid))
                criterio_id += 1

        if criterios:
            execute_batch(cur,
                          "INSERT INTO Criterio_Aceptacion (id_criterio, descripcion_criterio, id_funcionalidad) VALUES (%s, %s, %s) ON CONFLICT (id_criterio) DO NOTHING",
                          criterios)

        # ErrorBug
        estados_bug = ["Abierto", "En Progreso", "Resuelto", "Cerrado"]
        bugs = []
        for bid in range(1, NUM_BUGS + 1):
            titulo = f"Error {bid}"  # Título más acorde con el contexto
            descripcion = faker.paragraph(nb_sentences=2)  # Resumen más corto
            fecha = random_date(2023, 2025)
            estado = random.choice(estados_bug)  # Asignar estado aleatorio
            id_topico = random.randint(1, NUM_TOPICS)
            user_rut = random.choice(user_ruts)
            bugs.append((bid, titulo, descripcion, fecha, estado, id_topico, user_rut))

        execute_batch(cur,
                      """INSERT INTO ErrorBug (id_bug, titulo_error, descripcion, fecha_error, estado_error, id_topico, user_rut)
                      VALUES (%s, %s, %s, %s, %s, %s, %s) ON CONFLICT (id_bug) DO NOTHING""",
                      bugs)

        # Asignaciones de funcionalidad: 1-2 ingenieros por funcionalidad
        asign_funcs = []
        for fid in range(1, NUM_FUNCS + 1):
            k = random.randint(1, 2)
            chosen = random.sample(ing_ruts, k)
            for ing in chosen:
                asign_funcs.append((fid, ing))

        if asign_funcs:
            execute_batch(cur,
                          "INSERT INTO Asignacion_Funcionalidad (id_funcionalidad, ing_rut) VALUES (%s, %s) ON CONFLICT (id_funcionalidad, ing_rut) DO NOTHING",
                          asign_funcs)

        # Asignaciones de errores: 1-2 ingenieros por bug
        asign_bugs = []
        for bid in range(1, NUM_BUGS + 1):
            k = random.randint(1, 2)
            chosen = random.sample(ing_ruts, k)
            for ing in chosen:
                asign_bugs.append((bid, ing))

        if asign_bugs:
            execute_batch(cur,
                          "INSERT INTO Asignacion_Error (id_bug, ing_rut) VALUES (%s, %s) ON CONFLICT (id_bug, ing_rut) DO NOTHING",
                          asign_bugs)

        conn.commit()

        print(f"Insertados: {len(topics)} tópicos, {len(users)} usuarios, {len(ings)} ingenieros, {len(funcs)} funcionalidades, {len(bugs)} errores.")
        print(f"Criterios creados: {len(criterios)}. Asign. funcionalidad: {len(asign_funcs)}. Asign. errores: {len(asign_bugs)}")

    except Exception as e:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    main()
