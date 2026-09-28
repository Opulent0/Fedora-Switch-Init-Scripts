#!/usr/bin/env bash

log() {
    printf '[setup] %s\n' "$*"
}

# Install any of the given packages that aren't installed yet,
# in a single dnf transaction.
pkg_install() {
    local missing=()
    local pkg

    for pkg in "$@"; do
        if rpm -q "$pkg" &>/dev/null; then
            log "$pkg is already installed"
        else
            missing+=("$pkg")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        log "Installing: ${missing[*]}"
        sudo dnf install -y "${missing[@]}"
    fi
}

# Stop the whole script if a command a module depends on is missing
require_cmd() {
    if ! command -v "$1" &>/dev/null; then
        log "ERROR: required command '$1' not found"
        exit 1
    fi
}
