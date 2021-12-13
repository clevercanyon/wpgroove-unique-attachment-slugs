<?php
/** WP Groove™ <https://wpgroove.com>
 *  _       _  ___       ___
 * ( )  _  ( )(  _`\    (  _`\
 * | | ( ) | || |_) )   | ( (_) _ __   _      _    _   _    __  ™
 * | | | | | || ,__/'   | |___ ( '__)/'_`\  /'_`\ ( ) ( ) /'__`\
 * | (_/ \_) || |       | (_, )| |  ( (_) )( (_) )| \_/ |(  ___/
 * `\___x___/'(_)       (____/'(_)  `\___/'`\___/'`\___/'`\____)
 */
namespace WP_Groove\Unique_Attachment_Slugs;

/**
 * Dependencies.
 *
 * @since 1.0.0
 */
use Clever_Canyon\Utilities\OOPs\Version_1_0_0 as U;
use WP_Groove\Framework\Utilities\OOPs\Version_1_0_0 as UU;
use WP_Groove\Framework\Plugin\Version_1_0_0\{ Base };

/**
 * Plugin.
 *
 * @since 1.0.0
 */
class Plugin extends Base {
	/**
	 * On `init` hook.
	 *
	 * @since 1.0.0
	 */
	public function on_init() : void {
		add_filter( 'wp_unique_post_slug', [ $this, 'on_wp_unique_post_slug' ], 10, 6 );
	}

	/**
	 * On `wp_unique_post_slug` hook.
	 *
	 * @since 1.0.0
	 *
	 * @param  string $slug           Slug.
	 * @param  int    $post_id        Post ID.
	 * @param  string $post_status    Post status.
	 * @param  string $post_type      Post type.
	 * @param  int    $parent_post_id Post parent ID.
	 * @param  string $original_slug  Original slug.
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
