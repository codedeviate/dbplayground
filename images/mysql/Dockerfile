# syntax=docker/dockerfile:1
FROM mysql:8.4
LABEL org.opencontainers.image.source="https://github.com/codedeviate/dbplayground"
LABEL org.opencontainers.image.description="dbplayground MySQL, pre-seeded with the canonical test dataset"
LABEL org.opencontainers.image.licenses="MIT"
COPY seeds/mysql/ /docker-entrypoint-initdb.d/
