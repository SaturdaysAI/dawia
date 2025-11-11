-- ===================================================================
-- SCRIPT: 02_DML_Datos_Prueba.sql
-- PROYECTO: Sistema de Gestión de Biblioteca
-- DESCRIPCIÓN: Inserción de datos de prueba para todas las tablas
-- FECHA: Noviembre 2025
-- ===================================================================

-- =====================================================
-- 1. DATOS DE EDITORIALES (15 registros)
-- =====================================================
INSERT INTO EDITORIALES (nombre, pais) VALUES
('Alianza Editorial', 'España'),
('Penguin Random House', 'Estados Unidos'),
('Planeta', 'España'),
('Anagrama', 'España'),
('Alfaguara', 'España'),
('Salamandra', 'España'),
('Destino', 'España'),
('Espasa', 'España'),
('Santillana', 'España'),
('Cátedra', 'España'),
('Debolsillo', 'España'),
('RBA', 'España'),
('Grijalbo', 'España'),
('Seix Barral', 'España'),
('Tusquets Editores', 'España');

-- =====================================================
-- 2. DATOS DE GÉNEROS (12 registros)
-- =====================================================
INSERT INTO GENEROS (nombre, descripcion) VALUES
('Narrativa', 'Obras de ficción narrativa'),
('Poesía', 'Obras poéticas y versos'),
('Teatro', 'Obras dramáticas para representación'),
('Ensayo', 'Obras de reflexión y análisis'),
('Biografía', 'Vidas de personajes históricos'),
('Historia', 'Obras históricas y documentales'),
('Ciencia', 'Divulgación científica'),
('Filosofía', 'Pensamiento filosófico'),
('Infantil', 'Literatura para niños'),
('Juvenil', 'Literatura para jóvenes'),
('Terror', 'Narrativa de terror y suspense'),
('Ciencia Ficción', 'Narrativa de ciencia ficción');

-- =====================================================
-- 3. DATOS DE AUTORES (25 registros)
-- =====================================================
INSERT INTO AUTORES (nombre, apellido, nacionalidad, fecha_nacimiento) VALUES
('Gabriel', 'García Márquez', 'Colombiana', '1927-03-06'),
('Mario', 'Vargas Llosa', 'Peruana', '1936-03-28'),
('Jorge Luis', 'Borges', 'Argentina', '1899-08-24'),
('Julio', 'Cortázar', 'Argentina', '1914-08-26'),
('Pablo', 'Neruda', 'Chilena', '1904-07-12'),
('Federico', 'García Lorca', 'Española', '1898-06-05'),
('Miguel', 'de Cervantes', 'Española', '1547-09-29'),
('Lope', 'de Vega', 'Española', '1562-11-25'),
('Antonio', 'Machado', 'Española', '1875-07-26'),
('Juan', 'Ramón Jiménez', 'Española', '1881-12-23'),
('José', 'Martí', 'Cubana', '1853-01-28'),
('Isabel', 'Allende', 'Chilena', '1942-08-02'),
('Carlos', 'Fuentes', 'Mexicana', '1928-11-11'),
('Octavio', 'Paz', 'Mexicana', '1914-03-31'),
('Jorge', 'Amado', 'Brasileña', '1912-08-10'),
('Claribel', 'Alegría', 'Nicaragüense', '1924-05-12'),
('Carlos', 'Ruiz Zafón', 'Española', '1964-09-25'),
('Arturo', 'Pérez-Reverte', 'Española', '1951-11-25'),
('Javier', 'Marías', 'Española', '1951-09-20'),
('Almudena', 'Grandes', 'Española', '1960-05-07'),
('Rosa', 'Montero', 'Española', '1951-01-03'),
('Juan', 'Goytisolo', 'Española', '1931-01-05'),
('Camilo', 'José Cela', 'Española', '1916-05-11'),
('Ana', 'María Matute', 'Española', '1925-07-26'),
('Carmen', 'Martín Gaite', 'Española', '1925-12-08');

-- =====================================================
-- 4. DATOS DE LIBROS (30 registros)
-- =====================================================
INSERT INTO LIBROS (isbn, titulo, editorial_id, genero_id, anio_publicacion, stock_total, stock_disponible, estado) VALUES
('978-84-206-8178-1', 'Cien años de soledad', 1, 1, 1967, 5, 3, 'Disponible'),
('978-84-339-7263-5', 'La ciudad y los perros', 2, 1, 1963, 4, 2, 'Disponible'),
('978-84-204-8147-2', 'Ficciones', 3, 1, 1944, 3, 1, 'Disponible'),
('978-84-322-2263-8', 'Rayuela', 4, 1, 1963, 4, 0, 'Prestado'),
('978-84-322-2264-5', 'Veinte poemas de amor', 5, 2, 1924, 6, 4, 'Disponible'),
('978-84-322-2265-2', 'Romancero gitano', 6, 2, 1928, 3, 2, 'Disponible'),
('978-84-206-8179-8', 'Don Quijote de la Mancha', 7, 1, 1605, 8, 5, 'Disponible'),
('978-84-339-7264-2', 'Fuenteovejuna', 8, 3, 1619, 2, 1, 'Disponible'),
('978-84-204-8148-9', 'Campos de Castilla', 9, 2, 1912, 4, 3, 'Disponible'),
('978-84-322-2266-9', 'Platero y yo', 10, 2, 1914, 5, 4, 'Disponible'),
('978-84-322-2267-6', 'Versos sencillos', 11, 2, 1891, 3, 2, 'Disponible'),
('978-84-206-8180-4', 'La casa de los espíritus', 12, 1, 1982, 4, 2, 'Disponible'),
('978-84-339-7265-9', 'La región más transparente', 13, 1, 1958, 3, 1, 'Disponible'),
('978-84-204-8149-6', 'El laberinto de la soledad', 14, 4, 1950, 4, 3, 'Disponible'),
('978-84-322-2268-3', 'Dona Flor y sus dos maridos', 15, 1, 1966, 3, 2, 'Disponible'),
('978-84-206-8181-1', 'Cenizas de Izalco', 1, 1, 1966, 2, 1, 'Disponible'),
('978-84-339-7266-6', 'La sombra del viento', 2, 1, 2001, 6, 3, 'Disponible'),
('978-84-204-8150-2', 'El capitán Alatriste', 3, 1, 1996, 5, 2, 'Disponible'),
('978-84-322-2269-0', 'Corazón tan blanco', 4, 1, 1992, 4, 1, 'Disponible'),
('978-84-206-8182-8', 'Los aires difíciles', 5, 1, 2002, 3, 2, 'Disponible'),
('978-84-339-7267-3', 'La loca de la casa', 6, 1, 2003, 4, 3, 'Disponible'),
('978-84-204-8151-9', 'Señas de identidad', 7, 1, 1966, 2, 1, 'Disponible'),
('978-84-322-2270-6', 'La familia de Pascual Duarte', 8, 1, 1942, 3, 2, 'Disponible'),
('978-84-206-8183-5', 'Primera memoria', 9, 1, 1960, 4, 2, 'Disponible'),
('978-84-339-7268-0', 'El cuarto de atrás', 10, 1, 1978, 3, 1, 'Disponible'),
('978-84-204-8152-6', 'El Aleph', 11, 1, 1949, 5, 3, 'Disponible'),
('978-84-322-2271-3', 'Bestiario', 12, 1, 1951, 2, 1, 'Disponible'),
('978-84-206-8184-2', 'Cuentos de la selva', 13, 9, 1918, 4, 4, 'Disponible'),
('978-84-339-7269-7', 'Frankenstein', 14, 11, 1818, 3, 2, 'Disponible'),
('978-84-204-8153-3', '1984', 15, 12, 1949, 6, 4, 'Disponible');

-- =====================================================
-- 5. RELACIÓN LIBRO-AUTOR (muchos a muchos)
-- =====================================================
INSERT INTO LIBRO_AUTOR (isbn, autor_id) VALUES
('978-84-206-8178-1', 1), ('978-84-339-7263-5', 2), ('978-84-204-8147-2', 3),
('978-84-322-2263-8', 4), ('978-84-322-2264-5', 5), ('978-84-322-2265-2', 6),
('978-84-206-8179-8', 7), ('978-84-339-7264-2', 8), ('978-84-204-8148-9', 9),
('978-84-322-2266-9', 10), ('978-84-322-2267-6', 11), ('978-84-206-8180-4', 12),
('978-84-339-7265-9', 13), ('978-84-204-8149-6', 14), ('978-84-322-2268-3', 15),
('978-84-206-8181-1', 16), ('978-84-339-7266-6', 17), ('978-84-204-8150-2', 18),
('978-84-322-2269-0', 19), ('978-84-206-8182-8', 20), ('978-84-339-7267-3', 21),
('978-84-204-8151-9', 22), ('978-84-322-2270-6', 23), ('978-84-206-8183-5', 24),
('978-84-339-7268-0', 25), ('978-84-204-8152-6', 3), ('978-84-322-2271-3', 4),
('978-84-206-8184-2', 1), ('978-84-339-7269-7', 1), ('978-84-204-8153-3', 1);

-- =====================================================
-- 6. DATOS DE SOCIOS (20 registros)
-- =====================================================
INSERT INTO SOCIOS (nombre, apellido, email, telefono, fecha_registro, estado, multa_acumulada) VALUES
('María', 'García López', 'maria.garcia@email.com', '612345678', '2024-01-15', 'Activo', 0.00),
('Juan', 'Pérez Rodríguez', 'juan.perez@email.com', '623456789', '2024-01-20', 'Activo', 2.50),
('Ana', 'Martínez Sánchez', 'ana.martinez@email.com', '634567890', '2024-02-01', 'Activo', 0.00),
('Carlos', 'González Díaz', 'carlos.gonzalez@email.com', '645678901', '2024-02-10', 'Activo', 5.00),
('Laura', 'Rodríguez Fernández', 'laura.rodriguez@email.com', '656789012', '2024-02-15', 'Activo', 0.00),
('Pedro', 'Sánchez Gómez', 'pedro.sanchez@email.com', '667890123', '2024-03-01', 'Activo', 12.00),
('Sofía', 'Fernández Martín', 'sofia.fernandez@email.com', '678901234', '2024-03-05', 'Activo', 0.00),
('David', 'Gómez Ruiz', 'david.gomez@email.com', '689012345', '2024-03-10', 'Activo', 3.50),
('Elena', 'Martín Jiménez', 'elena.martin@email.com', '690123456', '2024-03-15', 'Activo', 0.00),
('Javier', 'Ruiz Álvarez', 'javier.ruiz@email.com', '601234567', '2024-04-01', 'Activo', 0.00),
('Carmen', 'Jiménez Romero', 'carmen.jimenez@email.com', '612345670', '2024-04-05', 'Activo', 8.00),
('Manuel', 'Álvarez Navarro', 'manuel.alvarez@email.com', '623456781', '2024-04-10', 'Activo', 0.00),
('Isabel', 'Romero Serrano', 'isabel.romero@email.com', '634567892', '2024-04-15', 'Activo', 0.00),
('Francisco', 'Navarro Molina', 'francisco.navarro@email.com', '645678903', '2024-05-01', 'Activo', 15.00),
('Patricia', 'Serrano Delgado', 'patricia.serrano@email.com', '656789014', '2024-05-05', 'Activo', 0.00),
('Roberto', 'Molina Ortiz', 'roberto.molina@email.com', '667890125', '2024-05-10', 'Activo', 0.00),
('Natalia', 'Delgado Castro', 'natalia.delgado@email.com', '678901236', '2024-05-15', 'Activo', 4.00),
('Alberto', 'Ortiz Ramos', 'alberto.ortiz@email.com', '689012347', '2024-06-01', 'Activo', 0.00),
('Silvia', 'Castro Flores', 'silvia.castro@email.com', '690123458', '2024-06-05', 'Activo', 0.00),
('Ricardo', 'Ramos Gutiérrez', 'ricardo.ramos@email.com', '601234569', '2024-06-10', 'Activo', 0.00);

-- =====================================================
-- 7. DATOS DE PERSONAL (8 registros)
-- =====================================================
INSERT INTO PERSONAL (nombre, apellido, rol, email, fecha_contratacion, estado) VALUES
('Margarita', 'Luna Pérez', 'Bibliotecario', 'margarita.luna@biblioteca.com', '2023-01-15', 'Activo'),
('Roberto', 'Solar García', 'Bibliotecario', 'roberto.solar@biblioteca.com', '2023-02-01', 'Activo'),
('Cecilia', 'Estrella Martínez', 'Coordinador', 'cecilia.estrella@biblioteca.com', '2022-11-10', 'Activo'),
('Fernando', 'Nieve Rodríguez', 'Bibliotecario', 'fernando.nieve@biblioteca.com', '2023-03-15', 'Activo'),
('Gloria', 'Montaña Sánchez', 'Bibliotecario', 'gloria.montana@biblioteca.com', '2023-04-01', 'Activo'),
('Hugo', 'Valle Gómez', 'Administrador', 'hugo.valle@biblioteca.com', '2022-09-01', 'Activo'),
('Irene', 'Costa Fernández', 'Bibliotecario', 'irene.costa@biblioteca.com', '2023-05-15', 'Activo'),
('Jorge', 'Río Martín', 'Coordinador', 'jorge.rio@biblioteca.com', '2022-12-01', 'Activo');

-- =====================================================
-- 8. DATOS DE PRÉSTAMOS (15 registros activos y 10 históricos)
-- =====================================================
-- Préstamos activos (15 registros)
INSERT INTO PRESTAMOS (socio_id, isbn, personal_id, fecha_prestamo, fecha_devolucion, fecha_devolucion_real, estado) VALUES
(1, '978-84-206-8178-1', 1, '2024-10-15', '2024-10-30', NULL, 'Activo'),
(2, '978-84-339-7263-5', 2, '2024-10-18', '2024-11-02', NULL, 'Activo'),
(3, '978-84-204-8147-2', 3, '2024-10-20', '2024-11-04', NULL, 'Activo'),
(4, '978-84-322-2264-5', 4, '2024-10-22', '2024-11-06', NULL, 'Activo'),
(5, '978-84-322-2265-2', 5, '2024-10-25', '2024-11-09', NULL, 'Activo'),
(6, '978-84-206-8179-8', 6, '2024-10-28', '2024-11-12', NULL, 'Activo'),
(7, '978-84-339-7264-2', 7, '2024-10-30', '2024-11-14', NULL, 'Activo'),
(8, '978-84-204-8148-9', 1, '2024-11-01', '2024-11-16', NULL, 'Activo'),
(9, '978-84-322-2266-9', 2, '2024-11-03', '2024-11-18', NULL, 'Activo'),
(10, '978-84-322-2267-6', 3, '2024-11-05', '2024-11-20', NULL, 'Activo'),
(11, '978-84-206-8180-4', 4, '2024-11-07', '2024-11-22', NULL, 'Activo'),
(12, '978-84-339-7265-9', 5, '2024-11-08', '2024-11-23', NULL, 'Activo'),
(13, '978-84-204-8149-6', 6, '2024-11-10', '2024-11-25', NULL, 'Activo'),
(14, '978-84-322-2268-3', 7, '2024-11-11', '2024-11-26', NULL, 'Activo'),
(15, '978-84-206-8181-1', 1, '2024-11-12', '2024-11-27', NULL, 'Activo');

-- Préstamos históricos/devueltos (10 registros)
INSERT INTO PRESTAMOS (socio_id, isbn, personal_id, fecha_prestamo, fecha_devolucion, fecha_devolucion_real, estado) VALUES
(1, '978-84-339-7266-6', 2, '2024-09-01', '2024-09-16', '2024-09-15', 'Devuelto'),
(2, '978-84-204-8150-2', 3, '2024-09-05', '2024-09-20', '2024-09-22', 'Devuelto'),
(3, '978-84-322-2269-0', 4, '2024-09-10', '2024-09-25', '2024-09-24', 'Devuelto'),
(4, '978-84-206-8182-8', 5, '2024-09-12', '2024-09-27', '2024-10-01', 'Devuelto'),
(5, '978-84-339-7267-3', 6, '2024-09-15', '2024-09-30', '2024-09-29', 'Devuelto'),
(6, '978-84-204-8151-9', 7, '2024-09-18', '2024-10-03', '2024-10-05', 'Devuelto'),
(7, '978-84-322-2270-6', 1, '2024-09-20', '2024-10-05', '2024-10-04', 'Devuelto'),
(8, '978-84-206-8183-5', 2, '2024-09-22', '2024-10-07', '2024-10-08', 'Devuelto'),
(9, '978-84-339-7268-0', 3, '2024-09-25', '2024-10-10', '2024-10-09', 'Devuelto'),
(10, '978-84-204-8152-6', 4, '2024-09-28', '2024-10-13', '2024-10-12', 'Devuelto');

-- =====================================================
-- 9. DATOS DE RESERVAS (8 registros)
-- =====================================================
INSERT INTO RESERVAS (socio_id, isbn, fecha_reserva, fecha_caducidad, estado) VALUES
(1, '978-84-322-2263-8', '2024-11-01', '2024-11-04', 'Pendiente'),
(2, '978-84-322-2263-8', '2024-11-02', '2024-11-05', 'Pendiente'),
(3, '978-84-339-7266-6', '2024-11-03', '2024-11-06', 'Pendiente'),
(4, '978-84-339-7266-6', '2024-11-04', '2024-11-07', 'Pendiente'),
(5, '978-84-204-8150-2', '2024-11-05', '2024-11-08', 'Pendiente'),
(6, '978-84-322-2269-0', '2024-11-06', '2024-11-09', 'Pendiente'),
(7, '978-84-206-8182-8', '2024-11-07', '2024-11-10', 'Pendiente'),
(8, '978-84-339-7267-3', '2024-11-08', '2024-11-11', 'Pendiente');

-- =====================================================
-- 10. DATOS DE MULTAS (12 registros)
-- =====================================================
INSERT INTO MULTAS (prestamo_id, importe, fecha_generacion, fecha_pago, estado) VALUES
(16, 2.50, '2024-09-16', NULL, 'Pendiente'),
(17, 3.00, '2024-09-22', NULL, 'Pendiente'),
(18, 2.00, '2024-09-25', '2024-09-26', 'Pagada'),
(19, 4.00, '2024-10-01', NULL, 'Pendiente'),
(20, 1.50, '2024-09-29', '2024-09-30', 'Pagada'),
(21, 5.00, '2024-10-05', NULL, 'Pendiente'),
(22, 2.00, '2024-10-04', NULL, 'Pendiente'),
(23, 3.50, '2024-10-08', NULL, 'Pendiente'),
(24, 2.00, '2024-10-09', '2024-10-10', 'Pagada'),
(25, 1.00, '2024-10-12', NULL, 'Pendiente'),
(26, 6.00, '2024-10-15', NULL, 'Pendiente'),
(27, 2.50, '2024-10-18', NULL, 'Pendiente');

-- Mensaje de confirmación
SELECT '✓ Datos de prueba insertados correctamente' as Estado;
SELECT '✓ Total registros: Editoriales(15), Géneros(12), Autores(25), Libros(30), Socios(20), Personal(8)' as Resumen;
SELECT '✓ Préstamos(25), Reservas(8), Multas(12)' as Resumen_Detalles;