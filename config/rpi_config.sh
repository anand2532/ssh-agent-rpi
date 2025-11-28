#!/bin/bash
# Raspberry Pi SSH Configuration
# Edit these values to match your RPi setup

# RPi IP address or hostname
# Find it with: hostname -I (on RPi) or check your router's DHCP table
export RPI_HOST="192.168.1.8"  # RPi IP address

# RPi username (usually "pi" or your username)
export RPI_USER="lazy-learn"  # RPi username

# SSH port (default is 22)
export RPI_PORT="22"

# SSH options
export RPI_SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

