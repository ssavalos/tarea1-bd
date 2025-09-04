-- Consulta 1: Mostrar los nombres de los ingenieros que tienen mas de 5 solicitudes de cualquier tipo asignadas.
SELECT i.ing_rut, i.nombre_ing,
       COALESCE(af.c,0) AS funcionalidades,
       COALESCE(ae.c,0) AS errores,
       COALESCE(af.c,0) + COALESCE(ae.c,0) AS total_asignaciones
FROM Ingeniero i
LEFT JOIN (
  SELECT ing_rut, COUNT(*) AS c FROM Asignacion_Funcionalidad GROUP BY ing_rut
) af ON af.ing_rut = i.ing_rut
LEFT JOIN (
  SELECT ing_rut, COUNT(*) AS c FROM Asignacion_Error GROUP BY ing_rut
) ae ON ae.ing_rut = i.ing_rut
WHERE COALESCE(af.c,0) + COALESCE(ae.c,0) > 5
ORDER BY total_asignaciones DESC, i.nombre_ing;

-- Consulta 2: Identificar los 10 errores mas antiguos que se han reportado. Muestra el titulo del error, su fecha de publicacion y el nombre del autor.
SELECT e.id_bug, e.titulo_error, e.fecha_error, u.nombre AS autor
FROM ErrorBug e
JOIN Usuario u ON u.user_rut = e.user_rut
ORDER BY e.fecha_error ASC, e.id_bug ASC
LIMIT 10;

-- Consulta 3: Obtener una lista de todas las nuevas funcionalidades solicitadas para el ambiente "Movil", mostrando el titulo, el nombre del topico asociado y el nombre del usuario que la solicito.
SELECT f.titulo_funcion, t.nombre_topico, u.nombre, f.fecha_funcion, f.ambiente
FROM Funcionalidad f
JOIN Topico t ON f.id_topico = t.id_topico
JOIN Usuario u ON f.user_rut = u.user_rut
WHERE f.ambiente = 'Móvil'
  AND f.estado_funcion = 'Abierto'
ORDER BY f.fecha_funcion DESC;

-- Consulta 4: Mostrar los nombres de los topicos que son los mas problematicos, definidos como aquellos topicos con mas de 10 reportes de error.
SELECT t.id_topico, t.nombre_topico,
       COUNT(e.id_bug) AS total_errores
FROM Topico t
JOIN ErrorBug e ON e.id_topico = t.id_topico
GROUP BY t.id_topico, t.nombre_topico
HAVING COUNT(e.id_bug) > 10
ORDER BY total_errores DESC, t.nombre_topico;

-- Consulta 5: Encontrar todas las solicitudes de funcionalidad para las cuales el solicitante ha reportado al menos un error en el mismo topico previamente.
SELECT DISTINCT
  f.id_funcionalidad,
  f.titulo_funcion,
  u.nombre AS solicitante,
  t.nombre_topico,
  f.fecha_funcion
FROM Funcionalidad f
JOIN Usuario u ON f.user_rut = u.user_rut
JOIN Topico t ON f.id_topico = t.id_topico
WHERE EXISTS (
  SELECT 1
  FROM ErrorBug e
  WHERE e.user_rut  = f.user_rut
    AND e.id_topico = f.id_topico
    AND e.fecha_error < f.fecha_funcion
)
ORDER BY f.fecha_funcion DESC, f.titulo_funcion;

-- Consulta 6: Actualizar el estado de todas las funcionalidades que tengan mas de 3 años a "Archivado".
UPDATE Funcionalidad
SET estado_funcion = 'Archivado'
WHERE fecha_funcion < CURRENT_DATE - INTERVAL '3 years'
  AND estado_funcion <> 'Archivado';

-- Consulta 7: Obtener una lista de todos los ingenieros que son especialistas en un topico especifico, por ejemplo, 'Seguridad'.
SELECT i.ing_rut, i.nombre_ing, t.id_topico, t.nombre_topico
FROM Ingeniero i
JOIN Ingeniero_Especialidad ie ON ie.ing_rut   = i.ing_rut
JOIN Topico t                  ON t.id_topico  = ie.id_topico
WHERE t.nombre_topico = 'Seguridad'
ORDER BY i.nombre_ing;

-- Consulta 8: Obtener la cantidad total de solicitudes (errores y funcionalidades) creadas por cada usuario.
SELECT u.user_rut, u.nombre,
       COALESCE(f.cnt, 0) + COALESCE(e.cnt, 0) AS total_solicitudes
FROM Usuario u
LEFT JOIN (
  SELECT user_rut, COUNT(*) AS cnt
  FROM Funcionalidad
  GROUP BY user_rut
) f ON f.user_rut = u.user_rut
LEFT JOIN (
  SELECT user_rut, COUNT(*) AS cnt
  FROM ErrorBug
  GROUP BY user_rut
) e ON e.user_rut = u.user_rut
ORDER BY total_solicitudes DESC, u.nombre;

-- Consulta 9: Obtener la cantidad de Ingenieros que son especialistas en cada tema.
SELECT t.id_topico, t.nombre_topico, COUNT(DISTINCT ie.ing_rut) AS total_especialistas
FROM Topico t
LEFT JOIN Ingeniero_Especialidad ie ON ie.id_topico = t.id_topico
GROUP BY t.id_topico, t.nombre_topico
ORDER BY t.nombre_topico;

-- Consulta 10: Eliminar de la Base de Datos todas las solicitudes de gestion de error que tengan mas de 5 años de antiguedad.
DELETE FROM Asignacion_Error
WHERE id_bug IN (
  SELECT id_bug FROM ErrorBug
  WHERE fecha_error < CURRENT_DATE - INTERVAL '5 years'
);
DELETE FROM ErrorBug
WHERE fecha_error < CURRENT_DATE - INTERVAL '5 years';

-- Consulta para validad la consulta 6
SELECT id_funcionalidad, titulo_funcion, estado_funcion, fecha_funcion
FROM Funcionalidad
WHERE estado_funcion = 'Archivado'
ORDER BY fecha_funcion; 

-- Consulta para validar la consulta 10
SELECT COUNT(*) AS errores_antiguos
FROM ErrorBug
WHERE fecha_error < CURRENT_DATE - INTERVAL '5 years';


