Ace = require('ace-builds/src-noconflict/ace')
require('ace-builds/src-min-noconflict/mode-json')
require('ace-builds/src-min-noconflict/mode-html')
require('ace-builds/src-min-noconflict/mode-javascript')
require('ace-builds/src-min-noconflict/mode-css')

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

		@__aceEditor = Ace.edit(@__input,
			useWorker: false
			selectionStyle: "text"
		)
		@__aceEditor.getSession().setMode("ace/mode/#{@_mode}");

		value = @__data?[@_name]
		if value
			if CUI.util.isString(value)
				try # Workaround to format/indent
					value = JSON.parse(value)
			if @_mode == "json"
				value = JSON.stringify(value, null, '\t')
			@__aceEditor.setValue(value, -1) # -1 sets the cursor to the start
			@__aceEditor.clearSelection()

		@__aceEditor.on('change', =>
			@storeValue(@__aceEditor.getValue())
		)

	destroy: ->
		@__aceEditor?.destroy()
		return super()
