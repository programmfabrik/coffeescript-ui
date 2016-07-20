class MultiOutput extends Output
	initOpts: ->
		super()
		@addOpts
			control:
				mandatory: true
				check: MultiInputControl


	displayValue: ->
		super()
		key = @_control.getPreferredKey()
		assert(key, "Output.displayValue", "MultiInputControl: no preferred key set.", control: @_control)
		@setText(@getValue()[key.name])
		@

