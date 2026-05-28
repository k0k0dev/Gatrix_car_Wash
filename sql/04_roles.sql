-- ============================================================
-- GATRIX CAR WASH — Base de Datos PostgreSQL
-- Archivo: 04_usuarios.sql
-- Descripción: Creación de usuarios y asignación de permisos
-- ⚠️  Cambiar las contraseñas antes de pasar a producción
-- ============================================================

-- ------------------------------------------------------------
-- CREAR USUARIOS
-- ------------------------------------------------------------
CREATE USER administrador WITH PASSWORD 'GatrixAdmin#2026';
CREATE USER recepcionista WITH PASSWORD 'GatrixRecep#2026';
CREATE USER empleado      WITH PASSWORD 'GatrixOper#2026';
CREATE USER logistica     WITH PASSWORD 'GatrixLogis#2026';

-- ------------------------------------------------------------
-- CONEXIÓN A LA BASE DE DATOS
-- ------------------------------------------------------------
GRANT CONNECT ON DATABASE gatrix_car_wash TO administrador;
GRANT CONNECT ON DATABASE gatrix_car_wash TO recepcionista;
GRANT CONNECT ON DATABASE gatrix_car_wash TO empleado;
GRANT CONNECT ON DATABASE gatrix_car_wash TO logistica;

-- ============================================================
-- ADMINISTRADOR — Acceso total
-- ============================================================
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrador;

-- ============================================================
-- RECEPCIONISTA / CAJERO
-- ============================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM recepcionista;

-- Clientes y vehículos
GRANT SELECT, INSERT, UPDATE ON clientes  TO recepcionista;
GRANT SELECT, INSERT, UPDATE ON vehiculos TO recepcionista;

-- Atenciones
GRANT SELECT, INSERT, UPDATE ON atenciones TO recepcionista;

-- Pagos y facturación
GRANT SELECT, INSERT, UPDATE ON pagos        TO recepcionista;
GRANT SELECT                  ON metodos_pago TO recepcionista;

-- Solo lectura de servicios
GRANT SELECT ON servicios           TO recepcionista;
GRANT SELECT ON categorias_servicio TO recepcionista;

-- Secuencias necesarias
GRANT USAGE, SELECT ON SEQUENCE clientes_id_cliente_seq   TO recepcionista;
GRANT USAGE, SELECT ON SEQUENCE vehiculos_id_vehiculo_seq  TO recepcionista;
GRANT USAGE, SELECT ON SEQUENCE atenciones_id_atencion_seq TO recepcionista;
GRANT USAGE, SELECT ON SEQUENCE pagos_id_pago_seq          TO recepcionista;

-- ============================================================
-- EMPLEADO / OPERARIO
-- ============================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM empleado;

-- Atenciones (sin INSERT — las crea la recepción)
GRANT SELECT, UPDATE ON atenciones TO empleado;

-- Detalle y productos
GRANT SELECT, INSERT, UPDATE ON detalle_atencion TO empleado;
GRANT SELECT, INSERT, UPDATE ON uso_productos     TO empleado;

-- Lectura de apoyo
GRANT SELECT ON servicios           TO empleado;
GRANT SELECT ON categorias_servicio TO empleado;
GRANT SELECT ON productos           TO empleado;
GRANT SELECT ON vehiculos           TO empleado;
GRANT SELECT ON clientes            TO empleado;

-- Secuencias necesarias
GRANT USAGE, SELECT ON SEQUENCE detalle_atencion_id_detalle_seq TO empleado;
GRANT USAGE, SELECT ON SEQUENCE uso_productos_id_uso_seq         TO empleado;

-- ============================================================
-- LOGÍSTICA / SUPERVISOR
-- ============================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM logistica;

-- Lectura global
GRANT SELECT ON ALL TABLES IN SCHEMA public TO logistica;

-- Gestión de inventario
GRANT SELECT, INSERT, UPDATE ON productos     TO logistica;
GRANT SELECT, INSERT, UPDATE ON proveedores   TO logistica;
GRANT SELECT, INSERT, UPDATE ON uso_productos TO logistica;

-- Secuencias necesarias
GRANT USAGE, SELECT ON SEQUENCE productos_id_producto_seq   TO logistica;
GRANT USAGE, SELECT ON SEQUENCE proveedores_id_proveedor_seq TO logistica;
GRANT USAGE, SELECT ON SEQUENCE uso_productos_id_uso_seq     TO logistica;

-- ============================================================
-- VERIFICAR USUARIOS CREADOS
-- ============================================================
SELECT usename FROM pg_user;