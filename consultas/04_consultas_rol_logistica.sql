-- 1. Productos que necesitan reabastecerse con datos del proveedor
SELECT p.nombre AS producto,
       p.stock AS stock_actual,
       pr.nombre AS proveedor,
       pr.telefono AS contacto
FROM productos p
JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
WHERE p.stock < 25
ORDER BY p.stock ASC;

-- 2. Productos más consumidos en todos los meses (enero a mayo)
SELECT p.nombre AS producto,
       SUM(up.cantidad) AS total_consumido
FROM uso_productos up
JOIN productos p ON up.id_producto = p.id_producto
JOIN atenciones a ON up.id_atencion = a.id_atencion
WHERE a.estado = 'Completado'
GROUP BY p.nombre
ORDER BY total_consumido DESC;

-- 3. Gasto total en insumos por mes
SELECT TO_CHAR(a.fecha, 'Month') AS mes,
       SUM(up.cantidad * p.precio) AS gasto_total
FROM uso_productos up
JOIN productos p ON up.id_producto = p.id_producto
JOIN atenciones a ON up.id_atencion = a.id_atencion
GROUP BY TO_CHAR(a.fecha, 'Month'), EXTRACT(MONTH FROM a.fecha)
ORDER BY EXTRACT(MONTH FROM a.fecha);

-- 4. Valor total del inventario actual en soles
SELECT COUNT(*) AS tipos_producto,
       SUM(stock) AS unidades_totales,
       SUM(stock * precio) AS valor_total_soles
FROM productos;

-- 5. Productos sin rotación con dinero inmovilizado
SELECT p.nombre AS producto,
       p.stock,
       p.precio,
       p.stock * p.precio AS dinero_inmovilizado
FROM productos p
WHERE p.id_producto NOT IN (
    SELECT DISTINCT id_producto FROM uso_productos
)
ORDER BY dinero_inmovilizado DESC;

-- 6. Aporte de cada proveedor al inventario en valor
SELECT pr.nombre AS proveedor,
       COUNT(p.id_producto) AS productos_suministrados,
       SUM(p.stock * p.precio) AS valor_en_inventario
FROM proveedores pr
JOIN productos p ON pr.id_proveedor = p.id_proveedor
GROUP BY pr.nombre
ORDER BY valor_en_inventario DESC;

-- 7. Producto más caro de cada proveedor
SELECT pr.nombre AS proveedor,
       p.nombre AS producto_mas_caro,
       p.precio
FROM productos p
JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
WHERE p.precio = (
    SELECT MAX(p2.precio)
    FROM productos p2
    WHERE p2.id_proveedor = p.id_proveedor
)
ORDER BY p.precio DESC;

-- 8. Productos con sobrestock y poco consumo
SELECT p.nombre AS producto,
       p.stock,
       p.precio,
       p.stock * p.precio AS valor_almacenado
FROM productos p
LEFT JOIN uso_productos up ON p.id_producto = up.id_producto
GROUP BY p.nombre, p.stock, p.precio
HAVING SUM(up.cantidad) IS NULL OR SUM(up.cantidad) < 5
ORDER BY p.stock DESC;

-- 9. Unidades de insumos consumidas por mes
SELECT TO_CHAR(a.fecha, 'Month') AS mes,
       SUM(up.cantidad) AS unidades_consumidas
FROM uso_productos up
JOIN atenciones a ON up.id_atencion = a.id_atencion
GROUP BY TO_CHAR(a.fecha, 'Month'), EXTRACT(MONTH FROM a.fecha)
ORDER BY EXTRACT(MONTH FROM a.fecha);

-- 10. Promedio de unidades usadas por producto en cada atención
SELECT p.nombre AS producto,
       ROUND(AVG(up.cantidad), 1) AS promedio_por_atencion
FROM uso_productos up
JOIN productos p ON up.id_producto = p.id_producto
GROUP BY p.nombre
ORDER BY promedio_por_atencion DESC;

-- 11. Proveedores estratégicos con más de 3 productos
SELECT pr.nombre AS proveedor,
       pr.telefono,
       COUNT(p.id_producto) AS total_productos
FROM proveedores pr
JOIN productos p ON pr.id_proveedor = p.id_proveedor
GROUP BY pr.nombre, pr.telefono
HAVING COUNT(p.id_producto) > 3
ORDER BY total_productos DESC;

-- 12. Productos usados en atenciones con su estado
SELECT p.nombre AS producto,
       a.estado,
       SUM(up.cantidad) AS cantidad_usada
FROM uso_productos up
JOIN productos p ON up.id_producto = p.id_producto
JOIN atenciones a ON up.id_atencion = a.id_atencion
GROUP BY p.nombre, a.estado
ORDER BY p.nombre, cantidad_usada DESC;

-- 13. Precio promedio, mínimo y máximo por proveedor
SELECT pr.nombre AS proveedor,
       ROUND(AVG(p.precio), 2) AS precio_promedio,
       MIN(p.precio) AS precio_minimo,
       MAX(p.precio) AS precio_maximo
FROM productos p
JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
GROUP BY pr.nombre
ORDER BY precio_promedio DESC;

-- 14. Empleado que más insumos consume en sus atenciones
SELECT e.nombre || ' ' || e.apellido AS empleado,
       e.cargo,
       SUM(up.cantidad) AS total_insumos_usados
FROM uso_productos up
JOIN atenciones a ON up.id_atencion = a.id_atencion
JOIN empleados e ON a.id_empleado = e.id_empleado
GROUP BY e.nombre, e.apellido, e.cargo
ORDER BY total_insumos_usados DESC;

-- 15. Insumos consumidos por cada servicio
SELECT s.nombre AS servicio,
       p.nombre AS producto,
       SUM(up.cantidad) AS total_usado
FROM uso_productos up
JOIN productos p ON up.id_producto = p.id_producto
JOIN atenciones a ON up.id_atencion = a.id_atencion
JOIN detalle_atencion da ON da.id_atencion = a.id_atencion
JOIN servicios s ON da.id_servicio = s.id_servicio
GROUP BY s.nombre, p.nombre
ORDER BY s.nombre, total_usado DESC;