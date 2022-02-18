#!/usr/bin/env bash
# shellcheck disable=SC2129,SC2016
##
# WP docker entrypoint.
#
# @since 1.0.0
#
# @note PLEASE DO NOT EDIT THIS FILE!
# This file and the contents of it are updated automatically.
# Instead of editing this file, please edit `./.wp-docker.prj.sh`.
##
# ---------------------------------------------------------------------------------------------------------------------
# Guard against mishaps. Must run inside a container only.
# ---------------------------------------------------------------------------------------------------------------------

if [[ ! -f /usr/local/src/.wp-docker.is.sh || "$(whoami)" != 'root' ]]; then
	echo 'No direct access.'; exit 1;
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Strict mode and shell options.
# ---------------------------------------------------------------------------------------------------------------------

set   -o nounset; set   -o errexit; set   -o errtrace; set   -o pipefail;
shopt -s extglob; shopt -s dotglob; shopt -s globstar; shopt -s nullglob;

# ---------------------------------------------------------------------------------------------------------------------
# Stack trace handler.
# ---------------------------------------------------------------------------------------------------------------------

function stack_trace() {
  local last_command_status_code=$?;
  set +o xtrace; # {@see https://o5p.me/8eGn9c}.
  local exit_status_code="${1:-1}";

  echo '----------------------------------------------------------------------';
  echo 'Error in '"${BASH_SOURCE[1]}"':'"${BASH_LINENO[0]}";
  echo '`'"${BASH_COMMAND}"'` exited with status `'"${last_command_status_code}"'`.';

  if [[ ${#FUNCNAME[@]} -gt 2 ]]; then
    echo 'Stack Trace:';
    for ((_i=1; _i < ${#FUNCNAME[@]}-1; _i++)); do
      echo " ${_i}: ${BASH_SOURCE[${_i}+1]}:${BASH_LINENO[${_i}]} ${FUNCNAME[${_i}]}(...)";
    done;
  fi;
  echo 'Exiting w/ status `'"${exit_status_code}"'`.'; exit "${exit_status_code}";
};
trap stack_trace ERR;

# ---------------------------------------------------------------------------------------------------------------------
# Version compare utility function.
# ---------------------------------------------------------------------------------------------------------------------

function version-compare() {
  local v1="'${1:-}'"; local v2="'${2:-}'"; local op="'${3:-}'";
  if [[ "$(php -r 'echo (int)version_compare('"${v1}"', '"${v2}"', '"${op}"');')" == 1 ]];
  	then return 0; else return 1; fi;
};
# ---------------------------------------------------------------------------------------------------------------------
# Define a few variables.
# ---------------------------------------------------------------------------------------------------------------------

ROOT_HOME_DIR=/root;                                  # `root` user's home directory.
WWW_DATA_HOME_DIR=/var/www;                           # `www-data` user's home directory.
WORDPRESS_DIR=/var/www/html;                          # Apache `DOCUMENT_ROOT` directory.
WORDPRESS_URL=https://"${X_COMPOSE_PROJECT_SLUG}".wp; # Requires DNS mapping, which we do handle.
PROJECT_DIR=/x-host/project;                          # Mounted by Docker; this is the host project directory.

# ---------------------------------------------------------------------------------------------------------------------
# Run parent container's entrypoint before we continue.
# The `apache2-noop` name is important. Noting because it's extremely non-obvious.
# Take a peek at the top of `docker-entrypoint.sh` to see why `apache2` is key; {@see https://o5p.me/j70ja4}.
# ---------------------------------------------------------------------------------------------------------------------

if [[ ! -f /usr/local/bin/apache2-noop ]]; then
	echo "#!/usr/bin/env bash" > /usr/local/bin/apache2-noop;
	chmod +x /usr/local/bin/apache2-noop;
fi;
/usr/local/bin/docker-entrypoint.sh apache2-noop;

# ---------------------------------------------------------------------------------------------------------------------
# Maybe run initial installation/setup.
# The routines below install several things; including WordPress.
# It also installs WordPress plugins, themes, and handles activation.
# ---------------------------------------------------------------------------------------------------------------------

if [[ ! -f /usr/local/etc/x-.wp-docker.sh-install-complete ]]; then
	# -----------------------------------------------------------------------------------------------------------------
	# `www-data` should have write access to its own HOME directory.
	# -----------------------------------------------------------------------------------------------------------------

	chmod 0700                 "${WWW_DATA_HOME_DIR}";
	chown --recursive www-data "${WWW_DATA_HOME_DIR}";

	# -----------------------------------------------------------------------------------------------------------------
	# Adjust WP-CLI configuration.
	# -----------------------------------------------------------------------------------------------------------------

	echo "url: ${WORDPRESS_URL}"                          >> "${ROOT_HOME_DIR}"/.wp-cli/config.yml;
	echo "user: ${X_WORDPRESS_ADMIN_USERNAME}"            >> "${ROOT_HOME_DIR}"/.wp-cli/config.yml;

	cp --preserve=all "${ROOT_HOME_DIR}"/.wp-cli/config.yml  "${WWW_DATA_HOME_DIR}"/.wp-cli/config.yml;
	chown www-data                                           "${WWW_DATA_HOME_DIR}"/.wp-cli/config.yml;

	# -----------------------------------------------------------------------------------------------------------------
	# Install WordPress core.
	# -----------------------------------------------------------------------------------------------------------------

	wp core install --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
		--title="${X_WORDPRESS_SITE_TITLE}" \
		--admin_user="${X_WORDPRESS_ADMIN_USERNAME}" \
		--admin_password="${X_WORDPRESS_ADMIN_PASSWORD}" \
		--admin_email="${X_WORDPRESS_ADMIN_EMAIL}" --skip-email;

	# -----------------------------------------------------------------------------------------------------------------
	# Install `info.php` file for debugging.
	# -----------------------------------------------------------------------------------------------------------------

	echo '<?php phpinfo();' > "${WORDPRESS_DIR}"/info.php;

	# -----------------------------------------------------------------------------------------------------------------
	# Maybe update `.htaccess` file for mulitisite installs.
	# -----------------------------------------------------------------------------------------------------------------

	if [[ "${X_WORDPRESS_MULTISITE_TYPE}" == 'subdomains' ]]; then
		wp core multisite-convert --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
			--title="${X_WORDPRESS_SITE_TITLE}" --subdomains;

		echo 'RewriteEngine On'                                                       > "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]'         >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteBase /'                                                         >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^index\.php$ - [L]'                                        >> "${WORDPRESS_DIR}"/.htaccess;
		echo ''                                                                      >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^wp-admin$ wp-admin/ [R=301,L]'                            >> "${WORDPRESS_DIR}"/.htaccess;
		echo ''                                                                      >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteCond %{REQUEST_FILENAME} -f [OR]'                               >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteCond %{REQUEST_FILENAME} -d'                                    >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^ - [L]'                                                   >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^(wp-(content|admin|includes).*) $1 [L]'                   >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^(.*\.php)$ $1 [L]'                                        >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule . index.php [L]'                                           >> "${WORDPRESS_DIR}"/.htaccess;

	elif [[ -n "${X_WORDPRESS_MULTISITE_TYPE}" ]]; then
		wp core multisite-convert --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
			--title="${X_WORDPRESS_SITE_TITLE}";

		echo 'RewriteEngine On'                                                       > "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]'         >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteBase /'                                                         >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^index\.php$ - [L]'                                        >> "${WORDPRESS_DIR}"/.htaccess;
		echo ''                                                                      >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ $1wp-admin/ [R=301,L]'        >> "${WORDPRESS_DIR}"/.htaccess;
		echo ''                                                                      >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteCond %{REQUEST_FILENAME} -f [OR]'                               >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteCond %{REQUEST_FILENAME} -d'                                    >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^ - [L]'                                                   >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) $2 [L]' >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ $2 [L]'                      >> "${WORDPRESS_DIR}"/.htaccess;
		echo 'RewriteRule . index.php [L]'                                           >> "${WORDPRESS_DIR}"/.htaccess;
	fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Maybe install plugins|themes network-wide.
	# -----------------------------------------------------------------------------------------------------------------

	if [[ -n "${X_WORDPRESS_MULTISITE_TYPE}" ]]; then
		if [[ -n "${X_WORDPRESS_INSTALL_PLUGINS}" ]]; then
			while IFS=',' read -ra _x_wordpress_install_plugins; do
				for _x_wordpress_install_plugin in "${_x_wordpress_install_plugins[@]}"; do
				wp plugin install --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
					"${_x_wordpress_install_plugin}" --activate-network;
				done;
			done <<< "${X_WORDPRESS_INSTALL_PLUGINS}";
		fi;
		if [[ -n "${X_WORDPRESS_INSTALL_THEME}" && -n "${X_WORDPRESS_INSTALLED_THEME_SLUG}" ]]; then
			wp theme install --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_WORDPRESS_INSTALL_THEME}";

			wp theme enable --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_WORDPRESS_INSTALLED_THEME_SLUG}" --network --activate;
		fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Maybe install plugins|themes for standard WordPress.
	# -----------------------------------------------------------------------------------------------------------------
	else
		if [[ -n "${X_WORDPRESS_INSTALL_PLUGINS}" ]]; then
			while IFS=',' read -ra _x_wordpress_install_plugins; do
				for _x_wordpress_install_plugin in "${_x_wordpress_install_plugins[@]}"; do
				wp plugin install --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
					"${_x_wordpress_install_plugin}" --activate;
				done;
			done <<< "${X_WORDPRESS_INSTALL_PLUGINS}";
		fi;
		if [[ -n "${X_WORDPRESS_INSTALL_THEME}" ]]; then
			wp theme install --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_WORDPRESS_INSTALL_THEME}" --activate;
		fi;
	fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Maybe link a project's WordPress plugin|theme directory and activate.
	# -----------------------------------------------------------------------------------------------------------------

	if [[ "${X_COMPOSE_PROJECT_TYPE}" == 'library' && "${X_COMPOSE_PROJECT_LAYOUT}" == 'wp-plugin' && -f /x-host/project/trunk/plugin.php ]]; then
		ln -s /x-host/project/trunk "${WORDPRESS_DIR}"/wp-content/plugins/"${X_COMPOSE_PROJECT_SLUG}";

		if [[ -n "${X_WORDPRESS_MULTISITE_TYPE}" ]]; then
			wp plugin activate --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_COMPOSE_PROJECT_SLUG}" --network;
		else
			wp plugin activate --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_COMPOSE_PROJECT_SLUG}";
		fi;
	elif [[ "${X_COMPOSE_PROJECT_TYPE}" == 'library' && "${X_COMPOSE_PROJECT_LAYOUT}" == 'wp-theme' && -f /x-host/project/trunk/theme.php ]]; then
		ln -s /x-host/project/trunk "${WORDPRESS_DIR}"/wp-content/themes/"${X_COMPOSE_PROJECT_SLUG}";

		if [[ -n "${X_WORDPRESS_MULTISITE_TYPE}" ]]; then
			wp theme enable --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_COMPOSE_PROJECT_SLUG}" --network --activate;
		else
			wp theme enable --allow-root --path="${WORDPRESS_DIR}" --url="${WORDPRESS_URL}" \
				"${X_COMPOSE_PROJECT_SLUG}" --activate;
		fi;
	fi;
	# -----------------------------------------------------------------------------------------------------------------
	# Flag installation complete.
	# -----------------------------------------------------------------------------------------------------------------

	touch /usr/local/etc/x-.wp-docker.sh-install-complete;
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Maybe run project-specific entrypoint hook.
# ---------------------------------------------------------------------------------------------------------------------

if [[ -f "${PROJECT_DIR}"/.wp-docker.prj.sh ]]; then
	"${PROJECT_DIR}"/.wp-docker.prj.sh;
fi;
# ---------------------------------------------------------------------------------------------------------------------
# Start Apache.
# ---------------------------------------------------------------------------------------------------------------------

apache2-foreground;