# Using dbplayground (paste this into your agent)

> Copy everything below the line into your coding agent. It tells the agent how
> to spin up **dbplayground** — a disposable, multi-engine database fleet — and
> point tests at it. It requires only Docker with Compose v2.

---

You have Docker available. **dbplayground** is a throwaway, multi-engine
database fleet for testing database connectivity. Spin it up, run tests against
it, then tear it down. It is **not** production — treat it as disposable.

## 1. Start the fleet (no checkout needed — images come from GHCR)

```sh
curl -fsSL -O https://raw.githubusercontent.com/codedeviate/dbplayground/main/docker-compose.hub.yml
docker compose -f docker-compose.hub.yml up -d --wait
```

`--wait` returns only once every service is healthy, so when the command exits
the fleet is ready. First run pulls images (public, multi-arch amd64/arm64);
allow a minute or two. To also start OpenLDAP, add `--profile ldap`.

Pin a version with `DBP_TAG` (default `latest`), e.g.
`DBP_TAG=0.4.0 docker compose -f docker-compose.hub.yml up -d --wait`.
Change any host port with the matching env var (see the table) if it collides.

## 2. Connect — host ports and credentials

Default SQL credentials: user `playground`, password `playground`, database
`testdb` (root password `rootpw`). All services listen on `127.0.0.1`.

| Engine     | Host port(s)        | Connect as / notes                                   |
|------------|---------------------|------------------------------------------------------|
| PostgreSQL | `15432`             | `playground` / `playground`, db `testdb` — seeded    |
| MySQL      | `13306`             | `playground` / `playground`, db `testdb` — seeded    |
| MariaDB    | `13307`             | `playground` / `playground`, db `testdb` — seeded    |
| ClickHouse | `18123` (HTTP), `19000` (native) | `playground` / `playground`, db `testdb` — seeded |
| Redis      | `16379`             | no auth — seeded (demo keys)                          |
| Valkey     | `16380`             | no auth — seeded (demo keys)                          |
| Memcached  | `13211`             | no auth — always empty (no persistence)               |
| OpenLDAP   | `13389` (LDAP), `16636` (LDAPS) | profile `ldap`; admin `cn=admin,dc=example,dc=org` / `adminpw`, base `dc=example,dc=org` — seeded (users alice/bob, group testers) |

Env vars to override ports: `PG_PORT`, `MYSQL_PORT`, `MARIADB_PORT`,
`CLICKHOUSE_HTTP_PORT`, `CLICKHOUSE_NATIVE_PORT`, `REDIS_PORT`, `VALKEY_PORT`,
`MEMCACHED_PORT`, `LDAP_PORT`, `LDAPS_PORT`.

### Connection strings / one-line checks

```sh
psql "postgresql://playground:playground@127.0.0.1:15432/testdb" -tAc "SELECT count(*) FROM orders;"
mysql   -h127.0.0.1 -P13306 -uplayground -pplayground -N -e "SELECT count(*) FROM testdb.orders;"
mariadb -h127.0.0.1 -P13307 -uplayground -pplayground -N -e "SELECT count(*) FROM testdb.orders;"
curl -s "http://127.0.0.1:18123/?query=SELECT%20count(*)%20FROM%20testdb.orders"
redis-cli  -h 127.0.0.1 -p 16379 ping
valkey-cli -h 127.0.0.1 -p 16380 ping        # redis-cli also works against Valkey
printf 'stats\r\nquit\r\n' | nc 127.0.0.1 13211 | head   # memcached
```

## 3. Seed data (the SQL/OLAP engines)

Each SQL engine is pre-seeded with the same canonical schema, so the same
logical query works on all of them:

- `customers(id, name, email, country, created_at)`
- `products(id, sku, name, price, in_stock)`
- `orders(id, customer_id, product_id, quantity, ordered_at)`

There are 4 rows in each table (so `SELECT count(*) FROM orders;` returns `4`).

## 4. Tear down

```sh
docker compose -f docker-compose.hub.yml --profile ldap down -v
```

`-v` also removes the data volumes (full reset).

## 5. Alternative: clone the repo

The GHCR fleet above is fully seeded — Redis/Valkey have the demo keys and
OpenLDAP (when started with `--profile ldap`) has the test directory. If you
prefer to build and run everything locally from source, clone the repo and use
its Makefile instead:

```sh
git clone https://github.com/codedeviate/dbplayground.git
cd dbplayground
make init          # create .env from .env.example
make up            # all default engines, seeds Redis + Valkey too
make up-all        # same, plus a seeded OpenLDAP
make down          # stop (keep data)   |   make reset = stop + wipe volumes
```

Same ports, credentials, and schema as above.
