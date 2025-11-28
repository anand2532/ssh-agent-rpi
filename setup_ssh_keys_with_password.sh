#!/bin/bash
# Set up SSH key authentication using password

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "${SCRIPT_DIR}/config/rpi_config.sh"

# Password (passed as argument or environment variable)
RPI_PASSWORD="${1:-${RPI_PASSWORD}}"

if [ -z "${RPI_PASSWORD}" ]; then
    echo "Usage: $0 <password>"
    echo "Or set RPI_PASSWORD environment variable"
    exit 1
fi

# Check if SSH key exists, if not generate one
SSH_KEY="${HOME}/.ssh/id_rsa"
if [ ! -f "${SSH_KEY}" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "${SSH_KEY}" -N "" -q
    echo "SSH key generated at ${SSH_KEY}"
else
    echo "Using existing SSH key at ${SSH_KEY}"
fi

# Accept host key first
echo "Accepting host key..."
ssh-keyscan -H ${RPI_HOST} >> ~/.ssh/known_hosts 2>/dev/null

# Copy public key to RPi using sshpass
echo "Copying SSH public key to RPi..."

# Check if sshpass is available
if command -v sshpass &> /dev/null; then
    sshpass -p "${RPI_PASSWORD}" ssh-copy-id -p ${RPI_PORT} ${RPI_USER}@${RPI_HOST} 2>/dev/null
    RESULT=$?
elif command -v expect &> /dev/null; then
    # Use expect as fallback
    expect << EOF
spawn ssh-copy-id -p ${RPI_PORT} ${RPI_USER}@${RPI_HOST}
expect {
    "password:" { send "${RPI_PASSWORD}\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    RESULT=$?
else
    echo "Error: Neither sshpass nor expect is installed."
    echo "Please install one of them:"
    echo "  sudo apt-get install sshpass"
    echo "  sudo apt-get install expect"
    echo ""
    echo "Or manually add the key using show_public_key.sh"
    exit 1
fi

if [ $RESULT -eq 0 ]; then
    echo ""
    echo "✓ SSH key authentication set up successfully!"
    echo "You can now SSH to your RPi without a password."
    echo ""
    echo "Test the connection:"
    echo "  ./rpi_exec.sh 'hostname'"
else
    echo ""
    echo "✗ Failed to set up SSH key authentication."
    echo "Trying manual method..."
    echo ""
    echo "Your public key:"
    cat "${SSH_KEY}.pub"
    echo ""
    echo "Please manually add this key to your RPi:"
    echo "  ssh ${RPI_USER}@${RPI_HOST}"
    echo "  mkdir -p ~/.ssh"
    echo "  echo '$(cat ${SSH_KEY}.pub)' >> ~/.ssh/authorized_keys"
    echo "  chmod 700 ~/.ssh"
    echo "  chmod 600 ~/.ssh/authorized_keys"
    exit 1
fi

