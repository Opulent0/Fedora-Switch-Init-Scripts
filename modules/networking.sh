#!/usr/bin/env bash

setup_networking() {
    log "Setting up networking..."

    # 1. Confirm the WireGuard private key is actually present before
    #    doing anything else. A missing secret here should stop the
    #    whole script, same reasoning as require_cmd.
    if [[ -z "$WG_PRIVATE_KEY" ]]; then
        log "ERROR: WG_PRIVATE_KEY is not set. Check files/secrets.sh."
        exit 1
    fi

    # 2. Import the WireGuard connection, only if it doesn't already exist.
    #    Re-importing an existing connection would fight with settings
    #    (autoconnect, the injected key) that get applied afterward.
    if ! nmcli connection show wg0 &>/dev/null; then
        nmcli connection import type wireguard file "$SCRIPT_DIR/files/citadel.conf"
        log "wg0 imported"
    else
        log "wg0 connection already exists, skipping import"
    fi

    # 3. Inject the real private key every time, unconditionally.
    #    This is what makes key rotation actually work on a rerun,
    #    rather than silently leaving the connection on a stale key.
    nmcli connection modify wg0 wireguard.private-key "$WG_PRIVATE_KEY"

    # 4. Autoconnect on boot, per your earlier decision.
    nmcli connection modify wg0 connection.autoconnect yes

    log "Networking setup complete."
}
