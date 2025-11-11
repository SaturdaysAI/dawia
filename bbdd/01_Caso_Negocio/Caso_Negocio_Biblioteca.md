# Caso de Negocio: Sistema de Gestión de Biblioteca

## 1. Descripción del Proyecto

### 1.1 Contexto Empresarial
La biblioteca municipal "Biblioteca Central" necesita modernizar su sistema de gestión para mejorar la eficiencia operativa y el servicio a los usuarios. Actualmente, los procesos se realizan manualmente con registros en papel, lo que genera problemas de organización, pérdida de información y lentitud en las operaciones.

### 1.2 Objetivos del Sistema
- **Objetivo Principal**: Digitalizar y automatizar la gestión de la biblioteca
- **Objetivos Específicos**:
  - Mejorar el control del catálogo de libros
  - Optimizar el proceso de préstamos y devoluciones
  - Gestionar eficientemente los socios de la biblioteca
  - Implementar un sistema de reservas
  - Generar reportes estadísticos
  - Controlar multas y pagos

## 2. Alcance del Sistema

### 2.1 Funcionalidades Incluidas
- Gestión de catálogo de libros (altas, bajas, modificaciones)
- Control de socios (registro, actualización, bajas)
- Sistema de préstamos y devoluciones
- Sistema de reservas de libros
- Gestión de personal bibliotecario
- Generación de reportes y estadísticas
- Control de multas por retraso
- Búsqueda avanzada de libros

### 2.2 Funcionalidades Excluidas
- Sistema de compras y adquisiciones
- Integración con sistemas de pago externos
- Aplicación móvil (para esta versión)
- Sistema de alertas por email/SMS

## 3. Stakeholders

### 3.1 Usuarios Principales
- **Bibliotecarios**: Encargados de la gestión diaria
- **Socios**: Usuarios finales del sistema
- **Administrador**: Supervisión y mantenimiento

### 3.2 Requisitos por Rol

#### Bibliotecario
- Registrar préstamos y devoluciones
- Gestionar reservas
- Consultar catálogo
- Generar reportes básicos

#### Socio
- Consultar catálogo
- Realizar reservas
- Ver historial de préstamos
- Consultar multas pendientes

#### Administrador
- Gestión completa del sistema
- Mantenimiento de catálogo
- Gestión de personal
- Reportes avanzados
- Backup y mantenimiento

## 4. Requisitos Funcionales

### 4.1 Gestión de Libros
- **RF-01**: Registrar nuevos libros con ISBN, título, autor, editorial, año, género
- **RF-02**: Modificar información de libros existentes
- **RF-03**: Dar de baja libros del catálogo
- **RF-04**: Consultar disponibilidad de libros
- **RF-05**: Búsqueda avanzada por múltiples criterios

### 4.2 Gestión de Socios
- **RF-06**: Registrar nuevos socios con datos personales
- **RF-07**: Actualizar información de socios
- **RF-08**: Dar de baja socios
- **RF-09**: Consultar historial de préstamos por socio
- **RF-10**: Gestionar estado de membresía

### 4.3 Sistema de Préstamos
- **RF-11**: Registrar préstamos con fecha límite de devolución
- **RF-12**: Registrar devoluciones y calcular multas
- **RF-13**: Controlar límite de libros por socio
- **RF-14**: Validar disponibilidad antes del préstamo
- **RF-15**: Renovar préstamos existentes

### 4.4 Sistema de Reservas
- **RF-16**: Permitir reservar libros no disponibles
- **RF-17**: Gestionar lista de espera por libro
- **RF-18**: Notificar cuando un libro reservado está disponible
- **RF-19**: Cancelar reservas

### 4.5 Control de Multas
- **RF-20**: Calcular automáticamente multas por retraso
- **RF-21**: Registrar pagos de multas
- **RF-22**: Bloquear préstamos a socios con multas pendientes
- **RF-23**: Generar reporte de multas por período

### 4.6 Reportes y Estadísticas
- **RF-24**: Libros más prestados
- **RF-25**: Socios más activos
- **RF-26**: Tasa de ocupación por género
- **RF-27**: Ingresos por multas
- **RF-28**: Inventario completo del catálogo

## 5. Requisitos No Funcionales

### 5.1 Rendimiento
- **RNF-01**: Tiempo de respuesta < 2 segundos para consultas simples
- **RNF-02**: Soporte para 100 usuarios concurrentes
- **RNF-03**: Disponibilidad 99% del tiempo

### 5.2 Seguridad
- **RNF-04**: Control de acceso por roles
- **RNF-05**: Encriptación de contraseñas
- **RNF-06**: Backup automático diario

### 5.3 Usabilidad
- **RNF-07**: Interfaz intuitiva y fácil de usar
- **RNF-08**: Mensajes de error claros y en español
- **RNF-09**: Documentación completa del sistema

## 6. Reglas de Negocio

### 6.1 Préstamos
- **RN-01**: Máximo 3 libros por socio simultáneamente
- **RN-02**: Período de préstamo: 15 días
- **RN-03**: Posibilidad de 1 renovación por 7 días adicionales
- **RN-04**: No se permiten préstamos a socios con multas > 10€

### 6.2 Multas
- **RN-05**: Tarifa: 0.50€ por día de retraso
- **RN-06**: Máximo 30€ por préstamo
- **RN-07**: Pago en efectivo en mostrador

### 6.3 Reservas
- **RN-08**: Máximo 2 reservas activas por socio
- **RN-09**: Tiempo de espera: 3 días para retirar libro reservado
- **RN-10**: Prioridad por orden de reserva

### 6.4 Libros
- **RN-11**: Cada libro tiene un código único (ej: BIB-00123)
- **RN-12**: Stock mínimo: 1 ejemplar para libros populares
- **RN-13**: Estado: Disponible, Prestado, Reservado, En reparación

## 7. Beneficios Esperados

### 7.1 Operativos
- Reducción del 60% en tiempo de procesamiento
- Eliminación de errores por registro manual
- Mejora en la organización del catálogo

### 7.2 Económicos
- Reducción de costos operativos
- Mejora en la recaudación de multas
- Optimización de recursos humanos

### 7.3 de Servicio
- Mejora en la experiencia del usuario
- Reducción de tiempos de espera
- Mayor satisfacción de los socios

## 8. Riesgos y Mitigación

### 8.1 Riesgos Identificados
- **Riesgo 1**: Resistencia al cambio por parte del personal
- **Riesgo 2**: Problemas técnicos durante la migración
- **Riesgo 3**: Falta de capacitación

### 8.2 Estrategias de Mitigación
- Capacitación completa del personal
- Plan de migración gradual
- Soporte técnico durante 3 meses post-implementación

## 9. Cronograma Estimado

### Fase 1: Análisis y Diseño (2 semanas)
- Recolección de requisitos
- Diseño de base de datos
- Aprobación del diseño

### Fase 2: Desarrollo (4 semanas)
- Implementación de base de datos
- Desarrollo de procedimientos
- Pruebas unitarias

### Fase 3: Pruebas (2 semanas)
- Pruebas de integración
- Pruebas de usuario
- Corrección de errores

### Fase 4: Implementación (1 semana)
- Migración de datos
- Capacitación
- Puesta en producción

## 10. Presupuesto Estimado

### Costos de Desarrollo
- Análisis y diseño: 20 horas
- Desarrollo: 40 horas
- Pruebas: 15 horas
- **Total**: 75 horas

### Costos de Infraestructura
- Servidor de base de datos
- Licencias de software
- Equipos de trabajo

## 11. Criterios de Éxito

- Reducción del 50% en tiempo de procesamiento de préstamos
- 95% de satisfacción del usuario
- 0% de pérdida de datos
- Disponibilidad del sistema > 99%
- Capacitación completa del personal

---

**Documento preparado para**: Proyecto - Gestión de Bases de Datos  
**Versión**: 1.0