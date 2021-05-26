#!/bin/sh

BACKUP_CMD="/sbin/su-exec ${UID}:${GID} /app/backup.sh"
LOGS_FILE="/app/log/backup.log"

# Run backup script once ($1 = First argument passed).
if [ "$1" = "manual" ]; then
  echo "[INFO] Running one-time, started at $(date +"%F %r")."
  $BACKUP_CMD
  exit 0
fi

# Create cron jobs.
if [ "$(id -u)" -eq 0 ] && [ "$(grep -c "$BACKUP_CMD" "$CRONFILE")" -eq 0 ]; then
  echo "$CRON_TIME $BACKUP_CMDD >> $LOGS_FILE 2>&1" | crontab -
  # Delete after x days job here.
fi

# Start crond if it's not running.
pgrep crond > /dev/null 2>&1
if [ $? -ne 0 ]; then
  /usr/sbin/crond -L /app/log/cron.log
fi

# Restart script as user "app:app".
if [ "$(id -u)" -eq 0 ]; then
  exec su-exec app:app "$0" "$@"
fi

echo "[INFO] Running automatically (${CRON_TIME}), started at $(date +"%F %r")."# > "$LOGS_FILE"
tail -F "$LOGS_FILE" /app/log/cron.log # Keeps terminal open and writes logs.
