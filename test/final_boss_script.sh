#!/bin/bash

# Variables
USERNAMES=(
  "user1" "user2" "user3" "user4" "user5"
  "user6" "user7" "user8" "user9" "user10"
  "user11" "user12" "user13" "user14" "user15"
  "user16" "user17" "user18" "user19" "user20"
  "user21" "user22" "user23" "user24" "user25"
  "user26" "user27" "user28" "user29" "user30"
  "user31" "user32" "user33" "user34" "user35"
  "user36" "user37" "user38" "user39" "user40"
  "user41" "user42" "user43" "user44" "user45"
  "user46" "user47" "user48" "user49" "user50"
)
PASSWORD="cyberrange"
GROUP_NAME="IRIC3"

# Create group if not exists
if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
  groupadd "$GROUP_NAME"
  echo "Group $GROUP_NAME created."
else
  echo "Group $GROUP_NAME already exists."
fi

# Create users and add them to the group
for USERNAME in "${USERNAMES[@]}"; do
  if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
  else
    useradd -m -G "$GROUP_NAME" -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "User $USERNAME created and added to group $GROUP_NAME with password $PASSWORD."
  fi
done

# # Configure SSH server
# echo "Configuring SSH server..."
# sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
# sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Grant sudo privileges to the group without password
if ! grep -q "^%$GROUP_NAME" /etc/sudoers; then
  echo "%$GROUP_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
  echo "Group $GROUP_NAME granted sudo privileges without password."
else
  echo "Group $GROUP_NAME already has sudo privileges."
fi

# Restart SSH service
echo "Restarting SSH service..."
sudo systemctl restart sshd

# Open SSH port in firewall
echo "Configuring firewall..."
sudo ufw allow 22
sudo ufw reload

# Restore default SSH configuration if needed
read -p "Do you want to restore the default SSH configuration? (y/n): " RESTORE_CONFIG
if [[ "$RESTORE_CONFIG" == "y" || "$RESTORE_CONFIG" == "Y" ]]; then
  echo "Restoring default SSH configuration..."
  cat > /etc/ssh/sshd_config <<EOL
# Default SSH configuration
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::
PermitRootLogin prohibit-password
PubkeyAuthentication yes
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOL
  sudo sshd -t
  if [ $? -eq 0 ]; then
    sudo systemctl restart sshd
    echo "Default SSH configuration restored and service restarted."
  else
    echo "Error in SSH configuration syntax. Please review."
  fi
fi

sudo systemctl restart sshd

# Open SSH port in firewall
echo "Configuring firewall..."
sudo ufw allow 22
sudo ufw reload

echo "Script execution completed."
