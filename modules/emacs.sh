#!/usr/bin/env bash

setup_emacs() {
    log "Setting up Emacs..."

    # Emacs daemon (Fedora's emacs package ships the unit file)
    systemctl --user enable --now emacs

    # init.el hardcodes ~/.npm-global, so point npm there first
    npm config set prefix "$HOME/.npm-global"

    # typescript goes first, on its own: the language servers below
    # need it to already be present when they install
    npm install -g typescript || { log "ERROR: npm install failed for typescript"; exit 1; }

    # LSP servers (npm)
    local pkg
    for pkg in @vue/language-server typescript-language-server \
               bash-language-server vscode-langservers-extracted pyright; do
        npm install -g "$pkg" || { log "ERROR: npm install failed for $pkg"; exit 1; }
    done

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
