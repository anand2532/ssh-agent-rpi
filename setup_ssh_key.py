#!/usr/bin/env python3
"""
Set up SSH key authentication using password
"""
import subprocess
import sys
import os
from pathlib import Path

# Load config
config_file = Path(__file__).parent / "config" / "rpi_config.sh"
config_vars = {}
with open(config_file) as f:
    for line in f:
        if line.startswith("export "):
            key, value = line.replace("export ", "").strip().split("=", 1)
            value = value.strip('"').strip("'")
            config_vars[key] = value

RPI_HOST = config_vars.get("RPI_HOST", "192.168.1.8")
RPI_USER = config_vars.get("RPI_USER", "lazy-learn")
RPI_PORT = config_vars.get("RPI_PORT", "22")
RPI_PASSWORD = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("RPI_PASSWORD")

if not RPI_PASSWORD:
    print("Usage: python3 setup_ssh_key.py <password>")
    print("Or set RPI_PASSWORD environment variable")
    sys.exit(1)

# Get or generate SSH key
ssh_dir = Path.home() / ".ssh"
ssh_dir.mkdir(mode=0o700, exist_ok=True)
private_key = ssh_dir / "id_rsa"
public_key = ssh_dir / "id_rsa.pub"

if not private_key.exists():
    print("Generating SSH key pair...")
    subprocess.run(["ssh-keygen", "-t", "rsa", "-b", "4096", "-f", str(private_key), "-N", ""], 
                   check=True, capture_output=True)
    print(f"SSH key generated at {private_key}")

# Read public key
with open(public_key) as f:
    pub_key = f.read().strip()

# Accept host key
print("Accepting host key...")
subprocess.run(["ssh-keyscan", "-H", RPI_HOST], 
               stdout=open(ssh_dir / "known_hosts", "a"), 
               stderr=subprocess.DEVNULL)

# Add key to RPi using ssh
print("Adding SSH public key to RPi...")
cmd = f"""mkdir -p ~/.ssh && 
echo '{pub_key}' >> ~/.ssh/authorized_keys && 
chmod 700 ~/.ssh && 
chmod 600 ~/.ssh/authorized_keys"""

# Use sshpass if available, otherwise use pexpect
try:
    result = subprocess.run(
        ["sshpass", "-p", RPI_PASSWORD, "ssh", 
         "-o", "StrictHostKeyChecking=no",
         "-p", RPI_PORT,
         f"{RPI_USER}@{RPI_HOST}", cmd],
        capture_output=True,
        text=True,
        timeout=10
    )
    if result.returncode == 0:
        print("\n✓ SSH key authentication set up successfully!")
        print("You can now SSH to your RPi without a password.")
        print("\nTest the connection:")
        print("  ./rpi_exec.sh 'hostname'")
        sys.exit(0)
except FileNotFoundError:
    # Try with pexpect
    try:
        import pexpect
        child = pexpect.spawn(
            f"ssh -o StrictHostKeyChecking=no -p {RPI_PORT} {RPI_USER}@{RPI_HOST}",
            timeout=10
        )
        child.logfile_read = sys.stdout.buffer
        index = child.expect(['password:', 'Password:', pexpect.EOF, pexpect.TIMEOUT], timeout=10)
        if index in [0, 1]:
            child.sendline(RPI_PASSWORD)
            child.expect(['$', '#', '>', pexpect.EOF], timeout=10)
            child.sendline(cmd)
            child.expect(['$', '#', '>', pexpect.EOF], timeout=10)
            child.sendline('exit')
            child.expect(pexpect.EOF, timeout=5)
            child.close()
            if child.exitstatus == 0 or child.signalstatus is None:
                print("\n✓ SSH key authentication set up successfully!")
                print("You can now SSH to your RPi without a password.")
                print("\nTest the connection:")
                print("  ./rpi_exec.sh 'hostname'")
                sys.exit(0)
            else:
                raise Exception(f"SSH command failed with exit status {child.exitstatus}")
        else:
            raise Exception("Did not get password prompt")
    except ImportError:
        print("Error: Need either sshpass or pexpect installed.")
        print("Install one of them:")
        print("  sudo apt-get install sshpass")
        print("  pip3 install pexpect")
        print("\nOr manually add the key:")
        print(f"  ssh {RPI_USER}@{RPI_HOST}")
        print(f"  mkdir -p ~/.ssh")
        print(f"  echo '{pub_key}' >> ~/.ssh/authorized_keys")
        print(f"  chmod 700 ~/.ssh")
        print(f"  chmod 600 ~/.ssh/authorized_keys")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
else:
    print(f"\n✗ Failed to set up SSH key authentication.")
    print(f"Error: {result.stderr}")
    print("\nManual setup:")
    print(f"  ssh {RPI_USER}@{RPI_HOST}")
    print(f"  mkdir -p ~/.ssh")
    print(f"  echo '{pub_key}' >> ~/.ssh/authorized_keys")
    print(f"  chmod 700 ~/.ssh")
    print(f"  chmod 600 ~/.ssh/authorized_keys")
    sys.exit(1)

