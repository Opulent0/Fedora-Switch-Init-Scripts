#!/usr/bin/env bash

log() {
	# message will be 1
    # print a message with a consistent prefix, e.g. "[setup] message"
	echo "[setup] $1"
}

pkg_install() {
    # take one or more package names
    # for each: check if already installed (rpm -q), skip if so, else dnf install -y
    # this is what makes package installs idempotent
	for var in "$@"
	do
		# Check to make sure the package isn't already installed
		if rpm -q "$var" &>/dev/null; then
			log "$var is already installed"
		else
		# If it is not, install it
			dnf install -y "$var"
		fi
	done
}

require_cmd() {
    # take a command name, exit with an error if `command -v` doesn't find it
    # useful at the top of a module that depends on something being installed first

	return $1 -v
}
