-- ============================================================
--  m5_consultas_joins.sql
--  Proyecto: RetailPro | Curso Data Analytics — Coderhouse
--  Módulo 5: Cruzando tablas para enriquecer el análisis
--  Alumno:   Gastón Butazzi
--  Entorno:  SQL Server (SSMS 22)
-- ============================================================

USE Ventas_Tech_DB;
GO


-- ============================================================
-- CONSULTA 1 — Vista base del proyecto (INNER JOIN)
-- Combina ventas + clientes + productos + categorias
-- en una sola fila con toda la información del negocio.
-- ============================================================
-- Qué hace: INNER JOIN trae solo las filas que tienen
-- coincidencia en TODAS las tablas unidas. Es la consulta
-- principal que Power BI va a usar como fuente de datos.
-- Nota: la tabla territorios no tiene FK en ventas en nuestro
-- modelo actual, por lo que la vista se arma con las 4 tablas
-- disponibles: ventas, clientes, productos y categorias.
-- ============================================================

SELECT
    v.fecha_venta                          AS fecha,
    c.nombre                               AS nombre_cliente,
    c.ciudad                               AS ciudad_cliente,
    p.nombre_producto                      AS producto,
    cat.nombre_categoria                   AS categoria,
    v.cantidad                             AS cantidad,
    v.precio_unitario                      AS precio_unitario,
    v.cantidad * v.precio_unitario         AS total_venta,
    c.email                                AS email_cliente
FROM ventas v
INNER JOIN clientes  c   ON v.id_cliente  = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;
GO


-- ============================================================
-- CONSULTA 2 — Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que aún no realizaron ninguna compra
-- ============================================================
-- Qué hace: LEFT JOIN trae TODOS los clientes, hayan comprado
-- o no. Los que no tienen ventas aparecen con NULL en id_venta.
-- El WHERE IS NULL filtra solo esos casos.
-- ============================================================

SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO


-- ============================================================
-- CONSULTA 3 — Productos sin ventas (LEFT JOIN)
-- Productos del catálogo que no tienen ninguna venta registrada
-- ============================================================
-- Misma lógica que la consulta 2 pero aplicada a productos.
-- Útil para identificar stock sin movimiento.
-- ============================================================

SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria  AS categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v       ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;
GO


-- ============================================================
-- CONSULTA 4 — Consolidado por canal (UNION ALL)
-- Combina ventas Online y Presencial en un solo resultado
-- y calcula el total facturado por canal
-- ============================================================
-- Qué hace: UNION ALL apila filas de dos consultas.
-- A diferencia de UNION, conserva los duplicados (más eficiente).
-- Ambas consultas deben tener el mismo número de columnas
-- y tipos de datos compatibles.
-- Como todos nuestros datos tienen canal NULL (no se cargó),
-- separamos en dos grupos para demostrar la lógica.
-- ============================================================

SELECT canal, SUM(total_venta) AS total_facturado
FROM (
    -- Ventas Online
    SELECT
        ISNULL(canal, 'Online')          AS canal,
        cantidad * precio_unitario       AS total_venta
    FROM ventas
    WHERE id_venta IN (1, 3, 5, 7, 9)   -- simulamos ventas Online

    UNION ALL

    -- Ventas Presencial
    SELECT
        'Presencial'                     AS canal,
        cantidad * precio_unitario       AS total_venta
    FROM ventas
    WHERE id_venta IN (2, 4, 6, 8, 10)  -- simulamos ventas Presencial
) AS consolidado
GROUP BY canal
ORDER BY total_facturado DESC;
GO


-- ============================================================
-- HALLAZGOS — Análisis de resultados
-- ============================================================

-- Hallazgo 1:
-- La vista base (Consulta 1) muestra que la categoría "Computación"
-- concentra las ventas de mayor valor unitario (Laptop $1.200,
-- Monitor $450), siendo el segmento más rentable del catálogo.

-- Hallazgo 2:
-- La Consulta 2 no devuelve clientes sin ventas, lo que indica
-- que todos los clientes registrados realizaron al menos una compra.
-- Esto es esperable con la carga inicial de datos del M3.

-- Hallazgo 3:
-- La Consulta 3 tampoco devuelve productos sin ventas, confirmando
-- que todos los productos del catálogo tuvieron al menos una
-- transacción en el período analizado.
