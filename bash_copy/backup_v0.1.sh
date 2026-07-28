#!/bin/bash

SRC="/home/roomin/users/"
DST="backup@192.168.0.6:/volume1/backup_test/users/"
SSH="ssh -i ~/.ssh/synology -p 132"
LOG="$HOME/log/backup.log"

for dir in "$SRC"*/; do
  username=$(basename "$dir")

  echo "Backup user: $username"
  echo  "------" $(date) "-------" >> "$LOG"

  rsync -rlt --delete -e "$SSH" "$dir" "$DST$username/" >> "$LOG" 2>&1

done

