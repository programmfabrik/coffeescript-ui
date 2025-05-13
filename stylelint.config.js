module.exports = {
	'extends': 'stylelint-config-standard-scss',
	"ignoreFiles": [
		"src/scss/themes/debug/*.scss",
		"src/scss/themes/ng/*.scss",
	],
    'rules': {
        'scss/dollar-variable-colon-space-after': null,
        'scss/dollar-variable-empty-line-before': null,
        'scss/double-slash-comment-empty-line-before': null,
        'scss/at-mixin-argumentless-call-parentheses': 'always',
        'scss/at-mixin-pattern': [
            '^_?(-?[a-z][a-z0-9]*)(-[a-z0-9]+)*$', // This allows kebab-case with an optional starting underscore
            {
                message: 'Expected mixin to be kebab-case, mixins can start with an underscore',
            },
        ],  
        'selector-class-pattern': [
			'^([a-z][a-z0-9]*)(-?-?[a-z0-9]+)*$',
			{
				message: (selector) => `Expected class selector "${selector}" to be kebab-case, --modifier is allowed`,
			},
		],
        'scss/comment-no-empty': null,
        'no-empty-source': null,
        'color-hex-length': null,
        'declaration-block-no-redundant-longhand-properties': null,
        'no-descending-specificity': null,
        'property-no-unknown': [
            true,
            {
                'ignoreProperties': ['aspect-ratio', 'container-type', 'container-name'],
            }
        ],        
        "at-rule-empty-line-before": [
            "always",
            {
              except: ['blockless-after-same-name-blockless', 'first-nested'],
              ignore: ['after-comment'],
              ignoreAtRules: ['else'],
            },
        ],        
        'at-rule-no-unknown': [
            true,
            {
                'ignoreAtRules': [
                    'extend',
                    'at-root',
                    'debug',
                    'warn',
                    'error',
                    'if',
                    'else',
                    'for',
                    'each',
                    'while',
                    'mixin',
                    'include',
                    'content',
                    'return',
                    'function',
                    'tailwind',
                    'apply',
                    'responsive',
                    'variants',
                    'screen',
                    'use',
                    'container',
                ],
            },
        ],
    },
};
