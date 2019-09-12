class CUI.CodeInput extends CUI.Input

	readOpts: ->
		super()
		@_textarea = true
		return @

	initOpts: ->
		super()
		@addOpts
			mode:
				check: ["javascript", "json"]
				default: "javascript"

	render: ->
		super()

		CUI.CodeInput.loadAcePromise.done( =>
			ace = window.ace
			@__aceEditor = ace.edit(@__input,
				mode: "ace/mode/#{@_mode}",
				selectionStyle: "text",
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
		)

	destroy: ->
		@__aceEditor?.destroy()
		return super()

CUI.ready ->

	deferred = new CUI.Deferred()

	# Load library
	CUI.loadScript("https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.6/ace.js").done(->
		CUI.whenAll([ # Load modes.
			CUI.loadScript("https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.6/mode-javascript.js")
			CUI.loadScript("https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.6/mode-json.js")
		]).done(deferred.resolve).fail(deferred.reject)
	).fail(deferred.reject)

	CUI.CodeInput.loadAcePromise = deferred.promise()