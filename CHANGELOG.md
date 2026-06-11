# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-06-11

### Added
- Valkey (`valkey/valkey:8-alpine`, default-on, seeded with the same demo keys
  as Redis via the shared seed file, BSD-3 redis-compatible).

## [0.2.0] - 2026-06-11

### Added
- Redis (`redis:7-alpine`, default-on) with a seeded set of demo keys
  (`demo:greeting`, `product:1/2`, `customer:1/2`, `recent_orders`);
  seed is idempotent and runs automatically via `make up`.
- Memcached (`memcached:1.6-alpine`, default-on, connectivity-only — no
  persistence, starts empty).
- `make redis` convenience target — opens a `redis-cli` shell.
- Host-client connectivity check section in the README (redis-cli ping/get,
  memcached stats via `nc`).

### Notes
- MSSQL evaluated and deferred: x86_64-only image is slow under emulation on
  Apple Silicon and requires a multi-GB download; consistent with the existing
  Oracle rationale.

## [0.1.0] - 2026-06-11

### Added
- `docker-compose.yml` fleet running PostgreSQL, MySQL, MariaDB, and ClickHouse
  by default, with OpenLDAP behind the `ldap` profile.
- Configurable non-default host ports and credentials via `.env`
  (template in `.env.example`).
- Shared canonical seed dataset (`customers`, `products`, `orders`) for every
  SQL engine, plus a seeded OpenLDAP test directory.
- Per-service healthchecks; `make up` waits until the fleet is healthy.
- `Makefile` with lifecycle (`up`, `up-all`, `down`, `reset`) and per-engine
  shell targets (`psql`, `mysql`, `maria`, `click`, `ldap-search`).
- Commented, ready-to-uncomment Oracle Free service (`oracle` profile).
- `README.md` with badges, port table, and usage; `DOCKERHUB.md` publishing
  exploration; MIT `LICENSE`.

[Unreleased]: https://github.com/codedeviate/dbplayground/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/codedeviate/dbplayground/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/codedeviate/dbplayground/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/codedeviate/dbplayground/releases/tag/v0.1.0
