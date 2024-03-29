module.exports = {
	'extends': 'stylelint-config-standard',
	"ignoreFiles": [
		"src/scss/themes/fylr/body_ng.scss",
		"src/scss/themes/fylr/components/old/*.scss",
		"src/scss/themes/debug/*.scss",
		"src/scss/themes/ng/*.scss",
	],
    'rules': {
        'indentation': 'tab',
        'string-quotes': 'single',
        'no-empty-source': null,
        'color-hex-length': null,
        'max-empty-lines': 2,
        'declaration-block-no-redundant-longhand-properties': null,
        'selector-list-comma-newline-after': null,
        'no-descending-specificity': null,
        'no-eol-whitespace': null,
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
