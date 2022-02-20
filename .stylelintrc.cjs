/**
 * Stylelint config file.
 *
 * @since 1.0.0
 *
 * @note Stylelint is aware of this config file's location.
 *
 * @note PLEASE DO NOT EDIT THIS FILE!
 * This file and the contents of it are updated automatically.
 * - Instead of editing this file, please review source repository {@see https://o5p.me/LevQOD}.
 */
/* eslint-env node */

module.exports = {
	plugins   : [ 'stylelint-scss' ],
	extends   : [
		'stylelint-config-standard',
		'stylelint-config-html',
		'stylelint-no-unsupported-browser-features',
		'stylelint-config-recess-order',
		'stylelint-config-prettier',
	],
	rules     : {
		indentation                 : 'tab',
		'no-duplicate-selectors'    : false,
		'selector-type-no-unknown'  : false,
		'no-descending-specificity' : false,
		'selector-class-pattern'    : '^([a-z][a-z0-9]*)(-{1,2}[a-z0-9]+)*$',
		'selector-id-pattern'       : '^([a-z][a-z0-9]*)(-{1,2}[a-z0-9]+)*$',
		'at-rule-no-unknown'        : [
			true,
			{
				ignoreAtRules : [
					'tailwind',
					'apply',
					'variants',
					'responsive',
					'screen',
				],
			},
		],
	},
	overrides : [
		{
			files        : [ '{**/*,**/.*,.*,*}.css' ],
			customSyntax : 'postcss-safe-parser',
		},
		{
			files        : [ '{**/*,**/.*,.*,*}.scss' ],
			customSyntax : 'postcss-scss',
		},
		{
			files        : [ '{**/*,**/.*,.*,*}.{xml,htm,html,php}' ],
			customSyntax : 'postcss-html',
		},
	],
};
