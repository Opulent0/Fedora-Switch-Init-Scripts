#!/usr/bin/env bash

setup_security() {
    log "Checking security baseline..."

    # 1. SELinux
    # Get the current mode. What command returns just the mode name
    # (Enforcing/Permissive/Disabled), the one we used back when we
    # first talked about SELinux?
    #
    # If it's not "Enforcing", what should the script do? Think about
    # the tradeoff here: this is a security baseline check, and you
    # already decided earlier that a missing hard dependency should
    # exit the whole script (that's why require_cmd uses exit, not
    # return). Does "SELinux isn't enforcing" deserve the same
    # treatment, or something softer, like a loud log warning that
    # lets the rest of setup continue? There's a real argument for
    # either — decide and be able to say why.

	selinux_status="$(get_sel_status)"

	case "$selinux_status" in
		"Enforcing")
			:
			;;

		"Permissive") # Set the SELinux to actually enforce
			log "WARNING: SELinux is in Permissive mode. Setting to Enforcing."
			sudo setenforce 1
			sudo sed -i 's/^SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
			;;
	   
		"Disabled")
			log "WARNING: SELinux is Disabled. Enabling for next boot."
			sudo sed -i 's/^SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
			sudo touch /.autorelabel
			log "WARNING: Rebooting now to apply SELinux changes and relabel. Rerun this script after reboot to continue setup."
			sudo reboot
			;;
	esac

    # 2. firewalld
    # Two separate things to check, and they're not the same thing:
    #   - is it enabled (will it start on boot)?
    #   - is it active (is it running right now)?
    # `systemctl` has single-purpose subcommands for checking each of
    # these that return a useful exit code, rather than you grepping
    # `systemctl status` output. What are they?
    #
    # If it's not enabled/active, you have a clear, safe fix available:
    # `sudo systemctl enable --now firewalld`. Unlike SELinux mode
    # (which arguably shouldn't be silently flipped by a script),
    # turning firewalld on is unambiguously the right move if it's off.

    # --- 2. firewalld ---
    if ! systemctl is-active firewalld &>/dev/null || ! systemctl is-enabled firewalld &>/dev/null; then
        log "firewalld is not active/enabled. Enabling now."
        sudo systemctl enable --now firewalld
    fi
	
    log "Security baseline check complete."
}

# Get the status of selinux
get_sel_status() {
    local sel_status
    sel_status="$(getenforce)"
    echo "$sel_status"
}
