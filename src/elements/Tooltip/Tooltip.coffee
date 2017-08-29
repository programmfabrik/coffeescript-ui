###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Tooltip extends CUI.LayerPane
	constructor: (@opts = {}) ->
		super(@opts)
		assert(xor(@_text, @_content), "new #{@__cls}", "One of opts.text or opts.content must be set.", opts: @opts)

		@__dummyInst = =>

		if @_on_hover
			Events.listen
				type: "mouseenter"
				instance: @__dummyInst
				node: @__element
				call: (ev) =>
					if CUI.globalDrag
						return

					if @_on_hover == true or @_on_hover(@)
						@showTimeout(null, ev)
					return

			Events.listen
				type: "mouseleave"
				instance: @__dummyInst
				node: @__element
				call: (ev) =>
					if CUI.globalDrag
						@hide(ev)
					else
						@hideTimeout(null, ev)
					return

			CUI.DOM.addClass(@__element, "cui-dom-element-has-tooltip-on-hover")
			return

		if @_on_click
			CUI.DOM.addClass(@__element, "cui-dom-element-has-tooltip-on-click")

			Events.listen
				type: "click"
				instance: @__dummyInst
				node: @__element
				call: (ev) =>
					if ev.hasModifierKey()
						return

					@show()
					return

	initOpts: ->
		super()
		@mergeOpts
			element:
				mandatory: true

		@addOpts
			text:
				check: (v) ->
					isString(v) or CUI.isFunction(v)
			markdown:
				mandatory: true
				default: false
				check: Boolean
			content:
				check: (v) ->
					isString(v) or CUI.isFunction(v) or isElement(v) or CUI.isArray(v) or isElement(v?.DOM)
			# hide/show on click on element
			on_click:
				mandatory: true
				default: false
				check: Boolean
			# hide/show on click on hover
			on_hover:
				check: (v) ->
					isBoolean(v) or CUI.isFunction(v)

		return


	readOpts: ->
		if not @opts.hasOwnProperty("on_hover")
			@opts.on_hover = not @opts.on_click

		# if isUndef(@opts.anchor)
		#	@opts.anchor = @opts.element
		if @opts.on_click
			if not @opts.backdrop
				@opts.backdrop = {}
			if not @opts.backdrop.policy
				@opts.backdrop.policy = "click"

		if isUndef(@opts.backdrop)
			@opts.backdrop = false
		# @opts.role = "tooltip"
		@opts.pointer = "arrow"
		@opts.check_for_element = true
		@opts.placement = @opts.placement or "n"

		super()

		assert(not (@_on_click and @_on_hover), "new Tooltip", "opts.on_click and opts.on_hover cannot be used together.", opts: @opts)
		@

	@current: null # global to store currently shown tooltip

	setElement: ->
		# we don't set the element

	focusOnHide: (ev) ->

	focusOnShow: (ev) ->

	showTimeout: (ms=@_show_ms, ev) ->
		# console.error "Tooltip.showTimeout ", @getUniqueId(), !!Tooltip.current

		if CUI.Tooltip.current
			@show(ev)
			return CUI.resolvedPromise()
		else
			CUI.Tooltip.current = @
			return super(ms, ev)

	hideTimeout: (ms=@_show_ms, ev) ->
		CUI.Tooltip.current = null
		super(ev)

	hide: (ev) ->
		CUI.Tooltip.current = null
		super(ev)

	show: (ev) ->
		if CUI.Tooltip.current and CUI.Tooltip.current != @
			CUI.Tooltip.current.hide(ev)
		CUI.Tooltip.current = @
		if @__static
			super(ev)
		else
			@fillContent()
			.done =>
				super(ev)
		@

	getElementOpenClass: ->
		null

	fillContent: ->

		dfr = new CUI.Deferred()

		dfr.fail =>
			if not @__pane.isDestroyed()
				@__pane.empty("center")

		fill_text = (text) =>
			if isEmpty(text)
				return dfr.reject()

			fill_content(new Label(markdown: @_markdown, text: text, multiline: true))

		fill_content = (content) =>
			if not content or @__pane.isDestroyed()
				return dfr.reject()

			@__pane.replace(content, "center")
			dfr.resolve()

		if CUI.isFunction(@_text)
			ret = @_text.call(@, @)
			if isPromise(ret)
				ret.done (text) ->
					fill_text(text)
				ret.fail ->
					dfr.reject()
			else
				fill_text(ret)
		else if CUI.isFunction(@_content)
			ret = @_content.call(@, @)
			if isPromise(ret)
				ret.done (text) ->
					fill_content(text)
				ret.fail (xhr) ->
					dfr.reject(xhr)
			else
				fill_content(ret)
		else if not isEmpty(@_text)
			fill_text(@_text)
		else
			fill_content(@_content)

		if not CUI.isFunction(@_text) and not CUI.isFunction(@_content)
			# avoid this next time
			@__static = true
		else
			@__static = false

		dfr.promise()

	preventOverflow: ->
		super()
		CUI.DOM.width(@DOM, @__layer_dim._css_width)

	resetLayer: ->
		super()
		CUI.DOM.setStyleOne(@DOM, "max-width", @__viewport.width/2)

	destroy: ->
		# console.error "destroying ", @getUniqueId()
		Events.ignore(instance: @__dummyInst)
		super()
		CUI.DOM.removeClass(@__element, "cui-dom-element-has-tooltip-on-hover cui-dom-element-has-tooltip-on-click")
