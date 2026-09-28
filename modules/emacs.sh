#!/usr/bin/env bash

setup_emacs() {
    log "Setting up Emacs..."

    require_cmd npm
    require_cmd go

    # Needs ~/.emacs.d/init.el from setup_dotfiles
    if [[ ! -r "$HOME/.emacs.d/init.el" ]]; then
        log "ERROR: ~/.emacs.d/init.el not found. setup_dotfiles must run first."
        exit 1
    fi

    # init.el hardcodes ~/.npm-global, so point npm there before any global install
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$HOME/go/bin:$PATH"

    # typescript goes first, on its own, before the language servers
    npm install -g typescript || { log "ERROR: npm install failed for typescript"; exit 1; }

    # LSP servers (npm)
    local pkg
    for pkg in @vue/language-server typescript-language-server \
               bash-language-server vscode-langservers-extracted pyright; do
        npm install -g "$pkg" || { log "ERROR: npm install failed for $pkg"; exit 1; }
    done

    # Go LSP (installs to ~/go/bin)
    go install golang.org/x/tools/gopls@latest

    # JetBrainsMono Nerd Font (init.el sets it as the default face)
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNF"
    if [[ ! -d "$font_dir" ]]; then
        local zip
        zip="$(mktemp --suffix=.zip)"
        mkdir -p "$font_dir"
        curl -fsSL -o "$zip" \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -q "$zip" -d "$font_dir"
        rm -f "$zip"
        fc-cache -f
        log "JetBrainsMono Nerd Font installed"
    else
        log "Nerd Font already present, skipping"
    fi

    # Pre-install Emacs packages so the first launch isn't a long download.
    # Batch mode loads init.el as the user init file. Needs network.
    emacs --batch --eval '(message "init loaded")' \
        || log "WARNING: emacs package pre-install reported errors (check with: emacs --debug-init)"

    # Daemon: enable at login and restart so it reads the stowed init.el
    systemctl --user enable emacs
    systemctl --user restart emacs

    log "Emacs setup complete."
}
