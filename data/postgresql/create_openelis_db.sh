#!/bin/bash

set -eu
function create_user() {
	local user=$1
	local password=$2
	echo "  Creating '$user' user..."
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" $POSTGRES_DB <<-EOSQL
	    CREATE USER "$user" WITH UNENCRYPTED PASSWORD '$password';
	    ALTER USER "$user" CREATEDB;
EOSQL
}

function create_user_and_database() {
	local database=$1
	local user=$2
	local password=$3
	psql -v ON_ERROR_STOP=1 --username postgres postgres <<-EOSQL
	    CREATE USER "$user" WITH UNENCRYPTED PASSWORD '$password';
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOSQL
}

create_user ${OPENELIS_ATOMFEED_USER} ${OPENELIS_ATOMFEED_PASSWORD}

echo "  Creating 'OpenELIS' user and database..."
create_user_and_database ${OPENELIS_DB_NAME} ${OPENELIS_DB_USER} ${OPENELIS_DB_PASSWORD}

psql -U ${OPENELIS_DB_USER} -d ${OPENELIS_DB_NAME} < /docker-entrypoint-initdb.d/db/OpenELIS_base.sql
