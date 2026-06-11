# syntax=docker/dockerfile:1
FROM mariadb:11
LABEL org.opencontainers.image.source="https://github.com/codedeviate/dbplayground"
LABEL org.opencontainers.image.description="dbplayground MariaDB, pre-seeded with the canonical test dataset"
LABEL org.opencontainers.image.licenses="MIT"
COPY seeds/mariadb/ /docker-entrypoint-initdb.d/
