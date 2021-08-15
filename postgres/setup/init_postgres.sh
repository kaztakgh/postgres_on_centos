#!/bin/bash

set -x

DB_NAME=sampledb
DB_USER=user1
DB_PASS=password1
# PG_CONFDIR="/var/lib/pgsql/12/data"

__initial() {
  if [ -z "$(ls -A $PGDATA)" ]; then
    su postgres -c "initdb -E UTF8 -D $PGDATA --locale=C"
  fi
  # データの挿入
  # psql -f /init/setup.sql
}

__create_user() {
  #Grant rights
  usermod -G wheel postgres
  # postgresqlの開始
  su postgres -c "pg_ctl -w start -D $PGDATA"

  # Check to see if we have pre-defined credentials to use
  if [ -n "${DB_USER}" ]; then
    if [ -z "${DB_PASS}" ]; then
      echo ""
      echo "WARNING: "
      echo "No password specified for \"${DB_USER}\". Generating one"
      echo ""
      DB_PASS=$(pwgen -c -n -1 12)
      echo "Password for \"${DB_USER}\" created as: \"${DB_PASS}\""
    fi
    # ユーザ作成
    echo "Creating user \"${DB_USER}\"..."
    echo "CREATE ROLE ${DB_USER} WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD '${DB_PASS}';"
    su postgres -c "psql -U postgres -c \"CREATE ROLE ${DB_USER} WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD '${DB_PASS}';\""
  fi

  if [ -n "${DB_NAME}" ]; then
    echo "Creating database \"${DB_NAME}\"..."
    echo "CREATE DATABASE ${DB_NAME};" | 
      su postgres -c "createdb ${DB_NAME}"

    if [ -n "${DB_USER}" ]; then
      echo "Granting access to database \"${DB_NAME}\" for user \"${DB_USER}\"..."
      echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};"
      su postgres -c "psql -U postgres -c \"GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};\""
    fi
  fi
  # postgresqlをいったん終了する
  su postgres -c "pg_ctl -w stop -D $PGDATA"
}

# Call all functions
__initial
__create_user