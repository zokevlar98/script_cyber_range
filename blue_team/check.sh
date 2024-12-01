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
  "ufw"
  "auditd"
  "netdata"
  "ntopng"
  "tcpdump"
  "wireshark"
  "snort"
  "sleuthkit"
  "autopsy"
  "apparmor"
  "fail2ban"
  "lynis"
  "nmap"
  "iptables"
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

# Check if capture directory exists
if [ -d /opt/capture ]; then
  echo "Capture directory exists."
else
  echo "Capture directory does NOT exist."
fi

# Check if traffic-capture service is installed
if systemctl list-units --full -all | grep -q "traffic-capture.service"; then
  echo "Traffic-capture service is installed."
else
  echo "Traffic-capture service is NOT installed."
fi

# Check if log rotation for captures is configured
if [ -f /etc/logrotate.d/packet-capture ]; then
  echo "Log rotation for captures is configured."
else
  echo "Log rotation for captures is NOT configured."
fi

# Check if analysis script exists
if [ -f /opt/capture/analyze_traffic.py ]; then
  echo "Analysis script exists."
else
  echo "Analysis script does NOT exist."
fi
