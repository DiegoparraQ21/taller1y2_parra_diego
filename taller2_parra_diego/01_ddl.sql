DROP DATABASE IF EXISTS flotaya;
CREATE DATABASE flotaya;
USE flotaya;

CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE cities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    department_id BIGINT NOT NULL,
    name VARCHAR(80) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    UNIQUE (department_id, name)
);

CREATE TABLE branches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    city_id BIGINT NOT NULL,
    name VARCHAR(120) NOT NULL UNIQUE,
    address VARCHAR(160) NOT NULL,
    phone VARCHAR(25),
    is_airport BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(140) NOT NULL UNIQUE,
    role ENUM('ADMINISTRADOR','ASESOR','INSPECTOR','MECANICO') NOT NULL,
    hired_on DATE NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    minimum_age INT NOT NULL,
    deposit_amount DECIMAL(12,2) NOT NULL,
    CHECK (minimum_age >= 18),
    CHECK (deposit_amount > 0)
);

CREATE TABLE season_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name ENUM('BAJA','MEDIA','ALTA') NOT NULL UNIQUE
);

CREATE TABLE seasons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    season_type_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    starts_on DATE NOT NULL,
    ends_on DATE NOT NULL,
    CHECK (ends_on >= starts_on),
    FOREIGN KEY (season_type_id) REFERENCES season_types(id)
);

CREATE TABLE rates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    season_type_id BIGINT NOT NULL,
    daily_price DECIMAL(12,2) NOT NULL,
    CHECK (daily_price > 0),
    UNIQUE (category_id, season_type_id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (season_type_id) REFERENCES season_types(id)
);

CREATE TABLE brands (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE models (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    brand_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    name VARCHAR(60) NOT NULL,
    transmission ENUM('MECANICA','AUTOMATICA') NOT NULL,
    fuel_type ENUM('GASOLINA','DIESEL','HIBRIDO','ELECTRICO') NOT NULL,
    seats INT NOT NULL,
    CHECK (seats > 0),
    UNIQUE (brand_id, name),
    FOREIGN KEY (brand_id) REFERENCES brands(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE vehicles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    model_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    plate VARCHAR(10) NOT NULL UNIQUE,
    model_year INT NOT NULL,
    color VARCHAR(30) NOT NULL,
    mileage_km INT NOT NULL,
    status ENUM('DISPONIBLE','ALQUILADO','MANTENIMIENTO','FUERA_DE_SERVICIO') NOT NULL DEFAULT 'DISPONIBLE',
    CHECK (mileage_km >= 0),
    FOREIGN KEY (model_id) REFERENCES models(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE workshops (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    is_internal BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE maintenances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    workshop_id BIGINT NOT NULL,
    type ENUM('PREVENTIVO','CORRECTIVO','LATONERIA') NOT NULL,
    description VARCHAR(250) NOT NULL,
    starts_on DATE NOT NULL,
    ends_on DATE,
    cost DECIMAL(12,2),
    CHECK (ends_on >= starts_on),
    CHECK (cost >= 0),
    CHECK ((ends_on IS NULL AND cost IS NULL) OR (ends_on IS NOT NULL AND cost IS NOT NULL)),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (workshop_id) REFERENCES workshops(id)
);

CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    city_id BIGINT NOT NULL,
    document_type ENUM('CC','CE','PASAPORTE') NOT NULL DEFAULT 'CC',
    document_number VARCHAR(30) NOT NULL UNIQUE,
    first_names VARCHAR(70) NOT NULL,
    last_names VARCHAR(70) NOT NULL,
    email VARCHAR(140) NOT NULL UNIQUE,
    phone VARCHAR(25),
    birth_date DATE NOT NULL,
    registered_on DATE NOT NULL,
    status ENUM('ACTIVO','BLOQUEADO') NOT NULL DEFAULT 'ACTIVO',
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE licenses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    number VARCHAR(40) NOT NULL UNIQUE,
    category ENUM('B1','B2','C1','C2') NOT NULL,
    issued_on DATE NOT NULL,
    expires_on DATE NOT NULL,
    country VARCHAR(60) NOT NULL,
    CHECK (expires_on >= issued_on),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE drivers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_number VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    birth_date DATE NOT NULL,
    license_number VARCHAR(40) NOT NULL UNIQUE,
    license_expires_on DATE NOT NULL
);

CREATE TABLE extras (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE,
    daily_price DECIMAL(12,2) NOT NULL,
    CHECK (daily_price > 0)
);

CREATE TABLE reservations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    vehicle_id BIGINT NOT NULL,
    pickup_branch_id BIGINT NOT NULL,
    return_branch_id BIGINT NOT NULL,
    starts_on DATE NOT NULL,
    ends_on DATE NOT NULL,
    quoted_amount DECIMAL(12,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDIENTE','CONFIRMADA','CONVERTIDA','CANCELADA') NOT NULL DEFAULT 'PENDIENTE',
    CHECK (ends_on > starts_on),
    CHECK (quoted_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (pickup_branch_id) REFERENCES branches(id),
    FOREIGN KEY (return_branch_id) REFERENCES branches(id)
) AUTO_INCREMENT = 501;

CREATE TABLE contracts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reservation_id BIGINT NOT NULL UNIQUE,
    vehicle_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    starts_on DATE NOT NULL,
    expected_end_on DATE NOT NULL,
    returned_on DATE,
    rental_amount DECIMAL(12,2) NOT NULL,
    status ENUM('ABIERTO','CERRADO') NOT NULL DEFAULT 'ABIERTO',
    CHECK (expected_end_on > starts_on),
    CHECK (returned_on > starts_on),
    CHECK (rental_amount >= 0),
    CHECK (status <> 'CERRADO' OR returned_on IS NOT NULL),
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) AUTO_INCREMENT = 9001;

CREATE TABLE contract_extras (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    extra_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    agreed_daily_price DECIMAL(12,2) NOT NULL,
    CHECK (quantity >= 1),
    CHECK (agreed_daily_price > 0),
    UNIQUE (contract_id, extra_id),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (extra_id) REFERENCES extras(id)
);

CREATE TABLE contract_drivers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    driver_id BIGINT NOT NULL,
    UNIQUE (contract_id, driver_id),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

CREATE TABLE deliveries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL UNIQUE,
    branch_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    delivered_at DATETIME NOT NULL,
    mileage_km INT NOT NULL,
    fuel_pct INT NOT NULL,
    CHECK (mileage_km >= 0),
    CHECK (fuel_pct BETWEEN 0 AND 100),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE returns (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL UNIQUE,
    branch_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    returned_at DATETIME NOT NULL,
    mileage_km INT NOT NULL,
    fuel_pct INT NOT NULL,
    CHECK (mileage_km >= 0),
    CHECK (fuel_pct BETWEEN 0 AND 100),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE inspections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    stage ENUM('ENTREGA','DEVOLUCION') NOT NULL,
    inspected_at DATETIME NOT NULL,
    exterior_ok BOOLEAN NOT NULL,
    interior_ok BOOLEAN NOT NULL,
    notes VARCHAR(250),
    UNIQUE (contract_id, stage),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE damages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inspection_id BIGINT NOT NULL,
    description VARCHAR(250) NOT NULL,
    severity ENUM('LEVE','MODERADO','GRAVE') NOT NULL,
    repair_cost DECIMAL(12,2) NOT NULL,
    charge_customer BOOLEAN NOT NULL,
    CHECK (repair_cost >= 0),
    FOREIGN KEY (inspection_id) REFERENCES inspections(id)
);

CREATE TABLE deposits (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    held_at DATETIME NOT NULL,
    released_at DATETIME,
    applied_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    status ENUM('RETENIDO','LIBERADO','APLICADO') NOT NULL DEFAULT 'RETENIDO',
    CHECK (amount > 0),
    CHECK (applied_amount BETWEEN 0 AND amount),
    CHECK (released_at >= held_at),
    CHECK ((status = 'RETENIDO' AND released_at IS NULL AND applied_amount = 0) OR (status = 'LIBERADO' AND released_at IS NOT NULL AND applied_amount = 0) OR (status = 'APLICADO' AND released_at IS NOT NULL AND applied_amount > 0)),
    FOREIGN KEY (contract_id) REFERENCES contracts(id)
);

CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    concept ENUM('ALQUILER','EXTRAS','DAÑOS','CIERRE') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    method ENUM('TARJETA','EFECTIVO','TRANSFERENCIA','DEPOSITO') NOT NULL,
    paid_at DATETIME NOT NULL,
    card_last_four CHAR(4),
    authorization_code VARCHAR(40),
    CHECK (amount > 0),
    FOREIGN KEY (contract_id) REFERENCES contracts(id)
);

SHOW TABLES;
DESCRIBE reservations;
DESCRIBE contracts;
