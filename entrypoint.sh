#!/bin/bash
set -e

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
    echo "Environment variables:"
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