FROM alpine:3.19

LABEL maintainer="SamuelRu"
LABEL description="Docker image for rotating log files from other containers"
LABEL license="MIT"
LABEL copyright="Copyright (c) 2025 Samuel Runggaldier"
LABEL source="https://github.com/samuelru/logrotate"

# Install required packages
RUN apk add --no-cache \
    logrotate \
    tzdata \
    bash \
    coreutils \
    findutils \
    grep

# Create directory for logs
RUN mkdir -p /logs

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables with default values
ENV LOGS_PATH="/logs/*.log" \
    TRIGGER_INTERVAL="daily" \
    MAX_SIZE="NONE" \
    MAX_BACKUPS="365" \
    TZ="UTC"

# Set volume for logs
VOLUME /logs

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["run"]