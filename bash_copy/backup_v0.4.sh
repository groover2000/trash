#!/bin/bash

MAX_JOBS=3
pids=()
declare -A jobs_map # Словарь
declare -A start_map

SRC="/home/roomin/users/"
DST="backup@192.168.0.6:/volume1/backup_test/users/"
SSH="ssh -i ~/.ssh/synology -p 132"
LOG="$HOME/log/backup.log"

for dir in "$SRC"*/; do

  dirname=$(basename "$dir")
  echo "Make mirror for $dirname"
  rsync -a --no-owner --no-group --no-perms --delete -e "$SSH" "$dir" "$DST$dirname/" >> "$LOG" 2>&1 &

  jobs_map[$dirname]=$!
  start_map[$dirname]=$(date +%s)

done

for dir in "${!jobs_map[@]}";do

  pid=${jobs_map[$dir]}
  start_time=${start_map[$dir]}
  wait $pid
  status=$?
  end_time=$(date +%s)
  duration=$((end_time - start_time))

  if [ $status -eq 0 ]; then
    result="SUCCESS"
  else
    result="FAIL (code: $status)"
  fi

  echo "Directory: $dir" >> "$LOG"
  echo "Start time: $(date -d "@$start_time" "+%Y-%m-%d %H:%M:%S")" >> "$LOG"
  echo "Result: $result" >> "$LOG"
  echo "End: $(date -d "@$end_time" "+%Y-%m-%d %H:%M:%S")" >> "$LOG"
  echo "Duration: ${duration}s" >> "$LOG"
  echo "" >> "$LOG"

done


