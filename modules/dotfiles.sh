#!/usr/bin/env bash

setup_dotfiles() {
    log "Setting up dotfiles..."

    local repo_url="https://github.com/Opulent0/dotfiles.git"
    local dotfiles_dir="$HOME/dotfiles"
    local stow_pkgs=(emacs zsh)

    require_cmd git
    require_cmd stow

    # 1. Clone if missing. GIT_TERMINAL_PROMPT=0 makes a private repo or no
    #    network fail fast instead of hanging on a password prompt.
    if [[ -d "$dotfiles_dir/.git" ]]; then
        log "dotfiles already cloned, skipping clone"
    else
        GIT_TERMINAL_PROMPT=0 git clone "$repo_url" "$dotfiles_dir" || {
            log "ERROR: couldn't clone $repo_url (repo still private? no network?)"
            exit 1
        }
    fi

    # 2. Dry run first, so a conflict stops the script before anything changes
    if ! stow -d "$dotfiles_dir" -t "$HOME" --no-folding -R -n "${stow_pkgs[@]}"; then
        log "ERROR: stow found conflicts (listed above). Move or delete those files, then rerun."
        exit 1
    fi

    # 3. Apply. -R (restow) makes reruns safe.
    stow -d "$dotfiles_dir" -t "$HOME" --no-folding -R "${stow_pkgs[@]}"

    log "dotfiles stowed: ${stow_pkgs[*]}"
}
