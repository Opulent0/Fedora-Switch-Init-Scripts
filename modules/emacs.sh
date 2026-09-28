#!/usr/bin/env bash

setup_emacs() {
    log "Setting up Emacs..."

    # Emacs daemon (Fedora's emacs package ships the unit file)
    systemctl --user enable --now emacs

    # init.el hardcodes ~/.npm-global, so point npm there before any global install
    npm config set prefix "$HOME/.npm-global"

    # LSP servers (npm). Safe to rerun, npm just reinstalls or updates.
    npm install -g \
        typescript \
        @vue/language-server \
        typescript-language-server \
        bash-language-server \
        vscode-langservers-extracted \
        pyright

    # Go LSP (installs to ~/go/bin, which .zshenv puts on PATH)
    go install golang.org/x/tools/gopls@latest

    # JetBrainsMono Nerd Font (init.el sets it as the default face)
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNF"
    if [[ ! -d "$font_dir" ]]; then
        mkdir -p "$font_dir"
        curl -fsSL -o /tmp/JetBrainsMono.zip \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -q /tmp/JetBrainsMono.zip -d "$font_dir"
        rm /tmp/JetBrainsMono.zip
        fc-cache -f
        log "JetBrainsMono Nerd Font installed"
    else
        log "Nerd Font already present, skipping"
    fi

    log "Emacs setup complete."
}
