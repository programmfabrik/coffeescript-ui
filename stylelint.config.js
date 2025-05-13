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
