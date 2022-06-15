#!/bin/bash
set -e

# Postgresql Role = User with LOGIN access
# CREATE USER ... = CREATE ROLE ... & ALTER ROLE .. WITH LOGIN

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER "gogs-user";
    ALTER USER "gogs-user" WITH PASSWORD 'gogs-user-password';
    CREATE DATABASE "gogs-db";
    GRANT ALL PRIVILEGES ON DATABASE "gogs-db" TO "gogs-user";
EOSQL