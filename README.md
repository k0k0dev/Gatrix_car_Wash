# 🚗 Gatrix Car Wash — Base de Datos PostgreSQL
Proyecto académico desarrollado con PostgreSQL para la gestión de un car wash.
Sistema de gestión integral para talleres y lavaderos de autos. Administra clientes, vehículos, atenciones, servicios, empleados, inventario y pagos.

---

## 📋 Tabla de Contenidos

- [Requisitos previos](#-requisitos-previos)
- [Instalación paso a paso](#-instalación-paso-a-paso)
- [Estructura de la base de datos](#-estructura-de-la-base-de-datos)
- [Diagrama de relaciones](#-diagrama-de-relaciones)
- [Vistas disponibles](#-vistas-disponibles)
- [Usuarios y permisos](#-usuarios-y-permisos)
- [Consultas de ejemplo](#-consultas-de-ejemplo)
- [Datos de prueba](#-datos-de-prueba)

---

## ✅ Requisitos previos

- PostgreSQL 14 o superior
- **pgAdmin 4** para administración visual de PostgreSQL
- Sistema operativo Windows, Linux o macOS
- Verifica que PostgreSQL y pgAdmin 4 estén instalados correctamente.

---

## 🚀 Instalación paso a paso usando pgAdmin 4

### 1. Clonar o descargar el repositorio

```bash
git clone https://github.com/k0k0dev/Gatrix_car_Wash.git
```

También puedes descargar el proyecto como archivo ZIP desde GitHub.

---

### 2. Abrir pgAdmin 4

Inicia pgAdmin 4 y conéctate al servidor PostgreSQL usando tu usuario `postgres`.

---

### 3. Crear la base de datos

1. En el panel izquierdo, clic derecho en **Databases**
2. Selecciona:

```text
Create → Database
```

3. En el campo **Database**, escribe:

```text
gatrix_car_wash
```

4. Presiona **Save**

---

### 4. Ejecutar los scripts SQL

1. Selecciona la base de datos `gatrix_car_wash`
2. Ve a:

```text
Tools → Query Tool
```

3. Abre y ejecuta los siguientes archivos SQL en orden:

```text
sql/01_tablas.sql
sql/02_datos.sql
sql/03_vistas.sql
sql/04_usuarios.sql
```

4. Presiona el botón ▶ Execute después de cada script.

---

### 5. Verificar instalación

En el panel izquierdo de pgAdmin:

```text
Schemas → public → Tables
Schemas → public → Views
```

Ahí aparecerán todas las tablas y vistas creadas.

---

### 6. Probar consultas

```sql
SELECT * FROM clientes;

SELECT * FROM v_servicios_mas_solicitados;

SELECT * FROM v_cierre_diario;
```
---

## 🗂️ Estructura de la base de datos

La base de datos contiene **14 tablas** organizadas en los siguientes módulos:

### 👥 Módulo de Clientes y Vehículos

| Tabla | Descripción | Registros de prueba |
|---|---|---|
| `clientes` | Datos personales de los clientes | 40 |
| `vehiculos` | Vehículos registrados por cliente | 60 |

**`clientes`**
```
id_cliente  SERIAL PRIMARY KEY
nombre      VARCHAR(100)
apellido    VARCHAR(100)
telefono    VARCHAR(15)
email       VARCHAR(100)
```

**`vehiculos`**
```
id_vehiculo  SERIAL PRIMARY KEY
id_cliente   INT → clientes
placa        VARCHAR(10) UNIQUE
marca        VARCHAR(50)
modelo       VARCHAR(50)
color        VARCHAR(30)
```

---

### 🔧 Módulo de Servicios

| Tabla | Descripción | Registros de prueba |
|---|---|---|
| `categorias_servicio` | Agrupación de servicios | 5 |
| `servicios` | Catálogo de servicios con precio y duración | 18 |

**Categorías disponibles:**
- Mantenimiento Preventivo
- Mecánica General
- Electricidad
- Carrocería y Pintura
- Lavado y Detailing

---

### 📋 Módulo de Atenciones

| Tabla | Descripción | Registros de prueba |
|---|---|---|
| `atenciones` | Registro de cada visita de un vehículo | 100 |
| `detalle_atencion` | Servicios realizados por atención | ~130 |

**Estados de atención:** `Completado`, `En proceso`, `Pendiente`, `Cancelado`

---

### 💰 Módulo de Pagos

| Tabla | Descripción | Registros de prueba |
|---|---|---|
| `metodos_pago` | Tipos de pago aceptados | 5 |
| `pagos` | Registro de cobros con comprobante | 91 |

**Métodos de pago disponibles:**
- Efectivo
- Tarjeta de Débito
- Tarjeta de Crédito
- Transferencia Bancaria
- Yape / Plin

---

### 👨‍🔧 Módulo de Empleados y Turnos

| Tabla | Descripción | Registros de prueba |
|---|---|---|
| `empleados` | Personal del taller | 12 |
| `turnos` | Turnos de trabajo definidos | 3 |
| `empleados_turnos` | Asignación de empleados a turnos por fecha | 50 |

**Turnos disponibles:**
- Mañana: 07:00 – 13:00
- Tarde: 13:00 – 19:00
- Noche: 19:00 – 23:00

---

### 📦 Módulo de Inventario

| Tabla | Descripción | Registros de prueba |
|---|---|---|
| `proveedores` | Empresas proveedoras de productos | 6 |
| `productos` | Productos en stock con precio | 18 |
| `uso_productos` | Productos consumidos por atención | ~75 |

---

## 🔗 Diagrama de relaciones

```
clientes ──< vehiculos ──< atenciones >── empleados
                              │
                    ┌─────────┴──────────┐
                    │                    │
              detalle_atencion      uso_productos
                    │                    │
                 servicios           productos ──> proveedores
                    │
           categorias_servicio

atenciones ──< pagos >── metodos_pago

empleados ──< empleados_turnos >── turnos
```

---

## 👁️ Vistas disponibles

El sistema incluye **10 vistas** predefinidas para consultas frecuentes:

| Vista | Descripción |
|---|---|
| `v_atenciones_completas` | Atenciones con datos del cliente, vehículo y empleado |
| `v_ingresos_diarios_por_metodo` | Ingresos agrupados por día y método de pago |
| `v_servicios_mas_solicitados` | Ranking de servicios por demanda e ingresos generados |
| `v_cliente_vehiculos` | Clientes con todos sus vehículos agrupados |
| `v_stock_bajo` | Productos con stock igual o menor a 5 unidades |
| `v_rendimiento_empleados` | Atenciones y montos generados por empleado activo |
| `v_historial_vehiculo` | Historial completo de atenciones por vehículo |
| `v_turnos_asignados` | Planilla de turnos con datos del empleado |
| `v_consumo_productos` | Productos utilizados por atención con costos |
| `v_cierre_diario` | Resumen diario: atenciones, ingresos y margen bruto |

**Ejemplo de uso:**

```sql
-- Ver los servicios más solicitados
SELECT * FROM v_servicios_mas_solicitados LIMIT 5;

-- Ver el rendimiento de los empleados
SELECT * FROM v_rendimiento_empleados;

-- Ver el cierre del día
SELECT * FROM v_cierre_diario WHERE fecha = CURRENT_DATE;
```

---

## 🔐 Usuarios y permisos

El sistema define **4 roles** con acceso diferenciado:

| Usuario | Contraseña | Rol | Acceso |
|---|---|---|---|
| `administrador` | `********` | Administrador | Total — todas las tablas y secuencias |
| `recepcionista` | `********` | Recepcionista/Cajero | Clientes, vehículos, atenciones, pagos |
| `empleado` | `********` | Operario | Atenciones, detalle, uso de productos |
| `logistica` | `********` | Logística/Supervisor | Lectura global + gestión de inventario |

**Conectarse con un usuario específico:**

```bash
Para probar distintos usuarios, crea una nueva conexión en pgAdmin 4 utilizando las credenciales correspondientes.
```
## 🔐 Probar conexiones con distintos roles en pgAdmin 4

Para iniciar sesión con alguno de los roles del sistema (`administrador`, `recepcionista`, `empleado` o `logistica`):

1. En pgAdmin 4, clic derecho en **Servers**
2. Selecciona:

```text
Register → Server
```

3. En la pestaña **General**, asigna un nombre al servidor:

```text
Ejemplo: Recepcionista
```

4. En la pestaña **Connection**, completa los campos:

| Campo | Valor |
|---|---|
| Host name/address | `localhost` |
| Port | `5432` |
| Maintenance database | `gatrix_car_wash` |
| Username | Nombre del rol (`recepcionista`, `empleado`, etc.) |
| Password | Contraseña definida en `04_usuarios.sql` |

5. Presiona **Save**

Ahora podrás acceder a la base de datos utilizando los permisos específicos de cada rol.

**Verificar usuarios creados:**

```sql
SELECT usename FROM pg_user;
```

> ⚠️ **Importante:** Cambia las contraseñas antes de llevar el sistema a producción.

---

## 🔍 Consultas de ejemplo

### Clientes con sus vehículos
```sql
SELECT c.nombre, c.apellido, v.placa, v.marca, v.modelo
FROM clientes c
JOIN vehiculos v ON c.id_cliente = v.id_cliente;
```

### Atenciones con empleado asignado
```sql
SELECT a.id_atencion, a.fecha, a.estado, a.total,
       e.nombre || ' ' || e.apellido AS empleado
FROM atenciones a
JOIN empleados e ON a.id_empleado = e.id_empleado
ORDER BY a.fecha DESC;
```

### Ingresos totales por mes
```sql
SELECT TO_CHAR(fecha, 'YYYY-MM') AS mes,
       COUNT(*) AS atenciones,
       SUM(total) AS ingresos
FROM atenciones
WHERE estado = 'Completado'
GROUP BY TO_CHAR(fecha, 'YYYY-MM')
ORDER BY mes;
```

### Productos con stock bajo
```sql
SELECT * FROM v_stock_bajo;
```

### Servicios más solicitados
```sql
SELECT servicio, categoria, veces_solicitado, ingreso_generado
FROM v_servicios_mas_solicitados
LIMIT 10;
```

---

## 📊 Datos de prueba

El script de datos incluye información realista para el período enero – mayo 2024:

| Entidad | Cantidad |
|---|---|
| Clientes | 40 |
| Vehículos | 60 |
| Empleados | 12 (11 activos) |
| Turnos | 3 |
| Asignaciones de turno | 50 |
| Categorías de servicio | 5 |
| Servicios | 18 |
| Atenciones | 100 |
| Detalles de atención | ~130 |
| Métodos de pago | 5 |
| Pagos registrados | 91 |
| Proveedores | 6 |
| Productos | 18 |
| Uso de productos | ~75 |

---

## 📁 Estructura de archivos sugerida

```
gatrix-car-wash/
├── README.md
└── sql/
    ├── 01_tablas.sql       # Creación de tablas
    ├── 02_datos.sql        # Datos de prueba
    ├── 03_vistas.sql       # Vistas del sistema
    └── 04_usuarios.sql     # Usuarios y permisos
```

---

## 🛠️ Tecnologías

- **Motor de base de datos:** PostgreSQL 14+
- **Administrador visual:** pgAdmin 4
- **Lenguaje:** SQL estándar + extensiones PostgreSQL
- **Funciones usadas:** `SERIAL`, `BOOLEAN`, `TIMESTAMP`, `DECIMAL`, `STRING_AGG`, `COALESCE`, `DATE()`

---

## 📄 Licencia

Este proyecto es de uso educativo y puede adaptarse libremente para proyectos académicos o comerciales.
