-- ============================================================
--  m4_consultas_negocio.sql
--  Proyecto: RetailPro | Curso Data Analytics — Coderhouse
--  Módulo 4: Extrayendo métricas clave con SQL
--  Alumno:   Gastón Butazzi
--  Entorno:  SQL Server (SSMS 22)
-- ============================================================
 
USE Ventas_Tech_DB;
GO
 
 
-- ============================================================
-- CONSULTA 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- ============================================================
-- Qué hace: agrupa todas las ventas por mes y calcula 3 métricas clave.
-- cantidad * precio_unitario = facturación real de cada fila.
-- MONTH(fecha_venta) extrae el número de mes (3 = marzo, etc.)
-- ============================================================
 
SELECT
    MONTH(fecha_venta)                        AS mes,
    COUNT(*)                                  AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)           AS total_facturado,
    AVG(cantidad * precio_unitario)           AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO
 
 
-- ============================================================
-- CONSULTA 2 — Ranking de productos (Top 5)
-- Los 5 productos con mayor facturación total
-- ============================================================
-- Qué hace: agrupa por id_producto, suma lo que facturó cada uno
-- y toma solo los 5 primeros ordenados de mayor a menor.
-- En SQL Server usamos TOP 5 (en PostgreSQL sería LIMIT 5).
-- ============================================================
 
SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO
 
 
-- ============================================================
-- CONSULTA 3 — Clientes recurrentes
-- Clientes que realizaron más de un pedido
-- ============================================================
-- Qué hace: agrupa por cliente y filtra con HAVING los que
-- tienen más de 1 compra. HAVING es como WHERE pero se aplica
-- después del GROUP BY, sobre los grupos ya formados.
-- ============================================================
 
SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC;
GO
 
 
-- ============================================================
-- CONSULTA 4 — Meses por encima / por debajo del promedio
-- Etiqueta cada mes según si superó el promedio mensual general
-- ============================================================
-- Qué hace: primero calcula el total por mes (subconsulta interna),
-- después calcula el promedio de esos totales y etiqueta cada mes
-- con CASE WHEN. Es la consulta más avanzada del módulo.
-- ============================================================
 
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > AVG(total_facturado) OVER () THEN 'Por encima del promedio'
        ELSE 'Por debajo del promedio'
    END AS comparativa_vs_promedio
FROM (
    SELECT
        MONTH(fecha_venta)               AS mes,
        SUM(cantidad * precio_unitario)  AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS resumen_mensual
ORDER BY mes;
GO
 
 
-- ============================================================
-- HALLAZGOS — Análisis de resultados
-- ============================================================
 
-- Hallazgo 1:
-- El producto 1 (Laptop Pro 15) concentra la mayor facturación
-- del período, con 2 unidades vendidas a $1.200 cada una = $2.400 en total.
-- Es el producto de mayor ticket unitario y mayor impacto en los ingresos.
 
-- Hallazgo 2:
-- El cliente 1 (María López) es el único cliente recurrente con 2 pedidos
-- registrados, lo que indica una base de clientes todavía pequeña.
-- Con más datos se podrían identificar patrones de recompra por segmento.
 
-- Hallazgo 3:
-- Marzo concentra el 100% de las ventas del período analizado (10 transacciones
-- entre el 05/03 y el 15/03/2024). En módulos siguientes, con más datos
-- históricos, se podrá analizar la estacionalidad real del negocio.
