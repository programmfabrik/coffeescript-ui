###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.OutputContent extends CUI.DataFieldInput
	initOpts: ->
		super()
		@addOpts
			placeholder:
				default: ""
				check: String
			content:
				check: (v) ->
					CUI.util.isElement(v) or CUI.util.isElement(v.DOM)
			getValue:
				check: Function

	setContent: (content=null) ->
		if not content
			CUI.dom.addClass(@DOM, "cui-output-empty")
			@empty()
		else
			CUI.dom.removeClass(@DOM, "cui-output-empty")
			@replace(content)

	displayValue: ->
		super()
		if @getName()
			@setContent(@getValue())
		@

	getValue: ->
		value = super()
		if @_getValue
			@_getValue.call(@, value)
		else
			value

	render: ->
		super()
		@setContent(@_content)
