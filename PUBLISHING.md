# Publishing dbplayground — GHCR

> This file documents how the pre-seeded engine images are built and
> published to the GitHub Container Registry (GHCR), and how consumers can
> use them without cloning the repository.

## What is published

Four per-engine images are published to GHCR, each pre-seeded with the
canonical test dataset (`customers`, `products`, `orders`):

| Image | Engine |
|-------|--------|
| `ghcr.io/codedeviate/dbplayground-postgres` | PostgreSQL 17 |
| `ghcr.io/codedeviate/dbplayground-mysql` | MySQL 8.4 |
| `ghcr.io/codedeviate/dbplayground-mariadb` | MariaDB 11 |
| `ghcr.io/codedeviate/dbplayground-clickhouse` | ClickHouse 24 |

Redis is intentionally **not** republished — Redis 7's licence change
(RSALv2/SSPL) still permits local testing but complicates redistribution.
Valkey and Memcached could be published as upstream-only images but are
kept referencing upstream for simplicity. OpenLDAP is likewise upstream-only.
For seeded Redis/Valkey/LDAP data, clone the repo and use `make up`.

## How images are published

The `publish.yml` workflow (`.github/workflows/publish.yml`) triggers
automatically on every `v*` tag and also supports manual dispatch. It:

1. Builds all four engine images in parallel (matrix strategy).
2. Uses `docker/setup-qemu-action` + `docker/setup-buildx-action` for
   multi-arch support (`linux/amd64` + `linux/arm64`).
3. Authenticates to `ghcr.io` with the built-in `GITHUB_TOKEN` — no extra
   secrets to configure.
4. Tags each image with the full semver (`0.3.0`), `major.minor` (`0.3`),
   and `latest`.

**One-time setup:** after the first workflow run the packages will be created
in GHCR (initially private, inheriting repo visibility). To make them public,
go to each package's settings on GitHub and set visibility to "Public".
Alternatively, the `org.opencontainers.image.source` label links them to the
repo — public repos cause GHCR packages to be public automatically once
linked.

## How consumers use the images

### 1. Run a single seeded engine

```sh
# PostgreSQL — seeded, no repo checkout needed
docker run -d -p 15432:5432 \
  -e POSTGRES_USER=playground \
  -e POSTGRES_PASSWORD=playground \
  -e POSTGRES_DB=testdb \
  ghcr.io/codedeviate/dbplayground-postgres:0.3.0
```

### 2. Run the whole fleet (no repo checkout)

```sh
curl -O https://raw.githubusercontent.com/codedeviate/dbplayground/main/docker-compose.hub.yml
docker compose -f docker-compose.hub.yml up
```

The hub compose file uses upstream images for Redis/Valkey/Memcached
(connectivity only, starts empty) and the baked GHCR images for the four
SQL/OLAP engines (fully seeded).

### 3. Pin a specific release

```sh
DBP_TAG=0.3.0 docker compose -f docker-compose.hub.yml up
```

### Optional — fleet as a single OCI artifact (Compose v2.26+)

You can publish the entire fleet as a single OCI image artifact (manual,
not in CI — requires interactive confirmation):

```sh
# Publish (run locally, once)
docker compose -f docker-compose.hub.yml publish ghcr.io/codedeviate/dbplayground:0.3.0 -y

# Consumer
docker compose -f oci://ghcr.io/codedeviate/dbplayground:0.3.0 up
```

This is documented as optional — Compose v2.26+ only and the command is
interactive.

## Requirements recap

- **For consumers:** Docker Engine with Compose v2. No GitHub account needed
  for public packages. No `.env` file needed — `docker-compose.hub.yml` uses
  inline defaults for all variables.
- **For publishing:** the existing GitHub account and repo. `GITHUB_TOKEN` is
  provided automatically by Actions. Local Docker with buildx is only needed
  if you want to push by hand.
- **Cost:** public GHCR packages are free.

## Docker Hub alternative

The same approach works against Docker Hub instead of GHCR. Differences:

1. Replace `ghcr.io/codedeviate/` with `codedeviate/` in image names.
2. Store a Hub access token as `DOCKERHUB_TOKEN` and the username as
   `DOCKERHUB_USERNAME` in the repo's Actions secrets.
3. Swap the `docker/login-action` step to use Hub:
   ```yaml
   - uses: docker/login-action@v3
     with:
       username: ${{ secrets.DOCKERHUB_USERNAME }}
       password: ${{ secrets.DOCKERHUB_TOKEN }}
   ```
GHCR is preferred because it reuses the existing GitHub account with zero
extra secret management.
