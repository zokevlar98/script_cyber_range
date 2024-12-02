#!/bin/bash

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

# Password for all users
PASSWORD="cyberrange"
GROUP_NAME="IRIC3"

# Create the group if it doesn't exist
if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
  groupadd "$GROUP_NAME"
  echo "Group $GROUP_NAME created."
else
  echo "Group $GROUP_NAME already exists."
fi

# Create users and assign them to the group
for USERNAME in "${USERNAMES[@]}"; do
  # Check if the user already exists
  if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
  else
    # Create the user with the specified password and add to the group
    useradd -m -G "$GROUP_NAME" -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "User $USERNAME created and added to group $GROUP_NAME with password $PASSWORD."
  fi
done

sudo sed -i 's/^#PasswordAuthentication ./PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin ./PermitRootLogin no/' /etc/ssh/sshd_config

# Give the group sudo privileges without password
if ! grep -q "^%$GROUP_NAME" /etc/sudoers; then
  echo "%$GROUP_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
  echo "Group $GROUP_NAME granted sudo privileges without password."
else
  echo "Group $GROUP_NAME already has sudo privileges."
fi

systemctl restart sshd