# syntax=docker/dockerfile:1
FROM clickhouse/clickhouse-server:24-alpine
LABEL org.opencontainers.image.source="https://github.com/codedeviate/dbplayground"
LABEL org.opencontainers.image.description="dbplayground ClickHouse, pre-seeded with the canonical test dataset"
LABEL org.opencontainers.image.licenses="MIT"
COPY seeds/clickhouse/ /docker-entrypoint-initdb.d/
