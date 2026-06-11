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
| OpenLDAP   | `osixia/openldap:1.5.0`                  | profile  | `13389` / `16636`   | —          |

Default credentials (override in `.env`): user `playground` / password
`playground`; SQL root password `rootpw`; LDAP admin `cn=admin,dc=example,dc=org`
/ `adminpw`.

## Usage

| Command          | What it does                                              |
|------------------|----------------------------------------------------------|
| `make init`      | Create `.env` from `.env.example` (if missing)           |
| `make up`        | Start the four default engines, wait until healthy       |
| `make up-all`    | Same, **plus** OpenLDAP (`ldap` profile)                 |
| `make down`      | Stop & remove containers (keeps data volumes)            |
| `make reset`     | Stop & remove containers **and** volumes (forces reseed) |
| `make ps`        | Show service status                                      |
| `make logs`      | Follow all logs                                          |
| `make psql`      | `psql` shell into Postgres                               |
| `make mysql`     | `mysql` shell into MySQL                                 |
| `make maria`     | `mariadb` shell into MariaDB                             |
| `make click`     | `clickhouse-client` shell                                |
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

## Seed data

Every SQL engine is seeded with the same canonical schema —
`customers`, `products`, `orders` (a handful of rows) — so the same logical
query can be run against each engine and compared. OpenLDAP gets a small test
directory (`ou=people` / `ou=groups` with users `alice`, `bob` and a `testers`
group). Seed files live under `seeds/<engine>/` and run on first boot; use
`make reset` to wipe volumes and reseed.

## Oracle

Oracle Database Free is free to use but is x86_64-only (slow under emulation on
Apple Silicon) and multi-GB, so it is **not wired by default**. A ready-to-
uncomment `oracle` service (profile `oracle`) lives at the bottom of
`docker-compose.yml`.

## Publishing

This repo is just Compose + seed files using upstream official images, so there
is little to publish. See [DOCKERHUB.md](DOCKERHUB.md) for the options if you
later want pre-seeded images on Docker Hub or GHCR.

## Requirements

- Docker Engine with Compose v2 (`docker compose`)
- GNU Make

## License

[MIT](LICENSE)
