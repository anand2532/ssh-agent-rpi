#!/bin/bash
# Execute a command on the Raspberry Pi via SSH

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "${SCRIPT_DIR}/config/rpi_config.sh"

# Check if command is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    echo "Example: $0 'ls -la'"
    exit 1
fi

# Execute command on RPi
ssh ${RPI_SSH_OPTS} -p ${RPI_PORT} ${RPI_USER}@${RPI_HOST} "$@"

