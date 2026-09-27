#!/usr/bin/env bash
set -euo pipefail

# Figure out the directory this script lives in, so sourcing works
# regardless of where you run it from. Look up: how do people get
# a script's own directory in bash? (hint involves $BASH_SOURCE)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Source common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Source every file in modules/ so their functions become available.
# Think about how to loop over files in a directory and source each one,
# rather than listing them by name — that way adding a new module file
# later doesn't require editing this loop.
for module in "$SCRIPT_DIR"/modules/*.sh; do
    source "$module"
done

# Now call the actual setup functions, in the order you want them to run.
# This part SHOULD list them explicitly and in order — order matters here
# (e.g. you probably want packages installed before you configure zsh),
# so don't loop this part the way you looped the sourcing above.
log "Starting setup..."

setup_packages       # everything else depends on packages existing
setup_security       # SELinux enforcing, firewalld active — before anything opens ports
setup_networking     # WireGuard, Kerberos — needs packages + a configured firewall
setup_containers     # podman, quadlets, linger — needs packages + firewall rules in place
setup_emacs          # independent of the above, but needs packages (emacs, fonts, LSPs)
setup_zsh            # independent, needs packages (zsh, plugins, theme)

log "Setup complete."
