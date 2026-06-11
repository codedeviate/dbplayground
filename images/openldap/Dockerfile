# syntax=docker/dockerfile:1
FROM osixia/openldap:1.5.0
LABEL org.opencontainers.image.source="https://github.com/codedeviate/dbplayground"
LABEL org.opencontainers.image.description="dbplayground OpenLDAP, pre-seeded with the test directory"
LABEL org.opencontainers.image.licenses="MIT"
COPY seeds/ldap/ /container/service/slapd/assets/config/bootstrap/ldif/custom/
