-- PORTAFOLIO DE EJERCICIOS SQL (SQLite)
-- Archivo único: fundamentos, consultas intermedias, avanzadas y proyecto comercial.
-- IMPORTANTE: las consultas de la sección 8 se recuperaron del proyecto anterior.
-- Las secciones 1 a 7 son reconstrucciones representativas de los temas practicados,
-- NO transcripciones exactas de todos los ejercicios originales.
-- Esquema básico supuesto: clientes(id,nombre,edad,ciudad), pedidos(id,cliente_id,total).
-- Para las secciones 6 y 7, se supone además pedidos(fecha).
-- La sección 8 requiere: pedidos(estado), detalle_pedidos, productos, categorias.

-- =============================================================
-- 01. CONSULTAS BÁSICAS
-- =============================================================
SELECT * FROM clientes;
SELECT nombre, ciudad FROM clientes;
SELECT * FROM clientes WHERE edad >= 25;
SELECT * FROM clientes WHERE ciudad = 'Santo Domingo';
SELECT * FROM clientes ORDER BY edad DESC;
SELECT * FROM pedidos WHERE total > 1000 ORDER BY total DESC;
SELECT DISTINCT ciudad FROM clientes;

-- =============================================================
-- 02. AGREGACIONES
-- =============================================================
SELECT COUNT(*) AS cantidad_clientes FROM clientes;
SELECT SUM(total) AS ventas_totales FROM pedidos;
SELECT ROUND(AVG(total), 2) AS promedio_pedido FROM pedidos;
SELECT MIN(total) AS pedido_minimo, MAX(total) AS pedido_maximo FROM pedidos;

-- =============================================================
-- 03. JOINS
-- =============================================================
SELECT c.nombre, p.id AS pedido_id, p.total
FROM clientes AS c INNER JOIN pedidos AS p ON p.cliente_id = c.id;

SELECT c.nombre, COALESCE(SUM(p.total), 0) AS total_compras
FROM clientes AS c LEFT JOIN pedidos AS p ON p.cliente_id = c.id
GROUP BY c.id, c.nombre;

-- =============================================================
-- 04. GROUP BY Y HAVING
-- =============================================================
SELECT cliente_id, COUNT(*) AS cantidad_pedidos, SUM(total) AS total_gastado
FROM pedidos GROUP BY cliente_id;

SELECT c.nombre, COUNT(p.id) AS cantidad_pedidos
FROM clientes AS c JOIN pedidos AS p ON p.cliente_id = c.id
GROUP BY c.id, c.nombre HAVING COUNT(p.id) >= 2;

-- =============================================================
-- 05. SUBCONSULTAS Y CTE
-- =============================================================
SELECT * FROM pedidos WHERE total > (SELECT AVG(total) FROM pedidos);

SELECT c.nombre FROM clientes AS c
WHERE NOT EXISTS (SELECT 1 FROM pedidos AS p WHERE p.cliente_id = c.id);

WITH gastos_clientes AS (
  SELECT c.id, c.nombre, COALESCE(SUM(p.total), 0) AS total_gastado
  FROM clientes AS c LEFT JOIN pedidos AS p ON p.cliente_id = c.id
  GROUP BY c.id, c.nombre
)
SELECT * FROM gastos_clientes WHERE total_gastado > 3000
ORDER BY total_gastado DESC;

-- =============================================================
-- 06. CASE WHEN Y FECHAS
-- =============================================================
SELECT nombre, edad,
  CASE WHEN edad < 25 THEN 'Joven'
       WHEN edad < 60 THEN 'Adulto' ELSE 'Mayor' END AS grupo_edad
FROM clientes;

SELECT c.nombre, COALESCE(SUM(p.total), 0) AS total_gastado,
  CASE WHEN COALESCE(SUM(p.total), 0) >= 5000 THEN 'Oro'
       WHEN COALESCE(SUM(p.total), 0) >= 2000 THEN 'Plata'
       ELSE 'Bronce' END AS categoria_cliente
FROM clientes AS c LEFT JOIN pedidos AS p ON p.cliente_id = c.id
GROUP BY c.id, c.nombre;

-- Requiere columna pedidos.fecha con fecha reconocible por SQLite.
SELECT strftime('%Y-%m', fecha) AS mes, SUM(total) AS ventas
FROM pedidos GROUP BY strftime('%Y-%m', fecha) ORDER BY mes;

-- =============================================================
-- 07. WINDOW FUNCTIONS
-- =============================================================
SELECT p.cliente_id, p.id AS pedido_id, p.total,
  ROW_NUMBER() OVER (PARTITION BY p.cliente_id ORDER BY p.total DESC) AS posicion,
  RANK() OVER (PARTITION BY p.cliente_id ORDER BY p.total DESC) AS ranking,
  ROUND(AVG(p.total) OVER (PARTITION BY p.cliente_id), 2) AS promedio_cliente
FROM pedidos AS p;

SELECT p.cliente_id, p.id AS pedido_id, p.fecha, p.total,
  LAG(p.total) OVER (PARTITION BY p.cliente_id ORDER BY p.fecha, p.id) AS pedido_anterior,
  LEAD(p.total) OVER (PARTITION BY p.cliente_id ORDER BY p.fecha, p.id) AS pedido_siguiente,
  SUM(p.total) OVER (PARTITION BY p.cliente_id ORDER BY p.fecha, p.id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_acumulado
FROM pedidos AS p;

-- =============================================================
-- 08. PROYECTO FINAL: ANÁLISIS DE VENTAS
-- Consultas recuperadas de las prácticas previas.
-- =============================================================

-- 08.1 Top 5 de productos más vendidos e ingresos generados.
SELECT
    p.nombre,
    SUM(d.cantidad) AS cantidades,
    SUM(d.cantidad * d.precio_unitario) AS ingresos_generados
FROM productos AS p
JOIN detalle_pedidos AS d ON d.producto_id = p.id
JOIN pedidos AS pe ON d.pedido_id = pe.id
WHERE pe.estado = 'Completado'
GROUP BY p.id, p.nombre
ORDER BY cantidades DESC
LIMIT 5;

-- 08.2 Ingresos por categoría de producto.
SELECT
    c.nombre,
    SUM(d.cantidad * d.precio_unitario) AS ingresos_generados
FROM categorias AS c
JOIN productos AS p ON c.id = p.categoria_id
JOIN detalle_pedidos AS d ON d.producto_id = p.id
JOIN pedidos AS pe ON pe.id = d.pedido_id
WHERE pe.estado = 'Completado'
GROUP BY c.id, c.nombre;

-- 08.3 Clientes con al menos 2 pedidos completados: gasto y promedio.
SELECT
    c.nombre AS nombre_cliente,
    COUNT(DISTINCT p.id) AS pedidos_completados,
    SUM(d.cantidad * d.precio_unitario) AS total_gastado,
    ROUND(SUM(d.cantidad * d.precio_unitario) * 1.0
          / COUNT(DISTINCT p.id), 2) AS promedio_por_pedido
FROM clientes AS c
JOIN pedidos AS p ON p.cliente_id = c.id
JOIN detalle_pedidos AS d ON d.pedido_id = p.id
WHERE p.estado = 'Completado'
GROUP BY c.id, c.nombre
HAVING COUNT(DISTINCT p.id) >= 2
ORDER BY total_gastado DESC;
