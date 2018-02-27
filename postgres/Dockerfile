# vim:set ft=dockerfile:
FROM postgres 

COPY createSonar.sql /docker-entrypoint-initdb.d/
COPY createKeycloak.sql /docker-entrypoint-initdb.d/
