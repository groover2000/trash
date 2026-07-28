#!/bin/bash

MAX_JOBS=3
pids=()


SRC="/home/roomin/users/"
DST="backup@192.168.0.6:/volume1/backup_test/users/"
SSH="ssh -i ~/.ssh/synology -p 132"
LOG="$HOME/log/backup.log"

for dir in "$SRC"*/; do

  dirname=$(basename "$dir")
  echo "Make mirror for $dirname"
  rsync -a --no-owner --no-group --no-perms --delete -e "$SSH" "$dir" "$DST$dirname/" >> "$LOG" 2>&1 &
  pids+=($!)

done

for pid in "${pids[@]}";do

  wait $pid
  status=$?

  if [ $status -eq 0 ]; then
    echo "Result: SUCCESS" >> "$LOG"
  else
    echo "Result FAIL (code: $status)" >> "$LOG"
  fi

  echo "End: $(date)" >> "$LOG"
  echo "" >> "$LOG"

done


