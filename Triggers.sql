-- Restricciones que se ejecutan despues de crear las tablas y poblar

-- RESTRICCION: Un ingeniero no puede tener mas de 2 especialidades --
CREATE OR REPLACE FUNCTION limit_especialidades()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) 
      FROM Ingeniero_Especialidad
      WHERE ing_rut = NEW.ing_rut) >= 2 THEN
    RAISE EXCEPTION 'Un ingeniero no puede tener más de 2 especialidades (%).', NEW.ing_rut;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_especialidades ON Ingeniero_Especialidad;
CREATE TRIGGER trg_limit_especialidades
BEFORE INSERT ON Ingeniero_Especialidad
FOR EACH ROW
EXECUTE FUNCTION limit_especialidades();


-- RESTRICCION: El ingeniero debe ser especialista del mismo topico --

-- Funcionalidad
CREATE OR REPLACE FUNCTION chk_asign_func_especialidad()
RETURNS trigger AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM Funcionalidad f
    JOIN Ingeniero_Especialidad ie ON ie.id_topico = f.id_topico
    WHERE f.id_funcionalidad = NEW.id_funcionalidad
      AND ie.ing_rut = NEW.ing_rut
  ) THEN
    RAISE EXCEPTION 'Ingeniero % no es especialista del tópico de la funcionalidad %',
      NEW.ing_rut, NEW.id_funcionalidad;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_chk_asign_func_especialidad ON Asignacion_Funcionalidad;
CREATE TRIGGER trg_chk_asign_func_especialidad
BEFORE INSERT ON Asignacion_Funcionalidad
FOR EACH ROW EXECUTE FUNCTION chk_asign_func_especialidad();

-- ErrorBug
CREATE OR REPLACE FUNCTION chk_asign_error_especialidad()
RETURNS trigger AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM ErrorBug e
    JOIN Ingeniero_Especialidad ie ON ie.id_topico = e.id_topico
    WHERE e.id_bug = NEW.id_bug
      AND ie.ing_rut = NEW.ing_rut
  ) THEN
    RAISE EXCEPTION 'Ingeniero % no es especialista del tópico del error %',
      NEW.ing_rut, NEW.id_bug;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_chk_asign_error_especialidad ON Asignacion_Error;
CREATE TRIGGER trg_chk_asign_error_especialidad
BEFORE INSERT ON Asignacion_Error
FOR EACH ROW EXECUTE FUNCTION chk_asign_error_especialidad();


-- RESTRICCION: Exactamente 3 asignaciones por solicitud --
CREATE OR REPLACE FUNCTION limit_3_asign_func()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM Asignacion_Funcionalidad
      WHERE id_funcionalidad = NEW.id_funcionalidad) >= 3 THEN
    RAISE EXCEPTION 'La funcionalidad % ya tiene 3 ingenieros asignados', NEW.id_funcionalidad;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_3_asign_func ON Asignacion_Funcionalidad;
CREATE TRIGGER trg_limit_3_asign_func
BEFORE INSERT ON Asignacion_Funcionalidad
FOR EACH ROW EXECUTE FUNCTION limit_3_asign_func();

CREATE OR REPLACE FUNCTION limit_3_asign_error()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM Asignacion_Error
      WHERE id_bug = NEW.id_bug) >= 3 THEN
    RAISE EXCEPTION 'El error % ya tiene 3 ingenieros asignados', NEW.id_bug;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_3_asign_error ON Asignacion_Error;
CREATE TRIGGER trg_limit_3_asign_error
BEFORE INSERT ON Asignacion_Error
FOR EACH ROW EXECUTE FUNCTION limit_3_asign_error();


-- RESTRICCION: Maximo 20 solicitudes por ingeniero
CREATE OR REPLACE FUNCTION max_20_por_ingeniero()
RETURNS trigger AS $$
DECLARE total INTEGER;
BEGIN
  SELECT
    (SELECT COUNT(*) FROM Asignacion_Funcionalidad WHERE ing_rut = NEW.ing_rut) +
    (SELECT COUNT(*) FROM Asignacion_Error          WHERE ing_rut = NEW.ing_rut)
  INTO total;

  IF total >= 20 THEN
    RAISE EXCEPTION 'Ingeniero % no puede tener más de 20 solicitudes asignadas', NEW.ing_rut;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_max_20_func ON Asignacion_Funcionalidad;
CREATE TRIGGER trg_max_20_func
BEFORE INSERT ON Asignacion_Funcionalidad
FOR EACH ROW EXECUTE FUNCTION max_20_por_ingeniero();

DROP TRIGGER IF EXISTS trg_max_20_error ON Asignacion_Error;
CREATE TRIGGER trg_max_20_error
BEFORE INSERT ON Asignacion_Error
FOR EACH ROW EXECUTE FUNCTION max_20_por_ingeniero();


-- RESTRICCION: Titulos unicos por tipo de solicitud --
ALTER TABLE Funcionalidad
  ADD CONSTRAINT uq_titulo_funcion UNIQUE (titulo_funcion);

ALTER TABLE ErrorBug
  ADD CONSTRAINT uq_titulo_error UNIQUE (titulo_error);


-- RESTRICCION: Limite por dia max 25 funcionalidades/errores por usuario
CREATE OR REPLACE FUNCTION limit_25_func_por_dia()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM Funcionalidad
      WHERE user_rut = NEW.user_rut
        AND fecha_funcion = NEW.fecha_funcion) >= 25 THEN
    RAISE EXCEPTION 'El usuario % ya creó 25 funcionalidades el %',
      NEW.user_rut, NEW.fecha_funcion;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_25_func_por_dia ON Funcionalidad;
CREATE TRIGGER trg_limit_25_func_por_dia
BEFORE INSERT ON Funcionalidad
FOR EACH ROW EXECUTE FUNCTION limit_25_func_por_dia();

CREATE OR REPLACE FUNCTION limit_25_error_por_dia()
RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM ErrorBug
      WHERE user_rut = NEW.user_rut
        AND fecha_error = NEW.fecha_error) >= 25 THEN
    RAISE EXCEPTION 'El usuario % ya creó 25 errores el %',
      NEW.user_rut, NEW.fecha_error;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_25_error_por_dia ON ErrorBug;
CREATE TRIGGER trg_limit_25_error_por_dia
BEFORE INSERT ON ErrorBug
FOR EACH ROW EXECUTE FUNCTION limit_25_error_por_dia();


-- RESTRICCION: Asegurar que no queden < 3 criterios de aceptación por funcionalidad
CREATE OR REPLACE FUNCTION no_menos_de_3_criterios()
RETURNS trigger AS $$
DECLARE restantes INTEGER;
BEGIN
  SELECT COUNT(*) INTO restantes
  FROM Criterio_Aceptacion
  WHERE id_funcionalidad = OLD.id_funcionalidad
    AND id_criterio <> OLD.id_criterio;

  IF restantes < 3 THEN
    RAISE EXCEPTION 'La funcionalidad % no puede quedar con menos de 3 criterios',
      OLD.id_funcionalidad;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_no_menos_de_3_criterios ON Criterio_Aceptacion;
CREATE TRIGGER trg_no_menos_de_3_criterios
BEFORE DELETE ON Criterio_Aceptacion
FOR EACH ROW EXECUTE FUNCTION no_menos_de_3_criterios();
