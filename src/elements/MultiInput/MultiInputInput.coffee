class MultiInputInput extends Input
	getTemplate: ->
		new Template
			name: "data-field-multi-input"
			map:
				center: true
				right: true

	getTemplateKeyForRender: ->
		"center"
