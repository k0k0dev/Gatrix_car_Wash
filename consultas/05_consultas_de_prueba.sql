
--Consultas de pruebas




-- Verificar que cada atención tiene su cliente a través del vehículo
SELECT 
    a.id_atencion,
    a.fecha,
    v.placa,
    c.nombre || ' ' || c.apellido AS cliente
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE c.id_cliente IS NULL;

-- Intentar insertar un vehículo con un cliente que no existe
INSERT INTO vehiculos (id_cliente, placa, marca, modelo, color)
VALUES (999, 'ZZZ-999', 'Toyota', 'Falso', 'Rojo');

-- ============================================================
-- Insertar un nuevo cliente
INSERT INTO clientes (nombre, apellido, telefono, email)
VALUES ('Prueba', 'Temporal', '999999999', 'test@test.com');

-- Verificar inserción
SELECT * FROM clientes WHERE email = 'test@test.com';

-- Eliminar el cliente de prueba
DELETE FROM clientes WHERE email = 'test@test.com';

-- Verificar eliminación
SELECT * FROM clientes WHERE email = 'test@test.com';
-- ============================================================

-- Actualizar el teléfono del cliente ID=1
UPDATE clientes SET telefono = '999888777' WHERE id_cliente = 1;

-- Verificar cambio
SELECT id_cliente, nombre, telefono FROM clientes WHERE id_cliente = 1;

-- Restaurar valor original
UPDATE clientes SET telefono = '964112233' WHERE id_cliente = 1;

-- Verificar restauración
SELECT id_cliente, nombre, telefono FROM clientes WHERE id_cliente = 1;


-- ============================================================
-- prueba de consultas
-- ============================================================

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

-- ============================================================
-- prueba de rendimiento
-- ============================================================

-- Prueba 1 — Verificar índices existentes y tiempos de consulta
EXPLAIN ANALYZE
SELECT v.placa, c.nombre, c.apellido, a.fecha, a.total
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE a.fecha BETWEEN '2024-01-01' AND '2024-01-31';

-- Crear índice si no existe para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_atenciones_fecha ON atenciones(fecha);

-- Volver a ejecutar y comparar
EXPLAIN ANALYZE
SELECT v.placa, c.nombre, c.apellido, a.fecha, a.total
FROM atenciones a
JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo
JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE a.fecha BETWEEN '2024-01-01' AND '2024-01-31';



-- Prueba 2 — Rendimiento en vista de cierre diario
EXPLAIN ANALYZE SELECT * FROM v_cierre_diario;

-- Crear índice compuesto
CREATE INDEX IF NOT EXISTS idx_uso_productos_atencion 
ON uso_productos(id_atencion);

EXPLAIN ANALYZE SELECT * FROM v_cierre_diario;


-- ============================================================
-- prueba de concurrencia
-- ============================================================

-- Prueba 1 — Simular dos inserciones simultáneas de atenciones
BEGIN;
INSERT INTO atenciones (id_vehiculo, id_empleado, fecha, estado, total)
VALUES (1, 1, NOW(), 'En proceso', 80.00);

COMMIT;

-- En otra sesión ejecutar el mismo INSERT con diferentes datos
-- Luego hacer COMMIT en ambas sesiones
-- Verificar que ambas atenciones se registraron
SELECT * FROM atenciones WHERE id_vehiculo = 1 AND estado = 'En proceso'
ORDER BY fecha DESC LIMIT 5;

-- Prueba 2 — Actualización concurrente de stock de producto
BEGIN;
UPDATE productos SET stock = stock - 1 WHERE id_producto = 1;
-- En otra sesión ejecutar la misma actualización
-- Si el stock es suficiente, ambas sesiones pueden proceder
COMMIT;

-- Verificar consistencia del stock
SELECT id_producto, nombre, stock FROM productos WHERE id_producto = 1;


-- ============================================================
-- prueba de seguridad
-- ============================================================

-- Prueba 1 — Se verificar que recepcionista NO puede modificar empleados
-- (Ejecutar conectado como usuario 'recepcionista')
SELECT current_user;
UPDATE empleados SET telefono = '999999999' WHERE id_empleado = 1;
-- Esperado: ERROR - permission denied

-- Prueba 2 — Verificar que empleado NO puede ver ni modificar pagos
-- (Ejecutar conectado como usuario 'empleado')
SELECT current_user;
SELECT * FROM pagos;
-- Esperado: ERROR - permission denied
INSERT INTO pagos (id_atencion, id_metodo, monto, numero_comprobante, fecha_pago)
VALUES (1, 1, 100.00, 'TEST', NOW());
-- Esperado: ERROR - permission denied



-- Verificar quién eres actualmente
SELECT current_user;

-- Cambiar temporalmente al rol de recepcionista
SET ROLE recepcionista;

-- Verificar que ahora eres recepcionista
SELECT current_user;

-- Intentar modificar empleados (debe fallar)
UPDATE empleados SET telefono = '999999999' WHERE id_empleado = 1;
-- Esperado: ERROR - permission denied

-- Volver a ser administrador
RESET ROLE;

-- Verificar que regresaste
SELECT current_user;


-- ============================================================
-- PRUEBA SIMPLIFICADA DE RESPALDO Y RECUPERACIÓN
-- ============================================================

-- PASO 1: Insertar cliente de prueba (sin vehículos, sin dependencias)
INSERT INTO clientes (nombre, apellido, telefono, email) 
VALUES ('Cliente', 'Prueba', '999999999', 'prueba@test.com');

-- PASO 2: Verificar inserción
SELECT * FROM clientes WHERE email = 'prueba@test.com';

-- PASO 3: Crear backup de ese registro específico
CREATE TABLE cliente_respaldo AS 
SELECT * FROM clientes WHERE email = 'prueba@test.com';

-- PASO 4: Simular pérdida (este sí se puede eliminar sin error)
DELETE FROM clientes WHERE email = 'prueba@test.com';
--  Eliminado sin errores

-- PASO 5: Verificar pérdida
SELECT * FROM clientes WHERE email = 'prueba@test.com';
-- 0 filas

-- PASO 6: Recuperar desde backup
INSERT INTO clientes SELECT * FROM cliente_respaldo;

-- PASO 7: Verificar recuperación
SELECT * FROM clientes WHERE email = 'prueba@test.com';
-- 1 fila 

-- PASO 8: Limpiar
DROP TABLE IF EXISTS cliente_respaldo;
DELETE FROM clientes WHERE email = 'prueba@test.com';