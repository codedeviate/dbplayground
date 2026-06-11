-- dbplayground canonical dataset (PostgreSQL dialect)
-- Runs automatically via /docker-entrypoint-initdb.d against database "testdb".

CREATE TABLE customers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    country     VARCHAR(2)   NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id        SERIAL PRIMARY KEY,
    sku       VARCHAR(32)  NOT NULL UNIQUE,
    name      VARCHAR(100) NOT NULL,
    price     NUMERIC(10,2) NOT NULL,
    in_stock  BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customers(id),
    product_id   INTEGER NOT NULL REFERENCES products(id),
    quantity     INTEGER NOT NULL DEFAULT 1,
    ordered_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (name, email, country) VALUES
    ('Alice Andersson', 'alice@example.com', 'SE'),
    ('Bob Bauer',       'bob@example.com',   'DE'),
    ('Carla Costa',     'carla@example.com', 'PT'),
    ('Dmitri Dubois',   'dmitri@example.com','FR');

INSERT INTO products (sku, name, price, in_stock) VALUES
    ('SKU-001', 'Widget',  9.99,  TRUE),
    ('SKU-002', 'Gadget',  19.50, TRUE),
    ('SKU-003', 'Gizmo',   4.25,  FALSE),
    ('SKU-004', 'Doohickey', 99.00, TRUE);

INSERT INTO orders (customer_id, product_id, quantity) VALUES
    (1, 1, 3),
    (1, 2, 1),
    (2, 4, 2),
    (3, 3, 5);
