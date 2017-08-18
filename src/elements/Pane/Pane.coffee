###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Pane extends CUI.VerticalLayout

	@defaults:
		button_tooltip: text: "Turn fullscreen on / off"

	__init: ->
		super()
		@addClass("cui-pane")
		@__fill_screen_is_on = false

		if @_padded
			@addClass("cui-pane--padded")

	initOpts: ->
		super()
		@addOpts
			padded:
				check: Boolean
				default: false

	readOpts: ->
		@initDefaultPanes()
		super()

	hasHeader: ->
		!!@_top

	hasFooter: ->
		!!@_bottom

	getFillScreenState: ->
		@__fill_screen_is_on

	endFillScreen: (transition=true) ->

		if not @getFillScreenState()
			return

		@__fill_screen_is_on = false

		if not $elementIsInDOM(@__placeholder)
			@__fillscreenTmpl.destroy()
			@__placeholder = null
		else
			end_fill_screen = =>
				#CUI.debug "Stopping", event
				@__placeholder.before(@DOM)
				@__placeholder.remove()
				@__fillscreenTmpl.destroy()
				delete(@__fillscreenTmpl)
				Events.trigger
					type: "end-fill-screen"
					node: @DOM
				Events.trigger
					type: "viewport-resize"
					node: @DOM

			if transition
				Events.wait
					type: "transitionend"
					node: @__fillscreenTmpl
				.always =>
					end_fill_screen()

				@__fillscreenTmpl.removeClass("cui-pane-fill-screen-is-on")
			else
				end_fill_screen()
		@

	startFillScreen: ->
		if @getFillScreenState()
			return

		@__fillscreenTmpl = new Template
			name: "pane-fill-screen"
			map:
				inner: true

		# measure DOM start position
		rect = @DOM.rect()

		vp = CUI.DOM.getDimensions(window)
		@__placeholderTmpl = new Template
			name: "pane-fill-screen-placeholder"

		@__placeholder = @__placeholderTmpl.DOM
		inner = @__fillscreenTmpl.map.inner

		# add DOM element classes of all parent dom elements
		# to the inner container
		# for el in @DOM.parents(".cui-dom-element")
		# 	inner.addClass(DOM.data(el, "element").getDOMElementClasses())

		@__fillscreenTmpl.DOM.appendTo(document.body)
		rect_fill = @__fillscreenTmpl.DOM.rect()
		rect_fill_inner = inner.rect()

		# adjust start rect, so it matches the design of the
		# fill div

		adjust =
			left: (rect_fill_inner.left - rect_fill.left) + inner.cssEdgeSpace("left")
			top: (rect_fill_inner.top - rect_fill.top) + inner.cssEdgeSpace("top")
			right: (rect_fill.right - rect_fill_inner.right) + inner.cssEdgeSpace("right")
			bottom: (rect_fill.bottom - rect_fill_inner.bottom) + inner.cssEdgeSpace("bottom")

		start_rect =
			top: rect.top - adjust.top
			left: rect.left - adjust.left
			bottom: vp.height - rect.bottom - adjust.bottom
			right: vp.width - rect.right - adjust.right

		@__fillscreenTmpl.DOM.detach()

		@__fillscreenTmpl.DOM.css(start_rect)
		@__fillscreenTmpl.DOM.appendTo(document.body)

		# copy keys over for the placeholder, so that it has the
		# same dimension as the replaced div
		# this assumes, that the placeholder dont uses padding, border
		# or margin!

		@__placeholder.css
			width: @DOM.outerWidth(true)
			height: @DOM.outerHeight(true)

		for key_copy in ["position", "top", "left", "right", "bottom"]
			@__placeholder.css(key_copy, @DOM.css(key_copy))

		@DOM.after(@__placeholder)

		@__fillscreenTmpl.replace(@DOM, "inner")


		Events.wait
			type: "transitionend"
			node: @__fillscreenTmpl
		.always =>
			Events.trigger
				type: "start-fill-screen"
				node: @DOM
			Events.trigger
				type: "viewport-resize"
				node: @DOM


		@__fillscreenTmpl.addClass("cui-pane-fill-screen-is-on")

		@__fill_screen_is_on = true

		checkToggle = =>
			if not @getFillScreenState()
				return

			if not $elementIsInDOM(@__placeholder)
				@endFillScreen()

			CUI.setTimeout(checkToggle, 50)

		checkToggle()

		@__fill_screen_is_on

	toggleFillScreen: ->
		if @getFillScreenState()
			@endFillScreen()
		else
			@startFillScreen()


	# creates a button that can be used in paneheader (or somewhere else) to toggle fillscreen
	@getToggleFillScreenButton: (opts={}) ->
		for k, v of {
			icon_inactive: new Icon(class: "fa-expand")
			icon_active: new Icon(class: "fa-compress")
			switch: true
			onClick: (ev, btn) =>
				DOM.data(btn.DOM.closest(".cui-pane")[0], "element").toggleFillScreen()
		}
			opts[k] = v

		if not opts.tooltip
			opts.tooltip = CUI.Pane.defaults.button_tooltip

		new CUI.defaults.class.Button(opts)


CUI.Events.registerEvent
	type: ["start-fill-screen", "end-fill-screen"]
	sink: true
