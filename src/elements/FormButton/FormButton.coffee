###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class FormButton extends Checkbox

	constructor: (@opts={}) ->
		super(@opts)
		if CUI.__ng__
			@addClass("cui-button-button")

	getButtonOpts: ->
		opts = icon: @_icon
		for k in ["appearance"]
			opts[k] = @["_"+k]
		opts

	getCheckboxClass: ->
		"cui-button-form-button"

	initOpts: ->
		super()
		@addOpts
			icon:
				check: (v) ->
					v instanceof Icon or isString(v)
			appearance:
				check: ["link","flat","normal","important"]
