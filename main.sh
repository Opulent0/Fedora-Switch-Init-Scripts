#!/usr/bin/env bash
set -euo pipefail

# Directory this script lives in, so sourcing works from anywhere
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR/lib/common.sh"

# Run as your normal user. Only the commands that need root call sudo.
if [[ $EUID -eq 0 ]]; then
    log "ERROR: run this as your normal user, not root."
    exit 1
fi

# Secrets are placed by hand before the run (see files/secrets.sh.example)
if [[ ! -r "$SCRIPT_DIR/files/secrets.sh" ]]; then
    log "ERROR: files/secrets.sh not found. Copy files/secrets.sh.example to files/secrets.sh and fill it in."
    exit 1
fi
chmod 600 "$SCRIPT_DIR/files/secrets.sh"
source "$SCRIPT_DIR/files/secrets.sh"

# Load every module. Each one only defines a function, nothing runs yet.
for module in "$SCRIPT_DIR"/modules/*.sh; do
    source "$module"
done

log "Starting setup..."

# Ask for the sudo password once, up front
sudo -v || { log "ERROR: sudo is required."; exit 1; }

# Order matters:
setup_packages       # everything else needs packages
setup_dotfiles       # needs git + stow; emacs and zsh steps need the configs in place
setup_security       # SELinux and firewalld confirmed before anything opens ports
setup_power          # TLP (needs the package, conflicts with power-profiles-daemon)
setup_networking     # WireGuard (needs secrets.sh and the firewall baseline)
setup_emacs          # needs node, go, and the stowed init.el
setup_zsh            # needs git and the stowed zsh config

log "Setup complete. Log out and back in so the new login shell and PATH apply."
