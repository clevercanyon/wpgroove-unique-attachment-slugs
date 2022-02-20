#!/usr/bin/env bash
##
# WP docker entrypoint (project-specific).
#
# @since 1.0.0
#
# You *can* edit this file. It can contain project-specific scripting.
# This file is automatically detected by `./dev/.libs/docker/wp/entry.bash` and called like a hook.
##
# ---------------------------------------------------------------------------------------------------------------------
# Source a few dependencies.
# ---------------------------------------------------------------------------------------------------------------------

if [[ -f /wp-docker/host/project/dev/utilities/load.bash ]]; then
	. /wp-docker/host/project/dev/utilities/load.bash;
	. /wp-docker/host/project/dev/utilities/bash/partials/require-root;
	. /wp-docker/host/project/dev/utilities/bash/partials/require-wp-docker;

elif [[ -f /wp-docker/host/project/vendor/clevercanyon/dev/utilities/load.bash ]]; then
	. /wp-docker/host/project/vendor/clevercanyon/dev/utilities/load.bash;
	. /wp-docker/host/project/vendor/clevercanyon/dev/utilities/bash/partials/require-root;
	. /wp-docker/host/project/vendor/clevercanyon/dev/utilities/bash/partials/require-wp-docker;
else
	echo 'Missing required dependencies. Have you run `composer install` yet?'; exit 1;
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Project-specific customizations.
# ---------------------------------------------------------------------------------------------------------------------

	# Your code here.
