###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# this class initializes a flex handle
class CUI.FlexHandle extends CUI.Element
	constructor: (opts) ->
		super(opts)

		@__pane = null
		children = @_element.parentNode.children
		for c, idx in children
			if CUI.dom.is(c, @_pane)
				@__pane = c
				@__pane_idx = idx

			if CUI.dom.is(c, @_element)
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

		CUI.util.assert(@__pane, "new #{@__cls}", "pane \"#{@_pane}\" not found in parent element of cui-flex-handle element.", opts: @opts, children: children)

		CUI.dom.data(@__pane, "flexHandle", @)

		CUI.dom.setAttribute(@__pane, "flex-handled-pane", @_name)

	readOpts: ->
		super()
		if @_direction in ["horizontal", "row"]
			@__direction = "row"
		else if @_direction in ["vertical", "column"]
			@__direction = "column"

		CUI.util.assert(@__direction in ["row", "column"], "new #{@__cls}", "opts.direction needs to be set", opts: @opts, element: @_element)

		if @_label
			@addLabel(@_label)
		return


	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					CUI.util.isElement(v)
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
				default: false
				check: Boolean
			open_button_icon:
				mandatory: false
				check: (v) ->
					CUI.util.isString(v) or v instanceof CUI.Icon
			label:
				check: (v) ->
					v instanceof CUI.Label or CUI.util.isPlainObject(v)
			hidden:
				check: Boolean
			direction:
				check: ["horizontal", "vertical", "row", "column"]
			manage_state:
				default: true
				check: Boolean
			state_name:
				check: String
			class:
				check: String
			onResize:
				check: Function
			maxValue:
				check: (v) ->
					return v > 0
			unit:
				default: "px"
				check: (v) -> v in ["px", "%"]

	init: ->
		if @isDestroyed()
			return

		CUI.dom.addClass(@_element, "cui-flex-handle cui-flex-handle-#{@__direction} cui-flex-handle-#{@_name}")

		if @__closed
			@close()

		if @__hidden
			@hide()

		if @_class
			CUI.dom.addClass(@_element, @_class)

		if @__direction == "row"
			axis = "x"
			@__css_value = "Width"
		else
			axis = "y"
			@__css_value = "Height"


		if not @_open_button_icon
			CUI.Events.listen
				type: "dblclick"
				node: @_element
				call: (ev) =>
					if @__size == null # CUI.util.isEmpty(@__pane[0].style[@__css_value])
						if @isClosed()
							@open()
						else if @_closable
							@close()
					else
						@resetSize()

					@storeState()
					return

			CUI.Events.listen
				type: ["click"]
				node: @_element
				call: (ev) =>
					if not @__label
						return
					if @isClosed()
						@open()
						@storeState()
					return

			CUI.Events.listen
				type: "keydown"
				node: @_element
				call: (ev) =>
					if not @__label
						return
					if not @isClosed()
						return
					if ev.getKeyboardKey() not in ["Return", "Space"]
						return

					@open()
					@storeState()
					return
		else
			@_element.classList.add("cui-flex-handle-with-button-icon")

		# console.debug @_name, cursor, axis, css_value, @__pane_idx, @__element_idx
		drag_start_size = null

		new CUI.Draggable
			element: @_element
			axis: axis
			support_touch: true
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
					dim = CUI.dom.getDimensions(pane)
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

				if @_maxValue
					data.max = @_maxValue

				drag_start_size = @__pane.style[@__css_value.toLowerCase()]

				gd.__pane_data =
					flip: flip
					axis: axis
					min: data.min
					max: data.max
					value: data.value

				gd.isFlexHandleDrag = true
				gd

			get_cursor: (gd) ->
				if gd.__pane_data.axis == "x"
					return "ew-resize"
				else
					return "ns-resize"

			dragend: (ev, gd) =>
				dragging(gd)
				# We obtain the new size from the element, because the size might have been changed by the user
				newSize = CUI.dom.getDimension(@__pane, "contentBox" + @__css_value)
				# Size is in pixels, we use the setSize method to set the size, if we are using unit "%" this will convert the size to percentage
				@__setSize(newSize)
				@storeState()

			dragstop: =>
				@__pane.style[@__css_value.toLowerCase()] = drag_start_size
				drag_start_size = null
				@__resize()

			dragging: (ev, gd) =>
				if !CUI.__ng__  || CUI.browser.ie
					return

				dragging(gd)


		dragging = (gd) =>
			new_value = gd.__pane_data.value + gd.dragDiff[gd.__pane_data.axis] * gd.__pane_data.flip
			if gd.__pane_data.min
				new_value = Math.max(gd.__pane_data.min, new_value)

			if gd.__pane_data.max
				new_value = Math.min(gd.__pane_data.max, new_value)

			@__setSize(new_value)

		if @_manage_state
			if not @_state_name
				console.warn("new CUI.FlexHandle()", "opts.state_name missing, state will not be stored.", @opts)

			@__state_name = @_state_name
			@__setState()

		@

	getElement: ->
		@_element

	__setSize: (size) ->
		if CUI.util.isNull(size)
			CUI.dom.setStyleOne(@__pane, @__css_value.toLowerCase(), "")

			if @__isAlive()
				if CUI.dom.getDimension(@__pane, "contentBox"+@__css_value) == 0
					console.error("FlexHandle.__setSize: Pane size is 0 if unset, this needs to be fixed in CSS.", @__pane)
					CUI.dom.setDimension(@__pane, "contentBox"+@__css_value, 100)

			@__pane.classList.remove("cui-is-manually-sized")
			@_element.classList.remove("cui-is-manually-sized")
			@__size = null

		# If unit is set to "%" and there is a parent container
		else if @_unit == "%" and @__pane.parentNode?
			# If the size is a number (coming from a drag event in pixels)
			if typeof size is "number"
				parentDimension = CUI.dom.getDimension(@__pane.parentNode, "contentBox" + @__css_value)
				if parentDimension > 0
					percentValue = (size / parentDimension) * 100
				else
					percentValue = size
				# Clamp the percentage between 1% and 100%
				percentValue = Math.max(1, Math.min(percentValue, 100))
				sizeStr = percentValue.toFixed(2) + "%"
			else if typeof size == "string" and size.indexOf("%") != -1
				percentValue = parseFloat(size)
				percentValue = Math.max(1, Math.min(percentValue, 100))
				sizeStr = percentValue.toFixed(2) + "%"
			else
				parentDimension = CUI.dom.getDimension(@__pane.parentNode, "contentBox" + @__css_value)
				if parentDimension > 0
					percentValue = (parseFloat(size) / parentDimension) * 100
				else
					percentValue = size
				percentValue = Math.max(1, Math.min(percentValue, 100))
				sizeStr = percentValue.toFixed(2) + "%"

			@__pane.classList.add("cui-is-manually-sized")
			@_element.classList.add("cui-is-manually-sized")
			CUI.dom.setStyleOne(@__pane, @__css_value.toLowerCase(), sizeStr)
			@__size = sizeStr

		else
			# Default behavior: use pixels
			@__pane.classList.add("cui-is-manually-sized")
			@_element.classList.add("cui-is-manually-sized")
			CUI.dom.setDimension(@__pane, "contentBox"+@__css_value, size)
			@__size = size

		@__resize()

	resetSize: ->
		@__setSize(null)
		@

	getSize: ->
		@__size

	__isAlive: ->
		if @isDestroyed() or not CUI.dom.isInDOM(@_element)
			false
		else
			true

	__resize: ->
		# console.debug "FlexHandle.__resize", @__uniqueId, @isDestroyed(), @__isInDOM, @__isAlive()

		if not @__isAlive()
			return

		@_onResize?(@, @getSize())

		# console.info "FlexHandle[#{@getName()}].resize."
		CUI.Events.trigger
			type: "viewport-resize"
			info:
				FlexHandle: true

	__getState: ->
		value = CUI.getLocalStorage(@__state_name)
		if not CUI.util.isNull(value)
			state = JSON.parse(value)
		else
			state = {}
		state

	__setState: ->
		if not @__state_name
			return

		state = @__getState()

		if not CUI.util.isUndef(state.closed) and @_closable
			if state.closed
				@close()
			else
				@open()

		if not CUI.util.isUndef(state.size)
			@__setSize(state.size)

		# console.debug "setState", state
		@


	storeState: ->
		if not @__state_name
			return

		state =
			closed: @isClosed()
			size: @getSize()

		value = JSON.stringify(state)

		CUI.setLocalStorage(@__state_name, value)
		console.info("FlexHandle.storeState: ", @__state_name, value)
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
				els = CUI.dom.findPreviousSiblings(pane)
			when "east", "south"
				els = CUI.dom.findNextSiblings(pane)

		switch direction
			when "west", "east"
				set = "width"

			when "north", "south"
				set = "height"

		if do_stretch

			# first we set all the value to explicit "px"
			# so that the transition works
			for el in els
				el.classList.add("cui-flex-handle-hide-for-stretch")
				el.classList.add("cui-flex-handle-hide-for-stretch-#{direction}")

			CUI.dom[set](@__pane, "")

			pane.classList.add("cui-flex-handle-stretched")
			pane.classList.add("cui-flex-handle-stretched-#{direction}")
			CUI.Events.trigger
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
			CUI.Events.trigger
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

		if opts instanceof CUI.Label
			@__label = opts
		else
			if @__direction == "row"
				opts.rotate_90 = true

			@__label = new CUI.defaults.class.Label(opts)

		if @_open_button_icon
			button = new CUI.Button
				icon: @_open_button_icon
				onClick: =>
					if @isClosed()
						@open()
						@storeState()
					return
			CUI.dom.append(@_element, button)

		CUI.dom.append(@_element, @__label.DOM)
		CUI.dom.addClass(@_element, "cui-flex-handle-has-label")

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

		CUI.Events.trigger
			node: @getPane()
			type: "flex-close"

		CUI.dom.setAttribute(@_element, "tabindex", 0)
		@_element.classList.add("cui-flex-handle-closed")
		CUI.dom.hideElement(@__pane)
		@__resize()
		@

	open: ->
		if @isOpen()
			return @

		CUI.Events.trigger
			node: @getPane()
			type: "flex-open"

		CUI.dom.setAttribute(@_element, "tabindex")
		@_element.classList.remove("cui-flex-handle-closed")
		CUI.dom.showElement(@__pane)
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
		if @isShown()
			return @
		@_element.classList.remove("cui-flex-handle-hidden")
		delete(@__hidden)
		@__resize()
		@

	destroy: ->
		CUI.dom.removeData(@__pane, "flexHandle")
		CUI.dom.removeAttribute(@__pane, "flex-handled-pane")
		CUI.dom.remove(@_element)
		super()


	@getStretchButton: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "FlexHandle.getPushButton",
			direction:
				check: ["west","east","north","south"]
			text:
				check: String
			flexHandle:
				check: CUI.FlexHandle
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
					fh_els = CUI.dom.closest(btn.DOM, "[flex-handled-pane]")
					CUI.util.assert(fh_els, "FlexHandle.getStretchButton", "FlexHandle not or more than one found, name: #{opts.name}.", opts: opts, flexHandles: fh_els)
					fh = CUI.dom.data(fh_els, "flexHandle")

				if fh.isStretched()
					fh.unstretch()
				else
					fh.stretch(opts.direction)
		}
			btn_opts[k] = v

		new CUI.defaults.class.Button(btn_opts)


CUI.Events.registerEvent
	type: ["flex-stretch-start", "flex-stretch-end", "flex-close", "flex-open"]
	sink: true
