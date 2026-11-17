USE bibliored;
SET autocommit = 1;

-- T1.1 · BR-0011, Clara y un empleado que no existe.
SELECT id, barcode, status FROM copies WHERE id = 11;
-- ⚠️ ESPERADO: ERROR 1452. La FK de employee_id rechaza al empleado 9999.
-- CALL sp_prestar_ejemplar(11, 13, 9999, '2026-11-10');

SELECT c.id, c.barcode, c.status
FROM copies c
WHERE c.status = 'PRESTADO'
    AND NOT EXISTS (
        SELECT 1 FROM loans l WHERE l.copy_id = c.id AND l.status = 'ACTIVO'
    );

-- T1.1 · Con la llamada de prueba, BR-0011 pasó de DISPONIBLE a PRESTADO.
-- Con autocommit, el UPDATE se confirmó antes del INSERT. La FK rechazó el INSERT
-- y el CALL por sí solo no deshizo el UPDATE.
SELECT id, barcode, status FROM copies WHERE id = 11 AND status = 'PRESTADO';
UPDATE copies SET status = 'DISPONIBLE' WHERE id = 11 AND status = 'PRESTADO';
SELECT id, barcode, status FROM copies WHERE id = 11;

-- T1.2 · La misma llamada dentro de una transacción.
START TRANSACTION;
-- ⚠️ ESPERADO: ERROR 1452. La FK de employee_id rechaza al empleado 9999.
-- CALL sp_prestar_ejemplar(11, 13, 9999, '2026-11-10');
SELECT status AS estado_antes_del_rollback FROM copies WHERE id = 11;
ROLLBACK;
SELECT status AS estado_despues_del_rollback FROM copies WHERE id = 11;
-- Con la llamada de prueba: PRESTADO antes del ROLLBACK, DISPONIBLE después.

-- T2
DROP PROCEDURE IF EXISTS sp_prestar_ejemplar_tx;
DELIMITER $$
CREATE PROCEDURE sp_prestar_ejemplar_tx(
    IN p_copy_id BIGINT, IN p_member_id BIGINT, IN p_employee_id BIGINT, IN p_loaned_on DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    CALL sp_prestar_ejemplar(p_copy_id, p_member_id, p_employee_id, p_loaned_on);
    COMMIT;
END $$
DELIMITER ;

-- T2 · Antes de las llamadas: 22 préstamos. Último número: 1022.
SELECT COUNT(*) AS prestamos_antes, MAX(id) AS ultimo_prestamo FROM loans;

-- T2 · Caso 1. BR-0011 está disponible y el empleado 9999 no existe.
-- ⚠️ ESPERADO: ERROR 1452. La FK de employee_id rechaza al empleado 9999.
-- CALL sp_prestar_ejemplar_tx(11, 13, 9999, '2026-11-10');
SELECT status AS estado_ejemplar FROM copies WHERE id = 11;
SELECT COUNT(*) AS prestamos_despues_del_caso_1 FROM loans;

-- T2 · Caso 2. BR-0001 sigue prestado a Julián.
-- ⚠️ ESPERADO: ERROR 1644. El ejemplar no está disponible: PRESTADO
-- CALL sp_prestar_ejemplar_tx(1, 13, 1, '2026-11-10');
SELECT COUNT(*) AS prestamos_despues_del_caso_2 FROM loans;

-- T2 · Caso 3. Patricia le presta BR-0011 a Clara.
CALL sp_prestar_ejemplar_tx(11, 13, 1, '2026-11-10');
SELECT COUNT(*) AS prestamos_despues_del_caso_3, MAX(id) AS ultimo_prestamo FROM loans;
SELECT c.status AS estado_ejemplar, l.id AS prestamo, l.due_on AS vence
FROM copies c JOIN loans l ON l.copy_id = c.id AND l.status = 'ACTIVO'
WHERE c.id = 11;

-- Con las pruebas de error ejecutadas, el préstamo nuevo fue el 1026.
-- Los INSERT rechazados por la FK reservaron los números 1023 a 1025.
-- El ROLLBACK no devuelve esos números al contador AUTO_INCREMENT.

SELECT estados.*, (ejemplares_prestados = prestamos_activos) AS coinciden
FROM (
    SELECT
        (SELECT COUNT(*) FROM copies WHERE status = 'PRESTADO') AS ejemplares_prestados,
        (SELECT COUNT(*) FROM loans WHERE status = 'ACTIVO') AS prestamos_activos
) AS estados;

-- D14: 0 filas.
SELECT c.id AS ejemplar, COUNT(l.id) AS prestamos_activos
FROM copies c
LEFT JOIN loans l ON l.copy_id = c.id AND l.status = 'ACTIVO'
GROUP BY c.id, c.status
HAVING COUNT(l.id) <> CASE WHEN c.status = 'PRESTADO' THEN 1 ELSE 0 END;
