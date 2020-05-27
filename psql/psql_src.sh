#!/bin/bash
source ./psql_secrets.sh
PGPASSWORD=$SRC_RDS_PASSWD psql -U $SRC_RDS_USER -h $SRC_HOST $SRC_DB_NAME

