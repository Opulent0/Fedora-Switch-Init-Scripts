#!/usr/bin/env bash

setup_packages() {
    log "Installing packages..."

    local pkg_file="$SCRIPT_DIR/files/package-list.txt"
    local pkgs=()
    local line pkg

    while IFS= read -r line || [[ -n "$line" ]]; do
        # skip blank lines and full-line comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # strip inline comments and surrounding whitespace
        pkg="$(echo "$line" | sed 's/#.*//' | xargs)"
        [[ -z "$pkg" ]] && continue

        pkgs+=("$pkg")
    done < "$pkg_file"

    pkg_install "${pkgs[@]}"

    log "Package installation complete."
}
