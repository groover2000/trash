#!/bin/bash

set -e

## Another    ##
DATE=$(date "+%d%m%Y-%H%M%S")
START=$(date "+%s")
## Another    ##


## Credentials ##
USER="backup"
HOST="192.168.0.6"
SSH_KEY="${HOME}/.ssh/synology"
SSH_PORT="132"
SSH="ssh -i ${SSH_KEY} -p ${SSH_PORT}"
## Credentials ##

## PATH        ##
SRC="/mnt/${1%/}/"
DST="/volume1/backup_test/${1%/}/"
## PATH        ##


LAST_BACKUP=$($SSH ${USER}@${HOST} "ls ${DST} 2>/dev/null | grep '^[0-9]' | sort | tail -n 1 || true")
echo "${LAST_BACKUP}"

$SSH ${USER}@${HOST} "mkdir -p ${DST}${DATE}"

if [ -z "${LAST_BACKUP}" ]; then
  echo "No previous backup found. Running full backup"
  rsync -a --no-owner --no-group --no-perms --stats -e "${SSH}" "${SRC}" "${USER}@${HOST}:${DST}${DATE}/"

else
  echo "Using incremental backup based on ${LAST_BACKUP}"
  rsync -a --no-owner --no-group --no-perms --stats --link-dest="${DST}${LAST_BACKUP}" -e "${SSH}" "${SRC}" "${USER}@${HOST}:${DST}${DATE}/"

fi


END=$(date "+%s")

echo "$(( END - START))s"

echo ${DST}
