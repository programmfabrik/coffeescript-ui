class ListViewColumn extends CUI.Element

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
			element: {}


	setRow: (@listViewRow) ->

	getRow: ->
		@listViewRow

	render: ->
		if not isUndef(@_element)
			if @_element.DOM
				@_element.DOM
			else
				@_element
		else
			new Label(text: @_text).DOM

	getAttrs: ->
		@__attrs or {}

	# called by ListView after class rendering
	setElement: (@__element) ->
		@addClass(@getClass())
		if @__attrs
			for k, v of @__attrs
				@__element.attr(k, v)
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

	swapWidthAndHeight: ->
		false

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

