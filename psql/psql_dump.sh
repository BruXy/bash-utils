#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Estimate size of DB

printf "Size of DB %s:\n" $SRC_DB_NAME

PGPASSWORD=$SRC_RDS_PASS psql -U $SRC_RDS_USER -h $SRC_HOST $SRC_DB_NAME -c \
   "SELECT pg_size_pretty(pg_database_size('$SRC_DB_NAME'));"

# Dump database

DUMP=rds-${SRC_DB_NAME}-${TIMESTAMP}.dump

time PGPASSWORD=$SRC_RDS_PASS pg_dump -Fc -v -U $SRC_RDS_USER \
    -h "$SRC_HOST" -O "$SRC_DB_NAME" > $DUMP

retval=$?
if [ $retval -ne 0 ] ; then
    printf "Database dump failed with error code %d!" $retval 1>&2
else
    printf "Database dump: %s\n" $DUMP
fi
