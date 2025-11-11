-- ===================================================================
-- SCRIPT: 04_Triggers.sql
-- PROYECTO: Sistema de Gestión de Biblioteca
-- DESCRIPCIÓN: Triggers de validación y auditoría
-- FECHA: Noviembre 2025
-- ===================================================================

DELIMITER $$

-- =====================================================
-- 1. TRIGGER: trg_prestamo_before_insert
-- DESCRIPCIÓN: Valida préstamo antes de insertar (stock, límite, multas)
-- =====================================================
CREATE TRIGGER trg_prestamo_before_insert
BEFORE INSERT ON PRESTAMOS
FOR EACH ROW
BEGIN
    DECLARE v_stock_disponible INT;
    DECLARE v_socio_estado VARCHAR(20);
    DECLARE v_multas_pendientes DECIMAL(10,2);
    DECLARE v_prestamos_activos INT;
    DECLARE v_limite_multas DECIMAL(10,2) DEFAULT 10.00;
    DECLARE v_limite_prestamos INT DEFAULT 3;
    
    -- Validar stock disponible
    SELECT stock_disponible INTO v_stock_disponible
    FROM LIBROS WHERE isbn = NEW.isbn;
    
    IF v_stock_disponible IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Libro no encontrado en el catálogo';
    END IF;
    
    IF v_stock_disponible <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Stock no disponible para préstamo';
    END IF;
    
    -- Validar socio activo
    SELECT estado, multa_acumulada INTO v_socio_estado, v_multas_pendientes
    FROM SOCIOS WHERE socio_id = NEW.socio_id;
    
    IF v_socio_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Socio no encontrado en el sistema';
    END IF;
    
    IF v_socio_estado != 'Activo' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Socio no está activo - Contacte con administración';
    END IF;
    
    -- Validar límite de multas
    IF v_multas_pendientes > v_limite_multas THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('ERROR: Socio tiene multas pendientes (', v_multas_pendientes, '€) superiores al límite permitido');
    END IF;
    
    -- Validar límite de préstamos
    SELECT COUNT(*) INTO v_prestamos_activos
    FROM PRESTAMOS
    WHERE socio_id = NEW.socio_id AND estado = 'Activo';
    
    IF v_prestamos_activos >= v_limite_prestamos THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('ERROR: Límite de ', v_limite_prestamos, ' préstamos simultáneos alcanzado');
    END IF;
    
    -- Establecer valores por defecto
    SET NEW.fecha_prestamo = CURDATE();
    SET NEW.fecha_devolucion = DATE_ADD(CURDATE(), INTERVAL 15 DAY);
    SET NEW.estado = 'Activo';
END$$

-- =====================================================
-- 2. TRIGGER: trg_prestamo_after_update
-- DESCRIPCIÓN: Actualiza stock y procesa reservas después de devolución
-- =====================================================
CREATE TRIGGER trg_prestamo_after_update
AFTER UPDATE ON PRESTAMOS
FOR EACH ROW
BEGIN
    -- Si el préstamo fue devuelto (cambio de estado Activo a Devuelto)
    IF OLD.estado = 'Activo' AND NEW.estado = 'Devuelto' THEN
        -- Actualizar stock disponible del libro
        UPDATE LIBROS 
        SET stock_disponible = stock_disponible + 1,
            estado = CASE WHEN stock_disponible + 1 > 0 THEN 'Disponible' ELSE estado END
        WHERE isbn = NEW.isbn;
        
        -- Procesar reservas pendientes para este libro
        CALL sp_procesar_reservas_pendientes(NEW.isbn);
    END IF;
END$$

-- =====================================================
-- 3. TRIGGER: trg_libros_before_update
-- DESCRIPCIÓN: Valida actualización de stock y estado
-- =====================================================
CREATE TRIGGER trg_libros_before_update
BEFORE UPDATE ON LIBROS
FOR EACH ROW
BEGIN
    -- Validar que stock disponible no sea negativo
    IF NEW.stock_disponible < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Stock disponible no puede ser negativo';
    END IF;
    
    -- Validar que stock disponible no exceda stock total
    IF NEW.stock_disponible > NEW.stock_total THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Stock disponible no puede exceder el stock total';
    END IF;
    
    -- Actualizar estado automáticamente según stock
    IF NEW.stock_disponible = 0 THEN
        SET NEW.estado = 'Prestado';
    ELSEIF NEW.stock_disponible > 0 AND OLD.estado = 'Prestado' THEN
        SET NEW.estado = 'Disponible';
    END IF;
END$$

-- =====================================================
-- 4. TRIGGER: trg_multas_after_update
-- DESCRIPCIÓN: Actualiza multa acumulada del socio cuando se paga una multa
-- =====================================================
CREATE TRIGGER trg_multas_after_update
AFTER UPDATE ON MULTAS
FOR EACH ROW
BEGIN
    DECLARE v_socio_id INT;
    DECLARE v_importe_pagado DECIMAL(10,2);
    
    -- Si la multa fue pagada (cambio de estado Pendiente a Pagada)
    IF OLD.estado = 'Pendiente' AND NEW.estado = 'Pagada' THEN
        -- Obtener el socio del préstamo relacionado
        SELECT socio_id INTO v_socio_id
        FROM PRESTAMOS WHERE prestamo_id = NEW.prestamo_id;
        
        IF v_socio_id IS NOT NULL THEN
            -- Actualizar multa acumulada del socio
            UPDATE SOCIOS 
            SET multa_acumulada = GREATEST(multa_acumulada - OLD.importe, 0)
            WHERE socio_id = v_socio_id;
        END IF;
    END IF;
END$$

-- =====================================================
-- 5. TRIGGER: trg_reservas_before_insert
-- DESCRIPCIÓN: Valida reserva antes de insertar
-- =====================================================
CREATE TRIGGER trg_reservas_before_insert
BEFORE INSERT ON RESERVAS
FOR EACH ROW
BEGIN
    DECLARE v_stock_disponible INT;
    DECLARE v_socio_estado VARCHAR(20);
    DECLARE v_reservas_activas INT;
    DECLARE v_limite_reservas INT DEFAULT 2;
    
    -- Validar que el libro existe
    IF NOT EXISTS (SELECT 1 FROM LIBROS WHERE isbn = NEW.isbn) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Libro no encontrado en el catálogo';
    END IF;
    
    -- Validar socio activo
    SELECT estado INTO v_socio_estado
    FROM SOCIOS WHERE socio_id = NEW.socio_id;
    
    IF v_socio_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Socio no encontrado en el sistema';
    END IF;
    
    IF v_socio_estado != 'Activo' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Socio no está activo - No puede realizar reservas';
    END IF;
    
    -- Validar límite de reservas por socio
    SELECT COUNT(*) INTO v_reservas_activas
    FROM RESERVAS
    WHERE socio_id = NEW.socio_id AND estado = 'Pendiente';
    
    IF v_reservas_activas >= v_limite_reservas THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('ERROR: Límite de ', v_limite_reservas, ' reservas simultáneas alcanzado');
    END IF;
    
    -- Establecer valores por defecto
    SET NEW.fecha_reserva = CURDATE();
    SET NEW.fecha_caducidad = DATE_ADD(CURDATE(), INTERVAL 7 DAY);
    SET NEW.estado = 'Pendiente';
END$$

-- =====================================================
-- 6. TRIGGER: trg_socios_before_update
-- DESCRIPCIÓN: Valida actualización de datos de socio
-- =====================================================
CREATE TRIGGER trg_socios_before_update
BEFORE UPDATE ON SOCIOS
FOR EACH ROW
BEGIN
    -- Validar que el email no se duplique (si se está actualizando)
    IF NEW.email != OLD.email THEN
        IF EXISTS (SELECT 1 FROM SOCIOS WHERE email = NEW.email AND socio_id != OLD.socio_id) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'ERROR: El email ya está registrado por otro socio';
        END IF;
    END IF;
    
    -- Validar que multa acumulada no sea negativa
    IF NEW.multa_acumulada < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Multa acumulada no puede ser negativa';
    END IF;
    
    -- Si el socio pasa a inactivo, verificar que no tenga préstamos activos
    IF NEW.estado = 'Inactivo' AND OLD.estado = 'Activo' THEN
        IF EXISTS (SELECT 1 FROM PRESTAMOS WHERE socio_id = OLD.socio_id AND estado = 'Activo') THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'ERROR: Socio tiene préstamos activos - No puede ser dado de baja';
        END IF;
    END IF;
END$$

-- =====================================================
-- 7. TRIGGER: trg_libros_after_delete
-- DESCRIPCIÓN: Previene eliminación de libros con préstamos activos
-- =====================================================
CREATE TRIGGER trg_libros_before_delete
BEFORE DELETE ON LIBROS
FOR EACH ROW
BEGIN
    -- Verificar si hay préstamos activos
    IF EXISTS (SELECT 1 FROM PRESTAMOS WHERE isbn = OLD.isbn AND estado = 'Activo') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No se puede eliminar libro con préstamos activos';
    END IF;
    
    -- Verificar si hay reservas pendientes
    IF EXISTS (SELECT 1 FROM RESERVAS WHERE isbn = OLD.isbn AND estado = 'Pendiente') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No se puede eliminar libro con reservas pendientes';
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- 8. TABLA DE AUDITORÍA PARA LIBROS
-- =====================================================
CREATE TABLE IF NOT EXISTS AUDITORIA_LIBROS (
    auditoria_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20),
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255),
    usuario VARCHAR(100),
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_operacion ENUM('INSERT', 'UPDATE', 'DELETE'),
    INDEX idx_auditoria_isbn (isbn),
    INDEX idx_auditoria_fecha (fecha_modificacion)
);

-- =====================================================
-- 9. TRIGGER: trg_libros_auditoria_update
-- DESCRIPCIÓN: Registra cambios en la tabla LIBROS para auditoría
-- =====================================================
DELIMITER $$

CREATE TRIGGER trg_libros_auditoria_update
AFTER UPDATE ON LIBROS
FOR EACH ROW
BEGIN
    -- Registrar cambio en título
    IF OLD.titulo != NEW.titulo THEN
        INSERT INTO AUDITORIA_LIBROS (isbn, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.isbn, 'titulo', OLD.titulo, NEW.titulo, USER(), 'UPDATE');
    END IF;
    
    -- Registrar cambio en stock_disponible
    IF OLD.stock_disponible != NEW.stock_disponible THEN
        INSERT INTO AUDITORIA_LIBROS (isbn, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.isbn, 'stock_disponible', OLD.stock_disponible, NEW.stock_disponible, USER(), 'UPDATE');
    END IF;
    
    -- Registrar cambio en stock_total
    IF OLD.stock_total != NEW.stock_total THEN
        INSERT INTO AUDITORIA_LIBROS (isbn, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.isbn, 'stock_total', OLD.stock_total, NEW.stock_total, USER(), 'UPDATE');
    END IF;
    
    -- Registrar cambio en estado
    IF OLD.estado != NEW.estado THEN
        INSERT INTO AUDITORIA_LIBROS (isbn, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.isbn, 'estado', OLD.estado, NEW.estado, USER(), 'UPDATE');
    END IF;
END$$

-- =====================================================
-- 10. TRIGGER: trg_libros_auditoria_insert
-- DESCRIPCIÓN: Registro de inserciones en la tabla LIBROS
-- =====================================================
CREATE TRIGGER trg_libros_auditoria_insert
AFTER INSERT ON LIBROS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LIBROS (isbn, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
    VALUES (NEW.isbn, 'REGISTRO COMPLETO', 'N/A', CONCAT('Título: ', NEW.titulo, ' - Stock: ', NEW.stock_total), USER(), 'INSERT');
END$$

-- =====================================================
-- 11. TRIGGER: trg_libros_auditoria_delete
-- DESCRIPCIÓN: Registro de eliminaciones en la tabla LIBROS
-- =====================================================
CREATE TRIGGER trg_libros_auditoria_delete
AFTER DELETE ON LIBROS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LIBROS (isbn, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
    VALUES (OLD.isbn, 'REGISTRO COMPLETO', CONCAT('Título: ', OLD.titulo, ' - Stock: ', OLD.stock_total), 'ELIMINADO', USER(), 'DELETE');
END$$

DELIMITER ;

-- =====================================================
-- 12. TABLA DE LOG DE STOCK
-- =====================================================
CREATE TABLE IF NOT EXISTS LOG_STOCK (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20),
    tipo_movimiento VARCHAR(50),
    cantidad INT,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    personal_id INT,
    FOREIGN KEY (isbn) REFERENCES LIBROS(isbn),
    INDEX idx_log_isbn (isbn),
    INDEX idx_log_fecha (fecha_movimiento)
);

-- Mensaje de confirmación
SELECT '✓ Triggers creados exitosamente' as Estado;
SELECT '✓ Total triggers: 11 (7 validación + 4 auditoría)' as Resumen;
SELECT '✓ Tablas de auditoría y log creadas' as Detalles;