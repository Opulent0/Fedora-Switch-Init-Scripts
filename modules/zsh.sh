#!/usr/bin/env bash

setup_zsh() {
    log "Setting up zsh..."

    local plugin_dir="$HOME/.local/share/zsh-plugins"
    mkdir -p "$plugin_dir"

    # Powerlevel10k
    if [[ ! -d "$plugin_dir/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$plugin_dir/powerlevel10k"
        log "powerlevel10k cloned"
    else
        log "powerlevel10k already present, skipping clone"
    fi

    # zsh-autocomplete
    if [[ ! -d "$plugin_dir/zsh-autocomplete" ]]; then
        git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git "$plugin_dir/zsh-autocomplete"
        log "zsh-autocomplete cloned"
    else
        log "zsh-autocomplete already present, skipping clone"
    fi

    # Set zsh as the login shell, only if it isn't already
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        sudo chsh -s "$(which zsh)" "$USER"
        log "login shell set to zsh (takes effect next login)"
    else
        log "zsh is already the login shell"
    fi

    log "zsh setup complete."
}
