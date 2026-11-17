USE flotaya;

-- R1
SELECT r.id AS reserva, CONCAT(c.first_names, ' ', c.last_names) AS cliente,
       cat.name AS categoria, r.starts_on AS inicio, r.ends_on AS fin,
       r.quoted_amount AS cotizado,
       fn_valor_alquiler(cat.id, r.starts_on, r.ends_on) AS segun_temporada,
       fn_valor_alquiler(cat.id, r.starts_on, r.ends_on) - r.quoted_amount AS diferencia
FROM reservations r JOIN customers c ON c.id = r.customer_id
JOIN vehicles v ON v.id = r.vehicle_id JOIN models m ON m.id = v.model_id
JOIN categories cat ON cat.id = m.category_id
WHERE r.quoted_amount <> fn_valor_alquiler(cat.id, r.starts_on, r.ends_on)
ORDER BY diferencia DESC, r.id;
-- El procedimiento guarda lo calculado por fn_valor_alquiler, así que coincide
-- mientras se conserve el calendario y las tarifas usados al cotizar.

-- R2
SELECT t.* FROM (
    SELECT c.id AS contrato, CONCAT(cu.first_names, ' ', cu.last_names) AS cliente,
           c.rental_amount AS alquiler, COALESCE(e.valor, 0.00) AS extras,
           COALESCE(d.valor, 0.00) AS danos, COALESCE(p.valor, 0.00) AS pagado,
           c.rental_amount + COALESCE(e.valor, 0) + COALESCE(d.valor, 0) - COALESCE(p.valor, 0) AS saldo
    FROM contracts c JOIN reservations r ON r.id = c.reservation_id
    JOIN customers cu ON cu.id = r.customer_id
    LEFT JOIN (
        SELECT ce.contract_id, SUM(ce.quantity * ce.agreed_daily_price * DATEDIFF(c2.returned_on, c2.starts_on)) AS valor
        FROM contract_extras ce JOIN contracts c2 ON c2.id = ce.contract_id GROUP BY ce.contract_id
    ) e ON e.contract_id = c.id
    LEFT JOIN (
        SELECT i.contract_id, SUM(d2.repair_cost) AS valor
        FROM inspections i JOIN damages d2 ON d2.inspection_id = i.id
        WHERE i.stage = 'DEVOLUCION' AND d2.charge_customer = TRUE GROUP BY i.contract_id
    ) d ON d.contract_id = c.id
    LEFT JOIN (SELECT contract_id, SUM(amount) AS valor FROM payments GROUP BY contract_id) p ON p.contract_id = c.id
    WHERE c.status = 'CERRADO'
) t WHERE t.saldo > 0 ORDER BY t.saldo DESC, t.contrato;

-- R3
SELECT t.contrato, t.conductor, t.rol, t.categoria, t.edad, t.edad_minima,
       IF(t.vigente, 'Sí', 'No') AS licencia_vigente
FROM (
    SELECT c.id AS contrato, CONCAT(cu.first_names, ' ', cu.last_names) AS conductor,
           'TITULAR' AS rol, cat.name AS categoria,
           fn_edad_conductor(cu.birth_date, c.starts_on) AS edad, cat.minimum_age AS edad_minima,
           EXISTS (SELECT 1 FROM licenses l WHERE l.customer_id = cu.id
               AND l.issued_on <= c.starts_on AND l.expires_on >= COALESCE(c.returned_on, c.expected_end_on)) AS vigente
    FROM contracts c JOIN reservations r ON r.id = c.reservation_id JOIN customers cu ON cu.id = r.customer_id
    JOIN vehicles v ON v.id = c.vehicle_id JOIN models m ON m.id = v.model_id JOIN categories cat ON cat.id = m.category_id
    UNION ALL
    SELECT c.id, dr.full_name, 'ADICIONAL', cat.name,
           fn_edad_conductor(dr.birth_date, c.starts_on), cat.minimum_age,
           dr.license_expires_on >= COALESCE(c.returned_on, c.expected_end_on)
    FROM contracts c JOIN contract_drivers cd ON cd.contract_id = c.id JOIN drivers dr ON dr.id = cd.driver_id
    JOIN vehicles v ON v.id = c.vehicle_id JOIN models m ON m.id = v.model_id JOIN categories cat ON cat.id = m.category_id
) t WHERE t.edad < t.edad_minima OR NOT t.vigente ORDER BY t.contrato, t.rol, t.conductor;
