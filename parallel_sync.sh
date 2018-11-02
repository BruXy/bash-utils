#!/bin/bash
#
# Author: Martin 'BruXy' Bruchanov, bruchy at gmail.com
# GitHub: https://github.com/BruXy/bash-utils
#
#%A
# Parallel rsync
# ==============
#
# EFS data migration need run more copy processes concurently. Set number
# of processes in N_PROC variable.
#
# Usage example:
#
# parallel_sync.sh [source_dir] [dest_dir]
# parallel_sync.sh /mnt/source/ /mnt/efs/destination/
#
# The script was inspired by Amazon presentation:
# https://youtu.be/PlTuJx4VnGw?t=1840
#%B

SOURCE_DIR=$1
DEST_DIR=$2
N_PROC=20
CPY_CMD="cp -up"

# Input check
# -----------

[[ "$1" =~ ^-?-h(elp)?$ ]] || [ $# -ne 2 ] && {
    sed -ne '/^#%A/,/^#%B/s/\(^#\|^#%[AB]\)//p' "$0" >&2
    echo "$0: Please provide source and destination directories." >&2
    exit 1;
}
[ -d "$SOURCE_DIR" ] || {
    echo "$0: Source directory '$SOURCE_DIR' does not exist! " 1>&2; exit 1;
}
[ -d "$DEST_DIR" ] || {
    echo "$0: Destination directory '$DEST_DIR' does not exist! " 1>&2; exit 1;
}

# Is parallel present?
# --------------------

parallel --version > /dev/null 2>&1 || {
    echo "$0: Please install GNU parallel."
    exit 1
}

# Clone directory tree
# --------------------

echo "$0: Cloning directory tree from '$SOURCE_DIR' to '$DEST_DIR'."
find "$SOURCE_DIR" -type d | \
        sed -e "s:$SOURCE_DIR::" | \
        parallel -j $N_PROC "mkdir -p ${DEST_DIR}/{}"

# Copy data
# ---------

echo "$0: Running $N_PROC process of rsync in parallel."
find "$SOURCE_DIR" ! \( -type d \) | \
        sed -e "s:$SOURCE_DIR::" | \
        parallel -j $N_PROC "$CPY_CMD $SOURCE_DIR/{} $DEST_DIR/{}"
