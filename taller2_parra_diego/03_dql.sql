USE flotaya;
SET @corte = '2026-11-23';

-- Q-01
SELECT status AS estado, COUNT(*) AS vehiculos FROM vehicles
GROUP BY status ORDER BY vehiculos DESC, estado;

-- Q-02
SELECT s.name AS temporada, s.starts_on AS desde, s.ends_on AS hasta,
       DATEDIFF(s.ends_on, s.starts_on) + 1 AS dias
FROM seasons s JOIN season_types st ON st.id = s.season_type_id
WHERE st.name = 'ALTA' ORDER BY s.starts_on;

-- Q-03
SELECT v.plate AS placa, b.name AS marca, m.name AS modelo, c.name AS categoria,
       br.name AS sede, ci.name AS ciudad
FROM vehicles v JOIN models m ON m.id = v.model_id
JOIN brands b ON b.id = m.brand_id JOIN categories c ON c.id = m.category_id
JOIN branches br ON br.id = v.branch_id JOIN cities ci ON ci.id = br.city_id
WHERE v.status = 'DISPONIBLE' ORDER BY c.id, v.plate;

-- Q-04
SELECT c.id AS contrato, CONCAT(cu.first_names, ' ', cu.last_names) AS cliente,
       v.plate AS placa, m.name AS modelo, b.name AS sede_recogida,
       c.expected_end_on AS fin_esperado,
       DATEDIFF(c.expected_end_on, @corte) AS dias_para_devolver,
       (SELECT COUNT(*) FROM contract_drivers cd WHERE cd.contract_id = c.id) AS conductores_adicionales
FROM contracts c JOIN reservations r ON r.id = c.reservation_id
JOIN customers cu ON cu.id = r.customer_id JOIN vehicles v ON v.id = c.vehicle_id
JOIN models m ON m.id = v.model_id JOIN branches b ON b.id = r.pickup_branch_id
WHERE c.status = 'ABIERTO' ORDER BY dias_para_devolver, c.id;

-- Q-05
SELECT b.name AS sede, COUNT(DISTINCT c.id) AS contratos, ROUND(SUM(p.amount), 2) AS recaudado
FROM payments p JOIN contracts c ON c.id = p.contract_id
JOIN reservations r ON r.id = c.reservation_id JOIN branches b ON b.id = r.pickup_branch_id
GROUP BY b.id, b.name HAVING SUM(p.amount) > 2000000 ORDER BY recaudado DESC, sede;

-- Q-06
SELECT b.name AS marca, m.name AS modelo FROM models m JOIN brands b ON b.id = m.brand_id
WHERE NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.model_id = m.id)
ORDER BY marca, modelo;

-- Q-07
SELECT c.id, CONCAT(c.first_names, ' ', c.last_names) AS cliente FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM licenses l WHERE l.customer_id = c.id
    AND l.issued_on <= @corte AND l.expires_on >= @corte
) ORDER BY c.id;

-- Q-08
SELECT v.plate AS placa, m.name AS modelo, b.name AS sede FROM vehicles v
JOIN models m ON m.id = v.model_id JOIN branches b ON b.id = v.branch_id
WHERE v.status = 'DISPONIBLE' AND NOT EXISTS (
    SELECT 1 FROM reservations r WHERE r.vehicle_id = v.id AND r.status <> 'CANCELADA'
    AND r.starts_on <= '2026-12-31' AND r.ends_on >= '2026-12-01'
) ORDER BY v.plate;

-- Q-09
SELECT v.plate AS placa, ROUND(SUM(mt.cost), 2) AS gasto
FROM vehicles v JOIN maintenances mt ON mt.vehicle_id = v.id
GROUP BY v.id, v.plate HAVING SUM(mt.cost) > (
    SELECT AVG(t.gasto) FROM (SELECT SUM(cost) AS gasto FROM maintenances GROUP BY vehicle_id) t
) ORDER BY gasto DESC, placa;
SELECT ROUND(AVG(t.gasto), 2) AS promedio_por_vehiculo,
       COUNT(*) AS vehiculos, COUNT(t.gasto) AS con_gasto
FROM (SELECT vehicle_id, SUM(cost) AS gasto FROM maintenances GROUP BY vehicle_id) t;
-- SUM ignora los costos NULL. Un vehículo con solo trabajos en curso tiene suma NULL.
-- Cuenta como vehículo, pero AVG no lo incluye en el divisor. Un trabajo en curso
-- tampoco aumenta el gasto conocido de un vehículo que ya tiene otros trabajos.

-- Q-10
SELECT c.name AS categoria, v.plate AS placa, v.mileage_km AS kilometraje
FROM categories c JOIN models m ON m.category_id = c.id JOIN vehicles v ON v.model_id = m.id
WHERE v.mileage_km = (
    SELECT MAX(v2.mileage_km) FROM vehicles v2 JOIN models m2 ON m2.id = v2.model_id
    WHERE m2.category_id = c.id
) ORDER BY c.id, v.plate;
-- Lujo no aparece porque aún no tiene modelos ni vehículos.

-- Q-11
SELECT e.name AS extra, COUNT(ce.contract_id) AS contratos,
       ROUND(COALESCE(SUM(ce.quantity * ce.agreed_daily_price *
           DATEDIFF(COALESCE(c.returned_on, c.expected_end_on), c.starts_on)), 0), 2) AS ingresos
FROM extras e LEFT JOIN contract_extras ce ON ce.extra_id = e.id
LEFT JOIN contracts c ON c.id = ce.contract_id
GROUP BY e.id, e.name ORDER BY ingresos DESC, extra;

-- Q-12
SELECT c.id AS contrato, v.plate AS placa, CONCAT(cu.first_names, ' ', cu.last_names) AS cliente,
       i.stage AS etapa, d.description AS dano, d.severity AS severidad, d.repair_cost AS costo,
       IF(d.charge_customer, 'Sí', 'No') AS se_cobra
FROM damages d JOIN inspections i ON i.id = d.inspection_id
JOIN contracts c ON c.id = i.contract_id JOIN vehicles v ON v.id = c.vehicle_id
JOIN reservations r ON r.id = c.reservation_id JOIN customers cu ON cu.id = r.customer_id
ORDER BY c.id, d.id;
