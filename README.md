# SSH Agent for Raspberry Pi 5

This project provides tools to easily execute commands on your Raspberry Pi 5 over SSH from your laptop, enabling automated project implementation and error handling.

## Prerequisites

- Raspberry Pi 5 connected to the same WiFi network as your laptop
- SSH enabled on your Raspberry Pi
- Git installed on your laptop
- Basic terminal/command line knowledge

## Complete Setup Guide

### Step 1: Enable SSH on Raspberry Pi

**📍 Run on: Raspberry Pi**

If SSH is not already enabled, enable it:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

Verify SSH is running:
```bash
sudo systemctl status ssh
```

### Step 2: Find Your Raspberry Pi's IP Address

**📍 Run on: Raspberry Pi**

Get the IP address:
```bash
hostname -I
```

**Note:** Write down this IP address (e.g., `192.168.1.8`). You'll need it in the next step.

**Alternative - Find IP from Laptop:**

**📍 Run on: Laptop**

If you can't access the RPi directly, scan your network:
```bash
nmap -sn 192.168.1.0/24 | grep -B 2 "Raspberry Pi"
```

Or check your router's admin panel for connected devices.

### Step 3: Clone or Navigate to This Repository

**📍 Run on: Laptop**

If you haven't already, navigate to the project directory:
```bash
cd /home/anand/personal/ssh-agent-rpi
```

Or if cloning from GitHub:
```bash
git clone git@github.com:anand2532/ssh-agent-rpi.git
cd ssh-agent-rpi
```

### Step 4: Configure SSH Connection Settings

**📍 Run on: Laptop**

Edit the configuration file:
```bash
nano config/rpi_config.sh
```

Or use your preferred editor. Update these values:

- **`RPI_HOST`**: Set to your RPi's IP address (e.g., `"192.168.1.8"`)
- **`RPI_USER`**: Set to your RPi username (usually `"pi"` or your username)
- **`RPI_PORT`**: Usually `"22"` (default SSH port)

Example:
```bash
export RPI_HOST="192.168.1.8"
export RPI_USER="pi"
export RPI_PORT="22"
```

Save and close the file.

### Step 5: Set Up SSH Key Authentication (Passwordless Access)

This step enables passwordless SSH access so you (and the agent) can execute commands without entering a password each time.

#### Option A: Automated Setup (Recommended if you can enter password)

**📍 Run on: Laptop**

```bash
./setup_ssh_keys.sh
```

**What this script does:**
- Checks if you have an SSH key, generates one if needed
- Copies your public SSH key to the RPi
- You'll be prompted for your RPi password (this is the last time)

**If successful:** You'll see "✓ SSH key authentication set up successfully!"

#### Option B: Manual Setup (If automated setup fails)

**📍 Step 5B.1: Get Your Public SSH Key**

**📍 Run on: Laptop**

Display your public key:
```bash
./show_public_key.sh
```

**What this script does:**
- Shows your SSH public key
- Provides instructions for manual setup

Copy the entire public key that's displayed (starts with `ssh-rsa` or `ssh-ed25519`).

**📍 Step 5B.2: Add Public Key to Raspberry Pi**

**📍 Run on: Raspberry Pi**

SSH into your RPi (you'll need to enter password):
```bash
ssh pi@192.168.1.8
```

Then run these commands on the RPi:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Now add your public key (replace `YOUR_PUBLIC_KEY_HERE` with the actual key from step 5B.1):
```bash
echo 'YOUR_PUBLIC_KEY_HERE' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Exit the SSH session:
```bash
exit
```

### Step 6: Test the Connection

**📍 Run on: Laptop**

Test passwordless SSH access:
```bash
./rpi_exec.sh "hostname"
```

**What this script does:**
- Executes the command `hostname` on your RPi via SSH
- Should return your RPi's hostname without asking for a password

**Expected output:** Your RPi's hostname (e.g., `raspberrypi`)

If you see the hostname, **setup is complete!** ✅

If you get a password prompt or error, check:
- RPi is connected to the network
- IP address in `config/rpi_config.sh` is correct
- Username in `config/rpi_config.sh` is correct
- SSH key was properly added to RPi (Step 5)

## Usage

### Execute Commands on Raspberry Pi

**📍 Run on: Laptop**

Use the `rpi_exec.sh` script to run any command on your RPi:

```bash
./rpi_exec.sh "your command here"
```

**What `rpi_exec.sh` does:**
- Loads configuration from `config/rpi_config.sh`
- Connects to your RPi via SSH
- Executes the command you provide
- Returns the output

### Examples

**📍 Run on: Laptop**

List files on RPi:
```bash
./rpi_exec.sh "ls -la"
```

Check Python version on RPi:
```bash
./rpi_exec.sh "python3 --version"
```

Update packages on RPi:
```bash
./rpi_exec.sh "sudo apt update"
```

Check RPi system info:
```bash
./rpi_exec.sh "uname -a"
```

Check disk space on RPi:
```bash
./rpi_exec.sh "df -h"
```

Run a Python script on RPi:
```bash
./rpi_exec.sh "python3 /path/to/script.py"
```

## Project Files Explained

### `config/rpi_config.sh`
- **Purpose:** Stores your RPi connection settings
- **Contains:** IP address, username, SSH port, SSH options
- **When to edit:** When your RPi IP changes or you need to change username
- **Location:** Run from laptop, edits this file on laptop

### `rpi_exec.sh`
- **Purpose:** Execute commands on your RPi via SSH
- **Usage:** `./rpi_exec.sh "command"`
- **Location:** Run from laptop
- **What it does:** Connects to RPi and runs the specified command

### `setup_ssh_keys.sh`
- **Purpose:** Automatically set up passwordless SSH authentication
- **Usage:** `./setup_ssh_keys.sh`
- **Location:** Run from laptop
- **What it does:** Generates SSH key if needed, copies it to RPi
- **When to use:** First-time setup or if SSH keys are lost

### `show_public_key.sh`
- **Purpose:** Display your SSH public key for manual setup
- **Usage:** `./show_public_key.sh`
- **Location:** Run from laptop
- **What it does:** Shows your public key and manual setup instructions
- **When to use:** If automated setup fails, use this to get your key

## Troubleshooting

### Connection Refused
- **Check:** RPi is powered on and connected to WiFi
- **Check:** SSH is enabled on RPi (`sudo systemctl status ssh`)
- **Check:** IP address in `config/rpi_config.sh` is correct

### Permission Denied
- **Check:** Username in `config/rpi_config.sh` is correct
- **Check:** SSH key is properly set up (re-run Step 5)
- **Check:** Password authentication might be disabled on RPi

### Host Key Verification Failed
- **Solution:** Remove old host key: `ssh-keygen -R 192.168.1.8`
- **Then:** Re-run setup or manually add host key

### Command Not Found
- **Check:** You're running scripts from the project directory
- **Check:** Scripts are executable: `chmod +x *.sh`

## How the Agent Uses This

Once setup is complete, the AI agent can:
- Execute commands on your RPi using `./rpi_exec.sh`
- Implement projects directly on the RPi
- Fix errors automatically
- Install packages, configure services, and manage files on the RPi

All commands are executed from your laptop, but run on the RPi remotely.

## Security Notes

- SSH keys provide secure, passwordless access
- Keep your private key (`~/.ssh/id_rsa`) secure and never share it
- The public key is safe to share (it's already on your RPi)
- Consider using a non-default SSH port for additional security
- Regularly update your RPi: `./rpi_exec.sh "sudo apt update && sudo apt upgrade"`
