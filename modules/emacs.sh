#!/usr/bin/env bash

setup_emacs() {
    log "Setting up Emacs..."

    # Enable and start the Emacs daemon as a systemd user service.
    # Fedora's emacs package already ships the unit file.
    systemctl --user enable --now emacs

    # LSP: vue-language-server (Volar), handles both Vue and TypeScript
    # per this config's eglot setup.
    npm install -g typescript
    npm install -g @vue/language-server

    log "Emacs setup complete."
}
