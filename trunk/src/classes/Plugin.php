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
 * Plugin.
 *
 * @since 2021-12-15
 */
class Plugin extends AA6t_Plugin {
	/**
	 * On `init` hook.
	 *
	 * @since 2021-12-15
	 */
	public function on_init() : void {
		parent::on_init();

		add_filter( 'wp_unique_post_slug', [ $this, 'on_wp_unique_post_slug' ], 10, 6 );
	}

	/**
	 * On `wp_unique_post_slug` hook.
	 *
	 * @since 2021-12-15
	 *
	 * @param string $slug           Slug.
	 * @param int    $post_id        Post ID.
	 * @param string $post_status    Post status.
	 * @param string $post_type      Post type.
	 * @param int    $parent_post_id Post parent ID.
	 * @param string $original_slug  Original slug.
	 *
	 * @return string                 Unique slug.
	 */
	public function on_wp_unique_post_slug( string $slug, int $post_id, string $post_status, string $post_type, int $parent_post_id, string $original_slug ) : string {
		if ( 'attachment' === $post_type && ! preg_match( '/-cs-[a-z0-9]{8}$/ui', $slug ) ) {
			$slug .= '-cs-' . hash( 'crc32b', $slug );
		}
		return $slug;
	}
}
