#!/bin/bash

# Assign file descriptors to users and passwords files
exec 3< users.txt
exec 4< passwords.txt

# Read user and password
while read -r iuser <&3 && read -r ipasswd <&4 ; do
  # Just print this for debugging
  printf "\tCreating user: %s with password: %s\n" "$iuser" "$ipasswd"
  # Create the user with useradd (you can add whichever option you like)
  sudo useradd -m -s /bin/false "$iuser"
  # Assign the password to the user, passwd must read it from stdin
  echo "$iuser:$ipasswd" | sudo chpasswd
done

# Close file descriptors
exec 3<&-
exec 4<&-