#!/bin/bash

# Set strict error handling
set -euo pipefail

# Variables
LOG_FILE="user_creation.log"
PASSWORD="cyberrange"
GROUP_NAME="IRIC3"

# Function for logging
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Array of usernames
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

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    log "Error: This script must be run as root"
    exit 1
fi

# Create group
log "Creating group $GROUP_NAME..."
groupadd -f "$GROUP_NAME"

# Create users
for USERNAME in "${USERNAMES[@]}"; do
    if ! id "$USERNAME" &>/dev/null; then
        useradd -m -G "$GROUP_NAME" -s /bin/bash "$USERNAME"
        echo "$USERNAME:$PASSWORD" | chpasswd
        log "Created user: $USERNAME"
    else
        log "User $USERNAME already exists"
    fi
done

# Configure sudo access
SUDOERS_ENTRY="%$GROUP_NAME ALL=(ALL) NOPASSWD:ALL"
if ! grep -q "^$SUDOERS_ENTRY" /etc/sudoers; then
    echo "$SUDOERS_ENTRY" | tee -a /etc/sudoers
    log "Added sudo privileges for group $GROUP_NAME"
fi

# Configure SSH
cat > /etc/ssh/sshd_config <<EOL
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOL

# Test SSH configuration
if sshd -t; then
    systemctl restart sshd
    log "SSH configuration updated and service restarted"
else
    log "Error: SSH configuration test failed"
    exit 1
fi

# Configure firewall
if command -v ufw >/dev/null 2>&1; then
    ufw allow 22/tcp
    ufw --force enable
    log "Firewall configured - SSH port opened"
else
    log "Warning: UFW not installed"
fi

# Final status check
if systemctl is-active --quiet sshd; then
    log "SSH service is running"
else
    log "Error: SSH service failed to start"
    exit 1
fi

log "Script completed successfully"