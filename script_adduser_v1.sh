#!/bin/bash

# Variables
USERNAMES=(
  "AKARID" "ALAOUI_KASMI" "AMSAADI" "AQESRI" "BENNANI"
  "BOUCHTI" "BOULAMTAT" "CHAHBY" "CHEBLAOUI" "EL_ALAOUI"
  "EL_FATHI" "EL_HABCHI" "EL_HIANI" "EL_ABBOUDY" "EL_WADOUDI"
  "ERAOUI" "EZZINE" "EZZOUITINA" "FARKH" "GHARNATEI"
  "GOURRAM" "HBILATE" "JAIMOUH" "JDID" "JELAIDI"
  "KADIRI" "KADOURI" "KAMILI" "LAGRAINI" "LEGNAFDI"
  "MAJIDI" "MALIKI" "MEROUANE" "MOUINE" "MZIGUIR"
  "NAJEM" "OUNAIM" "PEZONGO" "QOURI" "RACHDA"
  "SADANI" "SARSAR" "SAYAH" "TAHIRI_ALAOUI" "TALIBI"
  "TARIK" "TEMRAOUI" "TOUBI" "WADDAY" "WATIK"
  "ZAAKOUR" "ZAARAOUI"
)

PASSWORD="cyberrange"
GROUP_NAME="IRIC3"

# Create group if not exists
if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
  sudo groupadd "$GROUP_NAME"
  echo "Group $GROUP_NAME created." >> output.txt
else
  echo "Group $GROUP_NAME already exists." >> output.txt
fi

# Create users and add them to the group
for USERNAME in "${USERNAMES[@]}"; do
  if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists." >> output.txt
  else
    sudo useradd -m -G "$GROUP_NAME" -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd 
    echo "User $USERNAME created and added to group $GROUP_NAME with password $PASSWORD." >> output.txt
  fi
done

# Grant sudo privileges to the group without password
if ! grep -q "^%$GROUP_NAME" /etc/sudoers; then
  echo "%$GROUP_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers >> "output.txt"
  echo "Group $GROUP_NAME granted sudo privileges without password." >> "output.txt"
else
  echo "Group $GROUP_NAME already has sudo privileges." >> "output.txt"
fi

# Restart SSH service
echo "Restarting SSH service..." >> "output.txt"
sudo systemctl restart sshd >> "output.txt"
sudo systemctl status sshd >> "output.txt"

# # Open SSH port in firewall
# echo "Configuring firewall..."
# sudo ufw allow 22
sudo ufw reload

# Restore default SSH configuration if needed
sudo cat > /etc/ssh/sshd_config <<EOL
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

sudo cat /etc/ssh/sshd_config >> output.txt

  sudo sshd -t
  if [ $? -eq 0 ]; then
    sudo systemctl restart sshd
    echo "Default SSH configuration restored and service restarted."
  else
    echo "Error in SSH configuration syntax. Please review."
  fi

# Open SSH port in firewall
echo "Configuring firewall..."
sudo ufw allow 22
sudo ufw reload
sudo systemctl status sshd >> "output.txt"
echo "Script execution completed."
