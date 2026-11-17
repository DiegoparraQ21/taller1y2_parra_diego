DROP DATABASE IF EXISTS bibliored;
CREATE DATABASE bibliored;
USE bibliored;

CREATE TABLE branches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    municipality VARCHAR(80) NOT NULL,
    address VARCHAR(150) NOT NULL,
    opened_on DATE NOT NULL
);

CREATE TABLE memberships (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE,
    loan_limit SMALLINT NOT NULL,
    loan_days SMALLINT NOT NULL,
    renewal_limit SMALLINT NOT NULL,
    daily_fine DECIMAL(10,2) NOT NULL,
    annual_fee DECIMAL(12,2) NOT NULL,
    CHECK (loan_limit > 0),
    CHECK (loan_days > 0),
    CHECK (renewal_limit >= 0),
    CHECK (daily_fine >= 0),
    CHECK (annual_fee >= 0)
);

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE publishers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL
);

CREATE TABLE authors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    nationality VARCHAR(60) NOT NULL,
    birth_year SMALLINT NOT NULL
);

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    hired_on DATE NOT NULL,
    role ENUM('COORDINADOR', 'BIBLIOTECARIO', 'AUXILIAR') NOT NULL DEFAULT 'BIBLIOTECARIO',
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE titles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    publisher_id BIGINT NOT NULL,
    isbn VARCHAR(13) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    publication_year SMALLINT NOT NULL,
    replacement_cost DECIMAL(12,2) NOT NULL DEFAULT 50000.00,
    CHECK (replacement_cost > 0),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(id)
);

CREATE TABLE title_authors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    author_order SMALLINT NOT NULL,
    UNIQUE (title_id, author_id),
    UNIQUE (title_id, author_order),
    CHECK (author_order > 0),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

CREATE TABLE copies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    barcode VARCHAR(30) NOT NULL UNIQUE,
    acquired_on DATE NOT NULL,
    status ENUM('DISPONIBLE', 'PRESTADO', 'EN_REPARACION', 'PERDIDO', 'DADO_DE_BAJA') NOT NULL DEFAULT 'DISPONIBLE',
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE members (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    membership_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    document_number VARCHAR(30) NOT NULL UNIQUE,
    first_names VARCHAR(80) NOT NULL,
    last_names VARCHAR(80) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(30),
    birth_date DATE NOT NULL,
    joined_on DATE NOT NULL,
    status ENUM('ACTIVO', 'SUSPENDIDO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    FOREIGN KEY (membership_id) REFERENCES memberships(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE loans (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    copy_id BIGINT NOT NULL,
    member_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    loaned_on DATE NOT NULL,
    due_on DATE NOT NULL,
    returned_on DATE,
    status ENUM('ACTIVO', 'DEVUELTO', 'PERDIDO') NOT NULL DEFAULT 'ACTIVO',
    CHECK (due_on > loaned_on),
    CHECK (returned_on >= loaned_on),
    CHECK ((status = 'DEVUELTO') = (returned_on IS NOT NULL)),
    FOREIGN KEY (copy_id) REFERENCES copies(id),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) AUTO_INCREMENT = 1001;

CREATE TABLE renewals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_id BIGINT NOT NULL,
    renewed_on DATE NOT NULL,
    previous_due_on DATE NOT NULL,
    new_due_on DATE NOT NULL,
    CHECK (new_due_on > previous_due_on),
    CHECK (renewed_on <= previous_due_on),
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

CREATE TABLE reservations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    title_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    reserved_on DATE NOT NULL,
    expires_on DATE NOT NULL,
    status ENUM('PENDIENTE', 'ATENDIDA', 'CANCELADA', 'VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
    CHECK (expires_on >= reserved_on),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE fines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_id BIGINT NOT NULL,
    reason ENUM('MORA', 'DAÑO', 'PERDIDA') NOT NULL,
    status ENUM('PENDIENTE', 'PAGADA', 'ANULADA') NOT NULL DEFAULT 'PENDIENTE',
    late_days INT NOT NULL DEFAULT 0,
    amount DECIMAL(12,2) NOT NULL,
    issued_on DATE NOT NULL,
    CHECK (late_days >= 0),
    CHECK (amount > 0),
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

CREATE TABLE fine_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fine_id BIGINT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    paid_on DATE NOT NULL,
    payment_method ENUM('EFECTIVO', 'TARJETA', 'TRANSFERENCIA') NOT NULL,
    CHECK (amount > 0),
    FOREIGN KEY (fine_id) REFERENCES fines(id)
);

SHOW TABLES;
DESCRIBE loans;

-- 10: El vencimiento inicial usa los días de una membresía de otra tabla.
-- 11: Se consultan socio, ejemplar, multas y cantidad de préstamos activos.
-- 12: Los estados del ejemplar y del préstamo están en filas de tablas distintas.
-- 14 y 15: Renovar depende de la membresía, el préstamo, el historial y las reservas.
-- 16: Vencer una reserva depende de la fecha de corte recibida.
-- 18: La mora usa la devolución, el vencimiento y una tarifa de otra tabla.
-- 19: La pérdida actualiza dos filas y crea una multa con el costo del título.
-- 20: El saldo requiere sumar cuotas de otras filas y actualizar la multa.
