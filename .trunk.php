<?php
/**
 * WP Groove™ {@see https://wpgroove.com}
 *  _       _  ___       ___
 * ( )  _  ( )(  _`\    (  _`\
 * | | ( ) | || |_) )   | ( (_) _ __   _      _    _   _    __  ™
 * | | | | | || ,__/'   | |___ ( '__)/'_`\  /'_`\ ( ) ( ) /'__`\
 * | (_/ \_) || |       | (_, )| |  ( (_) )( (_) )| \_/ |(  ___/
 * `\___x___/'(_)       (____/'(_)  `\___/'`\___/'`\___/'`\____)
 */
// <editor-fold desc="Strict types, namespace, use statements, and other headers.">

/**
 * Declarations & namespace.
 *
 * @since 2021-12-25
 */
declare( strict_types = 1 );
namespace WP_Groove\Unique_Attachment_Slugs;

/**
 * Utilities.
 *
 * @since 2021-12-15
 */
use Clever_Canyon\{Utilities as U};

/**
 * Framework.
 *
 * @since 2021-12-15
 */
use WP_Groove\{Framework as WPG};

/**
 * Plugin.
 *
 * @since 2021-12-15
 */
use WP_Groove\{Unique_Attachment_Slugs as WP};

// </editor-fold>

/**
 * Dev-only access.
 */
if ( ! getenv( 'COMPOSER_DEV_MODE' ) ) {
	exit( 1 ); // Dev mode only.
}

/**
 * Trunk autoloader.
 *
 * @since 2021-12-15
 *
 * @note  Very important to have `@prepend-autoloader: false` in `trunk/composer.json`.
 *        Reason is because otherwise it will have precedence over local development symlinks.
 */
if ( is_file( __DIR__ . '/trunk/vendor/autoload.php' ) ) {
	require_once __DIR__ . '/trunk/vendor/autoload.php';
}
