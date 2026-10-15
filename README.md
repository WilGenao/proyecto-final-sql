# Proyecto Final SQL

Análisis de una base de datos de ventas (SQLite) con 29 consultas SQL.

## Base de datos
Tablas: `clientes`, `categorias`, `productos`, `pedidos`, `detalle_pedidos`.

## Técnicas usadas
JOINs, GROUP BY / HAVING, subconsultas, CTEs, CASE WHEN, funciones de fecha
y window functions (RANK, ROW_NUMBER, LAG, LEAD, SUM OVER).

## Hallazgos
- Los pedidos completados generaron 3,046,180 en total.
- Santo Domingo concentra la mayor parte de los ingresos.
- Tecnología es la categoría que más ingresa.

## Archivos
- `proyecto_final_sql.db`: base de datos
- `consultas.sql`: consultas de los ejercicios