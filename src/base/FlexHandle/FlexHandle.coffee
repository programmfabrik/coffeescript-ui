# this class initializes a flex handle
class FlexHandle extends Element
	constructor: (@opts={}) ->
		@addOptsFromAttr(@opts.element?.attr("cui-flex-handle"))
		super(@opts)

		@__pane = null
		children = @_element.parent().children()
		for c, idx in children
			$c = $(c)
			if $c.is(@_pane)
				@__pane = $c
				@__pane_idx = idx
			if $c.is(@_element)
				@__element_idx = idx

		@__adjacent_pane = null

		if @__element_idx > @__pane_idx
			if @__element_idx < children.length-1
				@__adjacent_pane = $(children[@__element_idx+1])
		else
			if @__element_idx > 0
				@__adjacent_pane = $(children[@__element_idx-1])

		@__closed = @_closed
		@__hidden = @_hidden
		@__stretched = null
		@__size = null

		assert(@__pane, "new #{@__cls}", "pane \"#{@_pane}\" not found in parent element of cui-flex-handle element.", opts: @opts, children: children)

		DOM.data(@__pane[0], "flexHandle", @)

		@__pane.attr("flex-handled-pane", @_name)

	readOpts: ->
		super()
		if @_direction in ["horizontal", "row"]
			@__direction = "row"
		else if @_direction in ["vertical", "column"]
			@__direction = "column"

		assert(@__direction in ["row", "column"], "new #{@__cls}", "opts.direction needs to be set", opts: @opts, element: @_element[0])

		if @_label
			@addLabel(@_label)
		return


	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					v instanceof jQuery and v.length == 1
			pane:
				mandatory: true
				check: String
			name:
				mandatory: true
				check: String
			closed:
				check: Boolean
			label:
				check: (v) ->
					v instanceof Label or $.isPlainObject(v)
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

		@_element.addClass("cui-flex-handle cui-flex-handle-#{@__direction} cui-flex-handle-#{@_name}")

		cursor = @_element.css("cursor")

		if @__closed
			@close()

		if @__hidden
			@hide()

		if @__direction == "row"
			axis = "x"
			@__css_value = "width"
		else
			axis = "y"
			@__css_value = "height"


		Events.listen
			type: "dblclick"
			node: @_element
			call: (ev) =>
				if @__size == null # isEmpty(@__pane[0].style[@__css_value])
					if @isClosed()
						@open()
					else
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
			cursor: cursor
			create: =>
				if @isClosed()
					return false

			helper_remove_always: true

			dragstart: (ev, gd) =>
				if @__pane_idx < @__element_idx
					flip = 1
				else
					flip = -1


				get_data = (pane) =>
					min = pane.cssInt("min-#{@__css_value}", false)
					if min < 10
						min = 10

					min: min
					max: pane.cssInt("max-#{@__css_value}", false)
					value: pane[@__css_value]()

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

			set_helper_pos: (gd, helper_pos) ->
				data = gd.__pane_data
				if data.axis == "x"
					key = "left"
				else
					key = "top"

				new_value = data.value + helper_pos.dragDiff[data.axis] * data.flip
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
			@__pane[@__css_value]("")
			if @__pane[@__css_value]() == 0
				CUI.error("FlexHandle.__setSize: Pane size is 0 if unset, this needs to be fixed in CSS.", @__pane[0])
				@__pane[@__css_value](100)

			@__size = null
		else
			@__pane[@__css_value](size)
			@__size = @__pane[@__css_value]()

		@storeState()
		@__resize()

	resetSize: ->
		@__setSize(null)
		@

	__getSize: ->
		@__size

	__isAlive: ->
		if @isDestroyed() or not CUI.DOM.isInDOM(@_element[0])
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

		add_cls(@__pane[0])
		for parent, idx in @__pane.parents()
			add_cls(parent)

		@__state_name = "CUI-FlexHandle-"+cls_for_unique_name.join("/")
		@_element.prop("title", @__unique_name)

	__getState: () ->
		value = window.localStorage[@__state_name]
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

		window.localStorage[@__state_name] = value

		# CUI.debug "stored state", @__state_name, value
		@

	isStretched: ->
		@__stretched

	stretch: (direction, do_stretch = true) ->

		if do_stretch
			if @isStretched()  == direction
				return
			else
				@unstretch()

		switch direction
			when "west", "north"
				els = @getPane().prevAll()
			when "east", "south"
				els = @getPane().nextAll()

		switch direction
			when "west", "east"
				style = "maxWidth"
				set = "width"
			when "north", "south"
				style = "maxHeight"
				set = "height"

		Events.wait
			type: "transitionend"
			maxWait: 0
			node: els
		.always =>
			if do_stretch
				@getPane().addClass("cui-flex-handle-stretched cui-flex-handle-stretched-#{direction}")
				Events.trigger
					node: @getPane()
					type: "flex-stretch-start"
			else
				@getPane().removeClass("cui-flex-handle-stretched cui-flex-handle-stretched-#{direction}")
				Events.trigger
					node: @getPane()
					type: "flex-stretch-end"
				@__resize()

		if do_stretch
			for el in els
				$el = $(el)
				$el.css(style, $el[set]())
			els.addClass("cui-flex-handle-hide-for-stretch cui-flex-handle-hide-for-stretch-#{direction}")
			els.css(style, 0)
			@getPane().css(set,"")
			@__stretched = direction
		else
			els.removeClass("cui-flex-handle-hide-for-stretch cui-flex-handle-hide-for-stretch-#{direction}")
			els.css(style, "")
			@__stretched = null
			if @__size
				@getPane().css(set,@__size)
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
			@__label.setRotate90()
		else
			opts.rotate_90 = true
			@__label = new Label(opts)
		@_element.append(@__label.DOM)
		@_element.addClass("cui-flex-handle-has-label")

	getName: ->
		@_name


	getHandle: ->
		@_element

	getPane: ->
		@__pane

	isShown: ->
		not @isHidden()

	isHidden: ->
		@_element.hasClass("cui-flex-handle-hidden")

	isClosed: ->
		@_element.hasClass("cui-flex-handle-closed")

	isOpen: ->
		not @isClosed()

	close: ->
		if @isClosed()
			return @

		Events.trigger
			node: @getPane()
			type: "flex-close"

		@_element.addClass("cui-flex-handle-closed")
		@__pane.css("display", "none")
		@__resize()
		@

	open: ->
		# CUI.debug "FlexHandle.show", @__uniqueId, @isOpen()
		if @isOpen()
			return @
		@_element.removeClass("cui-flex-handle-closed")
		@__pane.css("display", "")
		delete(@__closed)
		@__resize()
		@

	hide: ->
		if @isHidden()
			return @
		@_element.addClass("cui-flex-handle-hidden")
		@__resize()
		@

	show: ->
		# CUI.debug "FlexHandle.show", @__uniqueId, @isShown()
		if @isShown()
			return @
		@_element.removeClass("cui-flex-handle-hidden")
		delete(@__hidden)
		@__resize()
		@

	destroy: ->
		@__pane.removeData("flexHandle")
		@__pane.removeAttr("flex-handled-pane")
		@_element.remove()
		super()


	@getStretchButton: (_opts={}) ->
		opts = Element.readOpts _opts, "FlexHandle.getPushButton",
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

