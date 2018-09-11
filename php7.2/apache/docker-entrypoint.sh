#!/bin/bash

echo >&2 "Waiting MySQL to be up and running..."
wait-for-it.sh -t 0 mysql:3306
echo >&2 "MySQL database is now ready to handle connection."

# Delete wp-config
if [ -f ${WP_ROOT}/wp-config.php ]; then
	echo >&2 "wp-config.php was detected. Deleting..."
	rm -f ${WP_ROOT}/wp-config.php
fi

# Then initialize a local wp-config if not exists
if [ -f ${WP_ROOT}/wp-config.local.php ]; then
	echo >&2 "wp-config.local.php was detected. Skipping downloading Wordpress files..."
else
	echo >&2 "Downloading Wordpress files..."
	wp core download --path=${WP_ROOT} --allow-root --locale=ja --version=${WP_VERSION}
	echo >&2 "Setting up wp-config.php..."
	wp core config --path=${WP_ROOT} --allow-root \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=root \
		--dbpass=${MYSQL_ROOT_PASSWORD} \
		--dbhost=mysql \
		--dbprefix=${WP_DB_PREFIX} \
		--skip-salts \
		--skip-check \
		--extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', true );
PHP
	mv ${WP_ROOT}/wp-config.php ${WP_ROOT}/wp-config.local.php
fi

# Make a symlink to wp-config
(cd ${WP_ROOT} && ln -s wp-config.local.php wp-config.php)

if $(wp core is-installed --path=${WP_ROOT} --allow-root); then
	echo >&2 "Wordpress seems to be installed."
else
	echo >&2 "Installing Wordpress..."
	# Install core
	wp core install --path=${WP_ROOT} --allow-root \
		--url=${WP_URL} \
		--title=wp \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--skip-email
fi

# Install and activate plugins

echo >&2 "Setting up themes and plugins..."
# Delete plugins
if $(wp plugin is-installed hello --path=${WP_ROOT} --allow-root); then
	wp plugin delete hello --path=${WP_ROOT} --allow-root
fi

if $(wp plugin is-installed akismet --path=${WP_ROOT} --allow-root); then
	wp plugin delete akismet --path=${WP_ROOT} --allow-root
fi


# Activate plugin
if $(wp plugin is-installed wp-multibyte-patch --path=${WP_ROOT} --allow-root); then
	wp plugin activate wp-multibyte-patch --path=${WP_ROOT} --allow-root
fi

# Install extra plugins specified by $WP_INSTALL_PLUGINS
if [[ -z "${WP_INSTALL_PLUGINS}" ]]; then
	echo >&2 "env var \$WP_INSTALL_PLUGINS is empty - skipping installing extra plugins";
else
	for TEMP_WP_PLUGIN in $WP_INSTALL_PLUGINS; do
		echo >&2 "Installing extra plugin ${TEMP_WP_PLUGIN}..."
		if ! $(wp plugin is-installed ${TEMP_WP_PLUGIN} --path=${WP_ROOT} --allow-root); then
			wp plugin install ${TEMP_WP_PLUGIN} --path=${WP_ROOT} --allow-root
		fi
		wp plugin activate ${TEMP_WP_PLUGIN} --path=${WP_ROOT} --allow-root
	done
	unset "TEMP_WP_PLUGIN"
fi

# Init wp_options setting by $WP_OPTIONS_SETUP
if [[ -z "${WP_OPTIONS_SETUP}" ]]; then
	echo >&2 "env var \$WP_OPTIONS_SETUP is empty - skipping updating wp_options";
else
	for TEMP_WP_OPTION in $WP_OPTIONS_SETUP; do
		TEMP_WP_OPTION_KEY=$(cut -d':' -f 1 <<<${TEMP_WP_OPTION})
        TEMP_WP_OPTION_VALUE=$(cut -d':' -f 2 <<<${TEMP_WP_OPTION})
		echo >&2 "Updating wp_options ${TEMP_WP_OPTION_KEY}..."
		wp option update ${TEMP_WP_OPTION_KEY} ${TEMP_WP_OPTION_VALUE} --allow-root
	done
	unset "TEMP_WP_OPTION"
	unset "TEMP_WP_OPTION_KEY"
	unset "TEMP_WP_OPTION_VALUE"
fi

# Activate theme
wp theme activate ${WP_CURRENT_THEME} --path=${WP_ROOT} --allow-root

# Delete default themes
for TEMP_WP_THEME in twentyfifteen twentysixteen twentyseventeen; do
		if $(wp theme is-installed ${TEMP_WP_THEME} --path=${WP_ROOT} --allow-root); then
			wp theme delete ${TEMP_WP_THEME} --path=${WP_ROOT} --allow-root
		fi
done
unset "TEMP_WP_THEME"

if ! $(wp core is-installed --path=${WP_ROOT} --allow-root); then
	echo >&2 "WARNING: It seems that wrong params was set to .env - press Ctrl+C now if this is an error!"
fi

envs=(
	MYSQL_ROOT_PASSWORD
	MYSQL_DATABASE
	WP_URL
	WP_ROOT
	WP_VERSION
	WP_DB_PREFIX
	WP_ADMIN_USER
	WP_ADMIN_PASSWORD
	WP_ADMIN_EMAIL
	WP_CURRENT_THEME
	WP_CURRENT_THEME
	WP_INSTALL_PLUGINS
	WP_OPTIONS_SETUP
)
# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
for e in "${envs[@]}"; do
	unset "$e"
done

echo >&2 "Wordpress initialization completed!"

exec "$@"
