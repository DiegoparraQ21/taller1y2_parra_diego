USE bibliored;
SET @corte = '2026-11-10';

-- R1
SELECT CONCAT(m.first_names, ' ', m.last_names) AS socio,
       COALESCE(m.phone, '') AS telefono,
       ROUND(COALESCE(saldos.saldo, 0), 2) AS saldo_multas,
       COALESCE(vencidos.total, 0) AS libros_vencidos,
       DATEDIFF(@corte, vencidos.vence_desde) AS dias_vencimiento_mas_antiguo
FROM members m
LEFT JOIN (
    SELECT l.member_id, SUM(f.amount - COALESCE(abonos.pagado, 0)) AS saldo
    FROM loans l
    JOIN fines f ON f.loan_id = l.id AND f.status = 'PENDIENTE'
    LEFT JOIN (
        SELECT fine_id, SUM(amount) AS pagado FROM fine_payments GROUP BY fine_id
    ) AS abonos ON abonos.fine_id = f.id
    GROUP BY l.member_id
) AS saldos ON saldos.member_id = m.id
LEFT JOIN (
    SELECT member_id, COUNT(*) AS total, MIN(due_on) AS vence_desde
    FROM loans WHERE status = 'ACTIVO' AND due_on < @corte
    GROUP BY member_id
) AS vencidos ON vencidos.member_id = m.id
WHERE COALESCE(saldos.saldo, 0) > 0 OR COALESCE(vencidos.total, 0) > 0
ORDER BY saldo_multas DESC, libros_vencidos DESC, m.id;

-- R2
SELECT cat.name AS categoria,
       COALESCE(inventario.titulos, 0) AS titulos,
       COALESCE(inventario.ejemplares, 0) AS ejemplares_en_circulacion,
       COALESCE(movimiento.prestamos, 0) AS prestamos,
       COALESCE(ROUND(COALESCE(movimiento.prestamos, 0) / NULLIF(inventario.ejemplares, 0), 2), 0.00)
           AS prestamos_por_ejemplar
FROM categories cat
LEFT JOIN (
    SELECT t.category_id, COUNT(DISTINCT t.id) AS titulos, COUNT(c.id) AS ejemplares
    FROM titles t
    LEFT JOIN copies c ON c.title_id = t.id AND c.status NOT IN ('PERDIDO', 'DADO_DE_BAJA')
    GROUP BY t.category_id
) AS inventario ON inventario.category_id = cat.id
LEFT JOIN (
    SELECT t.category_id, COUNT(*) AS prestamos
    FROM titles t
    JOIN copies c ON c.title_id = t.id
    JOIN loans l ON l.copy_id = c.id
    WHERE l.loaned_on BETWEEN '2026-10-01' AND @corte
    GROUP BY t.category_id
) AS movimiento ON movimiento.category_id = cat.id
ORDER BY prestamos_por_ejemplar DESC, categoria;

-- R3
DROP PROCEDURE IF EXISTS sp_vencer_reservas;
DELIMITER $$
CREATE PROCEDURE sp_vencer_reservas(IN p_cutoff DATE)
BEGIN
    UPDATE reservations FORCE INDEX (PRIMARY)
    SET status = 'VENCIDA'
    WHERE id > 0 AND status = 'PENDIENTE' AND expires_on < p_cutoff;

    SELECT ROW_COUNT() AS reservas_vencidas;
END $$
DELIMITER ;

-- R3 · Primera llamada: 2.
CALL sp_vencer_reservas('2026-11-21');

-- R3 · Segunda llamada: 0.
CALL sp_vencer_reservas('2026-11-21');
