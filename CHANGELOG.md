# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/codedeviate/dbplayground/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/codedeviate/dbplayground/releases/tag/v0.1.0
