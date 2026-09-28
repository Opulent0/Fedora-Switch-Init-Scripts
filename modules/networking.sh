#!/usr/bin/env bash

setup_networking() {
    log "Setting up networking..."

    local conf_src="$SCRIPT_DIR/files/citadel.conf"

    # 1. Preconditions: fail early with a clear message
    if [[ ! -r "$conf_src" ]]; then
        log "ERROR: $conf_src not found."
        exit 1
    fi

    if [[ -z "${WG_PRIVATE_KEY:-}" ]]; then
        log "ERROR: WG_PRIVATE_KEY is not set. Check files/secrets.sh."
        exit 1
    fi

    # A WireGuard key is 32 bytes of base64: 44 characters ending in "="
    if [[ ${#WG_PRIVATE_KEY} -ne 44 || "$WG_PRIVATE_KEY" != *= ]]; then
        log "ERROR: WG_PRIVATE_KEY is malformed (expected 44 chars ending in =). Check for stray spaces or quotes."
        exit 1
    fi

    # 2. Import the connection only if it doesn't exist yet.
    #    nmcli names the connection after the file, so the temp file must be
    #    called wg0.conf. nmcli also validates PrivateKey, so a throwaway
    #    valid key goes in and gets replaced in step 3.
    if ! sudo nmcli connection show wg0 &>/dev/null; then
        local tmpdir
        tmpdir="$(mktemp -d)"
        chmod 700 "$tmpdir"
        sed "s|^PrivateKey = .*|PrivateKey = $(wg genkey)|" "$conf_src" > "$tmpdir/wg0.conf"
        chmod 600 "$tmpdir/wg0.conf"
        sudo nmcli connection import type wireguard file "$tmpdir/wg0.conf"
        rm -rf "$tmpdir"
        log "wg0 imported"
    else
        log "wg0 connection already exists, skipping import"
    fi

    # 3. Inject the real key every run (this is what makes rotation work)
    sudo nmcli connection modify wg0 wireguard.private-key "$WG_PRIVATE_KEY"

    # 4. Autoconnect on boot
    sudo nmcli connection modify wg0 connection.autoconnect yes

    # 5. Bring it up now; don't abort the whole script if the network is down
    sudo nmcli connection up wg0 || log "WARNING: couldn't bring wg0 up (no network yet?). It will autoconnect later."

    log "Networking setup complete."
}
