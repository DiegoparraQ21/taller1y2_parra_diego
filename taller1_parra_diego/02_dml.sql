USE bibliored;

INSERT INTO branches (name, municipality, address, opened_on) VALUES
    ('Sede Central Chía', 'Chía', 'Calle 11 # 8-24', '2012-01-16'),
    ('Sede Cajicá', 'Cajicá', 'Carrera 5 # 3-18', '2015-02-09'),
    ('Sede Zipaquirá', 'Zipaquirá', 'Calle 6 # 9-31', '2017-03-06'),
    ('Sede Cota', 'Cota', 'Carrera 4 # 12-08', '2020-01-20'),
    ('Sede Tabio', 'Tabio', 'Calle 4 # 2-16', '2026-10-01');

INSERT INTO memberships (name, loan_limit, loan_days, renewal_limit, daily_fine, annual_fee) VALUES
    ('Básica', 2, 14, 1, 500.00, 0.00),
    ('Estudiante', 3, 14, 2, 300.00, 0.00),
    ('Docente', 5, 21, 2, 300.00, 30000.00),
    ('Infantil', 2, 7, 1, 200.00, 0.00),
    ('Institucional', 10, 30, 3, 1000.00, 250000.00);

INSERT INTO categories (name) VALUES
    ('Novela'), ('Cuento'), ('Poesía'), ('Historia'),
    ('Ciencia'), ('Infantil'), ('Referencia'), ('Cómic');

INSERT INTO employees (branch_id, full_name, email, hired_on, role) VALUES
    (1, 'Patricia Lemus', 'patricia@bibliored.example', '2012-01-16', 'COORDINADOR'),
    (1, 'Iván Santoro', 'ivan@bibliored.example', '2022-02-07', DEFAULT),
    (2, 'Julia Narvés', 'julia@bibliored.example', '2020-06-01', DEFAULT),
    (3, 'Samuel Ruedal', 'samuel@bibliored.example', '2021-05-03', DEFAULT),
    (4, 'Laura Montal', 'laura@bibliored.example', '2020-01-20', DEFAULT),
    (5, 'Paula Quirama', 'paula@bibliored.example', '2026-10-01', 'AUXILIAR');

INSERT INTO publishers (name, city) VALUES
    ('Pliego de Niebla', 'Bogotá'),
    ('Sauce de Papel', 'Tunja'),
    ('Letras del Aljibe', 'Chía'),
    ('Umbral de Tinta', 'Medellín'),
    ('Prisma de Sal', 'Zipaquirá'),
    ('Tinta de Páramo', 'Bucaramanga'),
    ('Cuaderno de Bruma', 'Cajicá');

INSERT INTO authors (full_name, nationality, birth_year) VALUES
    ('Lucía Arven', 'Colombiana', 1980),
    ('Mateo Velcira', 'Colombiana', 1978),
    ('Eva Mariluz', 'Ecuatoriana', 1986),
    ('Simón Caldesal', 'Colombiana', 1972),
    ('Alba Monteluz', 'Colombiana', 1989),
    ('Pablo Nerval', 'Peruana', 1983),
    ('Sara Villanís', 'Colombiana', 1990),
    ('Elías Norcés', 'Colombiana', 1969),
    ('Irene Peñalta', 'Colombiana', 1984),
    ('René Salbrés', 'Colombiana', 1991);

INSERT INTO titles (category_id, publisher_id, isbn, name, publication_year, replacement_cost) VALUES
    (2, 1, '9780000000019', 'Cuentos de la Sabana', 2009, DEFAULT),
    (1, 2, '9780000000026', 'El tren de las seis', 2014, 58000.00),
    (3, 3, '9780000000033', 'Versos junto al aljibe', 2018, DEFAULT),
    (4, 4, '9780000000040', 'Caminos de sal', 2015, 76000.00),
    (6, 5, '9780000000057', 'La cometa de Lina', 2021, 42000.00),
    (5, 6, '9780000000064', 'Átomos para curiosos', 2019, 68000.00),
    (1, 1, '9780000000071', 'La ventana del norte', 2017, DEFAULT),
    (7, 2, '9780000000088', 'Atlas de las quebradas', 2020, 91000.00),
    (2, 3, '9780000000095', 'Relatos del domingo', 2016, DEFAULT),
    (3, 4, '9780000000101', 'Coplas para la lluvia', 2019, 39000.00),
    (5, 5, '9780000000118', 'El cielo desde el patio', 2022, 65000.00),
    (6, 6, '9780000000125', 'Nico y el río', 2021, 35000.00),
    (4, 1, '9780000000132', 'Memoria de los molinos', 2018, 64000.00),
    (7, 2, '9780000000149', 'Guía de semillas del altiplano', 2025, DEFAULT);

INSERT INTO title_authors (title_id, author_id, author_order) VALUES
    (1, 1, 1), (1, 2, 2), (2, 2, 1), (2, 3, 2), (3, 4, 1),
    (4, 5, 1), (4, 6, 2), (5, 7, 1), (6, 8, 1), (7, 9, 1),
    (8, 6, 1), (9, 1, 1), (10, 4, 1), (11, 8, 1),
    (12, 7, 1), (13, 5, 1), (14, 9, 1);

INSERT INTO copies (title_id, branch_id, barcode, acquired_on, status) VALUES
    (1, 1, 'BR-0001', '2013-03-12', 'PRESTADO'),
    (1, 2, 'BR-0002', '2015-05-18', DEFAULT),
    (1, 3, 'BR-0003', '2011-08-11', DEFAULT),
    (2, 1, 'BR-0004', '2014-11-05', 'PRESTADO'),
    (3, 1, 'BR-0005', '2018-09-20', 'PRESTADO'),
    (4, 1, 'BR-0006', '2016-02-23', 'PRESTADO'),
    (5, 1, 'BR-0007', '2021-07-16', 'PRESTADO'),
    (6, 1, 'BR-0008', '2019-09-10', 'EN_REPARACION'),
    (8, 1, 'BR-0009', '2020-08-14', 'EN_REPARACION'),
    (9, 1, 'BR-0010', '2017-01-19', DEFAULT),
    (10, 1, 'BR-0011', '2019-11-07', DEFAULT),
    (11, 1, 'BR-0012', '2022-10-17', DEFAULT),
    (7, 2, 'BR-0013', '2018-01-22', 'PRESTADO'),
    (8, 2, 'BR-0014', '2021-02-08', 'PRESTADO'),
    (9, 2, 'BR-0015', '2016-08-15', DEFAULT),
    (10, 2, 'BR-0016', '2020-03-03', DEFAULT),
    (11, 2, 'BR-0017', '2023-01-12', DEFAULT),
    (12, 2, 'BR-0018', '2021-10-22', DEFAULT),
    (13, 2, 'BR-0019', '2019-03-04', 'DADO_DE_BAJA'),
    (2, 3, 'BR-0020', '2017-05-10', DEFAULT),
    (4, 3, 'BR-0021', '2018-04-25', DEFAULT),
    (5, 3, 'BR-0022', '2022-02-17', DEFAULT),
    (6, 4, 'BR-0023', '2020-07-06', 'PERDIDO'),
    (12, 4, 'BR-0024', '2022-04-28', DEFAULT),
    (13, 4, 'BR-0025', '2020-09-02', DEFAULT);

INSERT INTO members (membership_id, branch_id, document_number, first_names, last_names, email, phone, birth_date, joined_on, status) VALUES
    (1, 1, 'BR-S001', 'Julián', 'Cerval', 'julian@example.com', '3000000101', '1994-04-06', '2021-04-12', DEFAULT),
    (2, 1, 'BR-S002', 'Nora', 'Lunés', 'nora@example.com', '3000000102', '2004-09-16', '2024-08-05', DEFAULT),
    (2, 2, 'BR-S003', 'Inés', 'Ardila Mera', 'ines@example.com', '3000000103', '2001-03-11', '2022-06-15', 'SUSPENDIDO'),
    (1, 4, 'BR-S004', 'Felipe', 'Urbal', 'felipe@example.com', '3000000104', '1991-08-27', '2022-01-24', DEFAULT),
    (1, 1, 'BR-S005', 'Tomás', 'Reval', 'tomas@example.com', '3000000105', '1988-12-08', '2020-08-10', 'INACTIVO'),
    (3, 2, 'BR-S006', 'Marta', 'Niebles Luna', 'marta@example.com', '3000000106', '1985-06-19', '2019-10-07', DEFAULT),
    (2, 1, 'BR-S007', 'Sofía', 'Brial', 'sofia@example.com', '3000000107', '2006-11-29', '2025-01-20', DEFAULT),
    (4, 1, 'BR-S008', 'Gael', 'Moncira', NULL, NULL, '2015-05-09', '2024-07-16', DEFAULT),
    (4, 1, 'BR-S009', 'Emma', 'Veral', NULL, NULL, '2017-02-14', '2024-09-19', DEFAULT),
    (1, 1, 'BR-S010', 'Daniel', 'Mirasol', 'daniel@example.com', '3000000110', '1996-10-05', '2021-10-11', DEFAULT),
    (3, 3, 'BR-S011', 'Ana', 'Cendral', 'ana@example.com', '3000000111', '1982-07-03', '2018-06-04', DEFAULT),
    (2, 2, 'BR-S012', 'Luis', 'Navial', 'luis@example.com', NULL, '2005-01-13', '2025-08-20', DEFAULT),
    (1, 5, 'BR-S013', 'Clara', 'Valbrés', 'clara@example.com', '3000000113', '1999-07-24', '2026-10-05', DEFAULT),
    (1, 1, 'BR-S014', 'Mateo', 'Solbrén', 'mateo@example.com', '3000000114', '1998-04-02', '2026-11-05', DEFAULT);

INSERT INTO loans (copy_id, member_id, employee_id, loaned_on, due_on, returned_on, status) VALUES
    (1, 1, 1, '2026-09-02', '2026-09-16', '2026-09-12', 'DEVUELTO'),
    (4, 1, 2, '2026-09-20', '2026-10-04', '2026-10-02', 'DEVUELTO'),
    (1, 1, 1, '2026-10-27', '2026-11-10', NULL, DEFAULT),
    (4, 1, 2, '2026-10-15', '2026-11-12', NULL, DEFAULT),
    (5, 2, 2, '2026-09-01', '2026-09-15', '2026-09-10', 'DEVUELTO'),
    (6, 2, 2, '2026-09-12', '2026-09-26', '2026-09-24', 'DEVUELTO'),
    (5, 2, 1, '2026-09-29', '2026-11-10', NULL, DEFAULT),
    (6, 2, 2, '2026-11-04', '2026-11-18', NULL, DEFAULT),
    (13, 3, 3, '2026-10-15', '2026-10-29', NULL, DEFAULT),
    (14, 3, 3, '2026-09-10', '2026-09-24', '2026-10-04', 'DEVUELTO'),
    (23, 4, 5, '2026-10-20', '2026-11-03', NULL, 'PERDIDO'),
    (7, 5, 2, '2026-09-03', '2026-09-17', '2026-09-19', 'DEVUELTO'),
    (7, 6, 2, '2026-11-01', '2026-11-22', NULL, DEFAULT),
    (14, 6, 3, '2026-10-15', '2026-11-05', NULL, DEFAULT),
    (1, 7, 1, '2026-09-18', '2026-10-02', '2026-10-06', 'DEVUELTO'),
    (6, 8, 2, '2026-09-26', '2026-10-03', '2026-10-06', 'DEVUELTO'),
    (8, 9, 2, '2026-10-04', '2026-10-11', '2026-10-10', 'DEVUELTO'),
    (10, 10, 1, '2026-10-10', '2026-10-24', '2026-10-23', 'DEVUELTO'),
    (12, 11, 1, '2026-10-01', '2026-10-22', '2026-10-20', 'DEVUELTO'),
    (15, 12, 3, '2026-10-01', '2026-10-15', '2026-10-11', 'DEVUELTO');

INSERT INTO renewals (loan_id, renewed_on, previous_due_on, new_due_on) VALUES
    (1004, '2026-10-27', '2026-10-29', '2026-11-12'),
    (1007, '2026-10-11', '2026-10-13', '2026-10-27'),
    (1007, '2026-10-24', '2026-10-27', '2026-11-10');

INSERT INTO reservations (member_id, title_id, branch_id, reserved_on, expires_on, status) VALUES
    (13, 5, 2, '2026-11-03', '2026-11-16', DEFAULT),
    (10, 1, 3, '2026-11-04', '2026-11-20', DEFAULT),
    (12, 7, 4, '2026-11-06', '2026-11-22', DEFAULT),
    (11, 14, 3, '2026-10-22', '2026-11-05', DEFAULT),
    (12, 9, 2, '2026-09-29', '2026-10-05', 'ATENDIDA'),
    (7, 11, 1, '2026-10-25', '2026-11-08', 'VENCIDA'),
    (4, 12, 4, '2026-10-12', '2026-10-26', 'CANCELADA'),
    (9, 8, 2, '2026-11-08', '2026-11-18', 'CANCELADA');

INSERT INTO fines (loan_id, reason, status, late_days, amount, issued_on) VALUES
    (1010, 'MORA', DEFAULT, 10, 3000.00, '2026-10-04'),
    (1011, 'PERDIDA', DEFAULT, 0, 68000.00, '2026-11-04'),
    (1012, 'MORA', 'ANULADA', 2, 1000.00, '2026-09-19'),
    (1015, 'MORA', 'PAGADA', 4, 1200.00, '2026-10-06'),
    (1016, 'MORA', 'PAGADA', 3, 600.00, '2026-10-06');

INSERT INTO fine_payments (fine_id, amount, paid_on, payment_method) VALUES
    (1, 1000.00, '2026-10-08', 'EFECTIVO'),
    (4, 500.00, '2026-10-07', 'EFECTIVO'),
    (4, 700.00, '2026-10-14', 'TRANSFERENCIA'),
    (5, 600.00, '2026-10-06', 'TARJETA');

-- DML-01
SELECT id, barcode, status FROM copies WHERE id = 8;
UPDATE copies SET status = 'DISPONIBLE' WHERE id = 8;
SELECT id, barcode, status FROM copies WHERE id = 8;

-- DML-02
SELECT id, expires_on, status
FROM reservations WHERE id > 0 AND status = 'PENDIENTE' AND expires_on < '2026-11-10';
UPDATE reservations FORCE INDEX (PRIMARY)
SET status = 'VENCIDA'
WHERE id > 0 AND status = 'PENDIENTE' AND expires_on < '2026-11-10';
SELECT id, expires_on, status FROM reservations WHERE id = 4;

-- DML-03
SELECT id, name, annual_fee FROM memberships WHERE id = 3;
UPDATE memberships SET annual_fee = annual_fee * 1.10 WHERE id = 3;
SELECT id, name, annual_fee FROM memberships WHERE id = 3;

-- DML-04
SELECT id, first_names, phone FROM members WHERE id = 12;
UPDATE members SET phone = '3000000112' WHERE id = 12;
SELECT id, first_names, phone FROM members WHERE id = 12;

-- DML-05
SELECT id, status FROM reservations WHERE id = 7 AND status = 'CANCELADA';
DELETE FROM reservations WHERE id = 7 AND status = 'CANCELADA';

-- DML-06
SELECT p.id, p.name, COUNT(t.id) AS titulos
FROM publishers p LEFT JOIN titles t ON t.publisher_id = p.id
WHERE p.id = 7
GROUP BY p.id, p.name;
DELETE FROM publishers WHERE id = 7
    AND NOT EXISTS (SELECT 1 FROM titles WHERE publisher_id = 7);

-- ⚠️ ESPERADO: ERROR 1062. El código BR-0001 ya existe y barcode es UNIQUE.
-- INSERT INTO copies (title_id, branch_id, barcode, acquired_on) VALUES (1, 1, 'BR-0001', '2026-11-10');

-- ⚠️ ESPERADO: ERROR 3819. El CHECK exige que la cuota sea mayor que cero.
-- INSERT INTO fine_payments (fine_id, amount, paid_on, payment_method) VALUES (1, 0.00, '2026-11-10', 'EFECTIVO');

-- ⚠️ ESPERADO: ERROR 1452. La FK de member_id exige un socio registrado.
-- INSERT INTO reservations (member_id, title_id, branch_id, reserved_on, expires_on) VALUES (9999, 1, 1, '2026-11-10', '2026-11-15');

-- Conteos esperados
SELECT 'branches' AS tabla, COUNT(*) AS filas FROM branches -- 5
UNION ALL SELECT 'memberships', COUNT(*) FROM memberships -- 5
UNION ALL SELECT 'categories', COUNT(*) FROM categories -- 8
UNION ALL SELECT 'publishers', COUNT(*) FROM publishers -- 6
UNION ALL SELECT 'authors', COUNT(*) FROM authors -- 10
UNION ALL SELECT 'employees', COUNT(*) FROM employees -- 6
UNION ALL SELECT 'titles', COUNT(*) FROM titles -- 14
UNION ALL SELECT 'title_authors', COUNT(*) FROM title_authors -- 17
UNION ALL SELECT 'copies', COUNT(*) FROM copies -- 25
UNION ALL SELECT 'members', COUNT(*) FROM members -- 14
UNION ALL SELECT 'loans', COUNT(*) FROM loans -- 20
UNION ALL SELECT 'renewals', COUNT(*) FROM renewals -- 3
UNION ALL SELECT 'reservations', COUNT(*) FROM reservations -- 7
UNION ALL SELECT 'fines', COUNT(*) FROM fines -- 5
UNION ALL SELECT 'fine_payments', COUNT(*) FROM fine_payments; -- 4

-- D14: 0 filas.
SELECT c.id AS ejemplar, c.barcode AS codigo, c.status AS estado, COUNT(l.id) AS prestamos_activos
FROM copies c
LEFT JOIN loans l ON l.copy_id = c.id AND l.status = 'ACTIVO'
GROUP BY c.id, c.barcode, c.status
HAVING COUNT(l.id) <> CASE WHEN c.status = 'PRESTADO' THEN 1 ELSE 0 END;
