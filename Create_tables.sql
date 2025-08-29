-- Aquí van las tablas, llaves primarias y foráneas
-- Ejemplo: CREATE TABLE usuarios (...);

CREATE TABLE Usuario (
    user_rut INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Topico (
    id_topico INT PRIMARY KEY,
    nombre_topico VARCHAR(100)
);

CREATE TABLE Ingeniero (
    ing_rut INT PRIMARY KEY,
    nombre_ing VARCHAR(100),
    email_ing VARCHAR(100)
);

CREATE TABLE Ingeniero_Especialidad (
    id_topico INT,
    ing_rut INT,
    especialidad VARCHAR(100),
    PRIMARY KEY (id_topico, ing_rut),
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);

CREATE TABLE Funcionalidad (
    id_funcionalidad INT PRIMARY KEY,
    titulo_funcion VARCHAR(100),
    ambiente VARCHAR(100),
    resumen TEXT,
    estado_funcion VARCHAR(50),
    fecha_funcion DATE,
    id_topico INT,
    user_rut INT,
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
    titulo_error VARCHAR(100),
    descripcion TEXT,
    fecha_error DATE,
    estado_error VARCHAR(50),
    id_topico INT,
    user_rut INT,
    FOREIGN KEY (id_topico) REFERENCES Topico(id_topico),
    FOREIGN KEY (user_rut) REFERENCES Usuario(user_rut)
);

CREATE TABLE Asignacion_Funcionalidad (
    id_funcionalidad INT,
    ing_rut INT,
    PRIMARY KEY (id_funcionalidad, ing_rut),
    FOREIGN KEY (id_funcionalidad) REFERENCES Funcionalidad(id_funcionalidad),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);

CREATE TABLE Asignacion_Error (
    id_bug INT,
    ing_rut INT,
    PRIMARY KEY (id_bug, ing_rut),
    FOREIGN KEY (id_bug) REFERENCES ErrorBug(id_bug),
    FOREIGN KEY (ing_rut) REFERENCES Ingeniero(ing_rut)
);
