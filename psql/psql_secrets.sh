#!/bin/bash

# Credentials for source database
# -------------------------------
#
# Used for:
# psql_src.sh -- shell connect
# dump

SRC_HOST=...
SRC_RDS_PASSWD=...
SRC_RDS_USER=
SRC_DB_NAME=...

# Credentials for destination database
# ------------------------------------
#
# Used for:
# psql_dst.sh -- shell connect
# pg_restore

DST_HOST=...
DST_RDS_PASSWD=...
DST_RDS_USER=
DST_DB_NAME=...

