# Publishing dbplayground — options & requirements

> Exploration only. No publishing is wired in v0.1.0. This documents the
> choices so they can be actioned later.

## Key point

`dbplayground` is **not** a custom image — it is a `docker-compose.yml` plus
bind-mounted seed SQL/LDIF on top of upstream official images
(`postgres`, `mysql`, `mariadb`, `clickhouse`, `osixia/openldap`). So there is
very little of our own to publish.

## Options

### 1. Publish nothing (recommended for now)
Ship only the Git repo. Consumers `git clone` and `make up`. Zero registry
maintenance, no account needed, always uses the engines' own official images.

**Requirements:** none beyond the public GitHub repo.

### 2. Pre-seeded custom images
Bake the seed files into thin per-engine images
(`codedeviate/dbplayground-postgres`, `-mysql`, `-mariadb`, `-clickhouse`) so a
consumer can `docker run` a pre-seeded engine without cloning the repo. More
convenient for consumers; more to build/tag/push every release (N images).

**Requirements:**
- A `Dockerfile` per engine (`FROM <official>` + `COPY seeds/... initdb.d/`).
- Docker Hub account + `docker login`.
- One Docker Hub repository per image (or one repo, many tags).
- Recommended: a GitHub Actions workflow using `docker/setup-qemu-action`,
  `docker/setup-buildx-action`, and `docker/build-push-action` to build
  multi-arch (`linux/amd64,linux/arm64`) and push on Git tag.
- A Docker Hub access token stored as a GitHub Actions secret
  (e.g. `DOCKERHUB_TOKEN`) plus the username secret.
- Tag scheme aligned with SemVer (e.g. `:0.1.0` and `:latest`).

### 3. GHCR instead of Docker Hub
Same as option 2 but push to `ghcr.io/codedeviate/dbplayground-<engine>`.
Uses the existing GitHub account/permissions (`GITHUB_TOKEN` in Actions) — no
separate Docker Hub account or token needed. Good if everything else already
lives on GitHub.

**Requirements:**
- `packages: write` permission in the workflow.
- Login via `docker/login-action` against `ghcr.io` using `GITHUB_TOKEN`.

## Recommendation

Stay on option 1 until a concrete need appears for a `docker run`-able
pre-seeded image. If/when it does, prefer option 3 (GHCR) to avoid managing a
second registry account, and add a tag-triggered multi-arch build workflow.
