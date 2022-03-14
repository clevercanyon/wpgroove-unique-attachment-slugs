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
 * Plugin.
 *
 * @since 2021-12-15
 */
final class Plugin extends WPG\A6t\Plugin {
	/**
	 * Does hook setup on instantiation.
	 *
	 * @since 2021-12-15
	 */
	protected function setup_hooks() : void {
		parent::setup_hooks();

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
	 * @return string                Unique slug.
	 */
	public function on_wp_unique_post_slug( string $slug, int $post_id, string $post_status, string $post_type, int $parent_post_id, string $original_slug ) : string {
		if ( 'attachment' === $post_type && ! preg_match( '/-x[0-9a-f]{15}$/ui', $slug ) ) {
			$slug .= '-' . U\Crypto::x_sha( $slug, 16 );
		}
		return $slug;
	}
}
