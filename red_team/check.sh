#!/bin/bash

# List of dependencies to check
dependencies=(
  "build-essential"
  "python3-pip"
  "python3-dev"
  "git"
  "curl"
  "wget"
  "tar"
  "python3-venv"
  "libssl-dev"
  "libffi-dev"
  "openssh-client"
  "openssh-server"
  "openssl"
  "jq"
  "nmap"
  "netcat"
  "nikto"
  "gobuster"
  "recon-ng"
  "hydra"
  "sqlmap"
  "hashcat"
  "john"
  "wireshark"
)

# Function to check if a package is installed
check_package() {
  dpkg -l | grep -qw "$1"
}

# Check each dependency
for package in "${dependencies[@]}"; do
  if check_package "$package"; then
    echo "Package $package is installed."
  else
    echo "Package $package is NOT installed."
  fi
done

# Check if Amass is installed
if command -v amass &> /dev/null; then
  echo "Amass is installed."
else
  echo "Amass is NOT installed."
fi

# Check if Metasploit Framework is installed
if command -v msfconsole &> /dev/null; then
  echo "Metasploit Framework is installed."
else
  echo "Metasploit Framework is NOT installed."
fi

# Check if Empire is installed
if [ -d /opt/Empire ]; then
  echo "Empire is installed."
else
  echo "Empire is NOT installed."
fi

# Check if Social Engineering Toolkit is installed
if [ -d /opt/social-engineer-toolkit ]; then
  echo "Social Engineering Toolkit is installed."
else
  echo "Social Engineering Toolkit is NOT installed."
fi

# Check if Linux Exploit Suggester is installed
if [ -f les.sh ]; then
  echo "Linux Exploit Suggester is installed."
else
  echo "Linux Exploit Suggester is NOT installed."
fi