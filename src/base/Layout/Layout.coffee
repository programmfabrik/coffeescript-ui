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
class CUI.Layout extends CUI.DOMElement

	#Construct a new Layout.
	#
	# @param [Object] options for layout creation
	# @option options [String] maximize the center so that it pushes top pane to top and bottom pane to the bottom of the parent element
	# @option options [Object] pane name of the pane on its options, check {Layout.initPane} for the options.
	# TODO document other options
	# TODO create a Pane Class
	constructor: (opts) ->
		super(opts)
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
					CUI.util.isPlainObject(v) or v == false
			)


	readOpts: ->
		# DEBUG
		# without absolute "help", FF and Safari perform badly, Chrome & IE (Edge) are fine
		@initDefaultPanes()
		super()

		@maximizeReadOpts()

		if @_absolute
			CUI.util.assert(@__maximize, "new "+@__cls, "opts.absolute needs opts.maximize to be set.", opts: @opts)
		@

	maximizeAddClasses: ->
		if @__maximize
			@addClass("cui-maximize")

		if @__maximize_horizontal
			@addClass("cui-maximize-horizontal")

		if @__maximize_vertical
			@addClass("cui-maximize-vertical")

		@

	maximizeReadOpts: ->
		if CUI.util.isNull(@_maximize) and
			CUI.util.isNull(@_maximize_horizontal) and
			CUI.util.isNull(@_maximize_vertical)
				@_maximize = true

		if @_maximize
			CUI.util.assert(not @_maximize_horizontal and not @_maximize_vertical, "new "+CUI.util.getObjectClass(@), "opts.maximize cannot be set together with opts.maximize_horizontal or opts.maximize_vertical", opts: @opts)
			@__maximize_horizontal = true
			@__maximize_vertical = true
		else
			if @_maximize_horizontal
				@__maximize_horizontal = true

			if @_maximize_vertical
				@__maximize_vertical = true

		if @__maximize_vertical and @__maximize_horizontal
			@__maximize = true

		@

	init: ->
		@__init()

	getTemplateMap: ->
		map = {}
		for pn in @__panes
			map[pn] = true
		map

	__init: ->
		CUI.util.assert(not(@_maximize == false and @_absolute == true), "Layout.__init", "opts.maximize == false and opts.absolute == true is not allowed.", opts: @opts)

		@__panes = @getPanes()
		@__panes.push("center")


		@__name = @getName()

		@__layout = new CUI.Template
			name: @__name
			map_prefix: @getMapPrefix()
			map: @getTemplateMap()

		@registerTemplate(@__layout)

		if @__maximize_horizontal and @__maximize_vertical
			CUI.Events.listen
				type: "content-resize"
				instance: @
				node: @DOM
				call: (ev) =>
					if CUI.dom.closest(ev.getTarget(), '.cui-absolute')
						# no stopping inside absolute layouts
						return
					ev.stopPropagation()

		@maximizeAddClasses()

		@addClass(@getMapPrefix())

		if @_absolute
			@addClass("cui-absolute")
			CUI.util.assert(CUI.dom.getAttribute(@DOM, "data-cui-absolute-container") in ["row","column"], "new CUI.Layout", "opts.absolute: template must include a cui-absolute-container attribute set to \"row\" or \"column\".")

			CUI.dom.waitForDOMInsert(node: @DOM)
			.done =>
				# console.debug "Layout[absolute] inserted", @__uniqueId
				CUI.Layout.all()

			# _call = (event) =>
			# 	console.error "Layout.setAbsolute[#{event.getDebug()}]:", @DOM[0]
			# 	# console.error "Layout[viewport-resize] received", @DOM[0]
			# 	#
			# 	event.stopPropagation()
			# 	Layout.setAbsolute(@DOM)

			# CUI.Events.listen
			# 	type: "viewport-resize"
			# 	node: @DOM
			# 	instance: @
			# 	call: _call

			# CUI.Events.listen
			# 	type: "content-resize"
			# 	node: @DOM
			# 	instance: @
			# 	call: _call

		else
			CUI.dom.removeAttribute(@DOM, "data-cui-absolute-container")
			for child in @DOM.children
				CUI.dom.removeAttribute(child, "data-cui-absolute-set")


		@__buttonbars = {}

		if @hasFlexHandles()
			has_flex_handles = true
			# console.warn(CUI.util.getObjectClass(@)+".initFlexHandles", @opts, @__layout.__uniqueId, @DOM[0])
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
					CUI.util.assert(@["_#{pn}"], "#{@__cls}.#{pn}", "Pane \"#{pn}\" not initialized.", opts: @opts)
					CUI.util.assert(not @__layout.isDestroyed(), "Layout already destroyed, cannot get pane \"#{pn}\".")
					@__layout.map[pn]

			pane = @["_#{pn}"]

			if pane
				@__initPane(pane, pn)
				if has_flex_handles and pn != "center" and not pane.flexHandle
					@__layout.getFlexHandle(pn).destroy()
			else
				# console.debug(CUI.util.getObjectClass(@), "removing uninitialized pane", pn, @)
				CUI.dom.remove(@__layout.map[pn])
				if has_flex_handles
					@__layout.getFlexHandle(pn).destroy()

		@__isInit = true

	destroy: ->
		CUI.Events.ignore(instance: @)
		super()

	getMapPrefix: ->
		undefined

	#initialive pane option
	__initPane: (options, pane_name) ->
		CUI.util.assert(pane_name, "Layout.initPane", "pane_name must be set", options: options, pane_name: pane_name)
		opts = CUI.Element.readOpts(options, "new CUI.Layout.__initPane",
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
		CUI.util.assert(false, "#{@__cls}.getPanes", "Needs implementation")

	getSupportedPanes: ->
		CUI.util.assert(false, "#{@__cls}.getSupportedPanes", "Needs implementation")

	getLayout: ->
		@__layout

	getButtonbar: (key) ->
		if not @__buttonbars[key]
			@__buttonbars[key] = new CUI.Buttonbar()
			# console.info("#{@__cls}: automatically generated Buttonbar for #{key}.")
			CUI.DOMElement::append.call(@, @__buttonbars[key], key)
		@__buttonbars[key]


	__callAutoButtonbar: (value, key) ->

		if CUI.util.isFunction(value)
			value = value(@)

		get_value = (v) ->
			if CUI.util.isPlainObject(v)
				return new CUI.defaults.class.Button(v)
			else
				return v

		value = get_value(value)

		if CUI.util.isArray(value)
			for _v in value
				v = get_value(_v)
				if v instanceof CUI.Button
					@getButtonbar(key).addButton(v)
				else
					CUI.DOMElement::append.call(@, _v, key)

		else if value instanceof CUI.Button
			@getButtonbar(key).addButton(value)
		else
			return CUI.DOMElement::append.call(@, value, key)


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

	setAbsolute: ->
		@addClass("cui-absolute")
		CUI.Layout.__all()

	unsetAbsolute: ->
		@DOM.removeAttribute("data-cui-absolute-check-value")
		@DOM.removeAttribute("data-cui-absolute-values")

		for child in CUI.dom.children(@DOM)
			CUI.dom.setStyle child,
				top: ""
				left: ""
				right: ""
				bottom: ""

		@removeClass("cui-absolute")
		@

	getName: ->
		CUI.util.assert(false, "#{@__cls}.getName", "Needs to be overwritten.")

	@setAbsolute: (layout) ->
		# console.error "Layout.setAbsolute", layout[0]
		CUI.util.assert(CUI.util.isElement(layout), "Layout.setAbsolute", "layout needs to be HTMLElement", layout: layout)

		direction = CUI.dom.getAttribute(layout, "data-cui-absolute-container")
		switch direction
			when "row"
				rect_key = "marginBoxWidth"
				rect_check_key = "marginBoxHeight"
			when "column"
				rect_key = "marginBoxHeight"
				rect_check_key = "marginBoxWidth"
			else
				CUI.util.assert(false, "Layout.setAbsolute", "cui-absolute-container is not set for .cui-absolute container or not set to row or column.", container: layout, direction: direction)

		# measure all children
		values = []
		children = CUI.dom.children(layout)

		for child, idx in children
			values[idx] = CUI.dom.getDimensions(child)[rect_key]

		abs_values = values.join(",")
		check_value = CUI.dom.getDimensions(layout)[rect_check_key]+""

		# console.debug layout, abs_values, CUI.dom.getAttribute(layout, "data-cui-absolute-values")
		# console.debug layout, check_value, CUI.dom.getAttribute(layout, "data-cui-absolute-check-value")

		if CUI.dom.getAttribute(layout, "data-cui-absolute-values") == abs_values and
			CUI.dom.getAttribute(layout, "data-cui-absolute-check-value") == check_value
				# nothing to do
				return false

		if CUI.dom.getAttribute(layout, "data-cui-absolute-check-value") != check_value
			CUI.dom.setAttribute(layout, "data-cui-absolute-check-value", check_value)

		if CUI.dom.getAttribute(layout, "data-cui-absolute-values") != abs_values
			CUI.dom.setAttribute(layout, "data-cui-absolute-values", abs_values)
			# console.debug(txt, values)

			for child, idx in children
				set = CUI.dom.getAttribute(child, "data-cui-absolute-set")
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
							CUI.util.assert(false, "Layout.setAbsolute: Unknown key #{key} in data-cui-absolute-set.")
					# console.debug idx, key, value
					css[key] = value
				CUI.dom.setStyle(child, css)

		# CUI.Events.trigger
		# 	type: "viewport-resize"
		# 	exclude_self: true
		# 	node: layout
		return true

	@__all: ->
		layouts = []
		changed = 0
		for layout, idx in CUI.dom.matchSelector(document.documentElement, ".cui-absolute")
			if CUI.Layout.setAbsolute(layout)
				changed++

		if changed > 0
			# console.info("Layout.setAbsolute[all]: changed: ", changed)
			# console.debug "triggering viewport resize"
			CUI.Events.trigger(type: "viewport-resize")
		@


	@all: ->
		CUI.scheduleCallback(call: CUI.Layout.__all)

CUI.ready ->
	CUI.Events.listen
		type: ["viewport-resize", "content-resize"]
		call: (ev, info) ->
			if info.FlexHandle
				CUI.Layout.__all()
			else
				CUI.Layout.all()
