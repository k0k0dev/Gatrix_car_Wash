
-- CONSULTAS AVANZADAS SEGÚN LA BASE DE DATOS GATRIX CAR WASH

-- 1. Mostrar clientes y sus vehículos
SELECT c.nombre,
       c.apellido,
       v.placa,
       v.marca,
       v.modelo
FROM clientes c
JOIN vehiculos v
ON c.id_cliente = v.id_cliente;

-- 2. Mostrar empleados activos
SELECT nombre,
       apellido,
       cargo
FROM empleados
WHERE activo = TRUE;

-- 3. Mostrar empleados y sus turnos asignados
SELECT e.nombre,
       e.apellido,
       t.nombre AS turno,
       et.fecha
FROM empleados e
JOIN empleados_turnos et
ON e.id_empleado = et.id_empleado
JOIN turnos t
ON et.id_turno = t.id_turno;

-- 4. Mostrar servicios y su categoría
SELECT s.nombre AS servicio,
       cs.nombre AS categoria,
       s.precio_base
FROM servicios s
JOIN categorias_servicio cs
ON s.id_categoria = cs.id_categoria;

-- 5. Mostrar atenciones realizadas con datos del vehículo
SELECT a.id_atencion,
       v.placa,
       a.fecha,
       a.estado,
       a.total
FROM atenciones a
JOIN vehiculos v
ON a.id_vehiculo = v.id_vehiculo;

-- 6. Mostrar total de atenciones por empleado
SELECT e.nombre,
       e.apellido,
       COUNT(a.id_atencion) AS total_atenciones
FROM empleados e
JOIN atenciones a
ON e.id_empleado = a.id_empleado
GROUP BY e.nombre, e.apellido
ORDER BY total_atenciones DESC;

-- 7. Mostrar ingresos totales por día
SELECT DATE(fecha_pago) AS fecha,
       SUM(monto) AS ingresos_totales
FROM pagos
GROUP BY DATE(fecha_pago)
ORDER BY fecha DESC;

-- 8. Mostrar método de pago más utilizado
SELECT mp.nombre,
       COUNT(p.id_pago) AS veces_usado
FROM pagos p
JOIN metodos_pago mp
ON p.id_metodo = mp.id_metodo
GROUP BY mp.nombre
ORDER BY veces_usado DESC;

-- 9. Mostrar servicios más solicitados
SELECT s.nombre,
       COUNT(d.id_servicio) AS veces_solicitado
FROM detalle_atencion d
JOIN servicios s
ON d.id_servicio = s.id_servicio
GROUP BY s.nombre
ORDER BY veces_solicitado DESC;

-- 10. Mostrar productos y proveedores
SELECT p.nombre AS producto,
       pr.nombre AS proveedor,
       p.stock,
       p.precio
FROM productos p
JOIN proveedores pr
ON p.id_proveedor = pr.id_proveedor;

-- 11. Mostrar productos con stock bajo
SELECT nombre,
       stock
FROM productos
WHERE stock < 10;

-- 12. Mostrar productos usados en cada atención
SELECT up.id_atencion,
       p.nombre,
       up.cantidad
FROM uso_productos up
JOIN productos p
ON up.id_producto = p.id_producto
ORDER BY up.id_atencion;

-- 13. Mostrar total consumido de cada producto
SELECT p.nombre,
       SUM(up.cantidad) AS total_consumido
FROM uso_productos up
JOIN productos p
ON up.id_producto = p.id_producto
GROUP BY p.nombre
ORDER BY total_consumido DESC;

-- 14. Mostrar atenciones realizadas en un rango de fechas
SELECT id_atencion,
       fecha,
       estado,
       total
FROM atenciones
WHERE fecha BETWEEN '2026-01-01' AND '2026-12-31'
ORDER BY fecha;

-- 15. Mostrar cliente que más gastó en servicios
SELECT c.nombre,
       c.apellido,
       SUM(a.total) AS total_gastado
FROM clientes c
JOIN vehiculos v
ON c.id_cliente = v.id_cliente
JOIN atenciones a
ON v.id_vehiculo = a.id_vehiculo
GROUP BY c.nombre, c.apellido
ORDER BY total_gastado DESC;
