#!/bin/bash
# Display the SSH public key for manual setup

SSH_KEY="${HOME}/.ssh/id_rsa.pub"

if [ ! -f "${SSH_KEY}" ]; then
    echo "SSH public key not found. Generating one..."
    ssh-keygen -t rsa -b 4096 -f "${HOME}/.ssh/id_rsa" -N ""
fi

echo "Your SSH public key:"
echo "===================="
cat "${SSH_KEY}"
echo ""
echo "To manually add this key to your RPi, run on your RPi:"
echo "  mkdir -p ~/.ssh"
echo "  echo '$(cat ${SSH_KEY})' >> ~/.ssh/authorized_keys"
echo "  chmod 700 ~/.ssh"
echo "  chmod 600 ~/.ssh/authorized_keys"
echo ""
echo "Or copy the key above and paste it into:"
echo "  ~/.ssh/authorized_keys on your RPi"

