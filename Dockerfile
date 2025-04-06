FROM mongo:8.0.6

# Install AWS CLI
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        curl \
        unzip \
        && \
    pip3 install --no-cache-dir awscli==1.27.33 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy backup script
COPY backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup.sh

# Set environment variables with defaults (can be overridden)
ENV MONGODB_HOST="localhost" \
    MONGODB_PORT="27017" \
    MONGODB_USERNAME="" \
    MONGODB_PASSWORD="" \
    MONGODB_AUTH_DB="admin" \
    S3_BUCKET="" \
    S3_PREFIX="mongodb-backups" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="us-east-1" \
    BACKUP_RETENTION_DAYS="30"

# Set working directory
WORKDIR /backup

# Run backup script when container starts
ENTRYPOINT ["/usr/local/bin/backup.sh"]