# Checklist de Evaluación - Proyecto Sistema de Gestión de Biblioteca

**Asignatura**: Gestión de Bases de Datos  
**Fecha de Evaluación**: [DD/MM/AAAA]

---

## 📋 INFORMACIÓN DEL ALUMNO

**Nombre del Alumno**: _________________________  
**Grupo**: _______  
**Fecha de Entrega**: _________________________  
**Tipo de Evaluación**: ☐ Individual ☐ Grupal (máximo 3 personas)

---

## 🎯 CRITERIOS DE EVALUACIÓN

### 1. ANÁLISIS Y DISEÑO (25 puntos)

#### 1.1 Comprensión del Caso de Negocio (5 puntos)
- [ ] **5 pts**: Demuestra comprensión completa de los requisitos funcionales y no funcionales
- [ ] **3 pts**: Comprende la mayoría de requisitos pero omite algunos detalles importantes
- [ ] **1 pt**: Comprensión superficial o incompleta del caso de negocio
- [ ] **0 pts**: No demuestra comprensión del caso de negocio

**Observaciones**: _________________________

#### 1.2 Modelo Entidad-Relación (10 puntos)
- [ ] **10 pts**: Diagrama ER completo, correcto y bien documentado. Todas las entidades, relaciones y cardinalidades son correctas
- [ ] **7 pts**: Diagrama ER completo con errores menores en cardinalidades o relaciones
- [ ] **4 pts**: Diagrama incompleto o con errores significativos
- [ ] **0 pts**: No presenta diagrama ER o es incorrecto

**Observaciones**: _________________________

#### 1.3 Normalización (10 puntos)
- [ ] **10 pts**: Base de datos en 3FN con justificación clara del proceso. Identifica correctamente dependencias funcionales
- [ ] **7 pts**: Normalización correcta pero justificación incompleta o con errores menores
- [ ] **4 pts**: Normalización incompleta o con errores significativos (1FN o 2FN)
- [ ] **0 pts**: Base de datos desnormalizada sin justificación

**Observaciones**: _________________________

**Subtotal Análisis y Diseño**: _______/25

---

### 2. IMPLEMENTACIÓN SQL (35 puntos)

#### 2.1 Scripts DDL (10 puntos)
- [ ] **10 pts**: Todas las tablas correctamente definidas con claves primarias, foráneas, constraints y tipos de datos apropiados
- [ ] **7 pts**: Tablas definidas con errores menores (faltan algunos constraints o índices)
- [ ] **4 pts**: Tablas con errores significativos (faltan claves foráneas o constraints importantes)
- [ ] **0 pts**: Scripts DDL incompletos o con errores graves

**Observaciones**: _________________________

#### 2.2 Scripts DML y Datos de Prueba (5 puntos)
- [ ] **5 pts**: Datos de prueba completos y coherentes (mínimo 5 registros por tabla)
- [ ] **3 pts**: Datos de prueba incompletos o con inconsistencias
- [ ] **1 pt**: Datos de prueba mínimos o incorrectos
- [ ] **0 pts**: No hay datos de prueba

**Observaciones**: _________________________

#### 2.3 Stored Procedures (10 puntos)
- [ ] **10 pts**: 4+ procedimientos correctamente implementados con validaciones, transacciones y manejo de errores adecuado
- [ ] **7 pts**: 3 procedimientos implementados con errores menores o sin manejo completo de errores
- [ ] **4 pts**: 1-2 procedimientos implementados o con errores significativos
- [ ] **0 pts**: No hay stored procedures o son incorrectos

**Procedimientos implementados**:
- [ ] sp_registrar_prestamo
- [ ] sp_registrar_devolucion
- [ ] sp_renovar_prestamo
- [ ] sp_realizar_reserva
- [ ] Otros: _________________________

**Observaciones**: _________________________

#### 2.4 Triggers (5 puntos)
- [ ] **5 pts**: 2+ triggers correctamente implementados con lógica de negocio apropiada
- [ ] **3 pts**: 1 trigger implementado correctamente o 2 con errores menores
- [ ] **1 pt**: Trigger con errores significativos
- [ ] **0 pts**: No hay triggers o son incorrectos

**Triggers implementados**:
- [ ] trg_prestamo_before_insert
- [ ] trg_devolucion_after_update
- [ ] Otros: _________________________

**Observaciones**: _________________________

#### 2.5 Cursores (5 puntos)
- [ ] **5 pts**: Cursor avanzado correctamente implementado con lógica compleja y manejo adecuado
- [ ] **3 pts**: Cursor básico implementado correctamente
- [ ] **1 pt**: Cursor con errores significativos
- [ ] **0 pts**: No hay cursores o son incorrectos

**Cursores implementados**:
- [ ] sp_actualizar_multas_diarias
- [ ] sp_generar_reporte_morosidad
- [ ] Otros: _________________________

**Observaciones**: _________________________

**Subtotal Implementación SQL**: _______/35

---

### 3. CONCEPTOS AVANZADOS (20 puntos)

#### 3.1 Transacciones (5 puntos)
- [ ] **5 pts**: Uso correcto y justificado de transacciones donde es crítico (préstamos, devoluciones)
- [ ] **3 pts**: Transacciones implementadas pero no siempre donde son necesarias
- [ ] **1 pt**: Uso incorrecto o inconsistente de transacciones
- [ ] **0 pts**: No se usan transacciones

**Observaciones**: _________________________

#### 3.2 Índices y Optimización (5 puntos)
- [ ] **5 pts**: Índices apropiados y justificados en columnas de búsqueda frecuente
- [ ] **3 pts**: Algunos índices implementados pero no todos los necesarios
- [ ] **1 pt**: Índices implementados incorrectamente o sin justificación
- [ ] **0 pts**: No hay índices

**Índices implementados**:
- [ ] idx_libros_titulo
- [ ] idx_socios_email
- [ ] idx_prestamos_socio
- [ ] Otros: _________________________

**Observaciones**: _________________________

#### 3.3 Manejo de Errores (5 puntos)
- [ ] **5 pts**: Manejo completo de errores con bloques EXCEPTION y mensajes descriptivos
- [ ] **3 pts**: Manejo básico de errores implementado
- [ ] **1 pt**: Manejo de errores incompleto o inconsistente
- [ ] **0 pts**: No hay manejo de errores

**Observaciones**: _________________________

#### 3.4 Vistas y Consultas Complejas (5 puntos)
- [ ] **5 pts**: 3+ vistas complejas correctamente implementadas con JOINs múltiples y agregaciones
- [ ] **3 pts**: 2 vistas implementadas correctamente
- [ ] **1 pt**: 1 vista con errores o incompleta
- [ ] **0 pts**: No hay vistas o son incorrectas

**Vistas implementadas**:
- [ ] vw_libros_disponibles
- [ ] vw_prestamos_activos
- [ ] vw_multas_pendientes
- [ ] Otros: _________________________

**Observaciones**: _________________________

**Subtotal Conceptos Avanzados**: _______/20

---

### 4. PRUEBAS Y VALIDACIÓN (10 puntos)

#### 4.1 Casos de Prueba (5 puntos)
- [ ] **5 pts**: Casos de prueba completos que cubren escenarios normales y de error (mínimo 10 casos)
- [ ] **3 pts**: Casos de prueba básicos que cubren funcionalidad principal
- [ ] **1 pt**: Casos de prueba incompletos o mal documentados
- [ ] **0 pts**: No hay casos de prueba

**Total de casos de prueba documentados**: _______

**Observaciones**: _________________________

#### 4.2 Ejecución de Pruebas (5 puntos)
- [ ] **5 pts**: Pruebas ejecutadas con resultados documentados y evidencia de funcionamiento correcto
- [ ] **3 pts**: Algunas pruebas ejecutadas con resultados parciales
- [ ] **1 pt**: Pruebas ejecutadas sin documentación adecuada
- [ ] **0 pts**: No se ejecutaron pruebas

**Resultados de pruebas**:
- ✅ Pass: _______
- ❌ Fail: _______
- ⏭️ Skip: _______

**Observaciones**: _________________________

**Subtotal Pruebas y Validación**: _______/10

---

### 5. DOCUMENTACIÓN (10 puntos)

#### 5.1 Calidad de la Documentación (5 puntos)
- [ ] **5 pts**: Documentación completa, clara y bien estructurada con ejemplos y explicaciones detalladas
- [ ] **3 pts**: Documentación completa pero con explicaciones incompletas o poco claras
- [ ] **1 pt**: Documentación incompleta o difícil de entender
- [ ] **0 pts**: Documentación mínima o inexistente

**Observaciones**: _________________________

#### 5.2 Informe Técnico (5 puntos)
- [ ] **5 pts**: Informe bien estructurado con todas las secciones requeridas, conclusiones claras y lecciones aprendidas
- [ ] **3 pts**: Informe completo pero con secciones incompletas o conclusiones pobres
- [ ] **1 pt**: Informe incompleto o mal estructurado
- [ ] **0 pts**: No hay informe o es insuficiente

**Secciones del informe**:
- [ ] Resumen ejecutivo
- [ ] Análisis y diseño
- [ ] Implementación técnica
- [ ] Pruebas y validación
- [ ] Conclusiones

**Observaciones**: _________________________

**Subtotal Documentación**: _______/10

---

## 🏆 CRITERIOS ADICIONALES (Puntos Extra)

### 6.1 Funcionalidades Adicionales (Hasta +5 puntos)
- [ ] **+2 pts**: Sistema de roles y permisos de usuario
- [ ] **+2 pts**: Procedimiento de backup y recuperación
- [ ] **+1 pt**: Trigger de auditoría de cambios
- [ ] **+1 pt**: Cursor adicional con lógica compleja
- [ ] **+1 pt**: Sistema de notificaciones básico
- [ ] **+1 pt**: Optimización avanzada (índices compuestos, particionamiento)

**Funcionalidades adicionales implementadas**: _________________________

**Puntos extra obtenidos**: _______/5

### 6.2 Creatividad y Calidad del Código (Hasta +3 puntos)
- [ ] **+3 pts**: Soluciones creativas y eficientes, código limpio y bien comentado
- [ ] **+2 pts**: Buena calidad de código con algunas soluciones interesantes
- [ ] **+1 pt**: Código funcional pero poco elegante
- [ ] **0 pts**: Código difícil de leer o mantener

**Observaciones**: _________________________

**Puntos extra obtenidos**: _______/3

---

## 📊 RESUMEN DE LA EVALUACIÓN

| Criterio | Puntuación Máxima | Puntuación Obtenida | Porcentaje |
|----------|-------------------|---------------------|------------|
| Análisis y Diseño | 25 | | |
| Implementación SQL | 35 | | |
| Conceptos Avanzados | 20 | | |
| Pruebas y Validación | 10 | | |
| Documentación | 10 | | |
| **Subtotal** | **100** | | **%** |
| Funcionalidades Extra | +5 | | |
| Calidad del Código | +3 | | |
| **TOTAL** | **108** | | **%** |

---

## 📝 OBSERVACIONES Y RECOMENDACIONES DEL PROFESOR

### Fortalezas del Proyecto
1. _________________________
2. _________________________
3. _________________________

### Áreas de Mejora
1. _________________________
2. _________________________
3. _________________________

### Recomendaciones para el Futuro
- _________________________
- _________________________
- _________________________

---

## ✅ DECISIÓN FINAL

**Calificación numérica**: _______/108  
**Calificación cualitativa**: ☐ Sobresaliente (90-108) ☐ Notable (70-89) ☐ Aprobado (50-69) ☐ Suspenso (<50)

**Observaciones finales**: _________________________

**Firma del profesor**: _________________________  
**Fecha**: _________________________

---

## 📋 RÚBRICA DE CALIFICACIÓN DETALLADA

### Nivel de Excelencia (90-108 puntos)
El proyecto demuestra un dominio excepcional de los conceptos de bases de datos. El diseño es elegante, la implementación es robusta y la documentación es completa. El alumno va más allá de los requisitos mínimos y demuestra creatividad en la solución de problemas.

### Nivel de Notable (70-89 puntos)
El proyecto cumple con todos los requisitos principales de forma correcta. El diseño es apropiado y la implementación funciona correctamente. Puede haber pequeños errores o áreas de mejora, pero en general es un trabajo sólido y bien ejecutado.

### Nivel de Aprobado (50-69 puntos)
El proyecto cumple con los requisitos mínimos pero tiene deficiencias significativas en algún área. Puede tener errores en el diseño, implementación incompleta o documentación insuficiente. Requiere revisiones importantes para alcanzar un nivel profesional.

### Nivel de Suspenso (<50 puntos)
El proyecto no cumple con los requisitos mínimos. Tiene errores graves en el diseño, implementación incompleta o inexistente de conceptos clave, o documentación muy deficiente. Requiere trabajo sustancial para alcanzar los estándares mínimos.

---

**Nota**: Esta checklist debe adaptarse a los criterios específicos de cada centro educativo. Los profesores pueden ajustar puntajes y criterios según sus necesidades.
