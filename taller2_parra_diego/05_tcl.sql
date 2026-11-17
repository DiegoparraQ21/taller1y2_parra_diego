USE flotaya;

-- T1 · Paola
SELECT c.id AS contrato, c.status AS estado_contrato, c.rental_amount AS alquiler,
       v.status AS estado_vehiculo, v.mileage_km AS kilometraje, d.status AS deposito,
       d.applied_amount AS aplicado,
       (SELECT COUNT(*) FROM returns r WHERE r.contract_id = c.id) AS devoluciones,
       (SELECT COUNT(*) FROM inspections i WHERE i.contract_id = c.id AND i.stage = 'DEVOLUCION') AS inspecciones_devolucion,
       (SELECT COUNT(*) FROM payments p WHERE p.contract_id = c.id) AS pagos
FROM contracts c JOIN vehicles v ON v.id = c.vehicle_id
JOIN deposits d ON d.contract_id = c.id WHERE c.id = 9006;
START TRANSACTION;
INSERT INTO returns (contract_id, branch_id, employee_id, returned_at, mileage_km, fuel_pct)
VALUES (9006, 2, 9, '2026-11-23 09:30:00', 12480, 100);
INSERT INTO inspections (contract_id, employee_id, stage, inspected_at, exterior_ok, interior_ok, notes)
VALUES (9006, 9, 'DEVOLUCION', '2026-11-23 09:40:00', FALSE, TRUE, 'Rin delantero izquierdo rayado');
SET @inspeccion_paola = LAST_INSERT_ID();
SAVEPOINT antes_dano;
INSERT INTO damages (inspection_id, description, severity, repair_cost, charge_customer)
VALUES (@inspeccion_paola, 'Rin delantero izquierdo rayado', 'LEVE', 3800000, TRUE);
SELECT * FROM damages WHERE inspection_id = @inspeccion_paola;
ROLLBACK TO SAVEPOINT antes_dano;
SELECT * FROM damages WHERE inspection_id = @inspeccion_paola;
INSERT INTO damages (inspection_id, description, severity, repair_cost, charge_customer)
VALUES (@inspeccion_paola, 'Rin delantero izquierdo rayado', 'LEVE', 380000, TRUE);
CALL sp_cerrar_contrato(9006, '2026-11-23', @saldo_paola);
SELECT @saldo_paola AS saldo_750000;
INSERT INTO payments (contract_id, concept, amount, method, paid_at, card_last_four, authorization_code)
VALUES (9006, 'CIERRE', @saldo_paola, 'TARJETA', '2026-11-23 10:00:00', '3307', 'AUT-580114');
COMMIT;
SELECT c.id AS contrato, c.status AS estado_contrato, c.rental_amount AS alquiler,
       v.status AS estado_vehiculo, v.mileage_km AS kilometraje, d.status AS deposito,
       d.applied_amount AS aplicado,
       (SELECT COUNT(*) FROM returns r WHERE r.contract_id = c.id) AS devoluciones,
       (SELECT COUNT(*) FROM inspections i WHERE i.contract_id = c.id AND i.stage = 'DEVOLUCION') AS inspecciones_devolucion,
       (SELECT COUNT(*) FROM payments p WHERE p.contract_id = c.id) AS pagos
FROM contracts c JOIN vehicles v ON v.id = c.vehicle_id
JOIN deposits d ON d.contract_id = c.id WHERE c.id = 9006;
SELECT * FROM payments WHERE contract_id = 9006;
SELECT * FROM damages WHERE inspection_id = @inspeccion_paola;
-- LAST_INSERT_ID después de insertar el daño corresponde al daño, no a la inspección.
-- Tras el ROLLBACK TO no recupera automáticamente el número de la inspección.
-- Usarlo podría asociar el daño a otra inspección o causar un error de clave foránea.

-- T2 · Carlos
SELECT c.id AS contrato, c.status AS estado_contrato, c.rental_amount AS alquiler,
       v.status AS estado_vehiculo, v.mileage_km AS kilometraje, d.status AS deposito,
       d.applied_amount AS aplicado,
       (SELECT COUNT(*) FROM returns r WHERE r.contract_id = c.id) AS devoluciones,
       (SELECT COUNT(*) FROM inspections i WHERE i.contract_id = c.id AND i.stage = 'DEVOLUCION') AS inspecciones_devolucion,
       (SELECT COUNT(*) FROM payments p WHERE p.contract_id = c.id) AS pagos
FROM contracts c JOIN vehicles v ON v.id = c.vehicle_id
JOIN deposits d ON d.contract_id = c.id WHERE c.id = 9008;
START TRANSACTION;
INSERT INTO returns (contract_id, branch_id, employee_id, returned_at, mileage_km, fuel_pct)
VALUES (9008, 4, 10, '2026-11-23 18:00:00', 26950, 50);
INSERT INTO inspections (contract_id, employee_id, stage, inspected_at, exterior_ok, interior_ok)
VALUES (9008, 10, 'DEVOLUCION', '2026-11-23 18:10:00', TRUE, TRUE);
CALL sp_cerrar_contrato(9008, '2026-11-23', @saldo_carlos);
SELECT @saldo_carlos AS saldo_970000;
-- ⚠️ ESPERADO: ERROR 1265. CHEQUE no está en el ENUM de medios de pago.
-- INSERT INTO payments (contract_id, concept, amount, method, paid_at) VALUES (9008, 'CIERRE', @saldo_carlos, 'CHEQUE', '2026-11-23 18:20:00');
SELECT c.id AS contrato, c.status AS estado_contrato, c.rental_amount AS alquiler,
       v.status AS estado_vehiculo, v.mileage_km AS kilometraje, d.status AS deposito,
       d.applied_amount AS aplicado,
       (SELECT COUNT(*) FROM returns r WHERE r.contract_id = c.id) AS devoluciones,
       (SELECT COUNT(*) FROM inspections i WHERE i.contract_id = c.id AND i.stage = 'DEVOLUCION') AS inspecciones_devolucion,
       (SELECT COUNT(*) FROM payments p WHERE p.contract_id = c.id) AS pagos
FROM contracts c JOIN vehicles v ON v.id = c.vehicle_id
JOIN deposits d ON d.contract_id = c.id WHERE c.id = 9008;
ROLLBACK;
SELECT c.id AS contrato, c.status AS estado_contrato, c.rental_amount AS alquiler,
       v.status AS estado_vehiculo, v.mileage_km AS kilometraje, d.status AS deposito,
       d.applied_amount AS aplicado,
       (SELECT COUNT(*) FROM returns r WHERE r.contract_id = c.id) AS devoluciones,
       (SELECT COUNT(*) FROM inspections i WHERE i.contract_id = c.id AND i.stage = 'DEVOLUCION') AS inspecciones_devolucion,
       (SELECT COUNT(*) FROM payments p WHERE p.contract_id = c.id) AS pagos
FROM contracts c JOIN vehicles v ON v.id = c.vehicle_id
JOIN deposits d ON d.contract_id = c.id WHERE c.id = 9008;

-- T3 · Auditoría. Esperado: 0, 0, 0, 1, 16.
SELECT
    (SELECT COUNT(*) FROM vehicles v WHERE v.status = 'ALQUILADO'
        AND NOT EXISTS (SELECT 1 FROM contracts c WHERE c.vehicle_id = v.id AND c.status = 'ABIERTO'))
        AS alquilados_sin_contrato,
    (SELECT COUNT(*) FROM contracts c WHERE c.status = 'CERRADO'
        AND NOT EXISTS (SELECT 1 FROM returns r WHERE r.contract_id = c.id))
        AS cerrados_sin_devolucion,
    (SELECT COUNT(*) FROM deposits d JOIN contracts c ON c.id = d.contract_id
        WHERE d.status = 'RETENIDO' AND c.status = 'CERRADO')
        AS depositos_retenidos_de_cerrados,
    (SELECT COUNT(*) FROM contracts WHERE status = 'ABIERTO') AS contratos_abiertos,
    (SELECT COUNT(*) FROM payments) AS pagos;
