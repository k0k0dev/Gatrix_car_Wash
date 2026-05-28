-- consultas roll recepcionista 

-- 1. Buscar cliente por teléfono con total de visitas y gasto acumulado
SELECT 
    c.id_cliente,
    c.nombre || ' ' || c.apellido AS cliente,
    c.telefono,
    c.email,
    COUNT(a.id_atencion) AS total_visitas,
    COALESCE(SUM(a.total), 0) AS gasto_total
FROM clientes c
LEFT JOIN vehiculos v ON c.id_cliente = v.id_cliente
LEFT JOIN atenciones a ON v.id_vehiculo = a.id_vehiculo
WHERE c.telefono = '964112233'
GROUP BY c.id_cliente, c.nombre, c.apellido, c.telefono, c.email;

-- 2. Buscar vehículo por placa con servicios realizados
SELECT 
    v.placa,
    v.marca,
    v.modelo,
    c.nombre || ' ' || c.apellido AS propietario,
    c.telefono,
    COUNT(a.id_atencion) AS total_atenciones,
    STRING_AGG(DISTINCT s.nombre, ', ') AS servicios_recibidos
FROM vehiculos v
JOIN clientes c ON v.id_cliente = c.id_cliente
LEFT JOIN atenciones a ON v.id_vehiculo = a.id_vehiculo
LEFT JOIN detalle_atencion da ON a.id_atencion = da.id_atencion
LEFT JOIN servicios s ON da.id_servicio = s.id_servicio
WHERE v.placa = 'ABC-123'
GROUP BY v.placa, v.marca, v.modelo, c.nombre, c.apellido, c.telefono;

-- 3. Atenciones del día con empleado, estado y método de pago
SELECT 
    a.id_atencion,
    a.fecha::TIME AS hora,
    a.estado,
    a.total,
    v.placa,
    c.nombre || ' ' || c.apellido AS cliente,
    e.nombre || ' ' || e.apellido AS empleado,
    COALESCE(mp.nombre, 'Sin pago') AS metodo_pago
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN empleados e ON a.id_empleado = e.id_empleado
LEFT JOIN pagos p ON a.id_atencion = p.id_atencion
LEFT JOIN metodos_pago mp ON p.id_metodo = mp.id_metodo
WHERE DATE(a.fecha) = '2024-02-01'
ORDER BY a.fecha;

-- 4. Servicios disponibles agrupados por categoría con precios
SELECT 
    cs.nombre AS categoria,
    s.nombre AS servicio,
    s.precio_base,
    s.duracion_min || ' min' AS duracion
FROM servicios s
JOIN categorias_servicio cs ON s.id_categoria = cs.id_categoria
ORDER BY cs.nombre, s.precio_base;

-- 5. Historial de vehículo con empleados y fechas formateadas
SELECT 
    TO_CHAR(a.fecha, 'DD/MM/YYYY') AS fecha,
    TO_CHAR(a.fecha, 'HH12:MI AM') AS hora,
    a.estado,
    a.total,
    e.nombre || ' ' || e.apellido AS atendido_por,
    STRING_AGG(s.nombre, ', ') AS servicios
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN empleados e ON a.id_empleado = e.id_empleado
LEFT JOIN detalle_atencion da ON a.id_atencion = da.id_atencion
LEFT JOIN servicios s ON da.id_servicio = s.id_servicio
WHERE v.placa = 'ABC-123'
GROUP BY a.id_atencion, a.fecha, a.estado, a.total, e.nombre, e.apellido
ORDER BY a.fecha DESC;

-- 6. Métodos de pago con cantidad de usos
SELECT 
    mp.nombre AS metodo_pago,
    COUNT(p.id_pago) AS veces_usado,
    COALESCE(SUM(p.monto), 0) AS total_recaudado
FROM metodos_pago mp
LEFT JOIN pagos p ON mp.id_metodo = p.id_metodo
GROUP BY mp.id_metodo, mp.nombre
ORDER BY veces_usado DESC;

-- 7. Verificar pago de atención con detalle de comprobante
SELECT 
    a.id_atencion,
    a.estado,
    a.total AS total_atencion,
    CASE 
        WHEN p.id_pago IS NULL THEN 'PENDIENTE DE PAGO'
        ELSE 'PAGADO'
    END AS estado_pago,
    p.monto AS monto_pagado,
    p.numero_comprobante,
    mp.nombre AS metodo,
    TO_CHAR(p.fecha_pago, 'DD/MM/YYYY HH12:MI AM') AS fecha_pago
FROM atenciones a
LEFT JOIN pagos p ON a.id_atencion = p.id_atencion
LEFT JOIN metodos_pago mp ON p.id_metodo = mp.id_metodo
WHERE a.id_atencion = 1;


-- 8. Clientes frecuentes con todos sus vehículos (vista + filtro)
SELECT 
    cliente,
    telefono,
    cantidad_vehiculos,
    vehiculos
FROM v_cliente_vehiculos
WHERE cantidad_vehiculos > 1
ORDER BY cantidad_vehiculos DESC;

-- 9. Atenciones pendientes con tiempo de espera
SELECT 
    a.id_atencion,
    v.placa,
    c.nombre || ' ' || c.apellido AS cliente,
    a.estado,
    a.fecha AS registrada,
    NOW() - a.fecha AS tiempo_espera,
    e.nombre || ' ' || e.apellido AS asignado_a
FROM v_atenciones_completas a
JOIN vehiculos v ON a.placa = v.placa
JOIN clientes c ON a.cliente = c.nombre || ' ' || c.apellido
JOIN empleados e ON a.empleado = e.nombre || ' ' || e.apellido
WHERE a.estado IN ('Pendiente', 'En proceso')
ORDER BY a.fecha;

-- 10. Cierre diario con comparación día anterior
WITH cierre_hoy AS (
    SELECT * FROM v_cierre_diario WHERE fecha = '2024-02-01'
),
cierre_ayer AS (
    SELECT * FROM v_cierre_diario WHERE fecha = '2024-01-31'
)
SELECT 
    c1.fecha,
    c1.total_atenciones,
    c1.total_clientes,
    c1.ingresos_servicios,
    c1.costo_productos,
    c1.margen_bruto,
    c2.ingresos_servicios AS ingresos_dia_anterior,
    (c1.ingresos_servicios - c2.ingresos_servicios) AS diferencia_vs_ayer
FROM cierre_hoy c1
LEFT JOIN cierre_ayer c2 ON 1=1;

-- 11. Top 5 servicios más rentables con ticket promedio
SELECT 
    s.nombre AS servicio,
    cs.nombre AS categoria,
    COUNT(da.id_detalle) AS veces_solicitado,
    SUM(da.cantidad * da.precio_unitario) AS ingreso_total,
    ROUND(AVG(da.precio_unitario), 2) AS ticket_promedio
FROM detalle_atencion da
JOIN servicios s ON da.id_servicio = s.id_servicio
JOIN categorias_servicio cs ON s.id_categoria = cs.id_categoria
GROUP BY s.id_servicio, s.nombre, cs.nombre
ORDER BY ingreso_total DESC
LIMIT 5;

-- 12. Turnos del día con conteo de personal por turno
SELECT 
    t.nombre AS turno,
    t.hora_inicio::TEXT || ' - ' || t.hora_fin::TEXT AS horario,
    COUNT(et.id_empleado_turno) AS empleados_asignados,
    STRING_AGG(e.nombre || ' ' || e.apellido, ', ' ORDER BY e.nombre) AS personal
FROM v_turnos_asignados t
JOIN empleados_turnos et ON t.fecha = et.fecha AND t.turno = (SELECT nombre FROM turnos WHERE id_turno = et.id_turno)
JOIN empleados e ON et.id_empleado = e.id_empleado
WHERE t.fecha = '2024-02-14'
GROUP BY t.nombre, t.hora_inicio, t.hora_fin
ORDER BY t.hora_inicio;

-- 13. Clientes que no han visitado en los últimos 60 días
SELECT 
    c.nombre || ' ' || c.apellido AS cliente,
    c.telefono,
    c.email,
    MAX(a.fecha) AS ultima_visita,
    CURRENT_DATE - MAX(a.fecha)::DATE AS dias_sin_visitar
FROM clientes c
JOIN vehiculos v ON c.id_cliente = v.id_cliente
JOIN atenciones a ON v.id_vehiculo = a.id_vehiculo
GROUP BY c.id_cliente, c.nombre, c.apellido, c.telefono, c.email
HAVING MAX(a.fecha) < CURRENT_DATE - INTERVAL '60 days'
ORDER BY dias_sin_visitar DESC;

-- 14. Empleado del mes: mayor facturación y atenciones
SELECT 
    e.nombre || ' ' || e.apellido AS empleado,
    e.cargo,
    COUNT(a.id_atencion) AS atenciones,
    COALESCE(SUM(a.total), 0) AS facturacion_total,
    ROUND(AVG(a.total), 2) AS promedio_atencion,
    RANK() OVER (ORDER BY SUM(a.total) DESC) AS ranking
FROM empleados e
LEFT JOIN atenciones a ON e.id_empleado = a.id_empleado
    AND DATE_TRUNC('month', a.fecha) = '2024-02-01'
WHERE e.activo = TRUE
GROUP BY e.id_empleado, e.nombre, e.apellido, e.cargo
ORDER BY facturacion_total DESC;

-- 15. Historial completo de cliente con resumen de gastos por mes
SELECT 
    v.placa,
    TO_CHAR(DATE_TRUNC('month', a.fecha), 'Month YYYY') AS mes,
    COUNT(a.id_atencion) AS visitas,
    SUM(a.total) AS gasto_mensual,
    STRING_AGG(DISTINCT s.nombre, ', ') AS servicios_contratados
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
LEFT JOIN detalle_atencion da ON a.id_atencion = da.id_atencion
LEFT JOIN servicios s ON da.id_servicio = s.id_servicio
WHERE v.id_cliente = 1
GROUP BY v.placa, DATE_TRUNC('month', a.fecha)
ORDER BY DATE_TRUNC('month', a.fecha) DESC;