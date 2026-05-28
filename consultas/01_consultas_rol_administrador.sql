--consultas rol administrador

---------------------------------------------------------------
--CONSULTA 1: Resumen de ingresos por mes (2024)
---------------------------------------------------------------

SELECT
    TO_CHAR(fecha_pago, 'YYYY-MM') AS mes,
    COUNT(id_pago)                 AS total_pagos,
    SUM(monto)                     AS ingreso_total,
    ROUND(AVG(monto), 2)           AS ticket_promedio
FROM pagos
GROUP BY mes
ORDER BY mes;

---------------------------------------------------------------
--CONSULTA 2: Top 5 servicios más solicitados y lo que generan
---------------------------------------------------------------

SELECT
    s.nombre                           AS servicio,
    COUNT(da.id_detalle)               AS veces_solicitado,
    SUM(da.cantidad * da.precio_unitario) AS ingreso_generado
FROM detalle_atencion da
JOIN servicios s ON s.id_servicio = da.id_servicio
JOIN atenciones a ON a.id_atencion = da.id_atencion
WHERE a.estado = 'Completado'
GROUP BY s.nombre
ORDER BY veces_solicitado DESC
LIMIT 5;

---------------------------------------------------------------
--CONSULTA 3: Rendimiento de cada empleado (atenciones y ventas)
---------------------------------------------------------------

SELECT
    e.nombre || ' ' || e.apellido  AS empleado,
    e.cargo,
    COUNT(a.id_atencion)           AS atenciones_realizadas,
    SUM(a.total)                   AS monto_gestionado,
    ROUND(AVG(a.total), 2)         AS promedio_por_atencion
FROM empleados e
LEFT JOIN atenciones a ON a.id_empleado = e.id_empleado
    AND a.estado = 'Completado'
GROUP BY e.id_empleado, e.nombre, e.apellido, e.cargo
ORDER BY atenciones_realizadas DESC;

---------------------------------------------------------------
--CONSULTA 4: Clientes con mayor gasto histórico (TOP 10)
---------------------------------------------------------------

SELECT
    c.nombre || ' ' || c.apellido  AS cliente,
    c.telefono,
    c.email,
    COUNT(DISTINCT a.id_atencion)  AS total_visitas,
    SUM(p.monto)                   AS gasto_total
FROM clientes c
JOIN vehiculos v  ON v.id_cliente  = c.id_cliente
JOIN atenciones a ON a.id_vehiculo = v.id_vehiculo
JOIN pagos p      ON p.id_atencion = a.id_atencion
GROUP BY c.id_cliente, c.nombre, c.apellido, c.telefono, c.email
ORDER BY gasto_total DESC
LIMIT 10;

---------------------------------------------------------------
--CONSULTA 5: Atenciones pendientes o en proceso (dashboard diario)
---------------------------------------------------------------

SELECT
    a.id_atencion,
    a.fecha,
    a.estado,
    v.placa,
    v.marca || ' ' || v.modelo  AS vehiculo,
    c.nombre || ' ' || c.apellido AS cliente,
    c.telefono,
    e.nombre || ' ' || e.apellido AS empleado_asignado,
    a.total
FROM atenciones a
JOIN vehiculos  v ON v.id_vehiculo = a.id_vehiculo
JOIN clientes   c ON c.id_cliente  = v.id_cliente
JOIN empleados  e ON e.id_empleado = a.id_empleado
WHERE a.estado IN ('Pendiente', 'En proceso')
ORDER BY a.fecha;

---------------------------------------------------------------
--CONSULTA 6: Productos con stock bajo (alerta de reposición)
---------------------------------------------------------------

SELECT
    p.nombre          AS producto,
    p.stock           AS stock_actual,
    p.precio          AS precio_unitario,
    pr.nombre         AS proveedor,
    pr.telefono       AS contacto_proveedor
FROM productos p
JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
WHERE p.stock < 30
ORDER BY p.stock ASC;

---------------------------------------------------------------
--CONSULTA 7: Método de pago preferido por los clientes
---------------------------------------------------------------

SELECT
    mp.nombre          AS metodo_pago,
    COUNT(pg.id_pago)  AS cantidad_usos,
    SUM(pg.monto)      AS monto_total,
    ROUND(
        100.0 * COUNT(pg.id_pago) / SUM(COUNT(pg.id_pago)) OVER (),
        2
    )                  AS porcentaje
FROM pagos pg
JOIN metodos_pago mp ON mp.id_metodo = pg.id_metodo
GROUP BY mp.nombre
ORDER BY cantidad_usos DESC;

---------------------------------------------------------------
--CONSULTA 8: Ingresos por categoría de servicio
---------------------------------------------------------------

SELECT
    cs.nombre                                   AS categoria,
    COUNT(da.id_detalle)                        AS servicios_realizados,
    SUM(da.cantidad * da.precio_unitario)       AS ingreso_total,
    ROUND(AVG(da.precio_unitario), 2)           AS precio_promedio
FROM detalle_atencion da
JOIN servicios s          ON s.id_servicio  = da.id_servicio
JOIN categorias_servicio cs ON cs.id_categoria = s.id_categoria
JOIN atenciones a         ON a.id_atencion  = da.id_atencion
WHERE a.estado = 'Completado'
GROUP BY cs.nombre
ORDER BY ingreso_total DESC;

---------------------------------------------------------------
--CONSULTA 9: Vehículos que más veces han ingresado al taller
---------------------------------------------------------------

SELECT
    v.placa,
    v.marca || ' ' || v.modelo         AS vehiculo,
    v.color,
    c.nombre || ' ' || c.apellido      AS propietario,
    COUNT(a.id_atencion)               AS ingresos_totales,
    SUM(a.total)                       AS gasto_acumulado
FROM vehiculos v
JOIN clientes c   ON c.id_cliente  = v.id_cliente
JOIN atenciones a ON a.id_vehiculo = v.id_vehiculo
WHERE a.estado = 'Completado'
GROUP BY v.id_vehiculo, v.placa, v.marca, v.modelo, v.color,
         c.nombre, c.apellido
ORDER BY ingresos_totales DESC
LIMIT 10;

---------------------------------------------------------------
--CONSULTA 10: Producto más consumido en atenciones (insumos)
---------------------------------------------------------------

SELECT
    p.nombre                    AS producto,
    SUM(up.cantidad)            AS unidades_usadas,
    p.precio * SUM(up.cantidad) AS costo_estimado,
    pr.nombre                   AS proveedor
FROM uso_productos up
JOIN productos    p  ON p.id_producto  = up.id_producto
JOIN proveedores  pr ON pr.id_proveedor = p.id_proveedor
GROUP BY p.id_producto, p.nombre, p.precio, pr.nombre
ORDER BY unidades_usadas DESC
LIMIT 10;

---------------------------------------------------------------
--CONSULTA 11: Empleados activos y sus turnos del mes actual
---------------------------------------------------------------

SELECT
    e.nombre || ' ' || e.apellido  AS empleado,
    e.cargo,
    t.nombre                       AS turno,
    t.hora_inicio || ' - ' || t.hora_fin AS horario,
    COUNT(et.fecha)                AS dias_trabajados
FROM empleados_turnos et
JOIN empleados e ON e.id_empleado = et.id_empleado
JOIN turnos    t ON t.id_turno    = et.id_turno
WHERE e.activo = TRUE
  AND et.fecha BETWEEN '2024-01-01' AND '2024-02-29'
GROUP BY e.id_empleado, e.nombre, e.apellido, e.cargo,
         t.nombre, t.hora_inicio, t.hora_fin
ORDER BY dias_trabajados DESC;

---------------------------------------------------------------
--CONSULTA 12: Tasa de atenciones canceladas o pendientes vs completadas
---------------------------------------------------------------

SELECT
    estado,
    COUNT(*)                                        AS cantidad,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    )                                               AS porcentaje
FROM atenciones
GROUP BY estado
ORDER BY cantidad DESC;

---------------------------------------------------------------
--CONSULTA 13: Clientes que no han regresado en los últimos 60 días
---------------------------------------------------------------

SELECT
    c.nombre || ' ' || c.apellido  AS cliente,
    c.telefono,
    c.email,
    MAX(a.fecha)                   AS ultima_visita,
    CURRENT_DATE - MAX(a.fecha::DATE) AS dias_sin_visitar
FROM clientes c
JOIN vehiculos  v ON v.id_cliente  = c.id_cliente
JOIN atenciones a ON a.id_vehiculo = v.id_vehiculo
WHERE a.estado = 'Completado'
GROUP BY c.id_cliente, c.nombre, c.apellido, c.telefono, c.email
HAVING MAX(a.fecha::DATE) < CURRENT_DATE - INTERVAL '60 days'
ORDER BY dias_sin_visitar DESC;

---------------------------------------------------------------
--CONSULTA 14: Marcas de vehículos más frecuentes en el taller
---------------------------------------------------------------

SELECT
    v.marca,
    COUNT(DISTINCT v.id_vehiculo)  AS vehiculos_registrados,
    COUNT(a.id_atencion)           AS atenciones_totales,
    SUM(a.total)                   AS facturado
FROM vehiculos v
JOIN atenciones a ON a.id_vehiculo = v.id_vehiculo
WHERE a.estado = 'Completado'
GROUP BY v.marca
ORDER BY atenciones_totales DESC;

---------------------------------------------------------------
--CONSULTA 15: Comparativo de ingresos semana a semana (último mes)
---------------------------------------------------------------

SELECT
    DATE_TRUNC('week', p.fecha_pago)::DATE  AS semana_inicio,
    COUNT(p.id_pago)                        AS atenciones_pagadas,
    SUM(p.monto)                            AS ingreso_semanal
FROM pagos p
WHERE p.fecha_pago >= '2024-01-01'
  AND p.fecha_pago <  '2024-06-01'
GROUP BY semana_inicio
ORDER BY semana_inicio;