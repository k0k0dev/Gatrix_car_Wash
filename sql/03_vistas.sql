-- ============================================================
-- GATRIX CAR WASH — Base de Datos PostgreSQL
-- Archivo: 03_vistas.sql
-- Descripción: Creación de las 10 vistas del sistema
-- ============================================================

-- ------------------------------------------------------------
-- 1. Atenciones completas con vehículo y cliente
-- ------------------------------------------------------------
CREATE VIEW v_atenciones_completas AS
SELECT 
    a.id_atencion,
    a.fecha,
    a.estado,
    a.total,
    c.id_cliente,
    c.nombre || ' ' || c.apellido AS cliente,
    c.telefono,
    v.placa,
    v.marca,
    v.modelo,
    v.color,
    e.nombre || ' ' || e.apellido AS empleado
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN empleados e ON a.id_empleado = e.id_empleado;
SELECT * FROM v_atenciones_completas;

-- ------------------------------------------------------------
-- 2. Ingresos diarios por método de pago
-- ------------------------------------------------------------
CREATE VIEW v_ingresos_diarios_por_metodo AS
SELECT 
    DATE(p.fecha_pago) AS fecha,
    mp.nombre AS metodo_pago,
    COUNT(*) AS total_transacciones,
    SUM(p.monto) AS total_recaudado
FROM pagos p
JOIN metodos_pago mp ON p.id_metodo = mp.id_metodo
GROUP BY DATE(p.fecha_pago), mp.nombre
ORDER BY fecha DESC;
SELECT * FROM v_ingresos_diarios_por_metodo;

-- ------------------------------------------------------------
-- 3. Servicios más solicitados con categoría e ingresos
-- ------------------------------------------------------------
CREATE VIEW v_servicios_mas_solicitados AS
SELECT 
    s.id_servicio,
    s.nombre AS servicio,
    cs.nombre AS categoria,
    COUNT(da.id_detalle) AS veces_solicitado,
    SUM(da.cantidad * da.precio_unitario) AS ingreso_generado
FROM detalle_atencion da
JOIN servicios s ON da.id_servicio = s.id_servicio
JOIN categorias_servicio cs ON s.id_categoria = cs.id_categoria
GROUP BY s.id_servicio, s.nombre, cs.nombre
ORDER BY veces_solicitado DESC;
SELECT * FROM v_servicios_mas_solicitados;

-- ------------------------------------------------------------
-- 4. Clientes con sus vehículos agrupados
-- ------------------------------------------------------------
CREATE VIEW v_cliente_vehiculos AS
SELECT 
    c.id_cliente,
    c.nombre || ' ' || c.apellido AS cliente,
    c.telefono,
    c.email,
    COUNT(v.id_vehiculo) AS cantidad_vehiculos,
    STRING_AGG(v.placa || ' (' || v.marca || ' ' || v.modelo || ')', ', ') AS vehiculos
FROM clientes c
LEFT JOIN vehiculos v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido, c.telefono, c.email;
SELECT * FROM v_cliente_vehiculos;

-- ------------------------------------------------------------
-- 5. Productos bajos en stock
-- ------------------------------------------------------------

CREATE VIEW v_stock_bajo AS
SELECT 
    p.id_producto,
    p.nombre AS producto,
    p.stock,
    p.precio,
    pr.nombre AS proveedor,
    pr.telefono AS telefono_proveedor
FROM productos p
JOIN proveedores pr 
    ON p.id_proveedor = pr.id_proveedor
WHERE p.stock <= 45
ORDER BY p.stock ASC;
SELECT * FROM v_stock_bajo;

-- ------------------------------------------------------------
-- 6. Rendimiento de empleados activos
-- ------------------------------------------------------------
CREATE VIEW v_rendimiento_empleados AS
SELECT 
    e.id_empleado,
    e.nombre || ' ' || e.apellido AS empleado,
    e.cargo,
    COUNT(a.id_atencion) AS atenciones_realizadas,
    COALESCE(SUM(a.total), 0) AS monto_total_generado,
    ROUND(AVG(a.total), 2) AS promedio_por_atencion
FROM empleados e
LEFT JOIN atenciones a ON e.id_empleado = a.id_empleado
WHERE e.activo = TRUE
GROUP BY e.id_empleado, e.nombre, e.apellido, e.cargo
ORDER BY atenciones_realizadas DESC;
SELECT * FROM v_rendimiento_empleados;

-- ------------------------------------------------------------
-- 7. Historial de atención por vehículo
-- ------------------------------------------------------------
CREATE VIEW v_historial_vehiculo AS
SELECT 
    v.placa,
    v.marca,
    v.modelo,
    c.nombre || ' ' || c.apellido AS cliente,
    COUNT(a.id_atencion) AS total_atenciones,
    COALESCE(SUM(a.total), 0) AS total_gastado,
    MAX(a.fecha) AS ultima_visita
FROM vehiculos v
JOIN clientes c ON v.id_cliente = c.id_cliente
LEFT JOIN atenciones a ON v.id_vehiculo = a.id_vehiculo
GROUP BY v.placa, v.marca, v.modelo, c.nombre, c.apellido
ORDER BY total_atenciones DESC;
SELECT * FROM v_historial_vehiculo;

-- ------------------------------------------------------------
-- 8. Plantilla de turnos asignados
-- ------------------------------------------------------------
CREATE VIEW v_turnos_asignados AS
SELECT 
    et.fecha,
    t.nombre AS turno,
    t.hora_inicio,
    t.hora_fin,
    e.nombre || ' ' || e.apellido AS empleado,
    e.cargo,
    e.telefono
FROM empleados_turnos et
JOIN turnos t ON et.id_turno = t.id_turno
JOIN empleados e ON et.id_empleado = e.id_empleado
WHERE e.activo = TRUE
ORDER BY et.fecha DESC, t.hora_inicio;
SELECT * FROM v_turnos_asignados;

-- ------------------------------------------------------------
-- 9. Consumo de productos por atención
-- ------------------------------------------------------------
CREATE VIEW v_consumo_productos AS
SELECT 
    a.id_atencion,
    a.fecha,
    v.placa,
    p.nombre AS producto,
    up.cantidad,
    p.precio AS precio_unitario,
    (up.cantidad * p.precio) AS costo_total
FROM uso_productos up
JOIN atenciones a ON up.id_atencion = a.id_atencion
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN productos p ON up.id_producto = p.id_producto
ORDER BY a.fecha DESC;
SELECT * FROM v_consumo_productos;

-- ------------------------------------------------------------
-- 10. Cierre diario (ingresos y margen bruto)
-- ------------------------------------------------------------
CREATE VIEW v_cierre_diario AS
SELECT 
    DATE(a.fecha) AS fecha,
    COUNT(DISTINCT a.id_atencion) AS total_atenciones,
    COUNT(DISTINCT v.id_cliente) AS total_clientes,
    SUM(a.total) AS ingresos_servicios,
    COALESCE(SUM(up.cantidad * p.precio), 0) AS costo_productos,
    SUM(a.total) - COALESCE(SUM(up.cantidad * p.precio), 0) AS margen_bruto
FROM atenciones a
LEFT JOIN uso_productos up ON a.id_atencion = up.id_atencion
LEFT JOIN productos p ON up.id_producto = p.id_producto
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
GROUP BY DATE(a.fecha)
ORDER BY fecha DESC;
SELECT * FROM v_cierre_diario;