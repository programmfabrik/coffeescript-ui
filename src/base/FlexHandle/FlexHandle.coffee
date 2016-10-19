# this class initializes a flex handle
class FlexHandle extends CUI.Element
	constructor: (@opts={}) ->
		@addOptsFromAttr(CUI.DOM.getAttribute(@opts.element, "cui-flex-handle"))
		super(@opts)

		@__pane = null
		children = @_element.parentNode.children
		for c, idx in children
			if CUI.DOM.is(c, @_pane)
				@__pane = c
				@__pane_idx = idx

			if CUI.DOM.is(c, @_element)
				@__element_idx = idx

		@__adjacent_pane = null

		if @__element_idx > @__pane_idx
			if @__element_idx < children.length-1
				@__adjacent_pane = children[@__element_idx+1]
		else
			if @__element_idx > 0
				@__adjacent_pane = children[@__element_idx-1]

		@__closed = @_closed
		@__hidden = @_hidden
		@__stretched = null
		@__size = null

		assert(@__pane, "new #{@__cls}", "pane \"#{@_pane}\" not found in parent element of cui-flex-handle element.", opts: @opts, children: children)

		CUI.DOM.data(@__pane, "flexHandle", @)

		CUI.DOM.setAttribute(@__pane, "flex-handled-pane", @_name)

	readOpts: ->
		super()
		if @_direction in ["horizontal", "row"]
			@__direction = "row"
		else if @_direction in ["vertical", "column"]
			@__direction = "column"

		assert(@__direction in ["row", "column"], "new #{@__cls}", "opts.direction needs to be set", opts: @opts, element: @_element[0])
		@setClosable(@_closable)

		if @_label
			@addLabel(@_label)
		return


	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					isElement(v)
			pane:
				mandatory: true
				check: String
			name:
				mandatory: true
				check: String
			closed:
				check: Boolean
			closable:
				mandatory: true
				default: true
				check: Boolean
			label:
				check: (v) ->
					v instanceof Label or CUI.isPlainObject(v)
			hidden:
				check: Boolean
			direction:
				check: ["horizontal", "vertical", "row", "column"]
			manage_state:
				default: true
				check: Boolean

	init: ->
		if @isDestroyed()
			return

		DOM.addClass(@_element, "cui-flex-handle cui-flex-handle-#{@__direction} cui-flex-handle-#{@_name}")

		if @__closed
			@close()

		if @__hidden
			@hide()

		if @__direction == "row"
			axis = "x"
			@__css_value = "Width"
		else
			axis = "y"
			@__css_value = "Height"


		Events.listen
			type: "dblclick"
			node: @_element
			call: (ev) =>
				if @__size == null # isEmpty(@__pane[0].style[@__css_value])
					if @isClosed()
						@open()
					else if @getClosable()
						@close()
				else
					@resetSize()

				@storeState()
				return

		Events.listen
			type: "click"
			node: @_element
			call: (ev) =>
				if not @__label
					return
				if @isClosed()
					@open()
					@storeState()
				return


		# CUI.debug @_name, cursor, axis, css_value, @__pane_idx, @__element_idx

		new Draggable
			element: @_element
			axis: axis
			create: =>
				if @isClosed()
					return false

			# helper_remove_always: true

			dragstart: (ev, gd) =>
				if @__pane_idx < @__element_idx
					flip = 1
				else
					flip = -1

				get_data = (pane) =>
					dim = DOM.getDimensions(pane)
					min = dim["min"+@__css_value]
					if min < 10
						min = 10

					min: min
					max: dim["max"+@__css_value]
					value: dim["contentBox"+@__css_value]

				data = get_data(@__pane)

				if @__adjacent_pane
					adj_data = get_data(@__adjacent_pane)
					max_diff = adj_data.value - adj_data.min # this is the maximum change for the adj value
					data.max = Math.max(0, data.value+max_diff)

				gd.__pane_data =
					flip: flip
					axis: axis
					min: data.min
					max: data.max
					value: data.value

				gd.isFlexHandleDrag = true
				gd

			helper_set_pos: (gd, helper_pos) ->
				data = gd.__pane_data
				if data.axis == "x"
					key = "left"
				else
					key = "top"

				new_value = data.value + gd.dragDiff[data.axis] * data.flip
				if new_value < data.min
					new_value = data.min
				else if new_value > data.max
					new_value = data.max

				helper_pos[key] = (new_value - data.value) * data.flip + helper_pos.start[key]

				return

			dragend: (ev, gd) =>
				if ev.getType() != "mouseup"
					return

				new_value = gd.__pane_data.value + gd.dragDiff[gd.__pane_data.axis] * gd.__pane_data.flip
				if gd.__pane_data.min
					new_value = Math.max(gd.__pane_data.min, new_value)

				if gd.__pane_data.max
					new_value = Math.min(gd.__pane_data.max, new_value)

				#CUI.debug "dragend", @__css_value, diff, @__pane_data, new_value
				@__setSize(new_value)


		DOM.waitForDOMInsert(node: @_element)
		.done =>
			@__initState()
			@__setState()

			Events.listen
				type: "content-resize"
				node: @_element
				call: (ev) =>
					# CUI.info("FlexHandle stoped content-resize", @_element[0])
					ev.stopPropagation()
		@

	__setSize: (size) ->
		if isNull(size)
			DOM.setStyleOne(@__pane, @__css_value.toLowerCase(), "")
			if DOM.getDimension(@__pane, "contentBox"+@__css_value) == 0
				CUI.error("FlexHandle.__setSize: Pane size is 0 if unset, this needs to be fixed in CSS.", @__pane[0])
				DOM.setDimension(@__pane, "contentBox"+@__css_value, 100)

			@_element.classList.remove("cui-flex-handle-manual-size")
			@__size = null
		else
			console.debug "DOM set dimension", size, @__css_value, @__pane
			@_element.classList.add("cui-flex-handle-manual-size")
			DOM.setDimension(@__pane, "contentBox"+@__css_value, size)
			@__size = DOM.getDimension(@__pane, "contentBox"+@__css_value)

		@storeState()
		@__resize()

	setClosable: (@__closable) ->

	getClosable: ->
		!!@__closable

	resetSize: ->
		@__setSize(null)
		@

	__getSize: ->
		@__size

	__isAlive: ->
		if @isDestroyed() or not CUI.DOM.isInDOM(@_element)
			false
		else
			true

	__resize: ->
		# CUI.debug "FlexHandle.__resize", @__uniqueId, @isDestroyed(), @__isInDOM, @__isAlive()

		if not @__isAlive()
			return

		# CUI.info "FlexHandle[#{@getName()}].resize."
		Events.trigger
			type: "viewport-resize"
			info:
				FlexHandle: true

		# Events.trigger
		# 	type: "viewport-resize"
		# 	node: @_element.parent()


	__initState: ->
		if not @_manage_state
			return

		# add non cui class names to
		# the list to create a unique
		# name to store state in cookie
		cls_for_unique_name = [@_name]

		add_cls = (el) ->
			use_cls = []
			for cls in el.classList
				if cls.match(/^(ez-|cui-)/)
					continue
				use_cls.push(cls)
			cls_for_unique_name.push("."+use_cls.join("."))

		add_cls(@__pane)
		for parent, idx in DOM.parents(@__pane)
			add_cls(parent)

		@__state_name = "CUI-FlexHandle-"+cls_for_unique_name.join("/")
		DOM.setAttribute(@_element, "title", @__unique_name)

	__getState: () ->
		value = CUI.getLocalStorage(@__state_name)
		if not isNull(value)
			state = JSON.parse(value)
		else
			state = {}
		state

	__setState: ->
		if not @_manage_state
			return

		state = @__getState()

		if not isUndef(state.closed)
			if state.closed
				@close()
			else
				@open()

		if not isUndef(state.size)
			@__setSize(state.size)

		# CUI.debug "setState", state
		@


	storeState: ->
		if not @_manage_state
			return

		state =
			closed: @isClosed()
			size: @__getSize()

		value = JSON.stringify(state)

		CUI.setLocalStorage(@__state_name, value)
		# CUI.debug "stored state", @__state_name, value
		@

	isStretched: ->
		@__stretched

	stretch: (direction, do_stretch = true) ->

		if do_stretch
			if @isStretched() == direction
				return
			else
				@unstretch()

		pane = @getPane()

		switch direction
			when "west", "north"
				els = DOM.findPreviousSiblings(pane)
			when "east", "south"
				els = DOM.findNextSiblings(pane)

		switch direction
			when "west", "east"
				set = "width"

			when "north", "south"
				set = "height"

		if do_stretch

			# first we set all the value to explicit "px"
			# so that the transition works
			#
			for el in els
				el.classList.add("cui-flex-handle-hide-for-stretch")
				el.classList.add("cui-flex-handle-hide-for-stretch-#{direction}")

			@__pane[set]("")

			pane.classList.add("cui-flex-handle-stretched")
			pane.classList.add("cui-flex-handle-stretched-#{direction}")
			Events.trigger
				node: pane
				type: "flex-stretch-start"

			@__stretched = direction
		else
			for el in els
				el.classList.remove("cui-flex-handle-hide-for-stretch")
				el.classList.remove("cui-flex-handle-hide-for-stretch-#{direction}")

			@__stretched = null
			if @__size
				@__pane[set](@__size)

			pane.classList.remove("cui-flex-handle-stretched")
			pane.classList.remove("cui-flex-handle-stretched-#{direction}")
			Events.trigger
				node: pane
				type: "flex-stretch-end"
			@__resize()

		@

	unstretch: ->
		if not @isStretched()
			return
		@stretch(@__stretched, false)

	getLabel: ->
		if not @__isAlive()
			return null

		@__label

	addLabel: (opts={}) ->

		if opts instanceof Label
			@__label = opts
		else
			if @__direction == "row"
				opts.rotate_90 = true

			@__label = new Label(opts)
		DOM.append(@_element, @__label.DOM)
		DOM.addClass(@_element, "cui-flex-handle-has-label")

	getName: ->
		@_name


	getHandle: ->
		@_element

	getPane: ->
		@__pane

	isShown: ->
		not @isHidden()

	isHidden: ->
		@_element.classList.contains("cui-flex-handle-hidden")

	isClosed: ->
		@_element.classList.contains("cui-flex-handle-closed")

	isOpen: ->
		not @isClosed()

	close: ->
		if @isClosed()
			return @

		Events.trigger
			node: @getPane()
			type: "flex-close"

		@_element.classList.add("cui-flex-handle-closed")
		@__pane.css("display", "none")
		@__resize()
		@

	open: ->
		# CUI.debug "FlexHandle.show", @__uniqueId, @isOpen()
		if @isOpen()
			return @
		@_element.classList.remove("cui-flex-handle-closed")
		@__pane.css("display", "")
		delete(@__closed)
		@__resize()
		@

	hide: ->
		if @isHidden()
			return @
		@_element.classList.add("cui-flex-handle-hidden")
		@__resize()
		@

	show: ->
		# CUI.debug "FlexHandle.show", @__uniqueId, @isShown()
		if @isShown()
			return @
		@_element.classList.remove("cui-flex-handle-hidden")
		delete(@__hidden)
		@__resize()
		@

	destroy: ->
		DOM.removeData(@__pane, "flexHandle")
		DOM.removeAttribute(@__pane, "flex-handled-pane")
		DOM.remove(@_element)
		super()


	@getStretchButton: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "FlexHandle.getPushButton",
			direction:
				check: ["west","east","north","south"]
			text:
				check: String
			flexHandle:
				check: FlexHandle
			button:
				default: {}

		activedir =
			west: "east"
			east: "west"
			north: "south"
			south: "north"

		btn_opts = opts.button

		for k, v of {
			icon_active: activedir[opts.direction]
			icon_inactive: opts.direction
			class: "cui-pane-stretch-button"
			text: opts.text
			switch: true
			onClick: (ev, btn) =>

				if opts.flexHandle
					fh = opts.flexHandle
				else
					fh_els = btn.DOM.closest("[flex-handled-pane]")
					assert(fh_els.length == 1, "FlexHandle.getStretchButton", "FlexHandle not or more than one found, name: #{opts.name}.", opts: opts, flexHandles: fh_els)
					fh = DOM.data(fh_els[0], "flexHandle")

				if fh.isStretched()
					fh.unstretch()
				else
					fh.stretch(opts.direction)
		}
			btn_opts[k] = v

		new CUI.defaults.class.Button(btn_opts)


CUI.Events.registerEvent
	type: ["flex-stretch-start", "flex-stretch-end", "flex-close"]
	sink: true

