USE flotaya;

INSERT INTO departments (name) VALUES
    ('Bogotá D.C.'),
    ('Antioquia'),
    ('Bolívar'),
    ('Valle del Cauca'),
    ('Santander'),
    ('Quindío'),
    ('Magdalena');

INSERT INTO cities (department_id, name) VALUES
    (1, 'Bogotá'),
    (2, 'Medellín'),
    (2, 'Rionegro'),
    (3, 'Cartagena'),
    (4, 'Cali'),
    (5, 'Bucaramanga'),
    (6, 'Armenia');

INSERT INTO branches (city_id, name, address, phone, is_airport) VALUES
    (1, 'FlotaYa Bogotá Calle 26', 'Avenida Calle 26 # 69-76', '6017001001', 0),
    (1, 'FlotaYa Aeropuerto El Dorado', 'Avenida El Dorado # 103-09', '6017001002', 1),
    (2, 'FlotaYa Medellín El Poblado', 'Carrera 43A # 7-50', '6047001003', 0),
    (3, 'FlotaYa Aeropuerto José María Córdova', 'Vía Aeropuerto JMC km 1', '6047001004', 1),
    (4, 'FlotaYa Cartagena Bocagrande', 'Carrera 2 # 8-120', '6057001005', 0),
    (5, 'FlotaYa Cali Granada', 'Avenida 9N # 15-20', '6027001006', 0);

INSERT INTO employees (branch_id, full_name, email, role, hired_on) VALUES
    (1, 'Mónica Gaitán', 'monica.gaitan@flotaya.example.com', 'ADMINISTRADOR', '2025-01-15'),
    (1, 'Gustavo Pérez', 'gustavo.perez@flotaya.example.com', 'MECANICO', '2025-01-15'),
    (1, 'Luis Avendaño', 'luis.avendano@flotaya.example.com', 'ASESOR', '2025-01-15'),
    (2, 'Sara Mendoza', 'sara.mendoza@flotaya.example.com', 'ASESOR', '2025-01-15'),
    (3, 'Iván Castro', 'ivan.castro@flotaya.example.com', 'ASESOR', '2025-01-15'),
    (4, 'Lina Duarte', 'lina.duarte@flotaya.example.com', 'ASESOR', '2025-01-15'),
    (5, 'Elena Ríos', 'elena.rios@flotaya.example.com', 'ASESOR', '2025-01-15'),
    (6, 'Pedro Luna', 'pedro.luna@flotaya.example.com', 'ASESOR', '2025-01-15'),
    (2, 'Andrés Vega', 'andres.vega@flotaya.example.com', 'INSPECTOR', '2025-01-15'),
    (4, 'Claudia Rojas', 'claudia.rojas@flotaya.example.com', 'INSPECTOR', '2025-01-15'),
    (5, 'Hugo Bernal', 'hugo.bernal@flotaya.example.com', 'INSPECTOR', '2025-01-15'),
    (6, 'Sandra Ruiz', 'sandra.ruiz@flotaya.example.com', 'INSPECTOR', '2025-01-15'),
    (1, 'Felipe Ortiz', 'felipe.ortiz@flotaya.example.com', 'INSPECTOR', '2025-01-15'),
    (3, 'Nora Mora', 'nora.mora@flotaya.example.com', 'INSPECTOR', '2025-01-15');

INSERT INTO categories (name, minimum_age, deposit_amount) VALUES
    ('Económico', 21, 1500000),
    ('Compacto', 21, 1500000),
    ('SUV', 23, 2500000),
    ('Camioneta 4x4', 25, 3000000),
    ('Van', 25, 3000000),
    ('Lujo', 30, 5000000);

INSERT INTO season_types (name) VALUES
    ('BAJA'),
    ('MEDIA'),
    ('ALTA');

INSERT INTO seasons (season_type_id, name, starts_on, ends_on) VALUES
    (3, 'Fin de año 2025', '2025-12-15', '2026-01-15'),
    (1, 'Baja de inicio de año', '2026-01-16', '2026-03-28'),
    (3, 'Semana Santa', '2026-03-29', '2026-04-05'),
    (1, 'Baja de abril a junio', '2026-04-06', '2026-06-12'),
    (3, 'Vacaciones de mitad de año', '2026-06-13', '2026-07-19'),
    (1, 'Baja de segundo semestre', '2026-07-20', '2026-10-02'),
    (2, 'Receso escolar de octubre', '2026-10-03', '2026-10-12'),
    (1, 'Baja de noviembre', '2026-10-13', '2026-11-30'),
    (2, 'Temporada de novenas', '2026-12-01', '2026-12-14'),
    (3, 'Fin de año 2026', '2026-12-15', '2027-01-15');

INSERT INTO rates (category_id, season_type_id, daily_price) VALUES
    (1, 1, 120000),
    (1, 2, 140000),
    (1, 3, 180000),
    (2, 1, 150000),
    (2, 2, 175000),
    (2, 3, 220000),
    (3, 1, 230000),
    (3, 2, 270000),
    (3, 3, 340000),
    (4, 1, 300000),
    (4, 2, 350000),
    (4, 3, 430000),
    (5, 1, 320000),
    (5, 2, 370000),
    (5, 3, 460000),
    (6, 1, 450000),
    (6, 2, 520000),
    (6, 3, 650000);

INSERT INTO brands (name) VALUES
    ('Renault'),
    ('Kia'),
    ('Chevrolet'),
    ('Mazda'),
    ('Toyota'),
    ('Hyundai'),
    ('Nissan');

INSERT INTO models (brand_id, category_id, name, transmission, fuel_type, seats) VALUES
    (1, 1, 'Kwid', 'MECANICA', 'GASOLINA', 5),
    (2, 1, 'Picanto', 'AUTOMATICA', 'GASOLINA', 5),
    (3, 2, 'Onix', 'AUTOMATICA', 'GASOLINA', 5),
    (4, 2, 'Mazda 2', 'AUTOMATICA', 'GASOLINA', 5),
    (1, 3, 'Duster', 'MECANICA', 'GASOLINA', 5),
    (2, 3, 'Sportage', 'AUTOMATICA', 'HIBRIDO', 5),
    (5, 4, 'Hilux', 'MECANICA', 'DIESEL', 5),
    (6, 5, 'Staria', 'AUTOMATICA', 'DIESEL', 11),
    (4, 3, 'CX-30', 'AUTOMATICA', 'GASOLINA', 5);

INSERT INTO vehicles (plate, model_id, model_year, color, mileage_km, status, branch_id) VALUES
    ('KWD101', 1, 2024, 'Blanco', 18950, 'DISPONIBLE', 1),
    ('KWD102', 1, 2024, 'Gris', 22100, 'DISPONIBLE', 2),
    ('KWD103', 1, 2021, 'Blanco', 98400, 'FUERA_DE_SERVICIO', 6),
    ('PCN201', 2, 2025, 'Rojo', 10450, 'DISPONIBLE', 2),
    ('PCN202', 2, 2025, 'Blanco', 12400, 'DISPONIBLE', 3),
    ('ONX301', 3, 2024, 'Plata', 30500, 'ALQUILADO', 2),
    ('ONX302', 3, 2023, 'Negro', 41890, 'MANTENIMIENTO', 5),
    ('MZD401', 4, 2025, 'Azul', 9310, 'DISPONIBLE', 4),
    ('MZD402', 4, 2024, 'Rojo', 26300, 'ALQUILADO', 4),
    ('DST501', 5, 2023, 'Blanco', 48620, 'DISPONIBLE', 1),
    ('DST502', 5, 2024, 'Gris', 22710, 'DISPONIBLE', 6),
    ('SPT601', 6, 2025, 'Negro', 11500, 'ALQUILADO', 2),
    ('SPT602', 6, 2025, 'Blanco', 9600, 'DISPONIBLE', 4),
    ('HLX701', 7, 2023, 'Plata', 64380, 'DISPONIBLE', 3),
    ('HLX702', 7, 2022, 'Blanco', 88100, 'MANTENIMIENTO', 6),
    ('STR801', 8, 2024, 'Gris', 35700, 'DISPONIBLE', 2),
    ('STR802', 8, 2025, 'Blanco', 15480, 'DISPONIBLE', 5);

INSERT INTO workshops (name, is_internal) VALUES
    ('Taller FlotaYa Bogotá', 1),
    ('Diésel del Valle', 0),
    ('Latonería Caribe', 0);

INSERT INTO maintenances (vehicle_id, workshop_id, type, description, starts_on, ends_on, cost) VALUES
    (15, 2, 'CORRECTIVO', 'Cambio de embrague', '2026-11-16', NULL, NULL),
    (7, 3, 'LATONERIA', 'Reparación de latonería', '2026-10-26', NULL, NULL),
    (3, 2, 'CORRECTIVO', 'Diagnóstico de motor; pérdida total', '2026-10-01', '2026-10-03', 1800000),
    (1, 1, 'PREVENTIVO', 'Cambio de aceite', '2026-08-01', '2026-08-01', 250000),
    (1, 1, 'PREVENTIVO', 'Cambio de filtros', '2026-10-15', '2026-10-15', 180000),
    (14, 1, 'PREVENTIVO', 'Revisión de frenos', '2026-09-01', '2026-09-02', 650000);

INSERT INTO customers (first_names, last_names, birth_date, city_id, document_type, document_number, email, phone, registered_on, status) VALUES
    ('Andrea', 'Salazar', '1990-04-12', 1, 'CC', 'FY-C001', 'cliente1@example.com', '3000000001', '2026-01-10', 'ACTIVO'),
    ('Carlos', 'Mejía', '1985-09-30', 2, 'CC', 'FY-C002', 'cliente2@example.com', '3000000002', '2026-01-10', 'ACTIVO'),
    ('Juliana', 'Patiño', '2004-07-15', 1, 'CC', 'FY-C003', 'cliente3@example.com', '3000000003', '2026-01-10', 'ACTIVO'),
    ('Lucas', 'Ferreira', '1979-02-02', 4, 'CE', 'FY-C004', 'cliente4@example.com', '3000000004', '2026-01-10', 'ACTIVO'),
    ('Diana', 'Rozo', '1993-11-25', 5, 'CC', 'FY-C005', 'cliente5@example.com', '3000000005', '2026-01-10', 'ACTIVO'),
    ('Emma', 'Walker', '1988-06-18', 4, 'PASAPORTE', 'FY-C006', 'cliente6@example.com', '3000000006', '2026-01-10', 'ACTIVO'),
    ('Jorge', 'Arango', '1975-01-09', 2, 'CC', 'FY-C007', 'cliente7@example.com', '3000000007', '2026-01-10', 'ACTIVO'),
    ('Paola', 'Quintero', '1999-12-03', 1, 'CC', 'FY-C008', 'cliente8@example.com', '3000000008', '2026-01-10', 'ACTIVO'),
    ('Esteban', 'Rueda', '2002-05-21', 6, 'CC', 'FY-C009', 'cliente9@example.com', '3000000009', '2026-01-10', 'ACTIVO'),
    ('Martha', 'Cifuentes', '1968-03-14', 1, 'CC', 'FY-C010', 'cliente10@example.com', '3000000010', '2026-01-10', 'BLOQUEADO'),
    ('Kevin', 'Morales', '2005-10-02', 5, 'CC', 'FY-C011', 'cliente11@example.com', '3000000011', '2026-01-10', 'ACTIVO'),
    ('Laura', 'Benítez', '1996-08-08', 2, 'CC', 'FY-C012', 'cliente12@example.com', NULL, '2026-01-10', 'ACTIVO'),
    ('Ricardo', 'Lozano', '1982-12-24', 1, 'CC', 'FY-C013', 'cliente13@example.com', '3000000013', '2026-01-10', 'ACTIVO'),
    ('Sofía', 'Herrera', '2001-01-30', 3, 'CC', 'FY-C014', 'cliente14@example.com', '3000000014', '2026-01-10', 'ACTIVO');

INSERT INTO licenses (customer_id, number, category, issued_on, expires_on, country) VALUES
    (1, 'FY-L1', 'B1', '2020-01-01', '2028-05-10', 'Colombia'),
    (2, 'FY-L2', 'B1', '2020-01-01', '2027-02-20', 'Colombia'),
    (3, 'FY-L3', 'B1', '2022-08-01', '2032-08-01', 'Colombia'),
    (4, 'FY-L4', 'B1', '2020-01-01', '2026-12-31', 'Brasil'),
    (5, 'FY-L5', 'B1', '2020-01-01', '2029-11-30', 'Colombia'),
    (6, 'FY-L6', 'B1', '2020-01-01', '2031-06-01', 'Canadá'),
    (7, 'FY-L7', 'C1', '2010-01-15', '2030-01-15', 'Colombia'),
    (8, 'FY-L8', 'B1', '2016-12-10', '2026-12-10', 'Colombia'),
    (9, 'FY-L9', 'B1', '2020-01-01', '2026-08-01', 'Colombia'),
    (10, 'FY-L10', 'B1', '2020-01-01', '2028-04-04', 'Colombia'),
    (11, 'FY-L11', 'B1', '2023-10-10', '2033-10-10', 'Colombia'),
    (13, 'FY-L13', 'B1', '2020-01-01', '2027-12-24', 'Colombia'),
    (14, 'FY-L14', 'B1', '2020-01-01', '2029-02-01', 'Colombia'),
    (7, 'FY-L7-ANT', 'C1', '2000-01-15', '2010-01-15', 'Colombia');

INSERT INTO drivers (document_number, full_name, birth_date, license_number, license_expires_on) VALUES
    ('FY-D1', 'Felipe Salazar', '1988-03-03', 'FY-DL1', '2029-03-03'),
    ('FY-D2', 'Mónica Arango', '1977-07-07', 'FY-DL2', '2028-07-07'),
    ('FY-D3', 'Tomás Ferreira', '2006-03-03', 'FY-DL3', '2030-03-03'),
    ('FY-D4', 'Natalia Rozo', '1995-05-05', 'FY-DL4', '2026-09-30');

INSERT INTO extras (name, daily_price) VALUES
    ('GPS', 15000),
    ('Silla de bebé', 12000),
    ('Seguro total', 45000),
    ('Conductor adicional', 20000),
    ('Wi-Fi portátil', 10000),
    ('Portabicicletas', 18000);

INSERT INTO reservations (customer_id, vehicle_id, pickup_branch_id, return_branch_id, starts_on, ends_on, quoted_amount, created_at, status) VALUES
    (4, 17, 5, 5, '2026-10-01', '2026-10-06', 1750000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (7, 14, 3, 3, '2026-10-15', '2026-10-20', 1500000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (6, 7, 5, 5, '2026-10-20', '2026-10-24', 600000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (5, 11, 6, 6, '2026-10-08', '2026-10-12', 920000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (2, 8, 3, 4, '2026-09-10', '2026-09-13', 450000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (8, 12, 2, 2, '2026-11-15', '2026-11-22', 1610000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (13, 6, 2, 1, '2026-11-17', '2026-11-21', 600000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (2, 9, 4, 4, '2026-11-18', '2026-11-25', 1050000, '2026-08-20 09:00:00', 'CONVERTIDA'),
    (3, 1, 1, 1, '2026-11-27', '2026-12-02', 620000, '2026-11-10 09:00:00', 'CONFIRMADA'),
    (5, 16, 2, 2, '2026-12-18', '2026-12-23', 2300000, '2026-11-10 09:10:00', 'CONFIRMADA'),
    (11, 5, 3, 3, '2026-12-10', '2026-12-17', 980000, '2026-11-10 09:20:00', 'PENDIENTE'),
    (14, 13, 4, 4, '2026-12-05', '2026-12-09', 1080000, '2026-11-10 09:30:00', 'PENDIENTE'),
    (10, 2, 2, 2, '2026-09-15', '2026-09-18', 360000, '2026-08-10 09:00:00', 'CANCELADA'),
    (9, 1, 1, 1, '2026-07-20', '2026-07-23', 360000, '2026-07-01 09:00:00', 'CANCELADA');

INSERT INTO contracts (reservation_id, vehicle_id, employee_id, starts_on, expected_end_on, returned_on, rental_amount, status) VALUES
    (501, 17, 7, '2026-10-01', '2026-10-06', '2026-10-06', 1750000, 'CERRADO'),
    (502, 14, 5, '2026-10-15', '2026-10-20', '2026-10-20', 1500000, 'CERRADO'),
    (503, 7, 7, '2026-10-20', '2026-10-24', '2026-10-24', 600000, 'CERRADO'),
    (504, 11, 8, '2026-10-08', '2026-10-12', '2026-10-13', 1350000, 'CERRADO'),
    (505, 8, 5, '2026-09-10', '2026-09-13', '2026-09-13', 450000, 'CERRADO'),
    (506, 12, 4, '2026-11-15', '2026-11-22', NULL, 1610000, 'ABIERTO'),
    (507, 6, 4, '2026-11-17', '2026-11-21', NULL, 600000, 'ABIERTO'),
    (508, 9, 6, '2026-11-18', '2026-11-25', NULL, 1050000, 'ABIERTO');

INSERT INTO contract_extras (contract_id, extra_id, quantity, agreed_daily_price) VALUES
    (9001, 4, 1, 20000),
    (9002, 4, 1, 20000),
    (9003, 1, 1, 15000),
    (9004, 3, 1, 45000),
    (9005, 4, 1, 20000),
    (9006, 3, 1, 45000),
    (9006, 4, 1, 20000),
    (9007, 1, 1, 15000),
    (9008, 4, 1, 20000),
    (9008, 2, 2, 12000);

INSERT INTO contract_drivers (contract_id, driver_id) VALUES
    (9001, 3),
    (9002, 4),
    (9005, 2),
    (9006, 1),
    (9008, 2);

INSERT INTO deliveries (contract_id, branch_id, employee_id, delivered_at, mileage_km, fuel_pct) VALUES
    (9001, 5, 7, '2026-10-01 09:00:00', 15180, 100),
    (9002, 3, 5, '2026-10-15 09:00:00', 64080, 100),
    (9003, 5, 7, '2026-10-20 09:00:00', 41590, 100),
    (9004, 6, 8, '2026-10-08 09:00:00', 22410, 100),
    (9005, 3, 5, '2026-09-10 09:00:00', 9010, 100),
    (9006, 2, 4, '2026-11-15 09:00:00', 11500, 100),
    (9007, 2, 4, '2026-11-17 09:00:00', 30500, 100),
    (9008, 4, 6, '2026-11-18 09:00:00', 26300, 100);

INSERT INTO returns (contract_id, branch_id, employee_id, returned_at, mileage_km, fuel_pct) VALUES
    (9001, 5, 11, '2026-10-06 09:00:00', 15480, 100),
    (9002, 3, 14, '2026-10-20 09:00:00', 64380, 100),
    (9003, 5, 11, '2026-10-24 09:00:00', 41890, 100),
    (9004, 6, 12, '2026-10-13 09:00:00', 22710, 100),
    (9005, 4, 10, '2026-09-13 09:00:00', 9310, 100);

INSERT INTO inspections (contract_id, employee_id, stage, inspected_at, exterior_ok, interior_ok, notes) VALUES
    (9001, 11, 'ENTREGA', '2026-10-01 08:50:00', 0, 1, 'Rayón previo en el bómper trasero'),
    (9002, 14, 'ENTREGA', '2026-10-15 08:50:00', 1, 1, NULL),
    (9003, 11, 'ENTREGA', '2026-10-20 08:50:00', 1, 1, NULL),
    (9004, 12, 'ENTREGA', '2026-10-08 08:50:00', 1, 1, NULL),
    (9005, 14, 'ENTREGA', '2026-09-10 08:50:00', 1, 1, NULL),
    (9006, 9, 'ENTREGA', '2026-11-15 08:50:00', 1, 1, NULL),
    (9007, 9, 'ENTREGA', '2026-11-17 08:50:00', 1, 1, NULL),
    (9008, 10, 'ENTREGA', '2026-11-18 08:50:00', 1, 1, NULL),
    (9001, 11, 'DEVOLUCION', '2026-10-06 09:10:00', 1, 1, NULL),
    (9002, 14, 'DEVOLUCION', '2026-10-20 09:10:00', 0, 1, NULL),
    (9003, 11, 'DEVOLUCION', '2026-10-24 09:10:00', 0, 1, NULL),
    (9004, 12, 'DEVOLUCION', '2026-10-13 09:10:00', 1, 1, NULL),
    (9005, 10, 'DEVOLUCION', '2026-09-13 09:10:00', 1, 1, NULL);

INSERT INTO damages (inspection_id, description, severity, repair_cost, charge_customer) VALUES
    (1, 'Rayón previo en el bómper trasero', 'LEVE', 180000, 0),
    (10, 'Rayón en la puerta del conductor', 'LEVE', 350000, 1),
    (11, 'Golpe en la puerta trasera derecha', 'GRAVE', 2400000, 1);

INSERT INTO deposits (contract_id, amount, held_at, released_at, applied_amount, status) VALUES
    (9001, 3000000, '2026-10-01 08:40:00', '2026-10-06 10:00:00', 0, 'LIBERADO'),
    (9002, 3000000, '2026-10-15 08:40:00', '2026-10-20 10:00:00', 350000, 'APLICADO'),
    (9003, 1500000, '2026-10-20 08:40:00', '2026-10-24 10:00:00', 1500000, 'APLICADO'),
    (9004, 2500000, '2026-10-08 08:40:00', '2026-10-13 10:00:00', 0, 'LIBERADO'),
    (9005, 1500000, '2026-09-10 08:40:00', '2026-09-13 10:00:00', 0, 'LIBERADO'),
    (9006, 2500000, '2026-11-15 08:40:00', NULL, 0, 'RETENIDO'),
    (9007, 1500000, '2026-11-17 08:40:00', NULL, 0, 'RETENIDO'),
    (9008, 1500000, '2026-11-18 08:40:00', NULL, 0, 'RETENIDO');

INSERT INTO payments (contract_id, concept, amount, method, paid_at, card_last_four, authorization_code) VALUES
    (9001, 'ALQUILER', 1750000, 'TARJETA', '2026-10-01 09:00:00', '1101', 'AUT-FY001'),
    (9001, 'EXTRAS', 100000, 'EFECTIVO', '2026-10-06 10:00:00', NULL, NULL),
    (9002, 'ALQUILER', 1500000, 'TRANSFERENCIA', '2026-10-15 09:00:00', NULL, 'TR-FY002'),
    (9002, 'EXTRAS', 100000, 'EFECTIVO', '2026-10-20 10:00:00', NULL, NULL),
    (9002, 'DAÑOS', 350000, 'DEPOSITO', '2026-10-20 10:00:00', NULL, NULL),
    (9003, 'ALQUILER', 600000, 'TARJETA', '2026-10-20 09:00:00', '2202', 'AUT-FY003'),
    (9003, 'EXTRAS', 60000, 'EFECTIVO', '2026-10-24 10:00:00', NULL, NULL),
    (9003, 'DAÑOS', 1500000, 'DEPOSITO', '2026-10-24 10:00:00', NULL, NULL),
    (9004, 'ALQUILER', 1350000, 'TRANSFERENCIA', '2026-10-13 10:00:00', NULL, 'TR-FY004'),
    (9004, 'EXTRAS', 225000, 'EFECTIVO', '2026-10-13 10:05:00', NULL, NULL),
    (9005, 'ALQUILER', 450000, 'TARJETA', '2026-09-10 09:00:00', '3303', 'AUT-FY005'),
    (9005, 'EXTRAS', 60000, 'EFECTIVO', '2026-09-13 10:00:00', NULL, NULL),
    (9006, 'ALQUILER', 1610000, 'TARJETA', '2026-11-15 09:00:00', '3307', 'AUT-FY006'),
    (9007, 'ALQUILER', 600000, 'TARJETA', '2026-11-17 09:00:00', '4404', 'AUT-FY007');

-- Conteos de las semillas, antes de las operaciones del día.
SELECT 'departments' AS tabla, COUNT(*) AS filas FROM departments -- 7
UNION ALL SELECT 'cities', COUNT(*) FROM cities -- 7
UNION ALL SELECT 'branches', COUNT(*) FROM branches -- 6
UNION ALL SELECT 'employees', COUNT(*) FROM employees -- 14
UNION ALL SELECT 'categories', COUNT(*) FROM categories -- 6
UNION ALL SELECT 'season_types', COUNT(*) FROM season_types -- 3
UNION ALL SELECT 'seasons', COUNT(*) FROM seasons -- 10
UNION ALL SELECT 'rates', COUNT(*) FROM rates -- 18
UNION ALL SELECT 'brands', COUNT(*) FROM brands -- 7
UNION ALL SELECT 'models', COUNT(*) FROM models -- 9
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles -- 17
UNION ALL SELECT 'workshops', COUNT(*) FROM workshops -- 3
UNION ALL SELECT 'maintenances', COUNT(*) FROM maintenances -- 6
UNION ALL SELECT 'customers', COUNT(*) FROM customers -- 14
UNION ALL SELECT 'licenses', COUNT(*) FROM licenses -- 14
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers -- 4
UNION ALL SELECT 'extras', COUNT(*) FROM extras -- 6
UNION ALL SELECT 'reservations', COUNT(*) FROM reservations -- 14
UNION ALL SELECT 'contracts', COUNT(*) FROM contracts -- 8
UNION ALL SELECT 'contract_extras', COUNT(*) FROM contract_extras -- 10
UNION ALL SELECT 'contract_drivers', COUNT(*) FROM contract_drivers -- 5
UNION ALL SELECT 'deliveries', COUNT(*) FROM deliveries -- 8
UNION ALL SELECT 'returns', COUNT(*) FROM returns -- 5
UNION ALL SELECT 'inspections', COUNT(*) FROM inspections -- 13
UNION ALL SELECT 'damages', COUNT(*) FROM damages -- 3
UNION ALL SELECT 'deposits', COUNT(*) FROM deposits -- 8
UNION ALL SELECT 'payments', COUNT(*) FROM payments; -- 14

-- DML-01
INSERT INTO branches (city_id, name, address, phone)
VALUES (6, 'FlotaYa Bucaramanga Cabecera', 'Carrera 35 # 48-20', '6077001007');
INSERT INTO employees (branch_id, full_name, email, role, hired_on)
VALUES (7, 'Daniel Rojas', 'daniel.rojas@flotaya.example.com', 'ASESOR', '2026-11-20');
INSERT INTO vehicles (model_id, branch_id, plate, model_year, color, mileage_km)
VALUES (5, 7, 'DST503', 2026, 'Roja', 1200);
SELECT b.name AS sede, b.is_airport AS aeropuerto, c.name AS ciudad,
       e.full_name AS asesor, v.plate AS placa, v.status AS estado
FROM branches b JOIN cities c ON c.id = b.city_id
JOIN employees e ON e.branch_id = b.id
JOIN vehicles v ON v.branch_id = b.id
WHERE b.id = 7;

-- DML-02
SELECT * FROM rates WHERE id = 18;
UPDATE rates SET daily_price = daily_price * 1.05 WHERE id = 18;
SELECT * FROM rates WHERE id = 18;

SELECT * FROM extras WHERE id = 1;
UPDATE extras SET daily_price = 16000 WHERE id = 1;
SELECT * FROM extras WHERE id = 1;
SELECT ce.contract_id AS contrato, e.daily_price AS precio_lista, ce.agreed_daily_price AS precio_pactado
FROM extras e JOIN contract_extras ce ON ce.extra_id = e.id WHERE e.id = 1;

-- DML-03
SELECT * FROM reservations
WHERE status = 'PENDIENTE' AND starts_on BETWEEN '2026-12-01' AND '2026-12-31';
-- ⚠️ ESPERADO: ERROR 1175 con SQL_SAFE_UPDATES = 1. El filtro no usa una clave.
-- UPDATE reservations SET status = 'CONFIRMADA' WHERE status = 'PENDIENTE' AND starts_on BETWEEN '2026-12-01' AND '2026-12-31';
SELECT * FROM reservations WHERE id IN (511, 512);
UPDATE reservations SET status = 'CONFIRMADA' WHERE id IN (511, 512);
SELECT * FROM reservations WHERE id IN (511, 512);

-- DML-04
SELECT * FROM brands WHERE id = 7 AND NOT EXISTS (SELECT 1 FROM models WHERE brand_id = 7);
DELETE FROM brands WHERE id = 7 AND NOT EXISTS (SELECT 1 FROM models WHERE brand_id = 7);
SELECT * FROM brands WHERE id = 7 AND NOT EXISTS (SELECT 1 FROM models WHERE brand_id = 7);

SELECT * FROM extras WHERE id = 6 AND NOT EXISTS (SELECT 1 FROM contract_extras WHERE extra_id = 6);
DELETE FROM extras WHERE id = 6 AND NOT EXISTS (SELECT 1 FROM contract_extras WHERE extra_id = 6);
SELECT * FROM extras WHERE id = 6 AND NOT EXISTS (SELECT 1 FROM contract_extras WHERE extra_id = 6);

SELECT * FROM categories WHERE id = 1;
SELECT (SELECT COUNT(*) FROM models WHERE category_id = 1) AS modelos,
       (SELECT COUNT(*) FROM rates WHERE category_id = 1) AS tarifas;
-- ⚠️ ESPERADO: ERROR 1451. Hay modelos y tarifas que dependen de Económico.
-- DELETE FROM categories WHERE id = 1;
SELECT * FROM categories WHERE id = 1;

-- DML-05
-- ⚠️ ESPERADO: ERROR 1062. La placa es UNIQUE.
-- INSERT INTO vehicles (model_id, branch_id, plate, model_year, color, mileage_km) VALUES (1, 1, 'KWD101', 2026, 'Blanco', 0);
-- ⚠️ ESPERADO: ERROR 3819. La cantidad debe ser al menos 1.
-- INSERT INTO contract_extras (contract_id, extra_id, quantity, agreed_daily_price) VALUES (9001, 1, 0, 15000);
-- ⚠️ ESPERADO: ERROR 1265. CHEQUE no pertenece al ENUM de medios.
-- INSERT INTO payments (contract_id, concept, amount, method, paid_at) VALUES (9001, 'CIERRE', 1000, 'CHEQUE', '2026-11-23 10:00:00');
