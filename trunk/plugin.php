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
 * Plugin Name: Unique Attachment Slugs
 * Plugin URI: https://wpgroove.com/product/unique-attachment-slugs
 *
 * Description: Ensures every item in media library has a unique/random suffix in its permalink.
 * Tags: media library, attachments, permalinks
 *
 * Version: 1.0.0
 * Stable tag: 1.0.0
 *
 * Requires PHP: 7.4
 * Requires at least: 5.8.2
 * Tested up to: 5.8.2
 *
 * Author: WP Groove
 * Author URI: https://wpgroove.com
 * Donate link: https://wpgroove.com/donate
 * Contributors: clevercanyon
 *
 * License: GPLv2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 *
 * Text Domain: wpgroove-unique-attachment-slugs
 * Domain Path: /languages
 */

/**
 * Declarations & namespace.
 *
 * @since 2021-12-25
 */
declare( strict_types = 1 ); // ｡･:*:･ﾟ★.
namespace WP_Groove\Unique_Attachment_Slugs;

/**
 * Utilities.
 *
 * @since 2021-12-15
 */
use Clever_Canyon\Utilities\{STC as U};
use Clever_Canyon\Utilities\OOP\{Offsets, Generic, Error, Exception, Fatal_Exception};
use Clever_Canyon\Utilities\OOP\Abstracts\{A6t_Base, A6t_Offsets, A6t_Generic, A6t_Error, A6t_Exception};
use Clever_Canyon\Utilities\OOP\Interfaces\{I7e_Base, I7e_Offsets, I7e_Generic, I7e_Error, I7e_Exception};

/**
 * WP Groove utilities.
 *
 * @since 2021-12-15
 */
use WP_Groove\Framework\Utilities\{STC as UU};
use WP_Groove\Framework\Plugin\Abstracts\{AA6t_Plugin};
use WP_Groove\Framework\Utilities\OOP\Abstracts\{AA6t_App};

// </editor-fold>

/**
 * No direct access.
 *
 * @since 2021-12-15
 */
if ( ! defined( 'WPINC' ) ) {
	exit( 'No direct access.' );
}

/**
 * Requires autoloader.
 *
 * @since 2021-12-15
 */
require_once __DIR__ . '/vendor/autoload.php';

/**
 * Adds instance hooks.
 *
 * @since 2021-12-15
 */
Plugin::add_instance_hooks(
	__FILE__,
	'Unique Attachment Slugs', // @name
	'wpgroove-unique-attachment-slugs', // @slug
	'1.0.0' // @version
);
