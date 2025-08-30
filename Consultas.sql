-- Consulta 1: Mostrar los nombres de los ingenieros que tienen mas de 5 solicitudes de cualquier tipo asignadas.
SELECT i.nombre_ing
FROM Ingeniero i
JOIN Asignacion_Funcionalidad af ON i.ing_rut = af.ing_rut
JOIN Asignacion_Error ae ON i.ing_rut = ae.ing_rut
GROUP BY i.ing_rut
HAVING COUNT(af.id_funcionalidad) + COUNT(ae.id_bug) > 5;

-- Consulta 2: Identificar los 10 errores mas antiguos que se han reportado. Muestra el titulo del error, su fecha de publicacion y el nombre del autor.
SELECT e.titulo_error, e.fecha_error, u.nombre
FROM ErrorBug e
JOIN Usuario u ON e.user_rut = u.user_rut
ORDER BY e.fecha_error ASC
LIMIT 10;

-- Consulta 3: Obtener una lista de todas las nuevas funcionalidades solicitadas para el ambiente "Movil", mostrando el titulo, el nombre del topico asociado y el nombre del usuario que la solicito.
SELECT f.titulo_funcion, t.nombre_topico, u.nombre
FROM Funcionalidad f
JOIN Topico t ON f.id_topico = t.id_topico
JOIN Usuario u ON f.user_rut = u.user_rut
WHERE f.ambiente = 'Móvil';

-- Consulta 4: Mostrar los nombres de los topicos que son los mas problematicos, definidos como aquellos topicos con mas de 10 reportes de error.
SELECT t.nombre_topico
FROM Topico t
JOIN ErrorBug e ON t.id_topico = e.id_topico
GROUP BY t.id_topico
HAVING COUNT(e.id_bug) > 10;

-- Consulta 5: Encontrar todas las solicitudes de funcionalidad para las cuales el solicitante ha reportado al menos un error en el mismo topico previamente.
SELECT f.titulo_funcion
FROM Funcionalidad f
JOIN ErrorBug e ON f.id_topico = e.id_topico
WHERE f.user_rut = e.user_rut;

-- Consulta 6: Actualizar el estado de todas las funcionalidades que tengan mas de 3 años a "Archivado".
UPDATE Funcionalidad
SET estado_funcion = 'Archivado'
WHERE fecha_funcion < CURRENT_DATE - INTERVAL '3 years';

-- Consulta 7: Obtener una lista de todos los ingenieros que son especialistas en un topico especifico, por ejemplo, 'Seguridad'.
SELECT i.nombre_ing
FROM Ingeniero i
JOIN Ingeniero_Especialidad ie ON i.ing_rut = ie.ing_rut
JOIN Topico t ON ie.id_topico = t.id_topico
WHERE t.nombre_topico = 'Seguridad';

-- Consulta 8: Obtener la cantidad total de solicitudes (errores y funcionalidades) creadas por cada usuario.
SELECT u.nombre, 
       COUNT(DISTINCT f.id_funcionalidad) + COUNT(DISTINCT e.id_bug) AS total_solicitudes
FROM Usuario u
LEFT JOIN Funcionalidad f ON u.user_rut = f.user_rut
LEFT JOIN ErrorBug e ON u.user_rut = e.user_rut
GROUP BY u.user_rut;

-- Consulta 9: Obtener la cantidad de Ingenieros que son especialistas en cada tema.
SELECT t.nombre_topico, 
       STRING_AGG(i.nombre_ing, ', ') AS ingenieros
FROM Topico t
JOIN Ingeniero_Especialidad ie ON t.id_topico = ie.id_topico
JOIN Ingeniero i ON ie.ing_rut = i.ing_rut
GROUP BY t.nombre_topico;

-- Consulta 10: Eliminar de la Base de Datos todas las solicitudes de gestion de error que tengan mas de 5 años de antiguedad.
DELETE FROM ErrorBug
WHERE fecha_error < CURRENT_DATE - INTERVAL '5 years';
