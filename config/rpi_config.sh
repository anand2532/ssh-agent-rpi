#!/bin/bash
# Raspberry Pi SSH Configuration
# Edit these values to match your RPi setup

# RPi IP address or hostname
# Find it with: hostname -I (on RPi) or check your router's DHCP table
export RPI_HOST="raspberrypi.local"  # Change this to your RPi's IP (e.g., "192.168.1.100")

# RPi username (usually "pi" or your username)
export RPI_USER="pi"  # Change this to your RPi username

# SSH port (default is 22)
export RPI_PORT="22"

# SSH options
export RPI_SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

