class CUI.CodeInput extends CUI.Input

	@availableModes = ["javascript", "json", "css"]

	readOpts: ->
		super()
		@_textarea = true

		if not CUI.CodeInput.loadAcePromise
			CUI.CodeInput.loadAcePromise = @__fetchLibrary()

		return @

	initOpts: ->
		super()
		@addOpts
			mode:
				check: CUI.CodeInput.availableModes
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

	__fetchLibrary: ->
		deferred = new CUI.Deferred()

		# Load library
		CUI.loadScript("https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.6/ace.js").done(->
			modePromises = []
			for mode in CUI.CodeInput.availableModes
				modePromises.push(CUI.loadScript("https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.6/mode-#{mode}.js"))
			CUI.whenAll(modePromises).done(deferred.resolve).fail(deferred.reject)
		).fail(deferred.reject)

		return deferred.promise()
