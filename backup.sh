#!/bin/bash
set -e

# Create timestamp for backup name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_$TIMESTAMP"
BACKUP_PATH="/backup/$BACKUP_NAME"

# Create backup directory
mkdir -p $BACKUP_PATH

echo "Starting MongoDB backup at $(date)..."

# Build authentication options
AUTH_OPTS=""
if [ -n "$MONGODB_USERNAME" ] && [ -n "$MONGODB_PASSWORD" ]; then
  AUTH_OPTS="--username=$MONGODB_USERNAME --password=$MONGODB_PASSWORD --authenticationDatabase=$MONGODB_AUTH_DB"
fi

# Run mongodump to backup all databases and collections
mongodump --host=$MONGODB_HOST \
  --port=$MONGODB_PORT \
  $AUTH_OPTS \
  --out=$BACKUP_PATH

echo "MongoDB dump completed."

# Compress the backup
cd /backup
tar -zcvf $BACKUP_NAME.tar.gz $BACKUP_NAME
echo "Backup compressed to $BACKUP_NAME.tar.gz"

# Upload to S3 if S3 bucket is provided
if [ -n "$S3_BUCKET" ]; then
  echo "Uploading backup to S3 bucket: $S3_BUCKET"
  aws s3 cp /backup/$BACKUP_NAME.tar.gz s3://$S3_BUCKET/$S3_PREFIX/$BACKUP_NAME.tar.gz
  echo "Backup uploaded to S3: s3://$S3_BUCKET/$S3_PREFIX/$BACKUP_NAME.tar.gz"
else
  echo "No S3_BUCKET provided, skipping upload."
fi

# Cleanup backup directory
rm -rf $BACKUP_PATH
echo "Temporary files cleaned up."

# No retention handling here - using S3 bucket lifecycle policies instead

echo "Backup process completed successfully at $(date)!"