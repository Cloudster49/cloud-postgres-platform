#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$HOME/cloud-postgres-platform"

# Load database configuration
source "$PROJECT_ROOT/.env"

BACKUP_DIR="$PROJECT_ROOT/backup/backups"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/cloud_platform_$TIMESTAMP.dump"

mkdir -p "$BACKUP_DIR"

echo "Starting database backup..."
echo "Backup file: $BACKUP_FILE"

pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -F c -f "$BACKUP_FILE"

echo "Backup completed successfully."

ls -lh "$BACKUP_FILE"