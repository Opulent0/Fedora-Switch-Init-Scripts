#!/usr/bin/env bash

setup_zsh() {
    log "Setting up zsh..."

    require_cmd git
    require_cmd zsh
    require_cmd chsh

    # Where .zshrc sources these from
    local plugin_dir="$HOME/.local/share/zsh-plugins"
    mkdir -p "$plugin_dir"

    # Powerlevel10k (not packaged for Fedora)
    if [[ ! -d "$plugin_dir/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$plugin_dir/powerlevel10k"
        log "powerlevel10k cloned"
    else
        log "powerlevel10k already present, skipping clone"
    fi

    # zsh-autocomplete (not packaged for Fedora)
    if [[ ! -d "$plugin_dir/zsh-autocomplete" ]]; then
        git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git "$plugin_dir/zsh-autocomplete"
        log "zsh-autocomplete cloned"
    else
        log "zsh-autocomplete already present, skipping clone"
    fi

    # Login shell: compare against the passwd entry, not $SHELL
    # ($SHELL is stale until you log out and back in)
    local current_shell zsh_path
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    zsh_path="$(command -v zsh)"
    if [[ "$current_shell" != "$zsh_path" ]]; then
        sudo chsh -s "$zsh_path" "$USER"
        log "login shell set to zsh (takes effect at next login)"
    else
        log "zsh is already the login shell"
    fi

    log "zsh setup complete."
}
