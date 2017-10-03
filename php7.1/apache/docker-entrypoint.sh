#!/usr/bin/env bash

echo >&2 "Wait for MySQL running..."
wait-for-it.sh -t 0 mysql:3306
echo >&2 "MySQL started!"

# Delete wp-config
if [ -f ${WP_ROOT}/wp-config.php ]; then
  echo >&2 "Found wp-config.php - delete ..."
  rm -f ${WP_ROOT}/wp-config.php
fi

# Then initialize a local wp-config if not exists
if [ ! -f ${WP_ROOT}/wp-config.local.php ]; then
  echo >&2 "try download ..."
  wp core download --path=${WP_ROOT} --allow-root --locale=ja --version=${WP_VERSION}
  echo >&2 "try wp config ..."
  wp core config   --path=${WP_ROOT} --allow-root \
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

  if ! $(wp core is-installed --path=${WP_ROOT} --allow-root); then
    echo >&2 "try install ..."
    # Install core
    wp core install --path=${WP_ROOT} --allow-root \
      --url=${WP_URL} \
      --title=wp \
      --admin_user=${WP_ADMIN_USER} \
      --admin_password=${WP_ADMIN_PASSWORD} \
      --admin_email=${WP_ADMIN_EMAIL} \
      --skip-email

    # Install and activate plugins

    echo >&2 "try set up themes and plugins ..."
    # Delete plugin
    if $(wp plugin is-installed hello --path=${WP_ROOT} --allow-root); then
      wp plugin delete hello --path=${WP_ROOT} --allow-root
    fi

    # Activate plugin
    if $(wp plugin is-installed wp-multibyte-patch --path=${WP_ROOT} --allow-root); then
      wp plugin activate wp-multibyte-patch --path=${WP_ROOT} --allow-root
    fi

    # Activate theme
    wp theme activate ${WP_CURRENT_THEME} --path=${WP_ROOT} --allow-root

    # Delete theme
    if $(wp theme is-installed twentyfifteen --path=${WP_ROOT} --allow-root); then
      wp theme delete twentyfifteen --path=${WP_ROOT} --allow-root
    fi

    if $(wp theme is-installed twentysixteen --path=${WP_ROOT} --allow-root); then
      wp theme delete twentysixteen --path=${WP_ROOT} --allow-root
    fi

    if $(wp theme is-installed twentyseventeen --path=${WP_ROOT} --allow-root); then
      wp theme delete twentyseventeen --path=${WP_ROOT} --allow-root
    fi

    if ! $(wp core is-installed --path=${WP_ROOT} --allow-root); then
      echo >&2 "WARNING: It seems that wrong params was set to .env - press Ctrl+C now if this is an error!"
    fi

  fi

  mv ${WP_ROOT}/wp-config.php ${WP_ROOT}/wp-config.local.php

fi

# Finally, make a symlink to wp-config
(cd ${WP_ROOT} && ln -s wp-config.local.php wp-config.php)

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
)
# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
for e in "${envs[@]}"; do
  unset "$e"
done

exec "$@"
