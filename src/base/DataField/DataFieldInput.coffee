###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DataFieldInput extends CUI.DataField
	constructor: (@opts={}) ->
		super(@opts)
		CUI.DOM.setAttributeMap(@DOM, @_attr)
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

