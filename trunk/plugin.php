<?php
/** WP Groove™ <https://wpgroove.com>
 *  _       _  ___       ___
 * ( )  _  ( )(  _`\    (  _`\
 * | | ( ) | || |_) )   | ( (_) _ __   _      _    _   _    __  ™
 * | | | | | || ,__/'   | |___ ( '__)/'_`\  /'_`\ ( ) ( ) /'__`\
 * | (_/ \_) || |       | (_, )| |  ( (_) )( (_) )| \_/ |(  ___/
 * `\___x___/'(_)       (____/'(_)  `\___/'`\___/'`\___/'`\____)
 */
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
namespace WP_Groove\Unique_Attachment_Slugs;

/**
 * No direct access.
 *
 * @since 1.0.0
 */
if ( ! defined( 'WPINC' ) ) {
	exit( 'No direct access.' );
}

/**
 * Adds plugin instance hooks.
 *
 * @since 1.0.0
 */
require_once __DIR__ . '/vendor/autoload.php';
Plugin::add_plugin_instance_hooks( __FILE__, '1.0.0' /* @version */ );
