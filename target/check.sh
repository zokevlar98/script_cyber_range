#!/bin/bash

# Disable automatic updates
echo "Disabling automatic updates..."
sudo systemctl disable apt-daily.service apt-daily-upgrade.service

# Turn off UFW (firewall)
echo "Turning off UFW (firewall)..."
sudo ufw disable

# Verify installation of all tools
echo "Verifying installed tools..."
dpkg -l | grep -E 'apache2|mysql-server|vsftpd|samba'

# Check open ports and echo results
echo "Checking open ports on the system..."
open_ports=$(netstat -tuln | grep LISTEN)
if [ -z "$open_ports" ]; then
    echo "No open ports found."
else
    echo "Open ports on the system:"
    echo "$open_ports"
fi

# Restart Apache (if needed)
echo "Restarting Apache..."
sudo systemctl restart apache2

# Restart SSH (if needed)
echo "Restarting SSH..."
sudo systemctl restart ssh
