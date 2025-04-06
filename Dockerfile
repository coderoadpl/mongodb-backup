FROM mongo:8.0.6

# Install dependencies and AWS CLI
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv \
        curl \
        unzip \
        ca-certificates && \
    # Detect architecture and download appropriate AWS CLI version
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
        AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"; \
    else \
        AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
    fi && \
    # Download and install AWS CLI in a custom location
    mkdir -p /tmp/awscli && \
    cd /tmp/awscli && \
    curl "$AWS_CLI_URL" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    cd / && \
    rm -rf /tmp/awscli && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy backup script
COPY backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup.sh

# Set environment variables with defaults (can be overridden)
ENV MONGODB_URI="mongodb://localhost:27017"
ENV S3_BUCKET=""
ENV S3_PREFIX="mongodb-backups"
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_DEFAULT_REGION="us-east-1"

# Set working directory
WORKDIR /backup

# Run backup script when container starts
ENTRYPOINT ["/usr/local/bin/backup.sh"]