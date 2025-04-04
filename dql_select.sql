-- Consultas

-- 1. Encuentra el cliente que ha realizado la mayor cantidad de alquileres en los últimos 6 meses.
SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(a.id_alquiler) AS total_alquileres
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_alquileres DESC
LIMIT 1;

-- 2. Lista las cinco películas más alquiladas durante el último año.
SELECT p.id_pelicula, p.titulo, COUNT(a.id_alquiler) AS total_alquileres
FROM pelicula p
JOIN inventario i ON p.id_pelicula = i.id_pelicula
JOIN alquiler a ON i.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.id_pelicula, p.titulo
ORDER BY total_alquileres DESC
LIMIT 5;

-- 3. Obtén el total de ingresos y la cantidad de alquileres realizados por cada categoría de película.
SELECT cat.id_categoria,cat.nombre AS categoria,COUNT(a.id_alquiler) AS total_alquileres,SUM(p.total) AS ingresos_totales
FROM categoria cat
JOIN pelicula_categoria pc ON cat.id_categoria = pc.id_categoria
JOIN pelicula pel ON pc.id_pelicula = pel.id_pelicula
JOIN inventario inv ON pel.id_pelicula = inv.id_pelicula
JOIN alquiler a ON inv.id_inventario = a.id_inventario
JOIN pago p ON a.id_alquiler = p.id_alquiler
GROUP BY cat.id_categoria, cat.nombre
ORDER BY ingresos_totales DESC;

-- 4. Calcula el número total de clientes que han realizado alquileres por cada idioma disponible en un mes específico.
SELECT i.id_idioma,i.nombre AS idioma, COUNT(DISTINCT c.id_cliente) AS total_clientes
FROM idioma i
JOIN pelicula p ON i.id_idioma = p.id_idioma
JOIN inventario inv ON p.id_pelicula = inv.id_pelicula
JOIN alquiler a ON inv.id_inventario = a.id_inventario
JOIN cliente c ON a.id_cliente = c.id_cliente
WHERE MONTH(a.fecha_alquiler) = 3 AND YEAR(a.fecha_alquiler) = 2005
GROUP BY i.id_idioma, i.nombre;

-- 5. Encuentra a los clientes que han alquilado todas las películas de una misma categoría.
SELECT c.id_cliente, c.nombre, c.apellidos, cat.nombre AS categoria
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
JOIN inventario inv ON a.id_inventario = inv.id_inventario
JOIN pelicula p ON inv.id_pelicula = p.id_pelicula
JOIN pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
JOIN categoria cat ON pc.id_categoria = cat.id_categoria
GROUP BY c.id_cliente, c.nombre, c.apellidos, cat.id_categoria, cat.nombre
HAVING COUNT(DISTINCT p.id_pelicula) = (
        SELECT COUNT(DISTINCT pe.id_pelicula)
        FROM pelicula pe
        JOIN pelicula_categoria pcat ON pe.id_pelicula = pcat.id_pelicula
        WHERE pcat.id_categoria = cat.id_categoria
    );

-- 6. Lista las tres ciudades con más clientes activos en el último trimestre.
SELECT ci.id_ciudad,ci.nombre AS ciudad,COUNT(DISTINCT c.id_cliente) AS total_clientes_activos
FROM ciudad ci
JOIN direccion d ON ci.id_ciudad = d.id_ciudad
JOIN cliente c ON d.id_direccion = c.id_direccion
JOIN alquiler a ON c.id_cliente = a.id_cliente
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH) AND c.activo = 1
GROUP BY ci.id_ciudad, ci.nombre
ORDER BY total_clientes_activos DESC
LIMIT 3;

-- 7. Muestra las cinco categorías con menos alquileres registrados en el último año.
SELECT cat.id_categoria,cat.nombre AS categoria, COUNT(a.id_alquiler) AS total_alquileres
FROM categoria cat
LEFT JOIN pelicula_categoria pc ON cat.id_categoria = pc.id_categoria
LEFT JOIN pelicula p ON pc.id_pelicula = p.id_pelicula
LEFT JOIN inventario inv ON p.id_pelicula = inv.id_pelicula
LEFT JOIN alquiler a ON inv.id_inventario = a.id_inventario AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY cat.id_categoria, cat.nombre
ORDER BY total_alquileres ASC
LIMIT 5;

-- 8. Calcula el promedio de días que un cliente tarda en devolver las películas alquiladas.
SELECT AVG(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS promedio_dias_devolucion
FROM alquiler a
WHERE a.fecha_devolucion IS NOT NULL;

-- 9. Encuentra los cinco empleados que gestionaron más alquileres en la categoría de Acción.
SELECT e.id_empleado,e.nombre,e.apellidos, COUNT(a.id_alquiler) AS total_alquileres_accion
FROM empleado e
JOIN alquiler a ON e.id_empleado = a.id_empleado
JOIN inventario inv ON a.id_inventario = inv.id_inventario
JOIN pelicula p ON inv.id_pelicula = p.id_pelicula
JOIN pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
JOIN categoria cat ON pc.id_categoria = cat.id_categoria
WHERE cat.nombre = 'Action' 
GROUP BY e.id_empleado, e.nombre, e.apellidos
ORDER BY total_alquileres_accion DESC
LIMIT 5;

-- 10. Genera un informe de los clientes con alquileres más recurrentes.
SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(a.id_alquiler) AS total_alquileres, 
    MAX(a.fecha_alquiler) AS ultimo_alquiler,
    AVG(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS promedio_dias_alquiler
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_alquileres DESC;

-- 11. Calcula el costo promedio de alquiler por idioma de las películas.
SELECT i.id_idioma, i.nombre AS idioma, AVG(p.rental_rate) AS costo_promedio_alquiler
FROM idioma i
JOIN pelicula p ON i.id_idioma = p.id_idioma
GROUP BY i.id_idioma, i.nombre
ORDER BY costo_promedio_alquiler DESC;

-- 12. Lista las cinco películas con mayor duración alquiladas en el último año.
SELECT p.id_pelicula, p.titulo, p.duracion, COUNT(a.id_alquiler) AS veces_alquilada
FROM pelicula p
JOIN inventario inv ON p.id_pelicula = inv.id_pelicula
JOIN alquiler a ON inv.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.id_pelicula, p.titulo, p.duracion
ORDER BY p.duracion DESC, veces_alquilada DESC
LIMIT 5;

-- 13. Muestra los clientes que más alquilaron películas de Comedia.
SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(a.id_alquiler) AS total_alquileres_comedia
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
JOIN inventario inv ON a.id_inventario = inv.id_inventario
JOIN pelicula p ON inv.id_pelicula = p.id_pelicula
JOIN pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
JOIN categoria cat ON pc.id_categoria = cat.id_categoria
WHERE cat.nombre = 'Comedy' 
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_alquileres_comedia DESC;

-- 14. Encuentra la cantidad total de días alquilados por cada cliente en el último mes.
SELECT c.id_cliente, c.nombre, c.apellidos, SUM(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS total_dias_alquiler
FROM cliente c
JOIN alquiler a ON c.id_cliente = a.id_cliente
WHERE 
    a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND a.fecha_devolucion IS NOT NULL
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_dias_alquiler DESC;

-- 15. Muestra el número de alquileres diarios en cada almacén durante el último trimestre.
SELECT DATE(a.fecha_alquiler) AS fecha, alm.id_almacen, COUNT(a.id_alquiler) AS total_alquileres_diarios
FROM alquiler a
JOIN inventario inv ON a.id_inventario = inv.id_inventario
JOIN almacen alm ON inv.id_almacen = alm.id_almacen
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY DATE(a.fecha_alquiler), alm.id_almacen
ORDER BY fecha, alm.id_almacen;

-- 16. Calcula los ingresos totales generados por cada almacén en el último semestre.
SELECT alm.id_almacen, SUM(p.total) AS ingresos_totales
FROM almacen alm
JOIN inventario inv ON alm.id_almacen = inv.id_almacen
JOIN alquiler a ON inv.id_inventario = a.id_inventario
JOIN pago p ON a.id_alquiler = p.id_alquiler
WHERE p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY alm.id_almacen
ORDER BY ingresos_totales DESC;


-- 17. Encuentra el cliente que ha realizado el alquiler más caro en el último año.
SELECT cl.nombre, MAX(p.rental_rate) AS Alquiler_Caro
FROM cliente cl
JOIN alquiler a ON cl.id_cliente = a.id_cliente
JOIN inventario i ON a.id_inventario = i.id_inventario
JOIN pelicula p ON i.id_pelicula = p.id_pelicula
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY cl.id_cliente
ORDER BY Alquiler_Caro DESC LIMIT 1;


-- 18. Lista las cinco categorías con más ingresos generados durante los últimos tres meses.
SELECT cat.id_categoria,cat.nombre AS categoria, SUM(p.total) AS ingresos_totales
FROM categoria cat
JOIN pelicula_categoria pc ON cat.id_categoria = pc.id_categoria
JOIN pelicula pel ON pc.id_pelicula = pel.id_pelicula
JOIN inventario inv ON pel.id_pelicula = inv.id_pelicula
JOIN alquiler a ON inv.id_inventario = a.id_inventario
JOIN pago p ON a.id_alquiler = p.id_alquiler
WHERE p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY cat.id_categoria, cat.nombre
ORDER BY ingresos_totales DESC
LIMIT 5;

-- 19. Obtén la cantidad de películas alquiladas por cada idioma en el último mes.
SELECT i.id_idioma,i.nombre AS idioma, COUNT(a.id_alquiler) AS total_peliculas_alquiladas
FROM idioma i
JOIN pelicula p ON i.id_idioma = p.id_idioma
JOIN inventario inv ON p.id_pelicula = inv.id_pelicula
JOIN alquiler a ON inv.id_inventario = a.id_inventario
WHERE a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY i.id_idioma, i.nombre
ORDER BY total_peliculas_alquiladas DESC;

-- 20. Lista los clientes que no han realizado ningún alquiler en el último año.
SELECT c.id_cliente,c.nombre,c.apellidos,c.email
FROM cliente c
LEFT JOIN alquiler a ON c.id_cliente = a.id_cliente AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
WHERE a.id_alquiler IS NULL
ORDER BY c.apellidos, c.nombre;