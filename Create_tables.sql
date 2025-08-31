-- Aqui van las tablas, llaves primarias y foraneas

CREATE TABLE Usuario (
    user_rut VARCHAR(12) PRIMARY KEY CHECK (user_rut ~ '^[0-9]{7,8}-[0-9K]$'),
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Topico (
    id_topico INT PRIMARY KEY,
    nombre_topico VARCHAR(100)
);

CREATE TABLE Ingeniero (
    ing_rut VARCHAR(12) PRIMARY KEY CHECK (ing_rut ~ '^[0-9]{7,8}-[0-9K]$'),
    nombre_ing VARCHAR(100),
    email_ing VARCHAR(100)
);

CREATE TABLE Ingeniero_Especialidad (
    id_topico INT,
    ing_rut VARCHAR(12),
    PRIMARY KEY (id_topico, ing_rut),
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);

CREATE TABLE Funcionalidad (
    id_funcionalidad INT PRIMARY KEY,
    titulo_funcion VARCHAR(100) NOT NULL CHECK (char_length(titulo_funcion) >= 20),
    ambiente VARCHAR(10) CHECK (ambiente IN ('Web','Móvil')),
    resumen VARCHAR(150) NOT NULL,
    estado_funcion VARCHAR(20) NOT NULL CHECK (estado_funcion IN ('Abierto','En Progreso','Resuelto','Cerrado')),
    fecha_funcion DATE NOT NULL,
    id_topico INT NOT NULL,
    user_rut VARCHAR(12) NOT NULL,
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (user_rut) REFERENCES Usuario(user_rut)
);

CREATE TABLE Criterio_Aceptacion (
    id_criterio INT PRIMARY KEY,
    descripcion_criterio TEXT,
    id_funcionalidad INT,
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad)
);

CREATE TABLE ErrorBug (
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

CREATE TABLE Asignacion_Funcionalidad (
    id_funcionalidad INT,
    ing_rut VARCHAR(12),
    PRIMARY KEY (id_funcionalidad, ing_rut),
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);

CREATE TABLE Asignacion_Error (
    id_bug INT,
    ing_rut VARCHAR(12),
    PRIMARY KEY (id_bug, ing_rut),
    FOREIGN KEY (id_bug) REFERENCES ErrorBug(id_bug),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);
