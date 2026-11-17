USE flotaya;

-- fn_prueba_1418
-- Con binlog activo y log_bin_trust_function_creators = 0, MySQL exige declarar
-- DETERMINISTIC, NO SQL o READS SQL DATA para evaluar la seguridad de la función.
-- Si el binlog está desactivado o se confía en los creadores, 1418 puede no aparecer.
DROP FUNCTION IF EXISTS fn_prueba_1418;
-- ⚠️ ESPERADO: ERROR 1418 bajo la configuración descrita arriba.
-- CREATE FUNCTION fn_prueba_1418() RETURNS INT RETURN 1;

-- Mismos argumentos, misma edad. No lee tablas.
DROP FUNCTION IF EXISTS fn_edad_conductor;
DELIMITER $$
CREATE FUNCTION fn_edad_conductor(p_birth_date DATE, p_reference DATE)
RETURNS INT DETERMINISTIC NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_birth_date, p_reference);
END $$
DELIMITER ;

-- El resultado depende de las tarifas y del calendario, que pueden cambiar.
DROP FUNCTION IF EXISTS fn_valor_alquiler;
DELIMITER $$
CREATE FUNCTION fn_valor_alquiler(p_category_id BIGINT, p_start DATE, p_end DATE)
RETURNS DECIMAL(12,2) NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_day DATE;
    DECLARE v_price DECIMAL(12,2);
    DECLARE v_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_matches INT;
    DECLARE v_message VARCHAR(128);
    IF p_start IS NULL OR p_end IS NULL OR p_end <= p_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha final debe ser posterior a la inicial';
    END IF;
    SET v_day = p_start;
    WHILE v_day < p_end DO
        SELECT COUNT(*), MAX(r.daily_price) INTO v_matches, v_price
        FROM seasons s JOIN rates r ON r.season_type_id = s.season_type_id
        WHERE r.category_id = p_category_id AND v_day BETWEEN s.starts_on AND s.ends_on;
        IF v_matches = 0 THEN
            SET v_message = CONCAT('No hay temporada o tarifa para el día ', v_day);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
        END IF;
        IF v_matches > 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay temporadas cruzadas en el calendario';
        END IF;
        SET v_total = v_total + v_price;
        SET v_day = DATE_ADD(v_day, INTERVAL 1 DAY);
    END WHILE;
    RETURN v_total;
END $$
DELIMITER ;

-- Consulta licencias. Una renovación registrada puede cambiar la respuesta.
DROP FUNCTION IF EXISTS fn_licencia_vigente;
DELIMITER $$
CREATE FUNCTION fn_licencia_vigente(p_customer_id BIGINT, p_date DATE)
RETURNS BOOLEAN NOT DETERMINISTIC READS SQL DATA
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM licenses WHERE customer_id = p_customer_id
        AND issued_on <= p_date AND expires_on >= p_date
    );
END $$
DELIMITER ;

-- Funciones · pruebas
SELECT fn_edad_conductor('2004-07-15', '2026-07-14') AS edad_21,
       fn_edad_conductor('2004-07-15', '2026-07-15') AS edad_22;
SELECT fn_valor_alquiler(1, '2026-11-27', '2026-12-02') AS economico_620000,
       fn_valor_alquiler(5, '2026-12-18', '2026-12-23') AS van_2300000,
       fn_valor_alquiler(3, '2026-10-08', '2026-10-12') AS suv_1080000,
       fn_valor_alquiler(6, '2026-12-14', '2026-12-16') AS lujo_1202500;
-- ⚠️ ESPERADO: ERROR 1644. La fecha final debe ser posterior a la inicial
-- SELECT fn_valor_alquiler(1, '2026-12-05', '2026-12-05');
-- ⚠️ ESPERADO: ERROR 1644. No hay temporada o tarifa para el día 2027-01-16
-- SELECT fn_valor_alquiler(1, '2027-01-14', '2027-01-18');
SELECT fn_licencia_vigente(7, '2026-11-23') AS jorge_1,
       fn_licencia_vigente(8, '2026-11-23') AS paola_1,
       fn_licencia_vigente(8, '2026-12-15') AS paola_0,
       fn_licencia_vigente(9, '2026-12-15') AS esteban_0,
       fn_licencia_vigente(12, '2026-12-15') AS laura_0;

SELECT CONCAT(first_names, ' ', last_names) AS cliente, birth_date AS nacimiento,
       fn_edad_conductor(birth_date, '2026-11-23') AS edad,
       IF(fn_edad_conductor(birth_date, '2026-11-23') >= 23 AND status = 'ACTIVO'
           AND fn_licencia_vigente(id, '2026-11-23'), 'Sí', 'No') AS puede_suv,
       IF(fn_edad_conductor(birth_date, '2026-11-23') >= 25 AND status = 'ACTIVO'
           AND fn_licencia_vigente(id, '2026-11-23'), 'Sí', 'No') AS puede_4x4_o_van
FROM customers WHERE fn_edad_conductor(birth_date, '2026-11-23') < 25
ORDER BY edad, id;
SELECT id, CONCAT(first_names, ' ', last_names) AS cliente,
       fn_licencia_vigente(id, '2026-11-23') AS vigente_al_corte,
       fn_licencia_vigente(id, '2026-12-15') AS vigente_15_dic
FROM customers WHERE NOT fn_licencia_vigente(id, '2026-12-15') ORDER BY id;

DROP PROCEDURE IF EXISTS sp_crear_reserva;
DELIMITER $$
CREATE PROCEDURE sp_crear_reserva(
    IN p_customer_id BIGINT, IN p_vehicle_id BIGINT,
    IN p_pickup_branch_id BIGINT, IN p_return_branch_id BIGINT,
    IN p_start DATE, IN p_end DATE, OUT p_reservation_id BIGINT
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_status VARCHAR(25);
    DECLARE v_birth DATE;
    DECLARE v_category_id BIGINT;
    DECLARE v_minimum_age INT;
    DECLARE v_age INT;
    DECLARE v_amount DECIMAL(12,2);
    DECLARE v_message VARCHAR(128);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_reservation_id = NULL;
        RESIGNAL;
    END;

    SET p_reservation_id = NULL;
    START TRANSACTION;
    SELECT status, birth_date INTO v_status, v_birth
    FROM customers WHERE id = p_customer_id FOR UPDATE;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no existe';
    END IF;
    IF v_status = 'BLOQUEADO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente está bloqueado';
    END IF;
    IF p_start IS NULL OR p_end IS NULL OR p_end <= p_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La devolución debe ser posterior a la recogida';
    END IF;
    SET v_status = NULL;
    SELECT v.status, m.category_id, c.minimum_age INTO v_status, v_category_id, v_minimum_age
    FROM vehicles v JOIN models m ON m.id = v.model_id
    JOIN categories c ON c.id = m.category_id WHERE v.id = p_vehicle_id FOR UPDATE;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vehículo no existe';
    END IF;
    IF v_status = 'FUERA_DE_SERVICIO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vehículo está fuera de servicio';
    END IF;
    IF EXISTS (
        SELECT 1 FROM reservations WHERE vehicle_id = p_vehicle_id
        AND status <> 'CANCELADA' AND starts_on <= p_end AND ends_on >= p_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vehículo ya está reservado en esas fechas';
    END IF;
    SET v_age = fn_edad_conductor(v_birth, p_start);
    IF v_age < v_minimum_age THEN
        SET v_message = CONCAT('El cliente tiene ', v_age, ' años y la categoría exige ', v_minimum_age);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
    END IF;
    IF NOT fn_licencia_vigente(p_customer_id, p_end) OR NOT EXISTS (
        SELECT 1 FROM licenses WHERE customer_id = p_customer_id
        AND issued_on <= p_start AND expires_on >= p_end
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no tiene licencia vigente durante todo el alquiler';
    END IF;

    SET v_amount = fn_valor_alquiler(v_category_id, p_start, p_end);
    INSERT INTO reservations (
        customer_id, vehicle_id, pickup_branch_id, return_branch_id,
        starts_on, ends_on, quoted_amount, created_at
    ) VALUES (
        p_customer_id, p_vehicle_id, p_pickup_branch_id, p_return_branch_id,
        p_start, p_end, v_amount, '2026-11-23 08:00:00'
    );
    SET p_reservation_id = LAST_INSERT_ID();
    COMMIT;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_cerrar_contrato;
DELIMITER $$
CREATE PROCEDURE sp_cerrar_contrato(IN p_contract_id BIGINT, IN p_closed_on DATE, OUT p_balance DECIMAL(12,2))
SQL SECURITY DEFINER
BEGIN
    DECLARE v_status VARCHAR(10);
    DECLARE v_start DATE;
    DECLARE v_vehicle_id BIGINT;
    DECLARE v_category_id BIGINT;
    DECLARE v_return_id BIGINT;
    DECLARE v_return_at DATETIME;
    DECLARE v_branch_id BIGINT;
    DECLARE v_mileage INT;
    DECLARE v_deposit_id BIGINT;
    DECLARE v_deposit DECIMAL(12,2);
    DECLARE v_rental DECIMAL(12,2);
    DECLARE v_extras DECIMAL(12,2);
    DECLARE v_damages DECIMAL(12,2);
    DECLARE v_applied DECIMAL(12,2);
    DECLARE v_paid DECIMAL(12,2);

    -- La transacción la abre quien llama. Este punto permite deshacer el cierre si falla.
    SAVEPOINT antes_cierre;
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK TO SAVEPOINT antes_cierre;
            SET p_balance = NULL;
            RESIGNAL;
        END;
        SET p_balance = NULL;
        SELECT status, starts_on, vehicle_id INTO v_status, v_start, v_vehicle_id
        FROM contracts WHERE id = p_contract_id FOR UPDATE;
        IF v_status IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El contrato no existe';
        END IF;
        IF v_status <> 'ABIERTO' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El contrato no está abierto';
        END IF;
        SELECT id, returned_at, branch_id, mileage_km
        INTO v_return_id, v_return_at, v_branch_id, v_mileage
        FROM returns WHERE contract_id = p_contract_id;
        IF v_return_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El contrato no tiene devolución registrada';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM inspections WHERE contract_id = p_contract_id AND stage = 'DEVOLUCION') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Falta la inspección de devolución';
        END IF;
        IF p_closed_on IS NULL OR p_closed_on <= v_start THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de cierre debe ser posterior al inicio';
        END IF;
        SELECT m.category_id INTO v_category_id
        FROM vehicles v JOIN models m ON m.id = v.model_id WHERE v.id = v_vehicle_id;
        SET v_rental = fn_valor_alquiler(v_category_id, v_start, DATE(v_return_at));
        SELECT COALESCE(SUM(quantity * agreed_daily_price), 0) * DATEDIFF(DATE(v_return_at), v_start)
        INTO v_extras FROM contract_extras WHERE contract_id = p_contract_id;
        SELECT COALESCE(SUM(d.repair_cost), 0) INTO v_damages
        FROM damages d JOIN inspections i ON i.id = d.inspection_id
        WHERE i.contract_id = p_contract_id AND i.stage = 'DEVOLUCION' AND d.charge_customer = TRUE;
        SELECT id, amount INTO v_deposit_id, v_deposit
        FROM deposits WHERE contract_id = p_contract_id FOR UPDATE;
        IF v_deposit_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El contrato no tiene depósito';
        END IF;
        SET v_applied = LEAST(v_deposit, v_damages);
        UPDATE deposits
        SET applied_amount = v_applied,
            released_at = TIMESTAMP(p_closed_on, TIME(v_return_at)),
            status = IF(v_applied > 0, 'APLICADO', 'LIBERADO')
        WHERE id = v_deposit_id;
        IF v_applied > 0 THEN
            INSERT INTO payments (contract_id, concept, amount, method, paid_at)
            VALUES (p_contract_id, 'DAÑOS', v_applied, 'DEPOSITO', TIMESTAMP(p_closed_on, TIME(v_return_at)));
        END IF;
        UPDATE contracts SET returned_on = DATE(v_return_at), rental_amount = v_rental, status = 'CERRADO'
        WHERE id = p_contract_id;
        UPDATE vehicles SET branch_id = v_branch_id, mileage_km = v_mileage, status = 'DISPONIBLE'
        WHERE id = v_vehicle_id;
        SELECT COALESCE(SUM(amount), 0) INTO v_paid FROM payments WHERE contract_id = p_contract_id;
        SET p_balance = v_rental + v_extras + v_damages - v_paid;
    END;
    RELEASE SAVEPOINT antes_cierre;
END $$
DELIMITER ;

-- Pruebas que dejan datos. El control evita repetirlas al ejecutar 04 por segunda vez.
DROP PROCEDURE IF EXISTS sp_pruebas_fase_5;
DELIMITER $$
CREATE PROCEDURE sp_pruebas_fase_5()
BEGIN
    DECLARE v_reservation_id BIGINT;
    DECLARE v_balance DECIMAL(12,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- sp_crear_reserva · prueba 1
    IF NOT EXISTS (
        SELECT 1 FROM reservations WHERE customer_id = 7 AND vehicle_id = 14
        AND starts_on = '2026-12-19' AND ends_on = '2026-12-22' AND status <> 'CANCELADA'
    ) THEN
        CALL sp_crear_reserva(7, 14, 3, 3, '2026-12-19', '2026-12-22', v_reservation_id);
    END IF;
    SELECT id AS reserva, status AS estado, quoted_amount AS cotizado
    FROM reservations WHERE customer_id = 7 AND vehicle_id = 14 AND starts_on = '2026-12-19';

    -- sp_cerrar_contrato · prueba 3
    IF EXISTS (SELECT 1 FROM contracts WHERE id = 9007 AND status = 'ABIERTO') THEN
        START TRANSACTION;
        INSERT INTO returns (contract_id, branch_id, employee_id, returned_at, mileage_km, fuel_pct)
        VALUES (9007, 1, 13, '2026-11-21 10:00:00', 30910, 100);
        INSERT INTO inspections (contract_id, employee_id, stage, inspected_at, exterior_ok, interior_ok)
        VALUES (9007, 13, 'DEVOLUCION', '2026-11-21 10:10:00', TRUE, TRUE);
        CALL sp_cerrar_contrato(9007, '2026-11-21', v_balance);
        SELECT v_balance AS saldo_60000;
        COMMIT;
    END IF;
    SELECT c.id AS contrato, c.status AS estado_contrato, c.rental_amount AS alquiler,
           v.plate AS placa, v.status AS estado_vehiculo, v.mileage_km AS kilometraje,
           b.name AS sede, d.status AS deposito
    FROM contracts c JOIN vehicles v ON v.id = c.vehicle_id
    JOIN branches b ON b.id = v.branch_id JOIN deposits d ON d.contract_id = c.id WHERE c.id = 9007;
END $$
DELIMITER ;

-- sp_crear_reserva · prueba 2. Carlos cumple edad y licencia, pero las fechas se cruzan.
-- ⚠️ ESPERADO: ERROR 1644. El vehículo ya está reservado en esas fechas
-- CALL sp_crear_reserva(2, 1, 1, 1, '2026-11-30', '2026-12-04', @reserva);
-- sp_crear_reserva · prueba 3
-- ⚠️ ESPERADO: ERROR 1644. El cliente tiene 22 años y la categoría exige 23
-- CALL sp_crear_reserva(3, 13, 4, 4, '2026-12-12', '2026-12-14', @reserva);
-- sp_crear_reserva · prueba 4
-- ⚠️ ESPERADO: ERROR 1644. El cliente no tiene licencia vigente durante todo el alquiler
-- CALL sp_crear_reserva(8, 2, 2, 2, '2026-12-08', '2026-12-12', @reserva);
-- sp_crear_reserva · prueba 5
-- ⚠️ ESPERADO: ERROR 1644. El cliente está bloqueado
-- CALL sp_crear_reserva(10, 2, 2, 2, '2026-12-01', '2026-12-03', @reserva);
-- sp_crear_reserva · prueba 6
-- ⚠️ ESPERADO: ERROR 1644. El vehículo está fuera de servicio
-- CALL sp_crear_reserva(1, 3, 6, 6, '2026-12-01', '2026-12-03', @reserva);

START TRANSACTION;
-- sp_cerrar_contrato · prueba 1
-- ⚠️ ESPERADO: ERROR 1644. El contrato no está abierto
-- CALL sp_cerrar_contrato(9001, '2026-11-23', @saldo);
ROLLBACK;
START TRANSACTION;
-- sp_cerrar_contrato · prueba 2
-- ⚠️ ESPERADO: ERROR 1644. El contrato no tiene devolución registrada
-- CALL sp_cerrar_contrato(9008, '2026-11-23', @saldo);
ROLLBACK;

CALL sp_pruebas_fase_5();
DROP PROCEDURE IF EXISTS sp_pruebas_fase_5;

-- Roles y cuentas de práctica
DROP USER IF EXISTS 'asesor_flotaya'@'localhost', 'taller_flotaya'@'localhost', 'auditor_flotaya'@'localhost';
DROP ROLE IF EXISTS 'rol_asesor_flotaya', 'rol_taller_flotaya', 'rol_auditor_flotaya';
CREATE ROLE 'rol_asesor_flotaya', 'rol_taller_flotaya', 'rol_auditor_flotaya';
CREATE USER 'asesor_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
CREATE USER 'taller_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
CREATE USER 'auditor_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';

GRANT SELECT, UPDATE (status) ON flotaya.reservations TO 'rol_asesor_flotaya';
GRANT SELECT ON flotaya.customers TO 'rol_asesor_flotaya';
GRANT SELECT ON flotaya.vehicles TO 'rol_asesor_flotaya';
GRANT EXECUTE ON PROCEDURE flotaya.sp_crear_reserva TO 'rol_asesor_flotaya';
GRANT EXECUTE ON FUNCTION flotaya.fn_valor_alquiler TO 'rol_asesor_flotaya';

GRANT SELECT, INSERT, UPDATE ON flotaya.maintenances TO 'rol_taller_flotaya';
GRANT SELECT (id, plate, status, mileage_km, branch_id), UPDATE (status)
ON flotaya.vehicles TO 'rol_taller_flotaya';

GRANT SELECT ON flotaya.contracts TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.reservations TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.vehicles TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.maintenances TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.returns TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.inspections TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.damages TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.deposits TO 'rol_auditor_flotaya';
GRANT SELECT (id, contract_id, concept, amount, paid_at)
ON flotaya.payments TO 'rol_auditor_flotaya';

GRANT 'rol_asesor_flotaya' TO 'asesor_flotaya'@'localhost';
GRANT 'rol_taller_flotaya' TO 'taller_flotaya'@'localhost';
GRANT 'rol_auditor_flotaya' TO 'auditor_flotaya'@'localhost';
SET DEFAULT ROLE 'rol_asesor_flotaya' TO 'asesor_flotaya'@'localhost';
SET DEFAULT ROLE 'rol_taller_flotaya' TO 'taller_flotaya'@'localhost';
SET DEFAULT ROLE 'rol_auditor_flotaya' TO 'auditor_flotaya'@'localhost';
SHOW GRANTS FOR 'rol_taller_flotaya';
SHOW GRANTS FOR 'asesor_flotaya'@'localhost';
SHOW GRANTS FOR 'asesor_flotaya'@'localhost' USING 'rol_asesor_flotaya';

-- SQL SECURITY DEFINER permite validar licencias con los permisos del creador.
-- La cuenta solo recibe EXECUTE. Un procedimiento mal escrito podría exponer
-- datos o permitir cambios usando los permisos del creador.
-- SELECT * solicita acceso a toda la tabla y produce 1142. Una columna concreta
-- sin permiso produce 1143 aunque otras columnas sí estén autorizadas.
-- Un rol asignado pero inactivo no aporta permisos a la sesión.


-- Como asesor_flotaya
-- USE flotaya;
-- SELECT USER() AS conexion, CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol;
-- SHOW TABLES;
-- SHOW GRANTS;
-- SET ROLE NONE;
-- SELECT CURRENT_ROLE() AS rol_sin_activar;
-- SHOW GRANTS;
-- SET ROLE DEFAULT;
-- SELECT CURRENT_ROLE() AS rol_activo;
-- SHOW GRANTS FOR CURRENT_USER USING 'rol_asesor_flotaya';
-- 
-- CALL sp_crear_reserva(14, 13, 4, 4, '2026-12-12', '2026-12-15', @reserva_sofia);
-- SELECT @reserva_sofia AS reserva, fn_valor_alquiler(3, '2026-12-12', '2026-12-15') AS cotizado_810000;
-- SELECT * FROM reservations WHERE id = @reserva_sofia;
-- UPDATE reservations SET status = 'CONFIRMADA' WHERE id = @reserva_sofia;
-- SELECT * FROM reservations WHERE id = @reserva_sofia;
-- 
-- ⚠️ ESPERADO: ERROR 1142. No tiene SELECT sobre pagos.
-- SELECT * FROM payments;
-- ⚠️ ESPERADO: ERROR 1142. No tiene DELETE sobre reservas.
-- DELETE FROM reservations WHERE id = @reserva_sofia;
-- ⚠️ ESPERADO: ERROR 1142. No tiene SELECT sobre licencias.
-- SELECT COUNT(*) FROM licenses;

-- Como taller_flotaya
-- USE flotaya;
-- SELECT USER() AS conexion, CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol;
-- SHOW TABLES;
-- SELECT * FROM maintenances WHERE id = 1;
-- UPDATE maintenances SET ends_on = '2026-11-23', cost = 1850000 WHERE id = 1;
-- SELECT * FROM maintenances WHERE id = 1;
-- SELECT id, plate, status, mileage_km, branch_id FROM vehicles WHERE id = 15;
-- UPDATE vehicles SET status = 'DISPONIBLE' WHERE id = 15;
-- SELECT id, plate, status, mileage_km, branch_id FROM vehicles WHERE id = 15;
-- INSERT INTO maintenances (vehicle_id, workshop_id, type, description, starts_on, ends_on, cost)
-- VALUES (13, 1, 'PREVENTIVO', 'Alineación y balanceo', '2026-11-23', '2026-11-23', 120000);
-- SELECT * FROM maintenances WHERE vehicle_id = 13;
-- 
-- ⚠️ ESPERADO: ERROR 1142. Solo puede leer las columnas autorizadas.
-- SELECT * FROM vehicles;
-- SELECT id, plate, status, mileage_km, branch_id FROM vehicles WHERE id = 15;
-- ⚠️ ESPERADO: ERROR 1143. No tiene UPDATE sobre mileage_km.
-- UPDATE vehicles SET mileage_km = 88101 WHERE id = 15;
-- SELECT id, plate, status, mileage_km, branch_id FROM vehicles WHERE id = 15;
-- ⚠️ ESPERADO: ERROR 1142. No tiene SELECT sobre contratos.
-- SELECT COUNT(*) FROM contracts;

-- Como auditor_flotaya
-- USE flotaya;
-- SELECT USER() AS conexion, CURRENT_USER() AS cuenta, CURRENT_ROLE() AS rol;
-- SHOW TABLES;
-- SELECT id, contract_id, concept, amount, paid_at FROM payments WHERE contract_id = 9003;
-- SELECT status AS estado, COUNT(*) AS contratos FROM contracts GROUP BY status;
-- ⚠️ ESPERADO: ERROR 1143. No tiene permiso de lectura sobre card_last_four.
-- SELECT card_last_four FROM payments;
-- ⚠️ ESPERADO: ERROR 1142. No puede leer todas las columnas de pagos.
-- SELECT * FROM payments;
-- SELECT id, status FROM contracts WHERE id = 9003;
-- ⚠️ ESPERADO: ERROR 1142. El auditor solo tiene lectura.
-- UPDATE contracts SET status = 'ABIERTO' WHERE id = 9003;
-- SELECT id, status FROM contracts WHERE id = 9003;
-- ⚠️ ESPERADO: ERROR 1142. No puede consultar clientes.
-- SELECT COUNT(*) FROM customers;
