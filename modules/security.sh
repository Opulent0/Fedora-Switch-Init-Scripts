#!/usr/bin/env bash

# Current SELinux mode: Enforcing / Permissive / Disabled
get_sel_status() {
    getenforce
}

setup_security() {
    log "Checking security baseline..."

    # --- 1. SELinux ---
    local selinux_status
    selinux_status="$(get_sel_status)"

    case "$selinux_status" in
        "Enforcing")
            log "SELinux is Enforcing"
            ;;

        "Permissive")
            # Safe to fix live on a fresh install: no accumulated mislabeled
            # files, so setenforce takes effect immediately.
            log "WARNING: SELinux is in Permissive mode. Setting to Enforcing."
            sudo setenforce 1
            sudo sed -i 's/^SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
            ;;

        "Disabled")
            # Can't be fixed live: needs a config edit, a relabel, and a reboot.
            log "WARNING: SELinux is Disabled. Enabling for next boot."
            sudo sed -i 's/^SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
            sudo touch /.autorelabel
            log "WARNING: Rebooting now to apply SELinux and relabel. Rerun this script after the reboot."
            sudo reboot
            exit 0   # reboot doesn't halt the script instantly, so stop here
            ;;

        *)
            log "WARNING: unexpected SELinux status: $selinux_status"
            ;;
    esac

    # --- 2. firewalld ---
    # is-active (running now) and is-enabled (starts on boot) are separate
    # checks; enable --now fixes both at once.
    if ! systemctl is-active firewalld &>/dev/null || ! systemctl is-enabled firewalld &>/dev/null; then
        log "firewalld is not active/enabled. Enabling now."
        sudo systemctl enable --now firewalld
    else
        log "firewalld is active and enabled"
    fi

    log "Security baseline check complete."
}
