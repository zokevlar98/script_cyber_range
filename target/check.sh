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
  "apache2"
  "php7.4"
  "libapache2-mod-php7.4"
  "vsftpd"
  "samba"
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
