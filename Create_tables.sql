-- Aquí van las tablas, llaves primarias y foráneas
-- Ejemplo: CREATE TABLE usuarios (...);

CREATE TABLE Usuario (
    id_user INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Topico (
    id_topico INT PRIMARY KEY,
    nombre_topico VARCHAR(100)
);

CREATE TABLE Ingeniero (
    id_ing INT PRIMARY KEY,
    nombre_ing VARCHAR(100),
    email_ing VARCHAR(100)
);

CREATE TABLE Ingeniero_Especialidad (
    id_topico INT,
    id_ing INT,
    especialidad VARCHAR(100),
    PRIMARY KEY (id_topico, id_ing),
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (id_ing) REFERENCES Ingeniero(id_ing)
);

CREATE TABLE Funcionalidad (
    id_funcionalidad INT PRIMARY KEY,
    titulo_funcion VARCHAR(100),
    ambiente VARCHAR(100),
    resumen TEXT,
    estado_funcion VARCHAR(50),
    fecha_funcion DATE,
    id_topico INT,
    id_user INT,
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (id_user) REFERENCES Usuario(id_user)
);

CREATE TABLE Criterio_Aceptacion (
    id_criterio INT PRIMARY KEY,
    descripcion_criterio TEXT,
    id_funcionalidad INT,
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad)
);

CREATE TABLE ErrorBug (
    id_bug INT PRIMARY KEY,
    titulo_error VARCHAR(100),
    descripcion TEXT,
    fecha_error DATE,
    estado_error VARCHAR(50),
    id_topico INT,
    id_user INT,
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (id_user) REFERENCES Usuario(id_user)
);

CREATE TABLE Asignacion_Funcionalidad (
    id_funcionalidad INT,
    id_ing INT,
    PRIMARY KEY (id_funcionalidad, id_ing),
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad),
    FOREIGN KEY (id_ing) REFERENCES Ingeniero(id_ing)
);

CREATE TABLE Asignacion_Error (
    id_bug INT,
    id_ing INT,
    PRIMARY KEY (id_bug, id_ing),
    FOREIGN KEY (id_bug) REFERENCES ErrorBug(id_bug),
    FOREIGN KEY (id_ing) REFERENCES Ingeniero(id_ing)
);
