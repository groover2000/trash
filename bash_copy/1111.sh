#!/bin/bash

MAX_JOBS=3
#pids=()
#declare -A jobs_map # Словарь
#declare -A start_map

USER="backup"
HOST="192.168.0.6"
SSH="ssh -i ~/.ssh/synology -p 132 $USER@$HOST"
SRC="/home/roomin/users/"
DST="${USER}@${HOST}:/volume1/backup_test/"
DATETIME=$(date "+%d-%m-%Y-%H-%M-%S")
LOG="$HOME/log/backup.log"
#LAST_BACKUP=$($SSH backup@192.168.0.6 "ls /volume1/backup_test/users/ | sort | tail -n1")
GLOBAL_START=$(date +%s)

for dir in "$SRC"*/; do

  while [[ $(jobs -p | wc -l) -ge "$MAX_JOBS" ]]; do

   wait -n

  done

  dirname=$(basename "$dir")
  echo "Make mirror for $dirname"

  (
  start_time=$(date +%s)
  $SSH "mkdir -p /volume1/backup_test/$DATETIME"
  rsync -a --no-owner --no-group --no-perms --backup -e "$SSH" "$dir" "$DST$DATETIME/$dirname/"
  status=$?
  end_time=$(date +%s)
  duration=$((end_time - start_time))

  if [[ $status -eq 0 ]]; then
      result="OK"
  else
    result="FAIL"
  fi

  {
    flock 200
    echo "$(date -d "@$start_time" "+%F %T")|$dirname|${duration}s|$result" >&200
  } 200>>"$LOG"
  ) &

done

wait

GLOBAL_END=$(date +%s)

ok_count=$(grep "OK" "$LOG" | wc -l)
fail_count=$(grep "FAIL" "$LOG" | wc -l)

echo "TOTAL: $ok_count OK, $fail_count FAIL"
echo "GLOBAL TIME $(( GLOBAL_END - GLOBAL_START ))s"

