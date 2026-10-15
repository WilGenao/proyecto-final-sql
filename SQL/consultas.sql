SELECT c.id, c.nombre
FROM clientes AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos AS p
    WHERE p.cliente_id = c.id
);