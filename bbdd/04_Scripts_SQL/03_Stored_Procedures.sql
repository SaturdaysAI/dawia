-- ===================================================================
-- SCRIPT: 03_Stored_Procedures.sql
-- PROYECTO: Sistema de Gestión de Biblioteca
-- DESCRIPCIÓN: Stored Procedures con transacciones y manejo de errores
-- FECHA: Noviembre 2025
-- ===================================================================

DELIMITER $$

-- =====================================================
-- 1. SP: sp_registrar_prestamo_completo
-- DESCRIPCIÓN: Registra un préstamo con validaciones completas y transacción
-- =====================================================
CREATE PROCEDURE sp_registrar_prestamo_completo(
    IN p_socio_id INT,
    IN p_isbn VARCHAR(20),
    IN p_personal_id INT,
    OUT p_prestamo_id INT,
    OUT p_mensaje VARCHAR(200)
)
proc_label: BEGIN
    DECLARE v_prestamos_activos INT;
    DECLARE v_multas_pendientes DECIMAL(10,2);
    DECLARE v_stock_disponible INT;
    DECLARE v_socio_estado VARCHAR(20);
    DECLARE v_libro_estado VARCHAR(20);
    DECLARE v_limite_multas DECIMAL(10,2) DEFAULT 10.00;
    DECLARE v_limite_prestamos INT DEFAULT 3;
    DECLARE v_dias_prestamo INT DEFAULT 15;
    
    -- Inicializar variables de salida
    SET p_prestamo_id = NULL;
    SET p_mensaje = '';
    
    -- Validación 1: Socio existe y está activo
    SELECT estado, multa_acumulada INTO v_socio_estado, v_multas_pendientes
    FROM SOCIOS WHERE socio_id = p_socio_id;
    
    IF v_socio_estado IS NULL THEN
        SET p_mensaje = 'ERROR: Socio no encontrado en el sistema';
        LEAVE proc_label;
    END IF;
    
    IF v_socio_estado != 'Activo' THEN
        SET p_mensaje = 'ERROR: Socio no está activo - Contacte con administración';
        LEAVE proc_label;
    END IF;
    
    -- Validación 2: Límite de multas
    IF v_multas_pendientes > v_limite_multas THEN
        SET p_mensaje = CONCAT('ERROR: Socio tiene multas pendientes (', v_multas_pendientes, '€) superiores al límite permitido');
        LEAVE proc_label;
    END IF;
    
    -- Validación 3: Límite de préstamos
    SELECT COUNT(*) INTO v_prestamos_activos
    FROM PRESTAMOS
    WHERE socio_id = p_socio_id AND estado = 'Activo';
    
    IF v_prestamos_activos >= v_limite_prestamos THEN
        SET p_mensaje = CONCAT('ERROR: Socio ha alcanzado el límite de ', v_limite_prestamos, ' préstamos simultáneos');
        LEAVE proc_label;
    END IF;
    
    -- Validación 4: Libro disponible
    SELECT stock_disponible, estado INTO v_stock_disponible, v_libro_estado
    FROM LIBROS WHERE isbn = p_isbn;
    
    IF v_stock_disponible IS NULL THEN
        SET p_mensaje = 'ERROR: Libro no encontrado en el catálogo';
        LEAVE proc_label;
    END IF;
    
    IF v_stock_disponible <= 0 OR v_libro_estado != 'Disponible' THEN
        SET p_mensaje = 'ERROR: Libro no está disponible para préstamo';
        LEAVE proc_label;
    END IF;
    
    -- Inserción del préstamo con transacción
    START TRANSACTION;
    
    INSERT INTO PRESTAMOS (socio_id, isbn, personal_id, fecha_devolucion)
    VALUES (p_socio_id, p_isbn, p_personal_id, DATE_ADD(CURDATE(), INTERVAL v_dias_prestamo DAY));
    
    SET p_prestamo_id = LAST_INSERT_ID();
    
    -- Actualizar stock del libro
    UPDATE LIBROS 
    SET stock_disponible = stock_disponible - 1,
        estado = CASE WHEN (stock_disponible - 1) = 0 THEN 'Prestado' ELSE 'Disponible' END
    WHERE isbn = p_isbn;
    
    COMMIT;
    SET p_mensaje = '✓ Préstamo registrado exitosamente';
    
END$$

-- =====================================================
-- 2. SP: sp_registrar_devolucion
-- DESCRIPCIÓN: Procesa la devolución de un libro y calcula multas
-- =====================================================
CREATE PROCEDURE sp_registrar_devolucion(
    IN p_prestamo_id INT,
    IN p_personal_id INT,
    OUT p_mensaje VARCHAR(200)
)
proc_label: BEGIN
    DECLARE v_isbn VARCHAR(20);
    DECLARE v_socio_id INT;
    DECLARE v_fecha_devolucion DATE;
    DECLARE v_dias_retraso INT;
    DECLARE v_importe_multa DECIMAL(10,2);
    DECLARE v_multa_maxima DECIMAL(10,2) DEFAULT 30.00;
    DECLARE v_tarifa_diaria DECIMAL(10,2) DEFAULT 0.50;
    
    -- Inicializar variable de salida
    SET p_mensaje = '';
    
    -- Obtener datos del préstamo
    SELECT isbn, socio_id, fecha_devolucion INTO v_isbn, v_socio_id, v_fecha_devolucion
    FROM PRESTAMOS WHERE prestamo_id = p_prestamo_id AND estado = 'Activo';
    
    IF v_isbn IS NULL THEN
        SET p_mensaje = 'ERROR: Préstamo no encontrado o ya fue devuelto';
        LEAVE proc_label;
    END IF;
    
    -- Calcular días de retraso
    SET v_dias_retraso = DATEDIFF(CURDATE(), v_fecha_devolucion);
    
    -- Procesar devolución con transacción
    START TRANSACTION;
    
    -- Actualizar préstamo
    UPDATE PRESTAMOS 
    SET fecha_devolucion_real = CURDATE(),
        estado = 'Devuelto'
    WHERE prestamo_id = p_prestamo_id;
    
    -- Actualizar stock del libro
    UPDATE LIBROS 
    SET stock_disponible = stock_disponible + 1,
        estado = 'Disponible'
    WHERE isbn = v_isbn;
    
    -- Generar multa si hay retraso
    IF v_dias_retraso > 0 THEN
        SET v_importe_multa = LEAST(v_dias_retraso * v_tarifa_diaria, v_multa_maxima);
        
        INSERT INTO MULTAS (prestamo_id, importe, estado)
        VALUES (p_prestamo_id, v_importe_multa, 'Pendiente');
        
        -- Actualizar multa acumulada del socio
        UPDATE SOCIOS 
        SET multa_acumulada = multa_acumulada + v_importe_multa
        WHERE socio_id = v_socio_id;
        
        SET p_mensaje = CONCAT('✓ Devolución registrada con multa de ', v_importe_multa, '€ por ', v_dias_retraso, ' días de retraso');
    ELSE
        SET p_mensaje = '✓ Devolución registrada exitosamente (sin retraso)';
    END IF;
    
    COMMIT;
    
END$$

-- =====================================================
-- 3. SP: sp_procesar_reservas_pendientes
-- DESCRIPCIÓN: Procesa reservas cuando un libro se hace disponible
-- =====================================================
CREATE PROCEDURE sp_procesar_reservas_pendientes(
    IN p_isbn VARCHAR(20)
)
proc_label: BEGIN
    DECLARE v_reserva_id INT;
    DECLARE v_socio_id INT;
    DECLARE v_socio_email VARCHAR(100);
    DECLARE v_dias_caducidad INT DEFAULT 3;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor para obtener la primera reserva pendiente del libro (FIFO)
    DECLARE cur_reservas CURSOR FOR
        SELECT r.reserva_id, r.socio_id, s.email
        FROM RESERVAS r
        JOIN SOCIOS s ON r.socio_id = s.socio_id
        WHERE r.isbn = p_isbn AND r.estado = 'Pendiente'
        ORDER BY r.fecha_reserva ASC
        LIMIT 1;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Verificar que el libro tiene stock disponible
    IF NOT EXISTS (SELECT 1 FROM LIBROS WHERE isbn = p_isbn AND stock_disponible > 0) THEN
        LEAVE proc_label;
    END IF;
    
    OPEN cur_reservas;
    FETCH cur_reservas INTO v_reserva_id, v_socio_id, v_socio_email;
    
    IF NOT done THEN
        -- Actualizar reserva a "Disponible para retiro"
        UPDATE RESERVAS 
        SET estado = 'Disponible', 
            fecha_caducidad = DATE_ADD(CURDATE(), INTERVAL v_dias_caducidad DAY)
        WHERE reserva_id = v_reserva_id;
        
        -- Aquí iría la lógica de notificación (email, SMS)
        -- Por ahora, solo registramos en una tabla de notificaciones
        INSERT INTO NOTIFICACIONES (socio_id, tipo, mensaje, fecha_envio)
        VALUES (v_socio_id, 'Reserva', 
                CONCAT('El libro ISBN:', p_isbn, ' está disponible para retiro. Tiene ', v_dias_caducidad, ' días.'),
                CURDATE());
    END IF;
    
    CLOSE cur_reservas;
    
END$$

-- =====================================================
-- 4. SP: sp_reporte_estadisticas_mensual
-- DESCRIPCIÓN: Genera reporte estadístico mensual
-- =====================================================
CREATE PROCEDURE sp_reporte_estadisticas_mensual(
    IN p_mes INT,
    IN p_anio INT,
    OUT p_total_prestamos INT,
    OUT p_total_multas DECIMAL(10,2),
    OUT p_libro_mas_popular VARCHAR(200)
)
proc_label: BEGIN
    -- Validar parámetros
    IF p_mes < 1 OR p_mes > 12 THEN
        SET p_total_prestamos = NULL;
        SET p_total_multas = NULL;
        SET p_libro_mas_popular = 'ERROR: Mes inválido';
        LEAVE proc_label;
    END IF;
    
    IF p_anio < 2020 OR p_anio > YEAR(CURDATE()) THEN
        SET p_total_prestamos = NULL;
        SET p_total_multas = NULL;
        SET p_libro_mas_popular = 'ERROR: Año inválido';
        LEAVE proc_label;
    END IF;
    
    -- Total de préstamos en el período
    SELECT COUNT(*) INTO p_total_prestamos
    FROM PRESTAMOS
    WHERE MONTH(fecha_prestamo) = p_mes 
      AND YEAR(fecha_prestamo) = p_anio;
    
    -- Total de multas generadas
    SELECT COALESCE(SUM(importe), 0) INTO p_total_multas
    FROM MULTAS
    WHERE MONTH(fecha_generacion) = p_mes 
      AND YEAR(fecha_generacion) = p_anio;
    
    -- Libro más popular
    SELECT l.titulo INTO p_libro_mas_popular
    FROM PRESTAMOS p
    JOIN LIBROS l ON p.isbn = l.isbn
    WHERE MONTH(p.fecha_prestamo) = p_mes 
      AND YEAR(p.fecha_prestamo) = p_anio
    GROUP BY l.isbn, l.titulo
    ORDER BY COUNT(*) DESC
    LIMIT 1;
    
    IF p_libro_mas_popular IS NULL THEN
        SET p_libro_mas_popular = 'No hay datos para el período';
    END IF;
    
END$$

-- =====================================================
-- 5. SP: sp_pagar_multa
-- DESCRIPCIÓN: Procesa el pago de una multa
-- =====================================================
CREATE PROCEDURE sp_pagar_multa(
    IN p_multa_id INT,
    OUT p_mensaje VARCHAR(200)
)
proc_label: BEGIN
    DECLARE v_prestamo_id INT;
    DECLARE v_importe DECIMAL(10,2);
    DECLARE v_socio_id INT;
    DECLARE v_multa_acumulada_actual DECIMAL(10,2);
    
    -- Inicializar variable de salida
    SET p_mensaje = '';
    
    -- Obtener datos de la multa
    SELECT prestamo_id, importe INTO v_prestamo_id, v_importe
    FROM MULTAS WHERE multa_id = p_multa_id AND estado = 'Pendiente';
    
    IF v_prestamo_id IS NULL THEN
        SET p_mensaje = 'ERROR: Multa no encontrada o ya fue pagada';
        LEAVE proc_label;
    END IF;
    
    -- Obtener socio del préstamo
    SELECT socio_id INTO v_socio_id
    FROM PRESTAMOS WHERE prestamo_id = v_prestamo_id;
    
    -- Procesar pago con transacción
    START TRANSACTION;
    
    -- Actualizar multa
    UPDATE MULTAS 
    SET estado = 'Pagada',
        fecha_pago = CURDATE()
    WHERE multa_id = p_multa_id;
    
    -- Actualizar multa acumulada del socio
    SELECT multa_acumulada INTO v_multa_acumulada_actual
    FROM SOCIOS WHERE socio_id = v_socio_id;
    
    UPDATE SOCIOS 
    SET multa_acumulada = GREATEST(v_multa_acumulada_actual - v_importe, 0)
    WHERE socio_id = v_socio_id;
    
    COMMIT;
    SET p_mensaje = CONCAT('✓ Multa de ', v_importe, '€ pagada exitosamente');
    
END$$

-- =====================================================
-- 6. SP: sp_actualizar_datos_socio
-- DESCRIPCIÓN: Actualiza datos de un socio con validaciones
-- =====================================================
CREATE PROCEDURE sp_actualizar_datos_socio(
    IN p_socio_id INT,
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    OUT p_mensaje VARCHAR(200)
)
proc_label: BEGIN
    -- Validar que el email no exista para otro socio
    IF EXISTS (SELECT 1 FROM SOCIOS WHERE email = p_email AND socio_id != p_socio_id) THEN
        SET p_mensaje = 'ERROR: El email ya está registrado por otro socio';
        LEAVE proc_label;
    END IF;
    
    -- Actualizar datos del socio
    UPDATE SOCIOS 
    SET email = p_email,
        telefono = p_telefono,
        fecha_registro = fecha_registro -- Mantener fecha original
    WHERE socio_id = p_socio_id;
    
    IF ROW_COUNT() = 0 THEN
        SET p_mensaje = 'ERROR: Socio no encontrado';
    ELSE
        SET p_mensaje = '✓ Datos del socio actualizados exitosamente';
    END IF;
    
END$$

-- =====================================================
-- 7. SP: sp_generar_reserva
-- DESCRIPCIÓN: Genera una reserva para un libro no disponible
-- =====================================================
CREATE PROCEDURE sp_generar_reserva(
    IN p_socio_id INT,
    IN p_isbn VARCHAR(20),
    OUT p_reserva_id INT,
    OUT p_mensaje VARCHAR(200)
)
proc_label: BEGIN
    DECLARE v_stock_disponible INT;
    DECLARE v_socio_estado VARCHAR(20);
    DECLARE v_reservas_activas INT;
    DECLARE v_limite_reservas INT DEFAULT 2;
    
    -- Inicializar variables de salida
    SET p_reserva_id = NULL;
    SET p_mensaje = '';
    
    -- Validar socio
    SELECT estado INTO v_socio_estado
    FROM SOCIOS WHERE socio_id = p_socio_id;
    
    IF v_socio_estado IS NULL THEN
        SET p_mensaje = 'ERROR: Socio no encontrado';
        LEAVE proc_label;
    END IF;
    
    IF v_socio_estado != 'Activo' THEN
        SET p_mensaje = 'ERROR: Socio no está activo';
        LEAVE proc_label;
    END IF;
    
    -- Validar límite de reservas
    SELECT COUNT(*) INTO v_reservas_activas
    FROM RESERVAS
    WHERE socio_id = p_socio_id AND estado = 'Pendiente';
    
    IF v_reservas_activas >= v_limite_reservas THEN
        SET p_mensaje = CONCAT('ERROR: Límite de ', v_limite_reservas, ' reservas simultáneas alcanzado');
        LEAVE proc_label;
    END IF;
    
    -- Verificar disponibilidad del libro
    SELECT stock_disponible INTO v_stock_disponible
    FROM LIBROS WHERE isbn = p_isbn;
    
    IF v_stock_disponible IS NULL THEN
        SET p_mensaje = 'ERROR: Libro no encontrado';
        LEAVE proc_label;
    END IF;
    
    IF v_stock_disponible > 0 THEN
        SET p_mensaje = 'INFO: El libro está disponible para préstamo inmediato';
        LEAVE proc_label;
    END IF;
    
    -- Insertar reserva
    INSERT INTO RESERVAS (socio_id, isbn, fecha_caducidad)
    VALUES (p_socio_id, p_isbn, DATE_ADD(CURDATE(), INTERVAL 7 DAY));
    
    SET p_reserva_id = LAST_INSERT_ID();
    SET p_mensaje = '✓ Reserva generada exitosamente';
    
END$$

-- =====================================================
-- 8. SP: sp_reporte_morosidad
-- DESCRIPCIÓN: Genera reporte de socios morosos
-- =====================================================
CREATE PROCEDURE sp_reporte_morosidad(
    OUT p_total_socios INT,
    OUT p_total_multas DECIMAL(10,2)
)
proc_label: BEGIN
    -- Calcular totales
    SELECT COUNT(DISTINCT s.socio_id), COALESCE(SUM(s.multa_acumulada), 0)
    INTO p_total_socios, p_total_multas
    FROM SOCIOS s
    WHERE s.multa_acumulada > 0;
    
    -- Devolver listado detallado
    SELECT 
        s.socio_id,
        CONCAT(s.nombre, ' ', s.apellido) as nombre_completo,
        s.email,
        s.multa_acumulada,
        COUNT(p.prestamo_id) as total_prestamos,
        SUM(CASE WHEN p.estado = 'Activo' THEN 1 ELSE 0 END) as prestamos_activos
    FROM SOCIOS s
    LEFT JOIN PRESTAMOS p ON s.socio_id = p.socio_id
    WHERE s.multa_acumulada > 0
    GROUP BY s.socio_id, s.nombre, s.apellido, s.email, s.multa_acumulada
    ORDER BY s.multa_acumulada DESC;
    
END$$

DELIMITER ;

-- =====================================================
-- 9. TABLA DE NOTIFICACIONES (para el sistema de reservas)
-- =====================================================
CREATE TABLE IF NOT EXISTS NOTIFICACIONES (
    notificacion_id INT PRIMARY KEY AUTO_INCREMENT,
    socio_id INT NOT NULL,
    tipo VARCHAR(50),
    mensaje VARCHAR(500),
    fecha_envio DATE,
    estado ENUM('Pendiente', 'Enviada', 'Leída') DEFAULT 'Pendiente',
    FOREIGN KEY (socio_id) REFERENCES SOCIOS(socio_id),
    INDEX idx_notificaciones_socio (socio_id),
    INDEX idx_notificaciones_fecha (fecha_envio)
);

-- Mensaje de confirmación
SELECT '✓ Stored Procedures creados exitosamente' as Estado;
SELECT '✓ Total SPs: 8 procedimientos con transacciones' as Resumen;
SELECT '✓ Tabla de notificaciones creada' as Detalles;