###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewColumn extends CUI.Element

	readOpts: ->
		super()
		@__cl = @_class or ""
		@__attrs = @_attrs or null

	initOpts: ->
		super()
		@addOpts
			class:
				default: ""
				check: String
			attrs:
				default: null
				check: "PlainObject"
			text:
				check: String
			colspan:
				check: "Integer"
			element:
				check: (v) ->
					isContent(v) or isString(v)
			onSetElement:
				check: Function

	setRow: (@listViewRow) ->

	getRow: ->
		@listViewRow

	render: ->
		if not isUndef(@_element)
			if @_element.DOM
				@_element.DOM
			else
				@_element
		else if not isEmpty(@_text)
			new Label(text: @_text).DOM
		else
			null

	getAttrs: ->
		@__attrs or {}

	# called by ListView after class rendering
	setElement: (@__element) ->
		@addClass(@getClass())
		if @__attrs
			CUI.DOM.setAttributeMap(@__element, @__attrs)
		@_onSetElement?(@)
		@__element

	getElement: ->
		@__element

	getClass: ->
		@__cl

	addClass: (cls) ->
		if not @__element
			@__cl += " "+cls
		else if @__element instanceof HTMLElement
			CUI.DOM.addClass(@__element, cls)
		@

	removeClass: (cls) ->
		if @__element instanceof HTMLElement
			CUI.DOM.removeClass(@__element, cls)
		@

	setColspan: (colspan) =>
		@_colspan = colspan

	getColspan: =>
		if CUI.isFunction(@_colspan)
			cp = parseInt(@_colspan())
		else
			cp = parseInt(@_colspan)

		if cp > 1
			return cp
		else
			return 1

ListViewColumn = CUI.ListViewColumn
