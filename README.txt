Nombre de los Alumnos:
Néstor López - Rol: 202304074-6
Sofía Avalos - Rol: 202373011-4

Instrucciones de Ejecución:

Este proyecto está diseñado para la Tarea 1 de Bases de Datos. Para su correcta ejecución, siga los siguientes pasos:

1.  **Instalar dependencias:**
    Asegúrese de tener Python y pip instalados. Luego, instale las librerías necesarias ejecutando el siguiente comando en la terminal:
    pip install -r requirements.txt

2.  **Configurar la conexión a la base de datos:**
    Cree un archivo llamado `.env` en el directorio raíz del proyecto con la siguiente información, reemplazando los valores por los de su base de datos PostgreSQL:

    DB_NAME=nombre_de_su_bd
    DB_USER=su_usuario
    DB_PASS=su_contraseña
    DB_HOST=su_host
    DB_PORT=su_puerto

3.  **Crear la base de datos y las tablas:**
    Ejecute el script `base_de_datos.py`. Este script creará la base de datos (si no existe) y luego ejecutará el archivo `Create_tables.sql` para generar el esquema de tablas.
    python base_de_datos.py

4.  **Poblar la base de datos:**
    Ejecute el script `poblar_base_de_datos.py`. Este script insertará los 600+ datos de prueba requeridos en las tablas.
    python poblar_base_de_datos.py

5.  **Ejecutar las consultas SQL:**
    Una vez que la base de datos esté poblada, puede encontrar las consultas requeridas en el archivo `Consultas.sql`. Copie y pegue estas consultas en un cliente de base de datos como pgAdmin para ejecutarlas y verificar los resultados.

6.  **Limpiar la base de datos (Opcional):**
    Si necesita vaciar las tablas y eliminar todos los datos de prueba, puede ejecutar el script `despoblar_base_de_datos.py`.
    python despoblar_base_de_datos.py