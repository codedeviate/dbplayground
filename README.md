# dbplayground

[![GitHub](https://img.shields.io/badge/github-codedeviate%2Fdbplayground-181717?logo=github)](https://github.com/codedeviate/dbplayground)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?logo=opensourceinitiative)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/docker-compose-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
<br/>
[![Latest release](https://img.shields.io/github/v/release/codedeviate/dbplayground?logo=semanticrelease&label=release&color=blue)](https://github.com/codedeviate/dbplayground/releases)
[![Conventional Commits](https://img.shields.io/badge/conventional%20commits-1.0.0-fe5196?logo=conventionalcommits)](https://www.conventionalcommits.org)

A throwaway, multi-engine **database playground** for testing tool
connectivity. Spin up PostgreSQL, MySQL, MariaDB, ClickHouse (and optionally
OpenLDAP) **all at once**, on **configurable non-default ports**, each seeded
with the same canonical dataset — then point your tool's test suite at them
and tear the whole thing down.

It is **not** a production service. It is a disposable test target.

```sh
make init     # create .env from .env.example
make up       # start pg + mysql + mariadb + clickhouse, wait until healthy
# ... run your tool's tests against the ports below ...
make down     # stop everything
```

## Why

Several tools support multiple database backends. Testing their connectivity
means standing up each engine — which collides with locally installed
databases and other Docker stacks on the default ports. `dbplayground` gives
every engine a configurable, out-of-the-way host port so they never collide,
and brings them up/down as one unit.

## Engines & default ports

All ports are set in `.env` (copied from `.env.example`) — change any of them
freely. Defaults sit in the `13000–19000` band to avoid collisions.

| Engine     | Image                                    | Default? | Host port(s)        | Default DB |
|------------|------------------------------------------|----------|---------------------|------------|
| PostgreSQL | `postgres:17-alpine`                     | yes      | `15432`             | `testdb`   |
| MySQL      | `mysql:8.4`                              | yes      | `13306`             | `testdb`   |
| MariaDB    | `mariadb:11`                             | yes      | `13307`             | `testdb`   |
| ClickHouse | `clickhouse/clickhouse-server:24-alpine` | yes      | `18123` / `19000`   | `testdb`   |
| Redis      | `redis:7-alpine`                         | yes      | `16379`             | —          |
| Valkey     | `valkey/valkey:8-alpine`                 | yes      | `16380`             | —          |
| Memcached  | `memcached:1.6-alpine`                   | yes      | `13211`             | —          |
| OpenLDAP   | `osixia/openldap:1.5.0`                  | profile  | `13389` / `16636`   | —          |

Default credentials (override in `.env`): user `playground` / password
`playground`; SQL root password `rootpw`; LDAP admin `cn=admin,dc=example,dc=org`
/ `adminpw`.

## Usage

| Command          | What it does                                              |
|------------------|----------------------------------------------------------|
| `make init`      | Create `.env` from `.env.example` (if missing)           |
| `make up`        | Start the default engines, wait until healthy            |
| `make up-all`    | Same, **plus** OpenLDAP (`ldap` profile)                 |
| `make down`      | Stop & remove containers (keeps data volumes)            |
| `make reset`     | Stop & remove containers **and** volumes (forces reseed) |
| `make ps`        | Show service status                                      |
| `make logs`      | Follow all logs                                          |
| `make psql`      | `psql` shell into Postgres                               |
| `make mysql`     | `mysql` shell into MySQL                                 |
| `make maria`     | `mariadb` shell into MariaDB                             |
| `make click`     | `clickhouse-client` shell                                |
| `make redis`     | `redis-cli` shell into Redis                             |
| `make valkey`    | `valkey-cli` shell into Valkey                           |
| `make ldap-search` | Sample `ldapsearch` against the seeded directory       |

### Connecting from another tool

Use the host ports from `.env`. Examples:

```sh
psql "postgresql://playground:playground@localhost:15432/testdb"
mysql -h127.0.0.1 -P13306 -uplayground -pplayground testdb
mariadb -h127.0.0.1 -P13307 -uplayground -pplayground testdb
curl "http://localhost:18123/?query=SELECT%20count(*)%20FROM%20testdb.orders"
ldapsearch -x -H ldap://localhost:13389 -b dc=example,dc=org \
  -D cn=admin,dc=example,dc=org -w adminpw
```

### Quick connectivity check (host clients)

After `make up` (or `make up-all`), verify each engine is reachable from the
host using locally installed clients. Each command should print `4` (the seeded
order count). The `psql` / `mysql` / `mariadb` / `ldapsearch` clients are
optional — skip any you don't have installed; the ClickHouse check needs only
`curl`.

```sh
psql "postgresql://playground:playground@127.0.0.1:15432/testdb" -tAc "SELECT count(*) FROM orders;"
mysql   -h127.0.0.1 -P13306 -uplayground -pplayground -N -e "SELECT count(*) FROM testdb.orders;"
mariadb -h127.0.0.1 -P13307 -uplayground -pplayground -N -e "SELECT count(*) FROM testdb.orders;"
curl -s "http://127.0.0.1:18123/?query=SELECT%20count(*)%20FROM%20testdb.orders"

redis-cli -h 127.0.0.1 -p 16379 ping                 # PONG
redis-cli -h 127.0.0.1 -p 16379 get demo:greeting
valkey-cli -h 127.0.0.1 -p 16380 ping                # PONG  (redis-cli also works)
valkey-cli -h 127.0.0.1 -p 16380 get demo:greeting
printf 'stats\r\nquit\r\n' | nc 127.0.0.1 13211 | head   # memcached stats

# OpenLDAP (make up-all): expect a non-zero entry count
ldapsearch -x -H ldap://127.0.0.1:13389 -b dc=example,dc=org \
  -D cn=admin,dc=example,dc=org -w adminpw "(objectClass=*)" dn | grep -c "^dn:"
```

## Seed data

Every SQL engine is seeded with the same canonical schema —
`customers`, `products`, `orders` (a handful of rows) — so the same logical
query can be run against each engine and compared. OpenLDAP gets a small test
directory (`ou=people` / `ou=groups` with users `alice`, `bob` and a `testers`
group). Seed files live under `seeds/<engine>/` and run on first boot; use
`make reset` to wipe volumes and reseed.

Redis is seeded with a handful of demo keys (`demo:greeting`, `product:1`,
`product:2`, `customer:1`, `customer:2`, `recent_orders`) automatically by
`make up` — the seed is idempotent (it `DEL`s `recent_orders` before
re-pushing, so running `make up` twice does not duplicate entries). Valkey is
a first-class default-on service and is seeded with the same demo keys using
the shared seed file (`seeds/redis/01-seed.redis`) — it is redis-protocol
compatible, so no separate seed file is needed. Memcached starts empty (no
persistence).

> **License note:** Redis 7's 2024 license change (RSALv2 / SSPLv1) still
> permits local testing and development use. [Valkey](https://valkey.io)
> (BSD-3) is now included as a first-class default-on service alongside Redis
> — it is a fully open-source, redis-compatible drop-in running on port
> `16380`.

## Using from an AI agent

Want a coding agent to spin up dbplayground and run tests against it? Copy the
contents of [AGENT.md](AGENT.md) into the agent — it's a self-contained guide
covering the no-checkout GHCR start, ports, credentials, seed schema, and
teardown.

## Oracle

Oracle Database Free is free to use but is x86_64-only (slow under emulation on
Apple Silicon) and multi-GB, so it is **not wired by default**. A ready-to-
uncomment `oracle` service (profile `oracle`) lives at the bottom of
`docker-compose.yml`.

## Publishing

Pre-seeded images for the four SQL/OLAP engines are published to GHCR on every
release and can be run without cloning this repo. See
[PUBLISHING.md](PUBLISHING.md) for the full details — what is published, how
the tag-triggered multi-arch workflow works, and how to consume the images.

## Requirements

- Docker Engine with Compose v2 (`docker compose`)
- GNU Make
- Image tags are pinned to a major (or major-minor) version and may pull newer patch releases on `docker compose pull`.

## License

[MIT](LICENSE)
