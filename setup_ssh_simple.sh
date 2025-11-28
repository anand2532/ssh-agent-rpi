#!/bin/bash
# Simple SSH key setup using password

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/rpi_config.sh"

RPI_PASSWORD="${1}"

if [ -z "${RPI_PASSWORD}" ]; then
    echo "Usage: $0 <password>"
    exit 1
fi

SSH_KEY="${HOME}/.ssh/id_rsa"
if [ ! -f "${SSH_KEY}" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "${SSH_KEY}" -N "" -q
fi

PUB_KEY=$(cat "${SSH_KEY}.pub")

echo "Accepting host key..."
ssh-keyscan -H ${RPI_HOST} >> ~/.ssh/known_hosts 2>/dev/null

echo "Adding SSH key to RPi..."

# Use Python with pexpect
python3 << PYEOF
import pexpect
import sys

rpi_host = """${RPI_HOST}"""
rpi_user = """${RPI_USER}"""
rpi_port = """${RPI_PORT}"""
rpi_password = """${RPI_PASSWORD}"""
pub_key = """${PUB_KEY}"""

cmd = f"""mkdir -p ~/.ssh && echo '{pub_key}' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"""

child = pexpect.spawn(f'ssh -o StrictHostKeyChecking=no -p {rpi_port} {rpi_user}@{rpi_host}', timeout=15)
child.logfile = sys.stdout.buffer

try:
    index = child.expect(['password:', 'Password:', pexpect.EOF, pexpect.TIMEOUT], timeout=10)
    if index in [0, 1]:
        child.sendline(rpi_password)
        child.expect(['$', '#', '>'], timeout=10)
        child.sendline(cmd)
        child.expect(['$', '#', '>'], timeout=10)
        child.sendline('exit')
        child.expect(pexpect.EOF, timeout=5)
        child.close()
        if child.exitstatus == 0:
            print("\n✓ SSH key authentication set up successfully!")
            sys.exit(0)
        else:
            print(f"\n✗ SSH command failed")
            sys.exit(1)
    else:
        print("\n✗ Did not get password prompt")
        sys.exit(1)
except Exception as e:
    print(f"\n✗ Error: {e}")
    sys.exit(1)
PYEOF

if [ $? -eq 0 ]; then
    echo ""
    echo "Test the connection:"
    echo "  ./rpi_exec.sh 'hostname'"
else
    echo ""
    echo "Manual setup:"
    echo "  ssh ${RPI_USER}@${RPI_HOST}"
    echo "  mkdir -p ~/.ssh"
    echo "  echo '${PUB_KEY}' >> ~/.ssh/authorized_keys"
    echo "  chmod 700 ~/.ssh"
    echo "  chmod 600 ~/.ssh/authorized_keys"
fi

