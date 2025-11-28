#!/bin/bash
# Set up SSH key authentication for passwordless access to RPi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "${SCRIPT_DIR}/config/rpi_config.sh"

# Check if SSH key exists, if not generate one
SSH_KEY="${HOME}/.ssh/id_rsa"
if [ ! -f "${SSH_KEY}" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "${SSH_KEY}" -N ""
    echo "SSH key generated at ${SSH_KEY}"
else
    echo "Using existing SSH key at ${SSH_KEY}"
fi

# Copy public key to RPi
echo "Copying SSH public key to RPi..."
echo "You may be prompted for your RPi password (this will be the last time)"
ssh-copy-id -p ${RPI_PORT} ${RPI_USER}@${RPI_HOST}

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SSH key authentication set up successfully!"
    echo "You can now SSH to your RPi without a password."
    echo ""
    echo "Test the connection:"
    echo "  ./rpi_exec.sh 'hostname'"
else
    echo ""
    echo "✗ Failed to set up SSH key authentication."
    echo "Please check:"
    echo "  1. RPi is connected to the network"
    echo "  2. SSH is enabled on RPi (sudo systemctl enable ssh)"
    echo "  3. RPI_HOST and RPI_USER in config/rpi_config.sh are correct"
    exit 1
fi

