# SSH Agent for Raspberry Pi 5

This project provides tools to easily execute commands on your Raspberry Pi 5 over SSH.

## Setup Instructions

### 1. Find your Raspberry Pi's IP address

On your RPi, run:
```bash
hostname -I
```

Or on your laptop, scan the network:
```bash
nmap -sn 192.168.1.0/24 | grep -B 2 "Raspberry Pi"
```

### 2. Configure SSH access

Edit `config/rpi_config.sh` and set:
- `RPI_HOST`: Your RPi's IP address or hostname
- `RPI_USER`: Your RPi username (usually `pi` or your username)

### 3. Set up SSH key authentication (recommended)

Run the setup script:
```bash
./setup_ssh_keys.sh
```

This will:
- Generate an SSH key if you don't have one
- Copy your public key to the RPi
- Enable passwordless SSH access

### 4. Test the connection

```bash
./rpi_exec.sh "hostname"
```

## Usage

Execute commands on the RPi:
```bash
./rpi_exec.sh "your command here"
```

Example:
```bash
./rpi_exec.sh "ls -la"
./rpi_exec.sh "python3 --version"
./rpi_exec.sh "sudo apt update"
```

## Files

- `config/rpi_config.sh` - RPi connection configuration
- `rpi_exec.sh` - Script to execute commands on RPi
- `setup_ssh_keys.sh` - Script to set up SSH key authentication

