<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wordpressuser' );

/** Database password */
define( 'DB_PASSWORD', 'wordpresssecret' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

define( 'FS_METHOD', 'direct' );

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
define('AUTH_KEY',         'XivQy#PQ-1I(iv+#}dwyQ78#**m7d7k.TDOL O$3hqVS!obf)0A!^<;P]|`K[W>e');
define('SECURE_AUTH_KEY',  'x5U?=A+rxV94`,MGh0_9aa~*-K~[p;(b<CN{Gr7li/6SJp~Z7].k&vZ`)^,s<~@[');
define('LOGGED_IN_KEY',    '^La~+)8C^Wcn;F6|q12CK0Gtm->$J^Vuy6YtWR--zc0YRD&z&OE)JO&L_*quHFNf');
define('NONCE_KEY',        '9{.ZS?vi^O~# =rO?b<rKu`B[X,a9}`p$NNRl60PwaMMbk2;6}O@E$p|WPW#k-d7');
define('AUTH_SALT',        'v=)nq1~:|ntuuxfp2m@J}e3Gt>?kk_12v;Qx%a9@PdbVh7E xC$Twhfyx-xfx?L;');
define('SECURE_AUTH_SALT', 'x?eY` |hDtUsbq4e(TFkxA%AK4|*,Q{U/DG,DvL3V8-lU9d_Rh;7~^G=pd#MN^uO');
define('LOGGED_IN_SALT',   ' r!z_oF~zG|D=?bD&]0GZYU|vJNV;}g|;N`mr(y^T%V$l|h/ 8y;jf#7,FR5EV0.');
define('NONCE_SALT',       ')jo&K`h:bspm~B0c|Pt$z}|?+-442:|(c7Levaz@j9a{1L6H#fY|0C2C?l?2%~J(');

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
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
