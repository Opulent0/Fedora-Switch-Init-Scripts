#!/usr/bin/env bash

setup_security() {
    log "Checking security baseline..."

    # --- 1. SELinux ---
    local selinux_status
    selinux_status="$(get_sel_status)"

    case "$selinux_status" in
        "Enforcing")
            # already correct, nothing to do
            ;;

        "Permissive")
            # Safe to fix live on a fresh install: no accumulated
            # mislabeled files to worry about, so setenforce takes
            # effect immediately, no reboot needed.
            log "WARNING: SELinux is in Permissive mode. Setting to Enforcing."
            sudo setenforce 1
            sudo sed -i 's/^SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
            ;;

        "Disabled")
            # Can't fix live: SELinux isn't loaded by the kernel at all.
            # Requires a config edit + relabel + reboot. Script triggers
            # the reboot itself; rerun this script afterward to continue.
            log "WARNING: SELinux is Disabled. Enabling for next boot."
            sudo sed -i 's/^SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
            sudo touch /.autorelabel
            log "WARNING: Rebooting now to apply SELinux changes and relabel. Rerun this script after reboot to continue setup."
            sudo reboot
            exit 0  # reboot doesn't halt execution immediately - stop here so
                    # nothing else runs mid-shutdown
            ;;
    esac

    # --- 2. firewalld ---
    # is-active and is-enabled check two different things (running now
    # vs. starts on boot), so check both; enable --now fixes both at once
    if ! systemctl is-active firewalld &>/dev/null || ! systemctl is-enabled firewalld &>/dev/null; then
        log "firewalld is not active/enabled. Enabling now."
        sudo systemctl enable --now firewalld
    fi

    log "Security baseline check complete."
}

# Get the current SELinux mode (Enforcing/Permissive/Disabled)
get_sel_status() {
    local sel_status
    sel_status="$(getenforce)"
    echo "$sel_status"
}
