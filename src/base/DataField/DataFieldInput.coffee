class CUI.DataFieldInput extends CUI.DataField
	constructor: (@opts={}) ->
		super(@opts)
		DOM.setAttributeMap(@DOM[0], @_attr)
		@addClass("cui-data-field-input")

	initOpts: ->
		super()
		@addOpts
			#group can be used for buttonbars to specify a group css style
			group:
				check: String
			# attributes for the @DOM element
			attr:
				default: {}
				check: "PlainObject"

	getGroup: ->
		@_group

	isResizable: ->
		true

DataFieldInput = CUI.DataFieldInput
