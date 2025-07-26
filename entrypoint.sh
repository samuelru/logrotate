#!/bin/bash
#
# Copyright (c) 2025 Samuel Runggaldier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

# Function to strip quotes from a string
strip_quotes() {
    local value="$1"
    # Remove leading and trailing double quotes
    value="${value#\"}"
    value="${value%\"}"
    # Remove leading and trailing single quotes
    value="${value#\'}"
    value="${value%\'}"
    echo "$value"
}

# Function to generate logrotate configuration
generate_logrotate_config() {
    echo "Generating logrotate configuration..."
    
    # Create logrotate configuration file
    cat > /etc/logrotate.d/docker-logs << EOF
${LOGS_PATH} {
    ${TRIGGER_INTERVAL}
    rotate ${MAX_BACKUPS}
    dateext
    dateformat -%Y%m%d
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
EOF

    # Add size condition if specified
    if [ "${MAX_SIZE}" != "NONE" ]; then
        echo "    size ${MAX_SIZE}" >> /etc/logrotate.d/docker-logs
    fi

    # Close the configuration block
    echo "}" >> /etc/logrotate.d/docker-logs
    
    echo "Logrotate configuration generated."
    echo "Configuration:"
    cat /etc/logrotate.d/docker-logs
}

# Function to setup cron job
setup_cron() {
    echo "Setting up cron job for logrotate..."
    
    # Create cron job based on TRIGGER_INTERVAL
    case "${TRIGGER_INTERVAL}" in
        hourly)
            echo "0 * * * * /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" > /etc/crontabs/root
            ;;
        daily)
            echo "0 0 * * * /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" > /etc/crontabs/root
            ;;
        weekly)
            echo "0 0 * * 0 /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" > /etc/crontabs/root
            ;;
        monthly)
            echo "0 0 1 * * /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" > /etc/crontabs/root
            ;;
        yearly)
            echo "0 0 1 1 * /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" > /etc/crontabs/root
            ;;
        *)
            echo "Invalid TRIGGER_INTERVAL: ${TRIGGER_INTERVAL}. Using daily as default."
            echo "0 0 * * * /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" > /etc/crontabs/root
            ;;
    esac
    
    # Add an additional job to run logrotate if MAX_SIZE is specified (check every 15 minutes)
    if [ "${MAX_SIZE}" != "NONE" ]; then
        echo "*/15 * * * * /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs" >> /etc/crontabs/root
    fi
    
    echo "Cron job set up."
    echo "Cron configuration:"
    cat /etc/crontabs/root
}

# Main function
main() {
    echo "Starting logrotate container..."
    
    # Strip quotes from environment variables
    LOGS_PATH=$(strip_quotes "${LOGS_PATH}")
    TRIGGER_INTERVAL=$(strip_quotes "${TRIGGER_INTERVAL}")
    MAX_SIZE=$(strip_quotes "${MAX_SIZE}")
    MAX_BACKUPS=$(strip_quotes "${MAX_BACKUPS}")
    TZ=$(strip_quotes "${TZ}")
    
    echo "Environment variables (after processing):"
    echo "LOGS_PATH: ${LOGS_PATH}"
    echo "TRIGGER_INTERVAL: ${TRIGGER_INTERVAL}"
    echo "MAX_SIZE: ${MAX_SIZE}"
    echo "MAX_BACKUPS: ${MAX_BACKUPS}"
    echo "TZ: ${TZ}"
    
    # Generate logrotate configuration
    generate_logrotate_config
    
    # Setup cron job
    setup_cron
    
    # Run logrotate once at startup
    echo "Running logrotate at startup..."
    /usr/sbin/logrotate -f /etc/logrotate.d/docker-logs
    
    # Start cron in foreground
    echo "Starting cron daemon..."
    crond -f -d 8
}

# Check if the command is "run"
if [ "$1" = "run" ]; then
    main
else
    # Execute the command passed as arguments
    exec "$@"
fi