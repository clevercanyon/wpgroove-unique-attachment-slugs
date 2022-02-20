#!/usr/bin/env bash
##
# WP docker entrypoint.
#
# @since 1.0.0
#
# @note PLEASE DO NOT EDIT THIS FILE!
# This file and the contents of it are updated automatically.
#
# - Instead of editing this file, you can modify `./dev/.libs/docker/wp/entry~prj.bash`.
# - Instead of editing this file, please review source repository {@see https://o5p.me/LevQOD}.
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
# Define a few variables.
# ---------------------------------------------------------------------------------------------------------------------

ROOT_HOME_DIR=/root;                                          # `root` user's home directory.
WWW_DATA_HOME_DIR=/var/www;                                   # `www-data` user's home directory.
WORDPRESS_DIR=/var/www/html;                                  # Apache `DOCUMENT_ROOT` directory.
WORDPRESS_URL=https://"${WP_DOCKER_COMPOSE_PROJECT_SLUG}".wp; # Requires DNS mapping, which we do handle.
PROJECT_DIR=/wp-docker/host/project;                          # Mounted by Docker; this is the host project directory.

# ---------------------------------------------------------------------------------------------------------------------
# Run parent container's entrypoint.
# ---------------------------------------------------------------------------------------------------------------------

/usr/local/bin/docker-entrypoint.sh apache2-noop;

# ---------------------------------------------------------------------------------------------------------------------
# Maybe run initial installation/setup.
# ---------------------------------------------------------------------------------------------------------------------
# The routines below install several things, including WordPress.
# It also installs WordPress plugins, themes, and handles activation.

if [[ ! -f /wp-docker/container/setup-complete ]]; then
	mkdir --parents /wp-docker/container;
	touch /wp-docker/container/setup-complete;

	# -----------------------------------------------------------------------------------------------------------------
	# Adjust WP-CLI configuration.
	# -----------------------------------------------------------------------------------------------------------------
	# This file has already been created by `/wp-docker/image/setup`.
	# The `path:` is in there already. We need to add `url:` and `user:` now.
	{
		echo "url : ${WORDPRESS_URL}";
		echo "user: ${WP_DOCKER_WORDPRESS_ADMIN_USERNAME}";
	} >> "${ROOT_HOME_DIR}"/.wp-cli/config.yml;

	cp --preserve=all "${ROOT_HOME_DIR}"/.wp-cli/config.yml "${WWW_DATA_HOME_DIR}"/.wp-cli/config.yml;
	chown www-data                                          "${WWW_DATA_HOME_DIR}"/.wp-cli/config.yml;

	# -----------------------------------------------------------------------------------------------------------------
	# Install WordPress core.
	# -----------------------------------------------------------------------------------------------------------------

	wp core install --allow-root \
		--title="${WP_DOCKER_WORDPRESS_SITE_TITLE}" \
		--admin_user="${WP_DOCKER_WORDPRESS_ADMIN_USERNAME}" \
		--admin_password="${WP_DOCKER_WORDPRESS_ADMIN_PASSWORD}" \
		--admin_email="${WP_DOCKER_WORDPRESS_ADMIN_EMAIL}" --skip-email;

	# -----------------------------------------------------------------------------------------------------------------
	# Maybe update `.htaccess` file for mulitisite installs.
	# -----------------------------------------------------------------------------------------------------------------

	if [[ "${WP_DOCKER_WORDPRESS_MULTISITE_TYPE}" == 'subdomains' ]]; then
		wp core multisite-convert --allow-root \
			--title="${WP_DOCKER_WORDPRESS_SITE_TITLE}" --subdomains;
		{
			echo 'RewriteEngine On';
			echo 'RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]';
			echo 'RewriteBase /';
			echo 'RewriteRule ^index\.php$ - [L]';
			echo '';
			echo 'RewriteRule ^wp-admin$ wp-admin/ [R=301,L]';
			echo '';
			echo 'RewriteCond %{REQUEST_FILENAME} -f [OR]';
			echo 'RewriteCond %{REQUEST_FILENAME} -d';
			echo 'RewriteRule ^ - [L]';
			echo 'RewriteRule ^(wp-(content|admin|includes).*) $1 [L]';
			echo 'RewriteRule ^(.*\.php)$ $1 [L]';
			echo 'RewriteRule . index.php [L]';
		} > "${WORDPRESS_DIR}"/.htaccess;

	elif [[ -n "${WP_DOCKER_WORDPRESS_MULTISITE_TYPE}" ]]; then
		wp core multisite-convert --allow-root \
			--title="${WP_DOCKER_WORDPRESS_SITE_TITLE}";
		{
			echo 'RewriteEngine On';
			echo 'RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]';
			echo 'RewriteBase /';
			echo 'RewriteRule ^index\.php$ - [L]';
			echo '';
			echo 'RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ $1wp-admin/ [R=301,L]';
			echo '';
			echo 'RewriteCond %{REQUEST_FILENAME} -f [OR]';
			echo 'RewriteCond %{REQUEST_FILENAME} -d';
			echo 'RewriteRule ^ - [L]';
			echo 'RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) $2 [L]';
			echo 'RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ $2 [L]';
			echo 'RewriteRule . index.php [L]';
		} > "${WORDPRESS_DIR}"/.htaccess;
	fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Maybe update to latest version.
	# -----------------------------------------------------------------------------------------------------------------

	wp core update --allow-root;

	if [[ -n "${WP_DOCKER_WORDPRESS_MULTISITE_TYPE}" ]]; then
		wp core update-db --network --allow-root;
	else
		wp core update-db --allow-root;
	fi;
	wp theme  update --all --allow-root;
	wp plugin update --all --allow-root;

	# -----------------------------------------------------------------------------------------------------------------
	# Maybe install plugins|themes network-wide.
	# -----------------------------------------------------------------------------------------------------------------

	if [[ -n "${WP_DOCKER_WORDPRESS_MULTISITE_TYPE}" ]]; then
		if [[ -n "${WP_DOCKER_WORDPRESS_INSTALL_PLUGINS}" ]]; then
			while IFS=',' read -ra _plugins; do
				for _plugin in "${_plugins[@]}"; do
					wp plugin install "${_plugin}" --activate-network --allow-root;
				done;
			done <<< "${WP_DOCKER_WORDPRESS_INSTALL_PLUGINS}";
		fi;
		if [[ -n "${WP_DOCKER_WORDPRESS_INSTALL_THEME}" && -n "${WP_DOCKER_WORDPRESS_INSTALLED_THEME_SLUG}" ]]; then
			wp theme install "${WP_DOCKER_WORDPRESS_INSTALL_THEME}" --allow-root;
			wp theme enable "${WP_DOCKER_WORDPRESS_INSTALLED_THEME_SLUG}" --network --activate --allow-root;
		fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Maybe install plugins|themes for standard WordPress.
	# -----------------------------------------------------------------------------------------------------------------

	else
		if [[ -n "${WP_DOCKER_WORDPRESS_INSTALL_PLUGINS}" ]]; then
			while IFS=',' read -ra _plugins; do
				for _plugin in "${_plugins[@]}"; do
					wp plugin install "${_plugin}" --activate --allow-root;
				done;
			done <<< "${WP_DOCKER_WORDPRESS_INSTALL_PLUGINS}";
		fi;
		if [[ -n "${WP_DOCKER_WORDPRESS_INSTALL_THEME}" ]]; then
			wp theme install "${WP_DOCKER_WORDPRESS_INSTALL_THEME}" --activate --allow-root;
		fi;
	fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Maybe link a project's WordPress plugin|theme directory and activate.
	# -----------------------------------------------------------------------------------------------------------------

	if [[ "${WP_DOCKER_COMPOSE_PROJECT_TYPE}" == 'library' \
			&& "${WP_DOCKER_COMPOSE_PROJECT_LAYOUT}" == 'wp-plugin' \
			&& -f "${PROJECT_DIR}"/trunk/plugin.php ]];
	then
		ln -s "${PROJECT_DIR}"/trunk "${WORDPRESS_DIR}"/wp-content/plugins/"${WP_DOCKER_COMPOSE_PROJECT_SLUG}";

		if [[ -n "${WP_DOCKER_WORDPRESS_MULTISITE_TYPE}" ]]; then
			wp plugin activate "${WP_DOCKER_COMPOSE_PROJECT_SLUG}" --network --allow-root;
		else
			wp plugin activate "${WP_DOCKER_COMPOSE_PROJECT_SLUG}" --allow-root;
		fi;
	elif [[ "${WP_DOCKER_COMPOSE_PROJECT_TYPE}" == 'library' \
			&& "${WP_DOCKER_COMPOSE_PROJECT_LAYOUT}" == 'wp-theme' \
			&& -f "${PROJECT_DIR}"/trunk/theme.php ]];
	then
		ln -s "${PROJECT_DIR}"/trunk "${WORDPRESS_DIR}"/wp-content/themes/"${WP_DOCKER_COMPOSE_PROJECT_SLUG}";

		if [[ -n "${WP_DOCKER_WORDPRESS_MULTISITE_TYPE}" ]]; then
			wp theme enable "${WP_DOCKER_COMPOSE_PROJECT_SLUG}" --network --activate --allow-root;
		else
			wp theme enable "${WP_DOCKER_COMPOSE_PROJECT_SLUG}" --activate --allow-root;
		fi;
	fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Install `info.php` file for debugging.
	# -----------------------------------------------------------------------------------------------------------------

	echo '<?php phpinfo();' > "${WORDPRESS_DIR}"/info.php;

	# -----------------------------------------------------------------------------------------------------------------
	# Update WordPress directory permissions.
	# -----------------------------------------------------------------------------------------------------------------

	chown --recursive www-data "${WORDPRESS_DIR}";
	find "${WORDPRESS_DIR}" -type d -exec chmod 0755 {} \;; # Includes the directory itself, too.
	find "${WORDPRESS_DIR}" -type f -exec chmod 0644 {} \;; # All files, in this case.
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Maybe run project-specific entrypoint hook.
# ---------------------------------------------------------------------------------------------------------------------

if [[ -x "${PROJECT_DIR}"/dev/.libs/docker/wp/entry~prj.bash ]]; then
	"${PROJECT_DIR}"/dev/.libs/docker/wp/entry~prj.bash;
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Start Apache.
# ---------------------------------------------------------------------------------------------------------------------

apache2-foreground;
