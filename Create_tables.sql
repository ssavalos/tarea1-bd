-- Elimina las tablas si existen, en orden inverso de dependencias
DROP TABLE IF EXISTS Asignacion_Error CASCADE;
DROP TABLE IF EXISTS Asignacion_Funcionalidad CASCADE;
DROP TABLE IF EXISTS ErrorBug CASCADE;
DROP TABLE IF EXISTS Criterio_Aceptacion CASCADE;
DROP TABLE IF EXISTS Funcionalidad CASCADE;
DROP TABLE IF EXISTS Ingeniero_Especialidad CASCADE;
DROP TABLE IF EXISTS Ingeniero CASCADE;
DROP TABLE IF EXISTS Topico CASCADE;
DROP TABLE IF EXISTS Usuario CASCADE;

CREATE TABLE IF NOT EXISTS Usuario (
    user_rut VARCHAR(12) PRIMARY KEY CHECK (user_rut ~ '^[0-9]{7,8}-[0-9K]$'),
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Topico (
    id_topico INT PRIMARY KEY,
    nombre_topico VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Ingeniero (
    ing_rut VARCHAR(12) PRIMARY KEY CHECK (ing_rut ~ '^[0-9]{7,8}-[0-9K]$'),
    nombre_ing VARCHAR(100),
    email_ing VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Ingeniero_Especialidad (
    id_topico INT,
    ing_rut VARCHAR(12),
    PRIMARY KEY (id_topico, ing_rut),
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);

CREATE TABLE IF NOT EXISTS Funcionalidad (
    id_funcionalidad INT PRIMARY KEY,
    titulo_funcion VARCHAR(100) NOT NULL CHECK (char_length(titulo_funcion) >= 20),
    ambiente VARCHAR(10) CHECK (ambiente IN ('Web','Móvil')),
    resumen VARCHAR(150) NOT NULL,
    estado_funcion VARCHAR(20) NOT NULL CHECK (estado_funcion IN ('Abierto','En Progreso','Resuelto','Cerrado','Archivado')),
    fecha_funcion DATE NOT NULL,
    id_topico INT NOT NULL,
    user_rut VARCHAR(12) NOT NULL,
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (user_rut) REFERENCES Usuario(user_rut)
);

CREATE TABLE IF NOT EXISTS Criterio_Aceptacion (
    id_criterio INT PRIMARY KEY,
    descripcion_criterio TEXT,
    id_funcionalidad INT,
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad)
);

CREATE TABLE IF NOT EXISTS ErrorBug (
    id_bug INT PRIMARY KEY,
    titulo_error VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    fecha_error DATE NOT NULL,
    estado_error VARCHAR(20) NOT NULL CHECK (estado_error IN ('Abierto','En Progreso','Resuelto','Cerrado')),
    id_topico INT NOT NULL,
    user_rut VARCHAR(12) NOT NULL,
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (user_rut) REFERENCES Usuario(user_rut)
);

CREATE TABLE IF NOT EXISTS Asignacion_Funcionalidad (
    id_funcionalidad INT,
    ing_rut VARCHAR(12),
    PRIMARY KEY (id_funcionalidad, ing_rut),
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);

CREATE TABLE IF NOT EXISTS Asignacion_Error (
    id_bug INT,
    ing_rut VARCHAR(12),
    PRIMARY KEY (id_bug, ing_rut),
    FOREIGN KEY (id_bug) REFERENCES ErrorBug(id_bug),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);
