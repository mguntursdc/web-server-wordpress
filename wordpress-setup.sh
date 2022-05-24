#!/bin/bash

sudo apt update && sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

sudo mkdir -p /srv/www && sudo chown www-data: /srv/www && curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

echo "
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/wordpress.conf

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default

sudo systemctl restart apache2
sudo systemctl reload apache2

sudo mysql -u root -pguntur <<EXEC
CREATE DATABASE wordpress;
CREATE USER 'wordpress'@'localhost' identified by 'guntur';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO 'wordpress'@'localhost';
FLUSH PRIVILEGES;
EXEC

sudo systemctl start mysql

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/guntur/' /srv/www/wordpress/wp-config.php


echo"<?php
     /**
      * The base configuration for WordPress
      *
      * The wp-config.php creation script uses this file during the installation.
      * You don't have to use the web site, you can copy this file to "wp-config.php"
      * and fill in the values.
      *
      * This file contains the following configurations:
      *
      * * Database settings
      * * Secret keys
      * * Database table prefix
      * * ABSPATH
      *
      * @link https://wordpress.org/support/article/editing-wp-config-php/
      *
      * @package WordPress
      */

     // ** Database settings - You can get this info from your web host ** //
     /** The name of the database for WordPress */
     define( 'DB_NAME', 'wordpress' );

     /** Database username */
     define( 'DB_USER', 'wordpress' );

     /** Database password */
     define( 'DB_PASSWORD', 'guntur' );

     /** Database hostname */
     define( 'DB_HOST', 'localhost' );

     /** Database charset to use in creating database tables. */
     define( 'DB_CHARSET', 'utf8' );

     /** The database collate type. Don't change this if in doubt. */
     define( 'DB_COLLATE', '' );

     /**#@+
      * Authentication unique keys and salts.
      *
      * Change these to different unique phrases! You can generate these using
      * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
      *
      * You can change these at any point in time to invalidate all existing cookies.
      * This will force all users to have to log in again.
      *
     * @since 2.6.0
      */

     /**#@-*/

     /**
      * WordPress database table prefix.
      *
      * You can have multiple installations in one database if you give each
      * a unique prefix. Only numbers, letters, and underscores please!
      */
     $table_prefix = 'wp_';

     /**
      * For developers: WordPress debugging mode.
      *
      * Change this to true to enable the display of notices during development.
      * It is strongly recommended that plugin and theme developers use WP_DEBUG
      * in their development environments.
      *
      * For information on other constants that can be used for debugging,
      * visit the documentation.
      *
       * For information on other constants that can be used for debugging,
       * visit the documentation.
       *
       * @link https://wordpress.org/support/article/debugging-in-wordpress/
       */
      define( 'WP_DEBUG', false );

      /* Add any custom values between this line and the "stop editing" line. */



      /* That's all, stop editing! Happy publishing. */

      /** Absolute path to the WordPress directory. */
      if ( ! defined( 'ABSPATH' ) ) {
              define( 'ABSPATH', __DIR__ . '/' );
      }

      /** Sets up WordPress vars and included files. */
      require_once ABSPATH . 'wp-settings.php';" > /srv/www/wordpress/wp-config.php

