# MongoDB Backup Tool

A simple and lightweight MongoDB backup solution using the official `mongodump` utility. This tool creates backups of your MongoDB databases and optionally uploads them to S3.

## Features

- Uses official MongoDB tools (`mongodump`)
- Simple shell script implementation (see [backup.sh](backup.sh))
- Optional S3 backup storage
- Docker support for easy deployment
- Supports MongoDB Atlas and self-hosted MongoDB instances via connection string

## Prerequisites

- Docker (if using the Docker image)
- MongoDB connection string (for MongoDB Atlas or your MongoDB instance)
- AWS credentials (optional, only if using S3 backup)

## Quick Start

1. Create a `.env` file based on the example:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your MongoDB connection string:
   ```
   MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<authdb>?retryWrites=true&w=majority
   ```

3. Create a backups directory:
   ```bash
   mkdir -p backups
   ```

4. Build the Docker image:
   ```bash
   docker build -t mongo-backup .
   ```

5. Run the container:
   ```bash
   docker run -d \
     --name mongo-backup \
     -v $(pwd)/backups:/backup \
     --env-file .env \
     mongo-backup
   ```

## Environment Variables

- `MONGODB_URI`: MongoDB connection string (required)
- `S3_BUCKET`: S3 bucket name for backup storage (optional)
- `S3_PREFIX`: Prefix for S3 backup files (optional, defaults to "mongodb-backups")
- `AWS_ACCESS_KEY_ID`: AWS access key (optional, required for S3)
- `AWS_SECRET_ACCESS_KEY`: AWS secret key (optional, required for S3)
- `AWS_DEFAULT_REGION`: AWS region (optional, defaults to "us-east-1")

## How It Works

This tool is built around a simple shell script ([backup.sh](backup.sh)) that uses the official MongoDB `mongodump` utility. The process is straightforward:

1. Creates a timestamped backup directory
2. Runs `mongodump` to create the backup
3. Compresses the backup into a tar.gz file
4. Optionally uploads to S3 if configured
5. Cleans up temporary files

## Manual Usage (Without Docker)

You can also use the backup script directly if you have MongoDB tools installed:

```bash
# Make the script executable
chmod +x backup.sh

# Run the backup
./backup.sh
```

## S3 Backup (Optional)

To enable S3 backup storage:
1. Set up your AWS credentials in the `.env` file
2. Configure the S3 bucket and prefix
3. The backups will be automatically uploaded to your S3 bucket

## License

MIT 