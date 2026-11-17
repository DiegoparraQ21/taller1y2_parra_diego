USE bibliored;

DROP PROCEDURE IF EXISTS sp_resumen_socio;
DELIMITER $$
CREATE PROCEDURE sp_resumen_socio(IN p_member_id BIGINT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM members WHERE id = p_member_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio no existe';
    END IF;

    SELECT (
        SELECT COUNT(*) FROM loans
        WHERE member_id = p_member_id AND status = 'ACTIVO'
    ) AS prestamos_activos,
    COALESCE((
        SELECT SUM(f.amount - COALESCE(a.pagado, 0))
        FROM loans l
        JOIN fines f ON f.loan_id = l.id AND f.status = 'PENDIENTE'
        LEFT JOIN (
            SELECT fine_id, SUM(amount) AS pagado
            FROM fine_payments GROUP BY fine_id
        ) AS a ON a.fine_id = f.id
        WHERE l.member_id = p_member_id
    ), 0.00) AS saldo_pendiente;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_prestar_ejemplar;
DELIMITER $$
CREATE PROCEDURE sp_prestar_ejemplar(
    IN p_copy_id BIGINT, IN p_member_id BIGINT, IN p_employee_id BIGINT, IN p_loaned_on DATE
)
BEGIN
    DECLARE v_member_status VARCHAR(15);
    DECLARE v_copy_status VARCHAR(15);
    DECLARE v_loan_limit SMALLINT;
    DECLARE v_loan_days SMALLINT;
    DECLARE v_message VARCHAR(128);

    SELECT m.status, ms.loan_limit, ms.loan_days
    INTO v_member_status, v_loan_limit, v_loan_days
    FROM members m
    JOIN memberships ms ON ms.id = m.membership_id
    WHERE m.id = p_member_id
    FOR UPDATE OF m;

    IF v_member_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio no existe';
    END IF;
    IF v_member_status <> 'ACTIVO' THEN
        SET v_message = CONCAT('El socio no está activo: ', v_member_status);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
    END IF;

    SELECT status INTO v_copy_status FROM copies WHERE id = p_copy_id FOR UPDATE;
    IF v_copy_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar no existe';
    END IF;
    IF v_copy_status <> 'DISPONIBLE' THEN
        SET v_message = CONCAT('El ejemplar no está disponible: ', v_copy_status);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
    END IF;

    IF EXISTS (
        SELECT 1 FROM loans l JOIN fines f ON f.loan_id = l.id
        WHERE l.member_id = p_member_id AND f.status = 'PENDIENTE'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio tiene multas pendientes';
    END IF;
    IF (SELECT COUNT(*) FROM loans WHERE member_id = p_member_id AND status = 'ACTIVO') >= v_loan_limit THEN
        SET v_message = CONCAT('El socio alcanzó su tope de ', v_loan_limit, ' préstamos');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
    END IF;

    UPDATE copies SET status = 'PRESTADO' WHERE id = p_copy_id;
    INSERT INTO loans (copy_id, member_id, employee_id, loaned_on, due_on)
    VALUES (p_copy_id, p_member_id, p_employee_id, p_loaned_on,
            DATE_ADD(p_loaned_on, INTERVAL v_loan_days DAY));
    SELECT LAST_INSERT_ID() AS prestamo;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_devolver_ejemplar;
DELIMITER $$
CREATE PROCEDURE sp_devolver_ejemplar(IN p_loan_id BIGINT, IN p_returned_on DATE)
BEGIN
    DECLARE v_status VARCHAR(10);
    DECLARE v_copy_id BIGINT;
    DECLARE v_loaned_on DATE;
    DECLARE v_due_on DATE;
    DECLARE v_daily_fine DECIMAL(10,2);
    DECLARE v_late_days INT;
    DECLARE v_amount DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT l.status, l.copy_id, l.loaned_on, l.due_on, ms.daily_fine
    INTO v_status, v_copy_id, v_loaned_on, v_due_on, v_daily_fine
    FROM loans l
    JOIN members m ON m.id = l.member_id
    JOIN memberships ms ON ms.id = m.membership_id
    WHERE l.id = p_loan_id
    FOR UPDATE OF l;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo no existe';
    END IF;
    IF v_status <> 'ACTIVO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo no está activo';
    END IF;
    IF p_returned_on < v_loaned_on THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de devolución es anterior al préstamo';
    END IF;

    SET v_late_days = GREATEST(DATEDIFF(p_returned_on, v_due_on), 0);
    SET v_amount = v_late_days * v_daily_fine;
    IF v_amount > 0 THEN
        INSERT INTO fines (loan_id, reason, late_days, amount, issued_on)
        VALUES (p_loan_id, 'MORA', v_late_days, v_amount, p_returned_on);
    END IF;

    UPDATE loans SET returned_on = p_returned_on, status = 'DEVUELTO' WHERE id = p_loan_id;
    UPDATE copies SET status = 'DISPONIBLE' WHERE id = v_copy_id;
    COMMIT;
    SELECT v_amount AS multa_generada;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_renovar_prestamo;
DELIMITER $$
CREATE PROCEDURE sp_renovar_prestamo(IN p_loan_id BIGINT, IN p_renewed_on DATE)
BEGIN
    DECLARE v_status VARCHAR(10);
    DECLARE v_due_on DATE;
    DECLARE v_new_due_on DATE;
    DECLARE v_title_id BIGINT;
    DECLARE v_loan_days SMALLINT;
    DECLARE v_renewal_limit SMALLINT;
    DECLARE v_message VARCHAR(128);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT l.status, l.due_on, c.title_id, ms.loan_days, ms.renewal_limit
    INTO v_status, v_due_on, v_title_id, v_loan_days, v_renewal_limit
    FROM loans l
    JOIN copies c ON c.id = l.copy_id
    JOIN members m ON m.id = l.member_id
    JOIN memberships ms ON ms.id = m.membership_id
    WHERE l.id = p_loan_id
    FOR UPDATE OF l;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo no existe';
    END IF;
    IF v_status <> 'ACTIVO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo no está activo';
    END IF;
    IF p_renewed_on > v_due_on THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo está vencido: primero debe devolverse';
    END IF;
    IF (SELECT COUNT(*) FROM renewals WHERE loan_id = p_loan_id) >= v_renewal_limit THEN
        SET v_message = CONCAT('El préstamo ya usó sus ', v_renewal_limit, ' renovaciones');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
    END IF;
    IF EXISTS (SELECT 1 FROM reservations WHERE title_id = v_title_id AND status = 'PENDIENTE') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay reservas pendientes para este título';
    END IF;

    SET v_new_due_on = DATE_ADD(v_due_on, INTERVAL v_loan_days DAY);
    INSERT INTO renewals (loan_id, renewed_on, previous_due_on, new_due_on)
    VALUES (p_loan_id, p_renewed_on, v_due_on, v_new_due_on);
    UPDATE loans SET due_on = v_new_due_on WHERE id = p_loan_id;
    COMMIT;
    SELECT v_new_due_on AS nuevo_vencimiento;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_reporte_sedes;
DELIMITER $$
CREATE PROCEDURE sp_reporte_sedes(IN p_cutoff DATE)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_branch_id BIGINT;
    DECLARE v_branch_name VARCHAR(100);
    DECLARE v_copies BIGINT;
    DECLARE v_loaned BIGINT;
    DECLARE v_overdue BIGINT;

    DECLARE branch_cursor CURSOR FOR SELECT id, name FROM branches ORDER BY id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS branch_report;
    CREATE TEMPORARY TABLE branch_report (
        sede VARCHAR(100) NOT NULL,
        ejemplares BIGINT NOT NULL,
        prestados BIGINT NOT NULL,
        vencidos BIGINT NOT NULL,
        ocupacion_pct DECIMAL(7,2)
    );

    OPEN branch_cursor;
    branch_loop: LOOP
        FETCH branch_cursor INTO v_branch_id, v_branch_name;
        IF v_done THEN
            LEAVE branch_loop;
        END IF;

        SELECT COUNT(*) INTO v_copies FROM copies
        WHERE branch_id = v_branch_id AND status NOT IN ('PERDIDO', 'DADO_DE_BAJA');

        SELECT COUNT(*), COUNT(CASE WHEN l.due_on < p_cutoff THEN 1 END)
        INTO v_loaned, v_overdue
        FROM loans l JOIN copies c ON c.id = l.copy_id
        WHERE c.branch_id = v_branch_id AND l.status = 'ACTIVO';

        INSERT INTO branch_report (sede, ejemplares, prestados, vencidos, ocupacion_pct)
        VALUES (v_branch_name, v_copies, v_loaned, v_overdue,
                ROUND(v_loaned * 100.00 / NULLIF(v_copies, 0), 2));
    END LOOP;
    CLOSE branch_cursor;

    SELECT sede, ejemplares, prestados, vencidos, ocupacion_pct
    FROM branch_report
    ORDER BY ocupacion_pct DESC, sede;
    DROP TEMPORARY TABLE branch_report;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_pagar_multa;
DELIMITER $$
CREATE PROCEDURE sp_pagar_multa(
    IN p_fine_id BIGINT, IN p_amount DECIMAL(12,2), IN p_payment_method TEXT, IN p_paid_on DATE
)
BEGIN
    DECLARE v_status VARCHAR(10);
    DECLARE v_fine_amount DECIMAL(12,2);
    DECLARE v_balance DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT status, amount INTO v_status, v_fine_amount
    FROM fines WHERE id = p_fine_id FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La multa no existe';
    END IF;
    IF v_status <> 'PENDIENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La multa no está pendiente';
    END IF;

    SELECT v_fine_amount - COALESCE(SUM(amount), 0)
    INTO v_balance FROM fine_payments WHERE fine_id = p_fine_id;
    IF p_amount IS NULL OR p_amount <= 0 OR p_amount > v_balance THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El abono debe ser mayor que 0 y no superar el saldo';
    END IF;

    BEGIN
        DECLARE EXIT HANDLER FOR 1265
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Medio de pago no válido: use EFECTIVO, TARJETA o TRANSFERENCIA';

        INSERT INTO fine_payments (fine_id, amount, paid_on, payment_method)
        VALUES (p_fine_id, p_amount, p_paid_on, COALESCE(p_payment_method, ''));
    END;

    SET v_balance = v_balance - p_amount;
    IF v_balance = 0 THEN
        UPDATE fines SET status = 'PAGADA' WHERE id = p_fine_id;
    END IF;
    COMMIT;
    SELECT v_balance AS saldo;
END $$
DELIMITER ;

-- sp_resumen_socio · prueba 1. Inés está suspendida. Tiene 1 activo y debe 2000.00.
CALL sp_resumen_socio(3);

-- sp_resumen_socio · prueba 2. Julián tiene 2 activos y saldo 0.00.
CALL sp_resumen_socio(1);

-- sp_resumen_socio · prueba 3. El socio 9999 no existe.
-- ⚠️ ESPERADO: ERROR 1644. El socio no existe
-- CALL sp_resumen_socio(9999);

-- sp_prestar_ejemplar · prueba 1. Mateo no tiene préstamos ni multas y BR-0010 está disponible.
CALL sp_prestar_ejemplar(10, 14, 1, '2026-11-10');
SET @prestamo_mateo = LAST_INSERT_ID();
SELECT l.id AS prestamo, l.due_on AS vence, c.status AS estado_ejemplar
FROM loans l JOIN copies c ON c.id = l.copy_id
WHERE l.id = @prestamo_mateo;

-- sp_prestar_ejemplar · prueba 2. Inés está suspendida y tiene una multa pendiente.
-- ⚠️ ESPERADO: ERROR 1644. El socio no está activo: SUSPENDIDO
-- CALL sp_prestar_ejemplar(12, 3, 1, '2026-11-10');

-- sp_prestar_ejemplar · prueba 3. Nora está activa y BR-0001 está prestado.
-- ⚠️ ESPERADO: ERROR 1644. El ejemplar no está disponible: PRESTADO
-- CALL sp_prestar_ejemplar(1, 2, 1, '2026-11-10');

-- sp_prestar_ejemplar · prueba 4. Felipe tiene la multa de reposición pendiente.
-- ⚠️ ESPERADO: ERROR 1644. El socio tiene multas pendientes
-- CALL sp_prestar_ejemplar(12, 4, 1, '2026-11-10');

-- sp_prestar_ejemplar · prueba 5. Julián tiene dos préstamos activos y su membresía es Básica.
-- ⚠️ ESPERADO: ERROR 1644. El socio alcanzó su tope de 2 préstamos
-- CALL sp_prestar_ejemplar(12, 1, 1, '2026-11-10');

-- sp_prestar_ejemplar · prueba 6. Nora está activa y el ejemplar 9999 no existe.
-- ⚠️ ESPERADO: ERROR 1644. El ejemplar no existe
-- CALL sp_prestar_ejemplar(9999, 2, 1, '2026-11-10');

-- sp_devolver_ejemplar · prueba 1. El 1009 tiene 12 días de mora a 300.00.
CALL sp_devolver_ejemplar(1009, '2026-11-10');
SELECT loan_id AS prestamo, late_days AS dias_mora, amount AS multa, status AS estado
FROM fines WHERE loan_id = 1009;

-- sp_devolver_ejemplar · prueba 2. El 1008 vence el 18 de noviembre.
CALL sp_devolver_ejemplar(1008, '2026-11-10');
SELECT COUNT(*) AS multas FROM fines WHERE loan_id = 1008;

-- sp_devolver_ejemplar · prueba 3. El 1001 se devolvió en septiembre.
-- ⚠️ ESPERADO: ERROR 1644. El préstamo no está activo
-- CALL sp_devolver_ejemplar(1001, '2026-11-10');

-- sp_devolver_ejemplar · prueba 4. El préstamo 1013 empezó el 1 de noviembre.
-- ⚠️ ESPERADO: ERROR 1644. La fecha de devolución es anterior al préstamo
-- CALL sp_devolver_ejemplar(1013, '2026-10-31');

-- sp_renovar_prestamo · prueba 1. El préstamo de Mateo sigue al día, sin renovaciones ni reservas pendientes del título.
CALL sp_renovar_prestamo(@prestamo_mateo, '2026-11-10');
SELECT loan_id AS prestamo, previous_due_on AS vencimiento_anterior, new_due_on AS nuevo_vencimiento
FROM renewals WHERE loan_id = @prestamo_mateo;

-- sp_renovar_prestamo · prueba 2. El 1007 vence el día de corte y ya agotó las dos renovaciones de Estudiante.
-- ⚠️ ESPERADO: ERROR 1644. El préstamo ya usó sus 2 renovaciones
-- CALL sp_renovar_prestamo(1007, '2026-11-10');

-- sp_renovar_prestamo · prueba 3. El 1014 venció el 5 de noviembre.
-- ⚠️ ESPERADO: ERROR 1644. El préstamo está vencido: primero debe devolverse
-- CALL sp_renovar_prestamo(1014, '2026-11-10');

-- sp_renovar_prestamo · prueba 4. La reserva 1 es del título del préstamo 1013.
-- ⚠️ ESPERADO: ERROR 1644. Hay reservas pendientes para este título
-- CALL sp_renovar_prestamo(1013, '2026-11-10');

-- sp_reporte_sedes · pruebas 1 y 2. Queda vencido el 1014 en Cajicá. Tabio tiene 0, 0, 0 y NULL.
CALL sp_reporte_sedes('2026-11-10');

-- sp_pagar_multa · prueba 1. Felipe debe 68000.00 por reposición y no tiene abonos.
CALL sp_pagar_multa(2, 68000.00, 'EFECTIVO', '2026-11-10');
SELECT id AS multa, status AS estado FROM fines WHERE id = 2;

-- sp_pagar_multa · prueba 2. Felipe vuelve a pedir BR-0012 con la multa saldada.
CALL sp_prestar_ejemplar(12, 4, 1, '2026-11-10');

-- sp_pagar_multa · prueba 3. La multa 1 ya tenía un abono de 1000.00 y queda debiendo 1500.00.
CALL sp_pagar_multa(1, 500.00, 'TARJETA', '2026-11-10');

-- sp_pagar_multa · prueba 4. La multa 4 quedó pagada desde octubre.
-- ⚠️ ESPERADO: ERROR 1644. La multa no está pendiente
-- CALL sp_pagar_multa(4, 100.00, 'EFECTIVO', '2026-11-10');

-- sp_pagar_multa · prueba 5. La multa 1 tiene saldo de 1500.00.
-- ⚠️ ESPERADO: ERROR 1644. El abono debe ser mayor que 0 y no superar el saldo
-- CALL sp_pagar_multa(1, 1501.00, 'EFECTIVO', '2026-11-10');

-- sp_pagar_multa · prueba 6. La multa 1 admite un abono de 100.00 con un medio válido.
-- ⚠️ ESPERADO: ERROR 1644. Medio de pago no válido: use EFECTIVO, TARJETA o TRANSFERENCIA
-- CALL sp_pagar_multa(1, 100.00, 'CHEQUE', '2026-11-10');

SHOW PROCEDURE STATUS WHERE Db = 'bibliored';
