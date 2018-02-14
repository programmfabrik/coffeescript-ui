###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Pane.html'));

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

		if not CUI.util.$elementIsInDOM(@__placeholder)
			@__fillscreenTmpl.destroy()
			@__placeholder = null
		else
			end_fill_screen = =>
				#console.debug "Stopping", event
				CUI.dom.insertBefore(@__placeholder, @DOM)

				parentPopover = CUI.dom.data(CUI.dom.parent(@__placeholder), "element")
				if parentPopover instanceof CUI.Popover
					parentPopover.setVisible(true)
				CUI.dom.remove(@__placeholder)

				@__fillscreenTmpl.destroy()
				delete(@__fillscreenTmpl)
				CUI.Events.trigger
					type: "end-fill-screen"
					node: @DOM
				CUI.Events.trigger
					type: "viewport-resize"
					node: @DOM

			if transition
				CUI.Events.wait
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

		@__fillscreenTmpl = new CUI.Template
			name: "pane-fill-screen"
			map:
				inner: true

		# measure DOM start position
		rect = CUI.dom.getRect(@DOM)

		vp = CUI.dom.getDimensions(window)
		@__placeholderTmpl = new CUI.Template
			name: "pane-fill-screen-placeholder"

		@__placeholder = @__placeholderTmpl.DOM
		inner = @__fillscreenTmpl.map.inner

		# add DOM element classes of all parent dom elements
		# to the inner container
		# for el in @DOM.parents(".cui-dom-element")
		# 	inner.addClass(DOM.data(el, "element").getDOMElementClasses())

		CUI.dom.append(document.body, @__fillscreenTmpl.DOM)
		dim_fill = CUI.dom.getDimensions(@__fillscreenTmpl.DOM)
		dim_fill_inner = CUI.dom.getDimensions(inner)

		# adjust start rect, so it matches the design of the
		# fill div

		adjust =
			left: (dim_fill_inner.clientBoundingRect.left - dim_fill.clientBoundingRect.left) + dim_fill_inner.borderLeft + dim_fill_inner.paddingLeft
			top: (dim_fill_inner.clientBoundingRect.top - dim_fill.clientBoundingRect.top) + dim_fill_inner.borderTop + dim_fill_inner.paddingTop
			right: (dim_fill.clientBoundingRect.right - dim_fill_inner.clientBoundingRect.right) + dim_fill_inner.borderRight + dim_fill_inner.paddingRight
			bottom: (dim_fill.clientBoundingRect.bottom - dim_fill_inner.clientBoundingRect.bottom) + dim_fill_inner.borderBottom + dim_fill_inner.paddingBottom

		start_rect =
			top: rect.top - adjust.top
			left: rect.left - adjust.left
			bottom: vp.height - rect.bottom - adjust.bottom
			right: vp.width - rect.right - adjust.right

		CUI.dom.remove(@__fillscreenTmpl.DOM)

		CUI.dom.setStyle(@__fillscreenTmpl.DOM, start_rect)
		CUI.dom.append(document.body, @__fillscreenTmpl.DOM)

		# copy keys over for the placeholder, so that it has the
		# same dimension as the replaced div
		# this assumes, that the placeholder dont uses padding, border
		# or margin!

		CUI.dom.setStyle(@__placeholder,
			width: CUI.dom.getDimensions(@DOM).marginBoxWidth
			height: CUI.dom.getDimensions(@DOM).marginBoxHeight
		)

		for key_copy in ["position", "top", "left", "right", "bottom"]
			CUI.dom.setStyleOne(@__placeholder, key_copy, CUI.dom.getComputedStyle(@DOM)[key_copy])

		CUI.dom.insertAfter(@DOM, @__placeholder)

		parentPopover = CUI.dom.data(CUI.dom.parent(@DOM), "element")
		if parentPopover instanceof CUI.Popover
			parentPopover.setVisible(false)

		@__fillscreenTmpl.replace(@DOM, "inner")

		CUI.Events.wait
			type: "transitionend"
			node: @__fillscreenTmpl
		.always =>
			CUI.Events.trigger
				type: "start-fill-screen"
				node: @DOM
			CUI.Events.trigger
				type: "viewport-resize"
				node: @DOM


		@__fillscreenTmpl.addClass("cui-pane-fill-screen-is-on")

		@__fill_screen_is_on = true

		checkToggle = =>
			if not @getFillScreenState()
				return

			if not CUI.util.$elementIsInDOM(@__placeholder)
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
	@getToggleFillScreenButton: (_opts={}) ->
		opts = CUI.Element.readOpts(_opts, "Pane.getToggleFillScreenButton",
			icon_inactive:
				mandatory: true
				check: (v) =>
					v instanceof CUI.Icon or CUI.util.isString(v) or CUI.isPlainObject(v)
				default: "fa-expand"
			icon_active:
				mandatory: true
				check: (v) =>
					v instanceof CUI.Icon or CUI.util.isString(v) or CUI.isPlainObject(v)
				default: "fa-compress"
			group:
				mandatory: false
				check: String
			tooltip:
				mandatory: true
				check: (v) =>
					v instanceof CUI.Tooltip or CUI.isPlainObject(v)
				default: CUI.Pane.defaults.button_tooltip
		)

		if CUI.util.isString(opts.icon_inactive)
			opts.icon_inactive = new CUI.Icon(class: opts.icon_inactive)

		if CUI.util.isString(opts.icon_active)
			opts.icon_active = new CUI.Icon(class: opts.icon_active)

		for key, value of {
			switch: true
			onClick: (ev, btn) =>
				paneDiv = CUI.dom.closest(btn.DOM, ".cui-pane")
				pane = CUI.dom.data(paneDiv, "element")
				pane.toggleFillScreen()
		}
			opts[key] = value

		new CUI.defaults.class.Button(opts)

CUI.Events.registerEvent
	type: ["start-fill-screen", "end-fill-screen"]
	sink: true
