-- dbplayground canonical dataset (ClickHouse dialect)
-- Runs automatically via /docker-entrypoint-initdb.d.

CREATE DATABASE IF NOT EXISTS testdb;

CREATE TABLE testdb.customers (
    id         UInt32,
    name       String,
    email      String,
    country    FixedString(2),
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree ORDER BY id;

CREATE TABLE testdb.products (
    id        UInt32,
    sku       String,
    name      String,
    price     Decimal(10,2),
    in_stock  Bool
) ENGINE = MergeTree ORDER BY id;

CREATE TABLE testdb.orders (
    id          UInt32,
    customer_id UInt32,
    product_id  UInt32,
    quantity    UInt32 DEFAULT 1,
    ordered_at  DateTime DEFAULT now()
) ENGINE = MergeTree ORDER BY id;

INSERT INTO testdb.customers (id, name, email, country) VALUES
    (1, 'Alice Andersson', 'alice@example.com', 'SE'),
    (2, 'Bob Bauer',       'bob@example.com',   'DE'),
    (3, 'Carla Costa',     'carla@example.com', 'PT'),
    (4, 'Dmitri Dubois',   'dmitri@example.com','FR');

INSERT INTO testdb.products (id, sku, name, price, in_stock) VALUES
    (1, 'SKU-001', 'Widget',    9.99,  true),
    (2, 'SKU-002', 'Gadget',    19.50, true),
    (3, 'SKU-003', 'Gizmo',     4.25,  false),
    (4, 'SKU-004', 'Doohickey', 99.00, true);

INSERT INTO testdb.orders (id, customer_id, product_id, quantity) VALUES
    (1, 1, 1, 3),
    (2, 1, 2, 1),
    (3, 2, 4, 2),
    (4, 3, 3, 5);
