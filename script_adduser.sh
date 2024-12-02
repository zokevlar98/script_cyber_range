#!/bin/bash

# Password for all users
PASSWORD="cyberrange"

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

# Give the group sudo privileges without password
if ! grep -q "^%$GROUP_NAME" /etc/sudoers; then
  echo "%$GROUP_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
  echo "Group $GROUP_NAME granted sudo privileges without password."
else
  echo "Group $GROUP_NAME already has sudo privileges."
fi