#!/usr/bin/env bash
##
# WP docker entrypoint (project-specific).
#
# @since 1.0.0
#
# You *CAN* edit this file. It can contain project-specific scripting.
# This file is automatically detected by `./.wp-docker.sh` and called like a hook.
##
# ---------------------------------------------------------------------------------------------------------------------
# Guard against mishaps. Must run inside a container only.
# ---------------------------------------------------------------------------------------------------------------------

if [[ ! -f /usr/local/src/.wp-docker.is.sh || "$(whoami)" != 'root' ]]; then
	echo 'No direct access.'; exit 1;
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Project-specific customizations:
# ---------------------------------------------------------------------------------------------------------------------
