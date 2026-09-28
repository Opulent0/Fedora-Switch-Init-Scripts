#!/usr/bin/env bash

setup_power() {
    log "Configuring power management (TLP)..."

    # power-profiles-daemon and TLP fight over the same kernel settings.
    # Mask the daemon so nothing else can start it either.
    if systemctl cat power-profiles-daemon.service &>/dev/null; then
        sudo systemctl disable --now power-profiles-daemon.service 2>/dev/null || true
        sudo systemctl mask power-profiles-daemon.service
        log "power-profiles-daemon masked"
    fi

    # TLP manages radio device state itself, so mask systemd's rfkill handling
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

    sudo systemctl enable --now tlp.service \
        || log "WARNING: couldn't start tlp (expected inside some VMs)"

    log "Power management setup complete."
}
