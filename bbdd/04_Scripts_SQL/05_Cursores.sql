-- ===================================================================
-- SCRIPT: 05_Cursores.sql
-- PROYECTO: Sistema de Gestión de Biblioteca
-- DESCRIPCIÓN: Cursores con procesamiento masivo de datos
-- FECHA: Noviembre 2025
-- ===================================================================

DELIMITER $$

-- =====================================================
-- 1. SP: sp_actualizar_multas_diarias
-- DESCRIPCIÓN: Actualiza multas diariamente usando cursor para préstamos vencidos
-- =====================================================
CREATE PROCEDURE sp_actualizar_multas_diarias()
proc_label: BEGIN
    DECLARE v_prestamo_id INT;
    DECLARE v_dias_retraso INT;
    DECLARE v_multa_existente DECIMAL(10,2);
    DECLARE v_importe_calculado DECIMAL(10,2);
    DECLARE v_tarifa_diaria DECIMAL(10,2) DEFAULT 0.50;
    DECLARE v_multa_maxima DECIMAL(10,2) DEFAULT 30.00;
    DECLARE v_total_actualizados INT DEFAULT 0;
    DECLARE v_total_nuevos INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor para préstamos vencidos sin multa o con multa desactualizada
    DECLARE cur_prestamos_vencidos CURSOR FOR
        SELECT p.prestamo_id, DATEDIFF(CURDATE(), p.fecha_devolucion)
        FROM PRESTAMOS p
        LEFT JOIN MULTAS m ON p.prestamo_id = m.prestamo_id AND m.estado = 'Pendiente'
        WHERE p.estado = 'Activo' 
          AND p.fecha_devolucion < CURDATE()
          AND (m.multa_id IS NULL OR m.importe != DATEDIFF(CURDATE(), p.fecha_devolucion) * v_tarifa_diaria);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_prestamos_vencidos;
    
    read_loop: LOOP
        FETCH cur_prestamos_vencidos INTO v_prestamo_id, v_dias_retraso;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calcular importe de la multa
        SET v_importe_calculado = LEAST(v_dias_retraso * v_tarifa_diaria, v_multa_maxima);
        
        -- Verificar si ya existe multa para este préstamo
        SELECT importe INTO v_multa_existente
        FROM MULTAS
        WHERE prestamo_id = v_prestamo_id AND estado = 'Pendiente'
        LIMIT 1;
        
        IF v_multa_existente IS NULL THEN
            -- Insertar nueva multa
            INSERT INTO MULTAS (prestamo_id, importe, estado)
            VALUES (v_prestamo_id, v_importe_calculado, 'Pendiente');
            
            SET v_total_nuevos = v_total_nuevos + 1;
        ELSEIF v_multa_existente != v_importe_calculado THEN
            -- Actualizar multa existente
            UPDATE MULTAS
            SET importe = v_importe_calculado
            WHERE prestamo_id = v_prestamo_id AND estado = 'Pendiente';
            
            SET v_total_actualizados = v_total_actualizados + 1;
        END IF;
        
    END LOOP;
    
    CLOSE cur_prestamos_vencidos;
    
    -- Mensaje de resumen
    SELECT CONCAT('✓ Proceso completado: ', v_total_nuevos, ' nuevas multas, ', v_total_actualizados, ' actualizadas') as resultado;
    
END$$

-- =====================================================
-- 2. SP: sp_generar_reporte_morosidad_detallado
-- DESCRIPCIÓN: Genera reporte detallado de morosidad usando cursor
-- =====================================================
CREATE PROCEDURE sp_generar_reporte_morosidad_detallado(
    OUT p_total_socios_morosos INT,
    OUT p_total_multas_generadas DECIMAL(10,2)
)
proc_label: BEGIN
    DECLARE v_socio_id INT;
    DECLARE v_total_multas_socio DECIMAL(10,2);
    DECLARE v_nombre_socio VARCHAR(200);
    DECLARE v_email_socio VARCHAR(100);
    DECLARE v_prestamos_activos INT;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor para recorrer socios con multas
    DECLARE cur_socios_multas CURSOR FOR
        SELECT socio_id, SUM(importe) as total_multas
        FROM MULTAS m
        JOIN PRESTAMOS p ON m.prestamo_id = p.prestamo_id
        WHERE m.estado = 'Pendiente'
        GROUP BY socio_id
        HAVING total_multas > 0
        ORDER BY total_multas DESC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Tabla temporal para resultados
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_morosidad_detalle (
        socio_id INT,
        nombre_completo VARCHAR(200),
        email VARCHAR(100),
        total_multas DECIMAL(10,2),
        cantidad_prestamos INT,
        cantidad_multas INT,
        nivel_morosidad VARCHAR(20)
    );
    
    OPEN cur_socios_multas;
    
    read_loop: LOOP
        FETCH cur_socios_multas INTO v_socio_id, v_total_multas_socio;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Obtener detalles del socio
        SELECT 
            CONCAT(s.nombre, ' ', s.apellido),
            s.email,
            COUNT(DISTINCT p.prestamo_id),
            COUNT(DISTINCT m.multa_id)
        INTO v_nombre_socio, v_email_socio, v_prestamos_activos, @v_cantidad_multas
        FROM SOCIOS s
        LEFT JOIN PRESTAMOS p ON s.socio_id = p.socio_id
        LEFT JOIN MULTAS m ON p.prestamo_id = m.prestamo_id AND m.estado = 'Pendiente'
        WHERE s.socio_id = v_socio_id
        GROUP BY s.socio_id, s.nombre, s.apellido, s.email;
        
        -- Insertar en tabla temporal con nivel de morosidad
        INSERT INTO temp_morosidad_detalle
        VALUES (
            v_socio_id,
            v_nombre_socio,
            v_email_socio,
            v_total_multas_socio,
            v_prestamos_activos,
            @v_cantidad_multas,
            CASE 
                WHEN v_total_multas_socio > 20 THEN 'Alto'
                WHEN v_total_multas_socio > 10 THEN 'Medio'
                ELSE 'Bajo'
            END
        );
        
    END LOOP;
    
    CLOSE cur_socios_multas;
    
    -- Calcular totales
    SELECT COUNT(*), COALESCE(SUM(total_multas), 0) 
    INTO p_total_socios_morosos, p_total_multas_generadas
    FROM temp_morosidad_detalle;
    
    -- Mostrar resultados detallados
    SELECT * FROM temp_morosidad_detalle ORDER BY total_multas DESC;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE IF EXISTS temp_morosidad_detalle;
    
END$$

-- =====================================================
-- 3. SP: sp_actualizar_estado_reservas
-- DESCRIPCIÓN: Actualiza estado de reservas vencidas usando cursor
-- =====================================================
CREATE PROCEDURE sp_actualizar_estado_reservas()
proc_label: BEGIN
    DECLARE v_reserva_id INT;
    DECLARE v_socio_id INT;
    DECLARE v_isbn VARCHAR(20);
    DECLARE v_total_vencidas INT DEFAULT 0;
    DECLARE v_total_procesadas INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor para reservas pendientes vencidas
    DECLARE cur_reservas_vencidas CURSOR FOR
        SELECT reserva_id, socio_id, isbn
        FROM RESERVAS
        WHERE estado = 'Pendiente' AND fecha_caducidad < CURDATE();
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_reservas_vencidas;
    
    read_loop: LOOP
        FETCH cur_reservas_vencidas INTO v_reserva_id, v_socio_id, v_isbn;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_total_vencidas = v_total_vencidas + 1;
        
        -- Actualizar estado a Vencida
        UPDATE RESERVAS 
        SET estado = 'Vencida'
        WHERE reserva_id = v_reserva_id;
        
        -- Notificar al socio (registrar en tabla de notificaciones)
        INSERT INTO NOTIFICACIONES (socio_id, tipo, mensaje, fecha_envio)
        VALUES (v_socio_id, 'Reserva Vencida', 
                CONCAT('Su reserva para el libro ISBN:', v_isbn, ' ha vencido'),
                CURDATE());
        
        SET v_total_procesadas = v_total_procesadas + 1;
        
    END LOOP;
    
    CLOSE cur_reservas_vencidas;
    
    -- Mensaje de resumen
    SELECT CONCAT('✓ Proceso completado: ', v_total_vencidas, ' reservas vencidas procesadas') as resultado;
    
END$$

-- =====================================================
-- 4. SP: sp_generar_informe_inventario
-- DESCRIPCIÓN: Genera informe completo de inventario usando cursor
-- =====================================================
CREATE PROCEDURE sp_generar_informe_inventario(
    OUT p_total_libros INT,
    OUT p_total_ejemplares INT,
    OUT p_valor_estimado DECIMAL(12,2)
)
proc_label: BEGIN
    DECLARE v_isbn VARCHAR(20);
    DECLARE v_titulo VARCHAR(200);
    DECLARE v_stock_total INT;
    DECLARE v_stock_disponible INT;
    DECLARE v_precio_estimado DECIMAL(10,2);
    DECLARE v_total_libros_proc INT DEFAULT 0;
    DECLARE v_total_ejemplares_proc INT DEFAULT 0;
    DECLARE v_valor_total DECIMAL(12,2) DEFAULT 0.00;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor para recorrer todos los libros
    DECLARE cur_inventario CURSOR FOR
        SELECT isbn, titulo, stock_total, stock_disponible
        FROM LIBROS
        ORDER BY titulo;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Tabla temporal para resultados detallados
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_inventario_detalle (
        isbn VARCHAR(20),
        titulo VARCHAR(200),
        stock_total INT,
        stock_disponible INT,
        stock_prestado INT,
        precio_estimado DECIMAL(10,2),
        valor_total DECIMAL(12,2),
        porcentaje_disponible DECIMAL(5,2)
    );
    
    OPEN cur_inventario;
    
    read_loop: LOOP
        FETCH cur_inventario INTO v_isbn, v_titulo, v_stock_total, v_stock_disponible;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_total_libros_proc = v_total_libros_proc + 1;
        SET v_total_ejemplares_proc = v_total_ejemplares_proc + v_stock_total;
        
        -- Calcular precio estimado (base: 15€ + 0.10€ por año de antigüedad)
        SET v_precio_estimado = 15.00 + (YEAR(CURDATE()) - 2000) * 0.10;
        
        -- Calcular valor total
        SET v_valor_total = v_valor_total + (v_stock_total * v_precio_estimado);
        
        -- Insertar en tabla temporal
        INSERT INTO temp_inventario_detalle
        VALUES (
            v_isbn,
            v_titulo,
            v_stock_total,
            v_stock_disponible,
            v_stock_total - v_stock_disponible,
            v_precio_estimado,
            v_stock_total * v_precio_estimado,
            CASE WHEN v_stock_total > 0 THEN (v_stock_disponible * 100.0 / v_stock_total) ELSE 0 END
        );
        
    END LOOP;
    
    CLOSE cur_inventario;
    
    -- Asignar valores de salida
    SET p_total_libros = v_total_libros_proc;
    SET p_total_ejemplares = v_total_ejemplares_proc;
    SET p_valor_estimado = v_valor_total;
    
    -- Mostrar resultados detallados
    SELECT * FROM temp_inventario_detalle ORDER BY valor_total DESC;
    
    -- Mostrar resumen por editorial
    SELECT 
        e.nombre as editorial,
        COUNT(DISTINCT l.isbn) as cantidad_libros,
        SUM(l.stock_total) as total_ejemplares,
        SUM(l.stock_disponible) as disponibles,
        ROUND(AVG((l.stock_disponible * 100.0 / l.stock_total)), 2) as porcentaje_disponible
    FROM LIBROS l
    JOIN EDITORIALES e ON l.editorial_id = e.editorial_id
    GROUP BY e.editorial_id, e.nombre
    ORDER BY total_ejemplares DESC;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE IF EXISTS temp_inventario_detalle;
    
END$$

-- =====================================================
-- 5. SP: sp_procesar_renovaciones_automaticas
-- DESCRIPCIÓN: Procesa renovaciones automáticas para préstamos sin reservas
-- =====================================================
CREATE PROCEDURE sp_procesar_renovaciones_automaticas(
    IN p_dias_extension INT,
    OUT p_total_renovados INT
)
proc_label: BEGIN
    DECLARE v_prestamo_id INT;
    DECLARE v_isbn VARCHAR(20);
    DECLARE v_socio_id INT;
    DECLARE v_fecha_devolucion_actual DATE;
    DECLARE v_tiene_reservas INT;
    DECLARE v_total_renovados_proc INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor para préstamos activos sin reservas pendientes
    DECLARE cur_prestamos_renovables CURSOR FOR
        SELECT p.prestamo_id, p.isbn, p.socio_id, p.fecha_devolucion
        FROM PRESTAMOS p
        WHERE p.estado = 'Activo' 
          AND p.fecha_devolucion >= CURDATE()
          AND NOT EXISTS (
              SELECT 1 FROM RESERVAS r 
              WHERE r.isbn = p.isbn AND r.estado = 'Pendiente'
          );
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET p_total_renovados = 0;
    
    OPEN cur_prestamos_renovables;
    
    read_loop: LOOP
        FETCH cur_prestamos_renovables INTO v_prestamo_id, v_isbn, v_socio_id, v_fecha_devolucion_actual;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Verificar que el socio no tenga multas pendientes > 5€
        IF NOT EXISTS (
            SELECT 1 FROM SOCIOS s 
            WHERE s.socio_id = v_socio_id AND s.multa_acumulada > 5.00
        ) THEN
            -- Renovar préstamo
            UPDATE PRESTAMOS 
            SET fecha_devolucion = DATE_ADD(v_fecha_devolucion_actual, INTERVAL p_dias_extension DAY)
            WHERE prestamo_id = v_prestamo_id;
            
            SET v_total_renovados_proc = v_total_renovados_proc + 1;
            
            -- Notificar al socio
            INSERT INTO NOTIFICACIONES (socio_id, tipo, mensaje, fecha_envio)
            VALUES (v_socio_id, 'Renovación', 
                    CONCAT('Su préstamo del libro ISBN:', v_isbn, ' ha sido renovado por ', p_dias_extension, ' días'),
                    CURDATE());
        END IF;
        
    END LOOP;
    
    CLOSE cur_prestamos_renovables;
    
    SET p_total_renovados = v_total_renovados_proc;
    
    -- Mensaje de resumen
    SELECT CONCAT('✓ Renovaciones procesadas: ', v_total_renovados_proc, ' préstamos renovados') as resultado;
    
END$$

DELIMITER ;

-- Mensaje de confirmación
SELECT '✓ Cursores creados exitosamente' as Estado;
SELECT '✓ Total procedimientos: 5 cursores con procesamiento masivo' as Resumen;
SELECT '✓ Procesamiento de multas, reservas, inventario y renovaciones' as Detalles;