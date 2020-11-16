###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Tooltip extends CUI.LayerPane
	constructor: (opts) ->
		super(opts)
		CUI.util.assert(CUI.util.xor(@_text, @_content), "new #{@__cls}", "One of opts.text or opts.content must be set.", opts: @opts)

		@__dummyInst = =>

		if @_on_hover
			if @_on_hover == true or @_on_hover(@)
				CUI.dom.addClass(@__element, "cui-dom-element-has-tooltip-on-hover")
				@showTimeout()

			return

		if @_on_click
			CUI.dom.addClass(@__element, "cui-dom-element-has-tooltip-on-click")

			CUI.Events.listen
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
					CUI.util.isString(v) or CUI.util.isFunction(v)
			markdown:
				mandatory: true
				default: false
				check: Boolean
			content:
				check: (v) ->
					CUI.util.isString(v) or CUI.util.isFunction(v) or CUI.util.isElement(v) or CUI.util.isArray(v) or CUI.util.isElement(v?.DOM)
			# hide/show on click on element
			on_click:
				mandatory: true
				default: false
				check: Boolean
			# hide/show on click on hover
			on_hover:
				check: (v) ->
					CUI.util.isBoolean(v) or CUI.util.isFunction(v)

		return


	readOpts: ->
		if not @opts.hasOwnProperty("on_hover")
			@opts.on_hover = not @opts.on_click

		# if CUI.util.isUndef(@opts.anchor)
		#	@opts.anchor = @opts.element
		if @opts.on_click
			if not @opts.backdrop
				@opts.backdrop = {}
			if not @opts.backdrop.policy
				@opts.backdrop.policy = "click"

		if CUI.util.isUndef(@opts.backdrop)
			@opts.backdrop = false
		# @opts.role = "tooltip"
		@opts.pointer = "arrow"
		@opts.check_for_element = true
		@opts.placement = @opts.placement or "n"

		super()

		CUI.util.assert(not (@_on_click and @_on_hover), "new CUI.Tooltip", "opts.on_click and opts.on_hover cannot be used together.", opts: @opts)
		@

	@current: null # global to store currently shown tooltip

	setElement: ->
		# we don't set the element

	focusOnHide: (ev) ->

	focusOnShow: (ev) ->

	showTimeout: ->
		@__mouseStillEvent?.destroy()

		@__mouseStillEvent = new CUI.Events.MouseIsStill
			ms: @_show_ms
			node: @_element
			call: (ev) =>
				@show(ev)
				CUI.Events.listen
					type: ["click", "dblclick", "mouseout"]
					capture: true
					node: @_element
					only_once: true
					call: (ev) =>
						CUI.setTimeout
							ms: @_hide_ms
							call: =>
								@hide(ev)

		return @__mouseStillEvent


	show: (ev) ->
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
			if CUI.util.isEmpty(text)
				return dfr.reject()

			fill_content(new CUI.Label(markdown: @_markdown, text: text, multiline: true))

		fill_content = (content) =>
			if not content or @__pane.isDestroyed()
				return dfr.reject()

			@__pane.replace(content, "center")
			dfr.resolve()

		if CUI.util.isFunction(@_text)
			ret = @_text.call(@, @)
			if CUI.util.isPromise(ret)
				ret.done (text) ->
					fill_text(text)
				ret.fail ->
					dfr.reject()
			else
				fill_text(ret)
		else if CUI.util.isFunction(@_content)
			ret = @_content.call(@, @)
			if CUI.util.isPromise(ret)
				ret.done (text) ->
					fill_content(text)
				ret.fail (xhr) ->
					dfr.reject(xhr)
			else
				fill_content(ret)
		else if not CUI.util.isEmpty(@_text)
			fill_text(@_text)
		else
			fill_content(@_content)

		if not CUI.util.isFunction(@_text) and not CUI.util.isFunction(@_content)
			# avoid this next time
			@__static = true
		else
			@__static = false

		dfr.promise()

	preventOverflow: ->
		super()
		CUI.dom.width(@DOM, @__layer_dim._css_width)

	resetLayer: ->
		super()
		CUI.dom.setStyleOne(@DOM, "max-width", @__viewport.width/2)

	destroy: ->
		@__mouseStillEvent?.destroy()
		CUI.Events.ignore(instance: @__dummyInst)
		super()
		CUI.dom.removeClass(@__element, "cui-dom-element-has-tooltip-on-hover cui-dom-element-has-tooltip-on-click")
