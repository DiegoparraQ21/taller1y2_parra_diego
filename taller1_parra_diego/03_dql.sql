USE bibliored;
SET @corte = '2026-11-10';

-- Q-01
SELECT id, CONCAT(first_names, ' ', last_names) AS socio, status AS estado,
        COALESCE(phone, '') AS telefono
FROM members
WHERE phone IS NULL OR status <> 'ACTIVO'
ORDER BY id;

-- Q-02
SELECT l.id AS prestamo, CONCAT(m.first_names, ' ', m.last_names) AS socio,
       ms.name AS membresia, t.name AS titulo, c.barcode AS ejemplar,
       b.name AS sede, l.due_on AS vence, DATEDIFF(@corte, l.due_on) AS dias_mora,
       ROUND(DATEDIFF(@corte, l.due_on) * ms.daily_fine, 2) AS multa_estimada
FROM loans l
JOIN members m ON m.id = l.member_id
JOIN memberships ms ON ms.id = m.membership_id
JOIN copies c ON c.id = l.copy_id
JOIN titles t ON t.id = c.title_id
JOIN branches b ON b.id = c.branch_id
WHERE l.status = 'ACTIVO' AND l.due_on < @corte
ORDER BY dias_mora DESC, prestamo;

-- Q-03
SELECT t.name AS titulo, COUNT(*) AS autores
FROM titles t
JOIN title_authors ta ON ta.title_id = t.id
GROUP BY t.id, t.name
HAVING COUNT(*) > 1
ORDER BY t.id;

-- Q-04
SELECT b.name AS sede, COUNT(*) AS prestamos_totales,
       SUM(CASE WHEN l.status = 'ACTIVO' THEN 1 ELSE 0 END) AS prestamos_activos,
       COUNT(DISTINCT l.member_id) AS socios_distintos
FROM branches b
JOIN copies c ON c.branch_id = b.id
JOIN loans l ON l.copy_id = c.id
GROUP BY b.id, b.name
HAVING COUNT(*) >= 5
ORDER BY prestamos_totales DESC, sede;

-- Q-05
SELECT m.id, CONCAT(m.first_names, ' ', m.last_names) AS socio, m.joined_on AS afiliado_desde
FROM members m
WHERE NOT EXISTS (SELECT 1 FROM loans l WHERE l.member_id = m.id)
ORDER BY m.id;

-- Q-06
SELECT 'categoria' AS tipo, c.name AS nombre
FROM categories c
WHERE NOT EXISTS (SELECT 1 FROM titles t WHERE t.category_id = c.id)
UNION ALL
SELECT 'autor', a.full_name
FROM authors a
WHERE NOT EXISTS (SELECT 1 FROM title_authors ta WHERE ta.author_id = a.id)
ORDER BY tipo, nombre;

-- Q-07
SELECT m.id, CONCAT(m.first_names, ' ', m.last_names) AS socio, m.status AS estado
FROM members m
WHERE EXISTS (
    SELECT 1 FROM loans l
    JOIN fines f ON f.loan_id = l.id
    WHERE l.member_id = m.id AND f.status = 'PENDIENTE'
)
ORDER BY m.id;

-- Q-08
SELECT r.id AS reserva, CONCAT(m.first_names, ' ', m.last_names) AS socio,
       t.name AS titulo, b.name AS sede, r.expires_on AS expira
FROM reservations r
JOIN members m ON m.id = r.member_id
JOIN titles t ON t.id = r.title_id
JOIN branches b ON b.id = r.branch_id
WHERE r.status = 'PENDIENTE'
  AND NOT EXISTS (
      SELECT 1 FROM copies c
      WHERE c.title_id = r.title_id AND c.branch_id = r.branch_id AND c.status = 'DISPONIBLE'
  )
ORDER BY r.id;

-- Q-09
SELECT name AS titulo, replacement_cost AS costo_reposicion
FROM titles
WHERE replacement_cost > (SELECT AVG(replacement_cost) FROM titles)
ORDER BY costo_reposicion DESC, titulo;

-- Q-10
SELECT m.id, CONCAT(m.first_names, ' ', m.last_names) AS socio, COUNT(*) AS prestamos
FROM members m
JOIN loans l ON l.member_id = m.id
GROUP BY m.id, m.first_names, m.last_names
HAVING COUNT(*) = (
    SELECT MAX(conteos.prestamos)
    FROM (SELECT COUNT(*) AS prestamos FROM loans GROUP BY member_id) AS conteos
)
ORDER BY m.id;

-- Q-11
SELECT b.name AS sede, c.barcode AS ejemplar, t.name AS titulo, c.acquired_on AS adquirido
FROM branches b
JOIN copies c ON c.branch_id = b.id
JOIN titles t ON t.id = c.title_id
WHERE c.acquired_on = (SELECT MIN(c2.acquired_on) FROM copies c2 WHERE c2.branch_id = b.id)
ORDER BY b.id, c.barcode;

-- Q-12
SELECT m.id, CONCAT(m.first_names, ' ', m.last_names) AS socio,
       ROUND(SUM(f.amount), 2) AS total_multas,
       ROUND(SUM(COALESCE(abonos.pagado, 0)), 2) AS pagado,
       ROUND(SUM(f.amount - COALESCE(abonos.pagado, 0)), 2) AS saldo
FROM members m
JOIN loans l ON l.member_id = m.id
JOIN fines f ON f.loan_id = l.id AND f.status <> 'ANULADA'
LEFT JOIN (
    SELECT fine_id, SUM(amount) AS pagado
    FROM fine_payments
    GROUP BY fine_id
) AS abonos ON abonos.fine_id = f.id
GROUP BY m.id, m.first_names, m.last_names
HAVING saldo > 0
ORDER BY saldo DESC, m.id;
