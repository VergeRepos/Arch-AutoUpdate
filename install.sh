#!/bin/bash
# -------------------------------------------------------------------
# Arch Auto-Update Installer with Timeshift Safety & Bar Widget
# Author: Verge (Yohan)
# Version: 1.2
# License: MIT (Use, modify, distribute freely. No warranty.)
# -------------------------------------------------------------------
# Features:
# - Timeshift snapshot protection (auto-configured if needed)
# - Gmail notifications with user-friendly prompt
# - Desktop notifications & reboot prompt
# - Toggle commands (autoupdate-on/off)
# - Top-bar widget for HyDE/KaJoo/Waybar
# - Secure file permissions (scripts readable/editable only by owner)
# - Final verification step before completing installation
# -------------------------------------------------------------------

set -e

# -------------------------------
# Color codes
RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RESET='\033[0m'

# -------------------------------
# ASCII Logo
echo -e "${CYAN}"
echo "  __      __      _                 _             "
echo "  \\ \\    / /__ _ (_)___ _ _  __ _  | |__ _ _  _  "
echo "   \\ \\/\\/ / _ \` || / -_) ' \\/ _\` | | / _\` | || |"
echo "    \\_/\\_/\\__,_|/ |\\___|_||_\\__,_| |_\\__,_|\\_, |"
echo "               |__/                        |__/ "
echo -e "${YELLOW}          Auto-Update Installer by Verge (Yohan)${RESET}\n"

# -------------------------------
# Step 1: Install packages
echo -e "${BLUE}Installing required packages...${RESET}"
sudo pacman -S --noconfirm yay msmtp mutt zenity libnotify timeshift jq

# -------------------------------
# Step 2: Create log directory
mkdir -p ~/.local/log
LOGFILE="$HOME/.local/log/aur-auto-update.log"
touch "$LOGFILE"

# -------------------------------
# Step 3: Gmail configuration prompt
MSMTP_CONFIG="$HOME/.msmtprc"
if [[ ! -f "$MSMTP_CONFIG" ]]; then
    echo -e "${YELLOW}Gmail configuration not found. Please enter your credentials.${RESET}"
    read -p "Username (email to send to): " GMAIL
    read -s -p "App Password: " APPPASS
    echo ""
    cat > "$MSMTP_CONFIG" <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        $HOME/.local/log/msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           $GMAIL
user           $GMAIL
password       $APPPASS

account default : gmail
EOF
    chmod 600 "$MSMTP_CONFIG"
    echo -e "${GREEN}Gmail configured successfully!${RESET}"
else
    GMAIL=$(grep '^from' "$MSMTP_CONFIG" | awk '{print $3}')
    echo -e "${GREEN}Gmail configuration found for $GMAIL.${RESET}"
fi

# -------------------------------
# Step 4: Gmail notification script
mkdir -p ~/.local/bin
MAIL_SCRIPT="$HOME/.local/bin/send-update-mail.sh"
cat > "$MAIL_SCRIPT" <<'EOF'
#!/bin/bash
STATUS=$1
LOGFILE="$HOME/.local/log/aur-auto-update.log"
echo -e "Subject: Arch Auto-Update Status: $STATUS\n\n$(tail -n 50 $LOGFILE)" | msmtp $USER
EOF
chmod 711 "$MAIL_SCRIPT"

# -------------------------------
# Step 5: Auto-update script with Timeshift
SERVICE_SCRIPT="$HOME/.local/bin/aur-auto-update.sh"
cat > "$SERVICE_SCRIPT" <<'EOF'
#!/bin/bash
LOGFILE="$HOME/.local/log/aur-auto-update.log"
mkdir -p "$(dirname "$LOGFILE")"

# --- Timeshift auto-configuration ---
if ! timeshift --list 2>/dev/null | grep -q Snapshot; then
    SNAP_LOCATION="/timeshift-snapshots"
    echo "Timeshift not configured. Creating default snapshot location..."
    sudo mkdir -p "$SNAP_LOCATION"
    sudo chown $USER:$USER "$SNAP_LOCATION"
    sudo timeshift --create --comments "Initial Setup" --tags D --snapshot-device "$SNAP_LOCATION" 2>&1 | tee -a "$LOGFILE" || \
        { echo "Failed initial Timeshift snapshot. Auto-update disabled." | tee -a "$LOGFILE"; systemctl --user stop aur-auto-update.timer; systemctl --user disable aur-auto-update.timer; exit 1; }
    notify-send "Timeshift initial snapshot created!"
fi

# --- Pre-update snapshot ---
notify-send "Auto Update: Creating Timeshift snapshot..."
if ! sudo timeshift --create --comments "Pre-auto-update snapshot" --tags D 2>&1 | tee -a "$LOGFILE"; then
    notify-send "Timeshift snapshot failed! Auto-update disabled."
    systemctl --user stop aur-auto-update.timer
    systemctl --user disable aur-auto-update.timer
    $HOME/.local/bin/send-update-mail.sh "Failed: Timeshift snapshot"
    exit 1
fi

# --- Run updates ---
yay -Syu --noconfirm --quiet 2>&1 | tee -a "$LOGFILE"

# --- Notifications ---
notify-send "Auto Update Finished"
$HOME/.local/bin/send-update-mail.sh "Finished"

# --- Reboot prompt ---
if zenity --question --text="Do you want to reboot?"; then
    systemctl reboot
fi
EOF
chmod 711 "$SERVICE_SCRIPT"

# -------------------------------
# Step 6: Systemd service & timer
SERVICE_UNIT="$HOME/.config/systemd/user/aur-auto-update.service"
TIMER_UNIT="$HOME/.config/systemd/user/aur-auto-update.timer"
mkdir -p "$(dirname "$SERVICE_UNIT")"
cat > "$SERVICE_UNIT" <<EOF
[Unit]
Description=Auto update Arch Linux + AUR packages

[Service]
Type=oneshot
ExecStart=$SERVICE_SCRIPT
EOF

cat > "$TIMER_UNIT" <<EOF
[Unit]
Description=Daily auto update for Arch + AUR

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now aur-auto-update.timer

# -------------------------------
# Step 7: Toggle commands
cat > ~/.local/bin/autoupdate-on <<'EOF'
#!/bin/bash
systemctl --user unmask aur-auto-update.timer
systemctl --user enable --now aur-auto-update.timer
notify-send "Auto-update: ON"
EOF

cat > ~/.local/bin/autoupdate-off <<'EOF'
#!/bin/bash
systemctl --user stop aur-auto-update.timer
systemctl --user disable aur-auto-update.timer
systemctl --user mask aur-auto-update.timer
notify-send "Auto-update: OFF"
EOF

chmod 711 ~/.local/bin/autoupdate-on ~/.local/bin/autoupdate-off

# -------------------------------
# Step 8: Bar widget script
HYPR_WIDGET="$HOME/.local/bin/hypr-autoupdate-status.sh"
cat > "$HYPR_WIDGET" <<'EOF'
#!/bin/bash
if systemctl --user is-active --quiet aur-auto-update.timer; then
  echo "AutoUpdate: ON"
else
  echo "AutoUpdate: OFF"
fi
EOF
chmod 711 "$HYPR_WIDGET"

# -------------------------------
# Step 9: Detect bar & add widget
declare -A BARS
BARS=( ["HyDE"]="$HOME/.config/hyde/config"
       ["HyDE2"]="$HOME/.config/hypr/hyde.conf"
       ["Waybar"]="$HOME/.config/waybar/config"
       ["KaJoo"]="$HOME/.config/kajoo/config" )

BAR_FOUND=false
for BAR in "${!BARS[@]}"; do
    CONFIG="${BARS[$BAR]}"
    if [[ -f "$CONFIG" ]]; then
        BAR_FOUND=true
        echo -e "${GREEN}Detected $BAR config at $CONFIG${RESET}"
        if ! grep -q "hypr-autoupdate-status.sh" "$CONFIG"; then
            if [[ "$BAR" == "Waybar" ]]; then
                jq '.modules.left += ["custom/hypr-autoupdate-status"] | .custom."hypr-autoupdate-status"={"exec":"'"$HYPR_WIDGET"'","interval":10}' "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
            else
                cat >> "$CONFIG" <<EOF

[module]
type = custom/script
exec = $HYPR_WIDGET
interval = 10
EOF
            fi
            echo -e "${GREEN}Auto-update widget added to $BAR!${RESET}"
        else
            echo -e "${YELLOW}Widget already exists in $BAR config.${RESET}"
        fi
        break
    fi
done

if ! $BAR_FOUND; then
    echo -e "${YELLOW}No supported bar detected. Installing Waybar by default...${RESET}"
    sudo pacman -S --noconfirm waybar jq
    mkdir -p ~/.config/waybar
    CONFIG="$HOME/.config/waybar/config"
    cat > "$CONFIG" <<EOF
{
  "modules-left": ["custom/hypr-autoupdate-status"],
  "custom": {
    "hypr-autoupdate-status": {
      "exec": "$HYPR_WIDGET",
      "interval": 10
    }
  }
}
EOF
    echo -e "${GREEN}Waybar installed and widget configured!${RESET}"
fi

# -------------------------------
# Step 10: Secure all files
echo -e "${BLUE}Securing scripts, logs, Gmail config, and systemd files...${RESET}"
chmod 711 ~/.local/bin/*
chmod 600 ~/.local/log/*
chmod 600 ~/.msmtprc
chmod 700 ~/.config/systemd/user/aur-auto-update*.service
chmod 700 ~/.config/systemd/user/aur-auto-update*.timer
echo -e "${GREEN}All files secured successfully!${RESET}"

# -------------------------------
# Step 11: Verification
echo -e "${BLUE}Verifying Timeshift and auto-update scripts...${RESET}"

# Test Timeshift snapshot
if ! sudo timeshift --create --comments "Test Snapshot" --tags D --snapshot-device "/timeshift-snapshots" --scripted 2>/dev/null; then
    echo -e "${RED}Timeshift test snapshot failed! Auto-update will be disabled.${RESET}"
    systemctl --user stop aur-auto-update.timer
    systemctl --user disable aur-auto-update.timer
else
    echo -e "${GREEN}Timeshift test snapshot successful.${RESET}"
fi

# Test auto-update script syntax
if ! bash -n "$SERVICE_SCRIPT"; then
    echo -e "${RED}Auto-update script has syntax errors! Please check.${RESET}"
else
    echo -e "${GREEN}Auto-update script syntax looks good.${RESET}"
fi

# Test Gmail notification
TEST_MAIL_SUBJECT="Test Auto-Update Email"
echo -e "Subject: $TEST_MAIL_SUBJECT\n\nThis is a test email from Arch Auto-Update installer." | msmtp $GMAIL 2>/dev/null && \
    echo -e "${GREEN}Test email sent successfully.${RESET}" || \
    echo -e "${YELLOW}Warning: Test email could not be sent. Check your Gmail credentials.${RESET}"

# -------------------------------
# Installation complete
echo -e "${GREEN}Installation complete!${RESET}"
echo "Use 'autoupdate-on' or 'autoupdate-off' to toggle auto-updates."
echo "Your auto-update widget is now added to your bar."
echo "Logs are saved in $LOGFILE"
echo "Timeshift snapshots are required for safe updates."
