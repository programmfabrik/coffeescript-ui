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
				mandatory: true
				default: "auto"
				check: ["auto","link","flat","normal","important"]
