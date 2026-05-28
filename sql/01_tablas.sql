CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    telefono VARCHAR(15),
    email VARCHAR(100)
);

CREATE TABLE vehiculos (
    id_vehiculo SERIAL PRIMARY KEY,
    id_cliente INT,
    placa VARCHAR(10) UNIQUE,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    color VARCHAR(30),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    cargo VARCHAR(50),
    telefono VARCHAR(15),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE turnos (
    id_turno SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    hora_inicio TIME,
    hora_fin TIME
);

CREATE TABLE empleados_turnos (
    id_empleado_turno SERIAL PRIMARY KEY,
    id_empleado INT,
    id_turno INT,
    fecha DATE,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_turno) REFERENCES turnos(id_turno)
);

CREATE TABLE categorias_servicio (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE servicios (
    id_servicio SERIAL PRIMARY KEY,
    id_categoria INT,
    nombre VARCHAR(100),
    precio_base DECIMAL(10,2),
    duracion_min INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias_servicio(id_categoria)
);

CREATE TABLE atenciones (
    id_atencion SERIAL PRIMARY KEY,
    id_vehiculo INT,
    id_empleado INT,
    fecha TIMESTAMP,
    estado VARCHAR(30),
    total DECIMAL(10,2),
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

CREATE TABLE detalle_atencion (
    id_detalle SERIAL PRIMARY KEY,
    id_atencion INT,
    id_servicio INT,
    cantidad INT DEFAULT 1,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_atencion) REFERENCES atenciones(id_atencion),
    FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio)
);

CREATE TABLE metodos_pago (
    id_metodo SERIAL PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE pagos (
    id_pago SERIAL PRIMARY KEY,
    id_atencion INT,
    id_metodo INT,
    monto DECIMAL(10,2),
    numero_comprobante VARCHAR(50),
    fecha_pago TIMESTAMP,
    FOREIGN KEY (id_atencion) REFERENCES atenciones(id_atencion),
    FOREIGN KEY (id_metodo) REFERENCES metodos_pago(id_metodo)
);

CREATE TABLE proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    telefono VARCHAR(15),
    direccion TEXT
);

CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    stock INT,
    precio DECIMAL(10,2),
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE uso_productos (
    id_uso SERIAL PRIMARY KEY,
    id_producto INT,
    id_atencion INT,
    cantidad INT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_atencion) REFERENCES atenciones(id_atencion)
);