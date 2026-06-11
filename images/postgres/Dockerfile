# syntax=docker/dockerfile:1
FROM postgres:17-alpine
LABEL org.opencontainers.image.source="https://github.com/codedeviate/dbplayground"
LABEL org.opencontainers.image.description="dbplayground PostgreSQL, pre-seeded with the canonical test dataset"
LABEL org.opencontainers.image.licenses="MIT"
COPY seeds/postgres/ /docker-entrypoint-initdb.d/
