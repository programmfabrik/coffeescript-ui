###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FormButton extends CUI.Checkbox

	constructor: (opts) ->
		super(opts)

	getButtonOpts: ->
		opts = icon: @_icon
		for k in ["appearance"]
			opts[k] = @["_"+k]
		opts

	render: ->
		super()
		@__checkbox.addClass("cui-button-button")
		return

	getCheckboxClass: ->
		"cui-button-form-button"

	initOpts: ->
		super()
		@addOpts
			icon:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v)
			appearance:
				check: ["link","flat","normal","important"]
