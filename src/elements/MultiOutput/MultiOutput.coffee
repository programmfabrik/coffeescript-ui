###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.MultiOutput extends CUI.Output
	initOpts: ->
		super()
		@addOpts
			control:
				mandatory: true
				check: CUI.MultiInputControl


	displayValue: ->
		super()
		key = @_control.getPreferredKey()
		CUI.util.assert(key, "Output.displayValue", "MultiInputControl: no preferred key set.", control: @_control)
		@setText(@getValue()[key.name])
		@
