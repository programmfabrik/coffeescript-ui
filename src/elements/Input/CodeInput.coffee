require('ace-builds')
require('ace-builds/src-min-noconflict/mode-json')
require('ace-builds/src-min-noconflict/mode-html')
require('ace-builds/src-min-noconflict/mode-javascript')
require('ace-builds/src-min-noconflict/mode-css')
require('ace-builds/webpack-resolver')

class CUI.CodeInput extends CUI.Input

	@availableModes = ["html", "javascript", "json", "css"]

	readOpts: ->
		super()
		@_textarea = true
		return @

	initOpts: ->
		super()
		@addOpts
			mode:
				check: CUI.CodeInput.availableModes
				default: "javascript"

	render: ->
		super()

		ace = window.ace
		@__aceEditor = ace.edit(@__input,
			mode: "ace/mode/#{@_mode}",
			selectionStyle: "text",
			useWorker: false
		)

		value = @__data?[@_name]
		if value
			try # Workaround to format/indent
				value = JSON.parse(value)
				value = JSON.stringify(value, null, '\t')

			@__aceEditor.setValue(value, -1) # -1 sets the cursor to the start
			@__aceEditor.clearSelection()

		@__aceEditor.on('change', =>
			@storeValue(@__aceEditor.getValue())
		)

	destroy: ->
		@__aceEditor?.destroy()
		return super()
