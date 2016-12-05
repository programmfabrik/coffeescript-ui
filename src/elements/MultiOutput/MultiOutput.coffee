###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

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

