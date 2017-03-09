###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# {Layout} is used for all layout related stuff, like {HorizontalLayout},
# {VerticalLayout}, {BorderLayout}, {Toolbar}, {Pane}, etc.
#
# It features an automatic {Buttonbar} generation for all panes (see {Layout#append})
class CUI.Layout extends CUI.DOM

	#Construct a new Layout.
	#
	# @param [Object] options for layout creation
	# @option options [String] maximize the center so that it pushes top pane to top and bottom pane to the bottom of the parent element
	# @option options [Object] pane name of the pane on its options, check {Layout.initPane} for the options.
	# TODO document other options
	# TODO create a Pane Class
	constructor: (@opts={}) ->
		super(@opts)
		@__isInit = false
		@init()

	initOpts: ->
		super()
		@addOpts
			absolute:
				check: Boolean
			maximize:
				check: Boolean
			maximize_horizontal:
				check: Boolean
			maximize_vertical:
				check: Boolean
			auto_buttonbar:
				default: true
				mandatory: true
				check: Boolean
			center:
				default: {}
				check: "PlainObject"

		for pn in @getSupportedPanes()
			@addOpt(pn,
				check: (v) ->
					CUI.isPlainObject(v) or v == false
			)

	readOpts: ->
		# DEBUG
		# without absolute "help", FF and Safari perform badly, Chrome & IE (Edge) are fine
		@initDefaultPanes()
		super()

		if isNull(@_maximize) and
			isNull(@_maximize_horizontal) and
			isNull(@_maximize_vertical)
				@_maximize = true

		if @_maximize
			assert(not @_maximize_horizontal and not @_maximize_vertical, "new Layout", "opts.maximize cannot be set together with opts.maximize_horizontal or opts.maximize_vertical", opts: @opts)
			@__maximize_horizontal = true
			@__maximize_vertical = true
		else
			if @_maximize_horizontal
				@__maximize_horizontal = true

			if @_maximize_vertical
				@__maximize_vertical = true

		if @__maximize_vertical and @__maximize_horizontal
			@__maximize = true

		if @_absolute
			assert(@__maximize, "new "+@__cls, "opts.absolute needs opts.maximize to be set.", opts: @opts)
		@


	init: ->
		@__init()

	getTemplateMap: ->
		map = {}
		for pn in @__panes
			map[pn] = true
		map

	__init: ->
		assert(not(@_maximize == false and @_absolute == true), "Layout.__init", "opts.maximize == false and opts.absolute == true is not allowed.", opts: @opts)

		@__panes = @getPanes()
		@__panes.push("center")


		@__name = @getName()

		@__layout = new Template
			name: @__name
			map_prefix: @getMapPrefix()
			map: @getTemplateMap()

		@registerTemplate(@__layout)

		if @__maximize
			@addClass("cui-maximize")

		if @__maximize_horizontal
			@addClass("cui-maximize-horizontal")

		if @__maximize_vertical
			@addClass("cui-maximize-vertical")

		@addClass(@getMapPrefix())

		if @_absolute
			@addClass("cui-absolute")
			assert(CUI.DOM.getAttribute(@DOM, "data-cui-absolute-container") in ["row","column"], "new Layout", "opts.absolute: template must include a cui-absolute-container attribute set to \"row\" or \"column\".")

			DOM.waitForDOMInsert(node: @DOM)
			.done =>
				# CUI.debug "Layout[absolute] inserted", @__uniqueId
				Layout.all()

			# _call = (event) =>
			# 	CUI.error "Layout.setAbsolute[#{event.getDebug()}]:", @DOM[0]
			# 	# CUI.error "Layout[viewport-resize] received", @DOM[0]
			# 	#
			# 	event.stopPropagation()
			# 	Layout.setAbsolute(@DOM)

			# Events.listen
			# 	type: "viewport-resize"
			# 	node: @DOM
			# 	instance: @
			# 	call: _call

			# Events.listen
			# 	type: "content-resize"
			# 	node: @DOM
			# 	instance: @
			# 	call: _call


		@__buttonbars = {}

		if @hasFlexHandles()
			has_flex_handles = true
			# CUI.warn(getObjectClass(@)+".initFlexHandles", @opts, @__layout.__uniqueId, @DOM[0])
			pane_opts = {}
			for pn in @__panes
				pane = @["_#{pn}"]
				if pane?.flexHandle
					pane_opts[pn] = pane.flexHandle
			@__layout.initFlexHandles(pane_opts)
		else
			has_flex_handles = false

		# every pane gets a method "<pane>: ->" to retrieve
		# the DOM element from the template

		for pn in @__panes
			do (pn) =>
				@[pn] = =>
					assert(@["_#{pn}"], "#{@__cls}.#{pn}", "Pane \"#{pn}\" not initialized.", opts: @opts)
					assert(not @__layout.isDestroyed(), "Layout already destroyed, cannot get pane \"#{pn}\".")
					@__layout.map[pn]

			pane = @["_#{pn}"]

			if pane
				@__initPane(pane, pn)
				if has_flex_handles and pn != "center" and not pane.flexHandle
					@__layout.getFlexHandle(pn).destroy()
			else
				# CUI.debug(getObjectClass(@), "removing uninitialized pane", pn, @)
				@__layout.map[pn].remove()
				if has_flex_handles
					@__layout.getFlexHandle(pn).destroy()

		@__isInit = true

	destroy: ->
		Events.ignore(instance: @)
		super()

	getMapPrefix: ->
		undefined

	#initialive pane option
	__initPane: (options, pane_name) ->
		assert(pane_name, "Layout.initPane", "pane_name must be set", options: options, pane_name: pane_name)
		opts = CUI.Element.readOpts(options, "new Layout.__initPane",
			class:
				check: String
			content: {}
			flexHandle: {}
		)

		@append(opts.content, pane_name)

		if opts.class
			@__layout.addClass(opts.class, pane_name)


	# returns true if this Layout has at least one
	# flexHandle
	hasFlexHandles: ->
		true

	# init default panes, so that they are in markup
	initDefaultPanes: ->
		for pn in @getPanes()
			if not @opts.hasOwnProperty(pn)
				@opts[pn] = {}
		@

	getPanes: ->
		assert(false, "#{@__cls}.getPanes", "Needs implementation")

	getSupportedPanes: ->
		assert(false, "#{@__cls}.getSupportedPanes", "Needs implementation")

	getLayout: ->
		@__layout

	getButtonbar: (key) ->
		if not @__buttonbars[key]
			@__buttonbars[key] = new Buttonbar()
			# CUI.info("#{@__cls}: automatically generated Buttonbar for #{key}.")
			DOM::append.call(@, @__buttonbars[key], key)
		@__buttonbars[key]


	__callAutoButtonbar: (value, key) ->

		if CUI.isFunction(value)
			value = value(@)

		get_value = (v) ->
			if CUI.isPlainObject(v)
				return new CUI.defaults.class.Button(v)
			else
				return v

		value = get_value(value)

		if CUI.isArray(value)
			for _v in value
				v = get_value(_v)
				if v instanceof Button
					@getButtonbar(key).addButton(v)
				else
					DOM::append.call(@, _v, key)

		else if value instanceof Button
			@getButtonbar(key).addButton(value)
		else
			return DOM::append.call(@, value, key)


	# @param [jQuery, Function, Array, ...] value the value to append to the layer
	# @param [String] key the name of the pane
	# @param [Boolean] auto_buttonbar if set to true (default), automatically generate a {Buttonbar} for Buttons passed directly, in an Array or thru a Function
	#
	# @return [jQuery] the DOM node (created and) appended
	append: (value, key, auto_buttonbar = @_auto_buttonbar) ->
		if auto_buttonbar
			return @__callAutoButtonbar(value, key)
		else
			return super(value, key)

	replace: (value, key, auto_buttonbar = @_auto_buttonbar) ->
		if auto_buttonbar
			delete(@__buttonbars[key])
			@empty(key)
			return @__callAutoButtonbar(value, key)
		else
			return super(value, key)


	getName: ->
		assert(false, "#{@__cls}.getName", "Needs to be overwritten.")

	@setAbsolute: (layout) ->
		# CUI.error "Layout.setAbsolute", layout[0]
		assert(isElement(layout), "Layout.setAbsolute", "layout needs to be HTMLElement", layout: layout)

		direction = CUI.DOM.getAttribute(layout, "data-cui-absolute-container")
		switch direction
			when "row"
				rect_key = "marginBoxWidth"
				rect_check_key = "marginBoxHeight"
			when "column"
				rect_key = "marginBoxHeight"
				rect_check_key = "marginBoxWidth"
			else
				assert(false, "Layout.setAbsolute", "cui-absolute-container is not set for .cui-absolute container or not set to row or column.", container: layout, direction: direction)

		# measure all children
		values = []
		children = DOM.children(layout)

		for child, idx in children
			values[idx] = DOM.getDimensions(child)[rect_key]

		abs_values = values.join(",")
		check_value = DOM.getDimensions(layout)[rect_check_key]+""

		# console.error "abs_value:", CUI.DOM.getAttribute(layout, "cui-absolute-values"), abs_values, CUI.DOM.getAttribute(layout, "cui-absolute-check-value"), check_value

		if CUI.DOM.getAttribute(layout, "data-cui-absolute-values") == abs_values and
			CUI.DOM.getAttribute(layout, "data-cui-absolute-check-value") == check_value
				# nothing to do
				return false

		# CUI.debug layout.attr("cui-absolute-values"), abs_values
		# CUI.debug layout.attr("cui-absolute-check-value"), check_value

		if CUI.DOM.getAttribute(layout, "data-cui-absolute-check-value") != check_value
			CUI.DOM.setAttribute(layout, "data-cui-absolute-check-value", check_value)

		if CUI.DOM.getAttribute(layout, "data-cui-absolute-values") != abs_values
			CUI.DOM.setAttribute(layout, "data-cui-absolute-values", abs_values)
			# CUI.debug(txt, values)

			for child, idx in children
				set = CUI.DOM.getAttribute(child, "data-cui-absolute-set")
				if not set
					continue

				css = {}
				for key in set.split(",")
					switch key
						when "left", "top"
							# this is left hand
							if idx > 0
								value = values.slice(0, idx).reduce((a,b) -> a+b)
							else
								value = 0
						when "right", "bottom"
							if idx + 1 < values.length
								value = values.slice(idx+1).reduce((a,b) -> a+b)
							else
								value = 0
						else
							assert(false, "Layout.setAbsolute: Unknown key #{key} in data-cui-absolute-set.")
					# CUI.debug idx, key, value
					css[key] = value
				DOM.setStyle(child, css)

		# Events.trigger
		# 	type: "viewport-resize"
		# 	exclude_self: true
		# 	node: layout
		return true

	@__all: ->
		layouts = []
		changed = 0
		for layout, idx in DOM.matchSelector(document.documentElement, ".cui-absolute")
			if Layout.setAbsolute(layout)
				changed++

		if changed > 0
			# CUI.info("Layout.setAbsolute[all]: changed: ", changed)
			# console.debug "triggering viewport resize"
			Events.trigger(type: "viewport-resize")
		@


	@all: ->
		CUI.scheduleCallback(call: Layout.__all)

Layout = CUI.Layout


CUI.ready ->
	Events.listen
		type: ["viewport-resize", "content-resize"]
		call: (ev, info) ->
			if info.FlexHandle
				Layout.__all()
			else
				Layout.all()
