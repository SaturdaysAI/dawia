# Proyecto: Sistema de Gestión de Biblioteca

## Descripción del Proyecto
Sistema completo de gestión de biblioteca para demostrar conceptos avanzados de bases de datos en el contexto de DAW/DAM.

## Estructura del Proyecto

```
Proyecto_Gestion_Biblioteca/
├── 01_Caso_Negocio/
│   ├── Caso_Negocio_Biblioteca.md
│   └── Requisitos_Funcionales.md
├── 02_Caso_Tecnico/
│   ├── Caso_Tecnico_Biblioteca.md
│   ├── Arquitectura_Sistema.md
│   └── Especificaciones_Tecnicas.md
├── 03_Disenio_BD/
│   ├── Esquema_BD.md
│   ├── Diagrama_ER.mmd
│   └── Diccionario_Datos.md
├── 04_SQL_Scripts/
│   ├── DDL/
│   │   ├── 01_Create_Tables.sql
│   │   ├── 02_Create_Indexes.sql
│   │   └── 03_Create_Constraints.sql
│   ├── DML/
│   │   ├── 01_Insert_Sample_Data.sql
│   │   └── 02_Insert_Test_Cases.sql
│   ├── Procedimientos/
│   │   ├── 01_Gestion_Prestamos.sql
│   │   ├── 02_Gestion_Reservas.sql
│   │   ├── 03_Reportes_Biblioteca.sql
│   │   └── 04_Mantenimiento.sql
│   ├── Disparadores/
│   │   ├── 01_Validacion_Prestamos.sql
│   │   ├── 02_Control_Stock.sql
│   │   ├── 03_Historial_Cambios.sql
│   │   └── 04_Notificaciones.sql
│   └── Cursores/
│       ├── 01_Procesamiento_Masivo.sql
│       └── 02_Generacion_Reportes.sql
├── 05_Documentacion/
│   ├── Manual_Instalacion.md
│   ├── Manual_Usuario.md
│   └── Guia_Desarrollo.md
├── 06_Pruebas/
│   ├── Casos_Prueba.md
│   ├── Script_Pruebas.sql
│   └── Resultados_Pruebas.md
├── 07_Entregas/
│   ├── Plantilla_Informe_Alumno.md
│   └── Checklist_Evaluacion.md
└── assets/
    ├── diagramas/
    ├── screenshots/
    └── templates/
```

## Requisitos del Sistema

### Funcionalidades Principales
- Gestión de catálogo de libros
- Control de socios/miembros
- Sistema de préstamos y devoluciones
- Reservas de libros
- Gestión de personal
- Reportes y estadísticas
- Control de multas

### Conceptos Técnicos a Demostrar
- Diseño de base de datos relacional
- Normalización (3FN)
- Stored Procedures
- Triggers
- Cursors
- Transacciones
- Índices y optimización
- Constraints y validaciones

## Tecnologías Recomendadas
- MySQL 8.0+ o PostgreSQL 13+
- MySQL Workbench o pgAdmin
- Herramienta de diagramas (draw.io, dbdiagram.io)

## Instrucciones de Uso
1. Revisar el Caso de Negocio
2. Estudiar el Caso Técnico
3. Implementar el esquema de base de datos
4. Ejecutar scripts SQL en orden
5. Realizar pruebas con datos de ejemplo
6. Desarrollar funcionalidades adicionales

## Evaluación
El proyecto será evaluado según:
- Correctitud del diseño de base de datos
- Implementación de conceptos avanzados
- Calidad de la documentación
- Funcionalidad del sistema
- Creatividad en soluciones