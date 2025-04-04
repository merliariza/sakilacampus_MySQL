-- Funciones
-- 1. TotalIngresosCliente(ClienteID, Año)
DELIMITER //
CREATE FUNCTION TotalIngresosCliente(ClienteID SMALLINT UNSIGNED, Anio INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_ingresos DECIMAL(10,2);
    SELECT IFNULL(SUM(p.total), 0.00) INTO total_ingresos
    FROM pago p
    WHERE p.id_cliente = ClienteID YEAR(p.fecha_pago) = Anio;
    
    RETURN total_ingresos;
END //
DELIMITER ;

-- 2. PromedioDuracionAlquiler(PeliculaID)

-- 3. IngresosPorCategoria(CategoriaID)
DELIMITER //
CREATE FUNCTION IngresosPorCategoria(CategoriaID TINYINT UNSIGNED) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_ingresos DECIMAL(10,2);
    
    SELECT IFNULL(SUM(p.total), 0.00) INTO total_ingresos
    FROM pago p
    JOIN alquiler a ON p.id_alquiler = a.id_alquiler
    JOIN inventario i ON a.id_inventario = i.id_inventario
    JOIN pelicula pel ON i.id_pelicula = pel.id_pelicula
    JOIN pelicula_categoria pc ON pel.id_pelicula = pc.id_pelicula
    WHERE pc.id_categoria = CategoriaID;
    
    RETURN total_ingresos;
END //
DELIMITER ;

-- 4. DescuentoFrecuenciaCliente(ClienteID)
DELIMITER //
CREATE FUNCTION DescuentoFrecuenciaCliente(ClienteID SMALLINT UNSIGNED) 
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
    DECLARE total_alquileres INT;
    DECLARE descuento DECIMAL(4,2);
    
    SELECT COUNT(id_alquiler) INTO total_alquileres
    FROM alquiler a
    WHERE a.id_cliente = ClienteID AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
    SET descuento = CASE
        WHEN total_alquileres > 30 THEN 25.00
        WHEN total_alquileres > 20 THEN 15.00
        WHEN total_alquileres > 5 THEN 5.00
        ELSE 0.00
    END;
    
    RETURN descuento;
END //
DELIMITER ;

-- 5. EsClienteVIP(ClienteID)
DELIMITER //
CREATE FUNCTION EsClienteVIP(ClienteID SMALLINT UNSIGNED) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total_alquileres INT;
    DECLARE total_gastos DECIMAL(10,2);
    DECLARE es_vip BOOLEAN;
    
    SELECT COUNT(id_alquiler) INTO total_alquileres
    FROM alquiler a
    WHERE a.id_cliente = ClienteID AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
    
    SELECT IFNULL(SUM(p.total), 0.00) INTO total_gastos
    FROM pago p
    WHERE p.id_cliente = ClienteID AND p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
    SET es_vip = (total_alquileres >= 50);

    RETURN es_vip;
END //
DELIMITER ;