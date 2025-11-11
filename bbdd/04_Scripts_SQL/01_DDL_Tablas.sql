-- ===================================================================
-- SCRIPT DDL - CREACIÓN DE TABLAS - SISTEMA DE GESTIÓN DE BIBLIOTECA
-- ===================================================================
-- Base de Datos: biblioteca
-- Motor: MySQL 8.0+
-- Descripción: Creación de todas las tablas con constraints, índices y relaciones
-- ===================================================================

-- Primero, asegurarnos de usar la base de datos correcta
USE biblioteca;

-- ===================================================================
-- 1. TABLAS DE REFERENCIA (SIN DEPENDENCIAS)
-- ===================================================================

-- Tabla: EDITORIALES
-- Descripción: Almacena información de editoriales
CREATE TABLE EDITORIALES (
    editorial_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_editorial_nombre (nombre)
) ENGINE=InnoDB COMMENT='Tabla de editoriales';

-- Tabla: GENEROS
-- Descripción: Categorías de libros
CREATE TABLE GENEROS (
    genero_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    INDEX idx_genero_nombre (nombre)
) ENGINE=InnoDB COMMENT='Tabla de géneros literarios';

-- Tabla: AUTORES
-- Descripción: Información de autores
CREATE TABLE AUTORES (
    autor_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50),
    fecha_nacimiento DATE,
    INDEX idx_autor_nombre (nombre, apellido),
    INDEX idx_autor_nacionalidad (nacionalidad)
) ENGINE=InnoDB COMMENT='Tabla de autores';

-- Tabla: PERSONAL
-- Descripción: Personal de la biblioteca
CREATE TABLE PERSONAL (
    personal_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol ENUM('Bibliotecario', 'Administrador', 'Técnico') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    fecha_contratacion DATE NOT NULL,
    estado ENUM('Activo', 'Inactivo', 'Vacaciones') NOT NULL DEFAULT 'Activo',
    INDEX idx_personal_email (email),
    INDEX idx_personal_rol (rol),
    INDEX idx_personal_estado (estado)
) ENGINE=InnoDB COMMENT='Tabla de personal bibliotecario';

-- Tabla: SOCIOS
-- Descripción: Miembros de la biblioteca
CREATE TABLE SOCIOS (
    socio_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    estado ENUM('Activo', 'Inactivo', 'Suspendido') NOT NULL DEFAULT 'Activo',
    multa_acumulada DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    INDEX idx_socios_email (email),
    INDEX idx_socios_estado (estado),
    INDEX idx_socios_multa (multa_acumulada),
    CONSTRAINT chk_multa_acumulada CHECK (multa_acumulada >= 0)
) ENGINE=InnoDB COMMENT='Tabla de socios';

-- ===================================================================
-- 2. TABLA PRINCIPAL: LIBROS
-- ===================================================================

-- Tabla: LIBROS
-- Descripción: Catálogo de libros de la biblioteca
CREATE TABLE LIBROS (
    isbn VARCHAR(20) PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    editorial_id INT NOT NULL,
    genero_id INT NOT NULL,
    anio_publicacion INT,
    stock_total INT NOT NULL DEFAULT 1,
    stock_disponible INT NOT NULL DEFAULT 1,
    estado ENUM('Disponible', 'Prestado', 'Reservado', 'En reparación') NOT NULL DEFAULT 'Disponible',
    INDEX idx_libro_titulo (titulo),
    INDEX idx_libro_editorial (editorial_id),
    INDEX idx_libro_genero (genero_id),
    INDEX idx_libro_estado (estado),
    INDEX idx_libro_stock (stock_disponible),
    CONSTRAINT chk_anio_publicacion CHECK (anio_publicacion >= 1000 AND anio_publicacion <= YEAR(CURDATE())),
    CONSTRAINT chk_stock_total CHECK (stock_total >= 0),
    CONSTRAINT chk_stock_disponible CHECK (stock_disponible >= 0 AND stock_disponible <= stock_total),
    FOREIGN KEY (editorial_id) REFERENCES EDITORIALES(editorial_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (genero_id) REFERENCES GENEROS(genero_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Tabla de libros del catálogo';

-- ===================================================================
-- 3. TABLA INTERMEDIA: LIBRO_AUTOR (RELACIÓN N:M)
-- ===================================================================

-- Tabla: LIBRO_AUTOR
-- Descripción: Relación muchos a muchos entre libros y autores
CREATE TABLE LIBRO_AUTOR (
    isbn VARCHAR(20) NOT NULL,
    autor_id INT NOT NULL,
    PRIMARY KEY (isbn, autor_id),
    INDEX idx_libro_autor_isbn (isbn),
    INDEX idx_libro_autor_autor (autor_id),
    FOREIGN KEY (isbn) REFERENCES LIBROS(isbn) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (autor_id) REFERENCES AUTORES(autor_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Tabla intermedia libros-autores';

-- ===================================================================
-- 4. TABLAS DE TRANSACCIÓN (CON DEPENDENCIAS)
-- ===================================================================

-- Tabla: PRESTAMOS
-- Descripción: Registro de préstamos de libros
CREATE TABLE PRESTAMOS (
    prestamo_id INT PRIMARY KEY AUTO_INCREMENT,
    socio_id INT NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    personal_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado ENUM('Activo', 'Devuelto', 'Vencido', 'Renovado') NOT NULL DEFAULT 'Activo',
    INDEX idx_prestamos_socio (socio_id),
    INDEX idx_prestamos_isbn (isbn),
    INDEX idx_prestamos_personal (personal_id),
    INDEX idx_prestamos_estado (estado),
    INDEX idx_prestamos_fechas (fecha_prestamo, fecha_devolucion),
    INDEX idx_prestamos_devolucion (fecha_devolucion_real),
    FOREIGN KEY (socio_id) REFERENCES SOCIOS(socio_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIBROS(isbn) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (personal_id) REFERENCES PERSONAL(personal_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Tabla de préstamos';

-- Tabla: RESERVAS
-- Descripción: Reservas de libros por parte de socios
CREATE TABLE RESERVAS (
    reserva_id INT PRIMARY KEY AUTO_INCREMENT,
    socio_id INT NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    fecha_reserva DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_caducidad DATE NOT NULL,
    estado ENUM('Pendiente', 'Disponible', 'Retirado', 'Caducado', 'Cancelado') NOT NULL DEFAULT 'Pendiente',
    INDEX idx_reservas_socio (socio_id),
    INDEX idx_reservas_isbn (isbn),
    INDEX idx_reservas_estado (estado),
    INDEX idx_reservas_fechas (fecha_reserva, fecha_caducidad),
    FOREIGN KEY (socio_id) REFERENCES SOCIOS(socio_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIBROS(isbn) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Tabla de reservas';

-- Tabla: MULTAS
-- Descripción: Multas generadas por retrasos en devolución
CREATE TABLE MULTAS (
    multa_id INT PRIMARY KEY AUTO_INCREMENT,
    prestamo_id INT NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    fecha_generacion DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_pago DATE,
    estado ENUM('Pendiente', 'Pagada') NOT NULL DEFAULT 'Pendiente',
    INDEX idx_multas_prestamo (prestamo_id),
    INDEX idx_multas_estado (estado),
    INDEX idx_multas_fechas (fecha_generacion, fecha_pago),
    UNIQUE KEY uk_multas_prestamo (prestamo_id),
    CONSTRAINT chk_importe_multa CHECK (importe >= 0 AND importe <= 30.00),
    FOREIGN KEY (prestamo_id) REFERENCES PRESTAMOS(prestamo_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Tabla de multas';

-- ===================================================================
-- 5. TABLA DE AUDITORÍA
-- ===================================================================

-- Tabla: AUDITORIA_PRESTAMOS
-- Descripción: Registro de cambios en préstamos para auditoría
CREATE TABLE AUDITORIA_PRESTAMOS (
    auditoria_id INT PRIMARY KEY AUTO_INCREMENT,
    prestamo_id INT NOT NULL,
    campo_modificado VARCHAR(50) NOT NULL,
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255),
    usuario VARCHAR(100) NOT NULL,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    INDEX idx_auditoria_prestamo (prestamo_id),
    INDEX idx_auditoria_fecha (fecha_modificacion),
    INDEX idx_auditoria_usuario (usuario)
) ENGINE=InnoDB COMMENT='Tabla de auditoría de préstamos';

-- ===================================================================
-- 6. ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ===================================================================

-- Índices compuestos para consultas complejas
CREATE INDEX idx_prestamos_completo ON PRESTAMOS(socio_id, isbn, estado);
CREATE INDEX idx_reservas_completo ON RESERVAS(socio_id, isbn, estado);
CREATE INDEX idx_libros_completo ON LIBROS(editorial_id, genero_id, estado);

-- Índices para búsquedas por texto
CREATE INDEX idx_libros_titulo_full ON LIBROS(titulo);
CREATE INDEX idx_autores_nombre_full ON AUTORES(nombre, apellido);
CREATE INDEX idx_socios_nombre_full ON SOCIOS(nombre, apellido);

-- ===================================================================
-- FIN DEL SCRIPT DDL
-- ===================================================================
-- Total de tablas creadas: 9 tablas principales + 1 tabla intermedia + 1 tabla de auditoría
-- Total de constraints: 20+ (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL)
-- Total de índices: 30+ para optimización de consultas
-- ===================================================================