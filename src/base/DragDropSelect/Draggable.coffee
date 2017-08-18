###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

globalDrag = null

class CUI.Draggable extends CUI.DragDropSelect
	@cls = "draggable"

	initOpts: ->
		super()
		@addOpts
			dragClass:
				default: "cui-dragging"
				check: String

			helper:
				default: "clone"
				check: (v) ->
					v == "clone" or isElement(v) or CUI.isFunction(v) or null

			helper_contain_element:
				check: (v) ->
					isElement(v)

			helper_set_pos:
				check: Function

			get_cursor:
				check: Function

			support_touch:
				check: Boolean

			dragend:
				check: Function

			dragstop:
				check: Function

			dragstart:
				check: Function

			dragging:
				check: Function

			create:
				default: -> true
				check: Function

			axis:
				check: ["x", "y"]

			# helper_remove_always:
			# 	check: Boolean

			# helper_parent:
			# 	default: "document"
			# 	check: ["document", "parent"]

			threshold:
				default: 2
				check: (v) ->
					v >= 0

			# ms:
			# 	default: 0
			# 	check: (v) ->
			# 		# must be multiple of MouseIsDownListener.interval_ms or 0
			# 		v % CUI.MouseIsDownListener.interval_ms == 0

			selector:
				check: (v) =>
					isString(v) or CUI.isFunction(v)

	readOpts: ->
		super()
		@__autoRepeatTimeout = null

		if @supportTouch()
			@__event_types =
				start: ["mousedown", "touchstart"]
				end: ["mouseup", "touchend"]
				move: ["mousemove", "touchmove"]
		else
			@__event_types =
				start: ["mousedown"]
				end: ["mouseup"]
				move: ["mousemove"]
		@

	getClass: ->
		if not @_selector
			"cui-draggable "+super()
		else
			super()

	supportTouch: ->
		!!@_support_touch

	__killTimeout: ->
		if @__autoRepeatTimeout
			CUI.clearTimeout(@__autoRepeatTimeout)
			@__autoRepeatTimeout = null
		@

	__cleanup: ->

		@__killTimeout()
		if @__ref
			Events.ignore(instance: @__ref)
			@__ref = null

		if globalDrag?.instance == @
			globalDrag = null
		return

	destroy: ->
		super()
		CUI.DOM.remove(globalDrag?.helperNode)
		@__cleanup()
		@

	init: ->
		# CUI.debug "Draggable", @options.selector
		assert(not @_helper_contain_element or CUI.DOM.closest(@_element, @_helper_contain_element), "new Draggable", "opts.helper_contain_element needs to be parent of opts.element", opts: @opts)

		DOM.addClass(@element, "no-user-select")

		Events.listen
			type: @__event_types.start
			node: @element
			# capture: true
			instance: @
			selector: @_selector
			call: (ev) =>
				if ev.getButton() > 0 and ev.getType() == "mousedown"
					# ignore if not the main button
					return

				if window.globalDrag
					# ignore if dragging is in progress
					return

				# console.debug getObjectClass(@), "[mousedown]", ev.getUniqueId(), @element

				# hint possible click event listeners like Sidebar to
				# not execute the click anymore...
				#
				position = elementGetPosition(getCoordinatesFromEvent(ev), $(ev.getTarget()))
				dim = DOM.getDimensions(ev.getTarget())

				if dim.clientWidthScaled > 0 and position.left - dim.scrollLeftScaled > dim.clientWidthScaled
					console.warn("Mousedown on a vertical scrollbar, not starting drag.")
					return

				if dim.clientHeightScaled > 0 and position.top - dim.scrollTopScaled > dim.clientHeightScaled
					console.warn("Mousedown on a horizontal scrollbar, not starting drag.")
					return

				target = ev.getCurrentTarget()
				target_dim = DOM.getDimensions(target)
				if not DOM.isInDOM(target) or target_dim.clientWidth == 0 or target_dim.clientHeight == 0
					return

				if CUI.DOM.closest(ev.getTarget(), "input,textarea,select")
					return

				$target = $(target)

				# console.debug "attempting to start drag", ev, $target
				@init_drag(ev, $target)
				return

	init_drag: (ev, $target) ->

		overwrite_options = {}
		globalDrag = @_create?(ev, overwrite_options, $target)

		# ev.getMousedownEvent?().preventDefault()

		if globalDrag == false
			# CUI.debug("not creating drag handle, opts.create returned 'false'.", ev, @)
			return

		# ev.preventDefault()

		for k, v of overwrite_options
			@["_#{k}"] = v

		if isNull(globalDrag) or globalDrag == true
			globalDrag = {}

		assert(CUI.isPlainObject(globalDrag), "CUI.Draggable.init_drag", "returned data must be a plain object", data: globalDrag)
		point = getCoordinatesFromEvent(ev)
		position = elementGetPosition(point, $target)

		init =
			$source: $target
			startEvent: ev
			startCoordinates: point
			instance: @
			startScroll:
				top: $target[0].scrollTop
				left: $target[0].scrollLeft
			start: position # offset to the $target
			threshold: @_threshold

		# CUI.debug "drag drop init", init
		for k, v of init
			window.globalDrag[k] = v

		# CUI.debug "starting drag...", globalDrag

		ev.stopPropagation()
		# ev.preventDefault()

		@before_drag(ev, $target)

		@__ref = new CUI.Dummy() # instance to easily remove events

		dragover_count = 0

		moveEvent = null

		dragover_scroll = =>

			# during a dragover scroll, the original target
			# might be not available any more, we need to recalculate it
			pointTarget = moveEvent.getPointTarget() or moveEvent.getTarget()

			Events.trigger
				type: "dragover-scroll"
				node: pointTarget
				count: dragover_count
				originalEvent: moveEvent

			dragover_count = dragover_count + 1

			@__killTimeout()

			@__autoRepeatTimeout = CUI.setTimeout
				ms: 100
				track: false
				call: dragover_scroll

		Events.listen
			node: document
			type: @__event_types.move
			instance: @__ref
			call: (ev) =>
				if not globalDrag
					return

				# this prevents chrome from focussing element while
				# we drag
				ev.preventDefault()

				if CUI.browser.firefox
					# ok, in firefox the target of the mousemove
					# event is WRONG while dragging. we need to overwrite
					# this with elementFromPoint, true story :(
					pointTarget = ev.getPointTarget()
				else
					pointTarget = ev.getTarget()

				$target = $(pointTarget)

				if globalDrag.ended
					return

				coordinates = getCoordinatesFromEvent(ev)

				diff =
					x: coordinates.pageX - globalDrag.startCoordinates.pageX
					y: coordinates.pageY - globalDrag.startCoordinates.pageY
					eventPoint: coordinates

				switch @get_axis()
					when "x"
						diff.y = 0
					when "y"
						diff.x = 0

				diff.bare_x = diff.x
				diff.bare_y = diff.y

				diff.x += globalDrag.$source.scrollLeft - globalDrag.startScroll.left
				diff.y += globalDrag.$source.scrollTop - globalDrag.startScroll.top

				if Math.abs(diff.x) >= globalDrag.threshold or
					Math.abs(diff.y) >= globalDrag.threshold or
					globalDrag.dragStarted

						globalDrag.dragDiff = diff

						if not globalDrag.dragStarted
							globalDrag.startEvent.preventDefault()

							@__startDrag(ev, $target, diff)

							if @_get_cursor
								document.body.setAttribute("data-cursor", @_get_cursor(globalDrag))
							else
								document.body.setAttribute("data-cursor", @getCursor())

						moveEvent = ev
						dragover_scroll()

						@do_drag(ev, $target, diff)
						@_dragging?(ev, window.globalDrag, diff)
				return

		end_drag = (ev, stop = false) =>

			start_target = globalDrag.$source
			start_target_parents = CUI.DOM.parents(start_target)

			globalDrag.ended = true

			document.body.removeAttribute("data-cursor")

			if stop
				globalDrag.stopped = true
				@stop_drag(ev)
				@_dragstop?(ev, globalDrag, @)
			else
				@end_drag(ev)
				@_dragend?(ev, globalDrag, @)

			if @isDestroyed()
				# this can happen if any of the
				# callbacks cleanup / reload
				return

			noClickKill = globalDrag.noClickKill

			@__cleanup()

			if noClickKill
				return

			has_same_parents = =>
				parents_now = CUI.DOM.parents(start_target)
				for p, idx in start_target_parents
					if parents_now[idx] != p
						return false
				return true

			if not has_same_parents or not CUI.DOM.isInDOM(ev.getTarget())
				return

			Events.listen
				type: "click"
				capture: true
				only_once: true
				node: window
				call: (ev) ->
					# console.error "Killing click after drag", ev.getTarget()
					return ev.stop()

			return

		Events.listen
			node: document
			type: ["keyup"]
			capture: true
			instance: @__ref
			call: (ev) =>
				if not globalDrag.dragStarted
					@__cleanup()
					return

				if ev.keyCode() == 27
					# console.error "stopped.."
					end_drag(ev, true)
					return ev.stop()

				return

		Events.listen
			node: document
			type: @__event_types.end
			capture: true
			instance: @__ref
			call: (ev) =>
				# console.debug "event received: ", ev.getType()
				# CUI.debug "draggable", ev.type
				if not globalDrag
					return

				if not globalDrag.dragStarted
					@__cleanup()
					return

				end_drag(ev)
				return ev.stop()
				# CUI.debug "mouseup, resetting drag stuff"
				#
		return

	getCursor: ->
		"grabbing"

	__startDrag: (ev, $target, diff) ->

		# It's ok to stop the events here, the "mouseup" and "keyup"
		# we need to end the drag are initialized before in init drag,
		# so they are executed before

		# CUI.debug "start drag", diff
		@_dragstart?(ev, window.globalDrag)
		@init_helper(ev, $target, diff)
		globalDrag.$source.addClass(@_dragClass)
		@start_drag(ev, $target, diff)
		globalDrag.dragStarted = true

	# call after first mousedown
	before_drag: ->

	start_drag: (ev, $target, diff) ->

	# do drag
	# first call
	do_drag: (ev, $target, diff) ->

		# position helper
		@position_helper(ev, $target, diff)

		if globalDrag.dragoverTarget and globalDrag.dragoverTarget[0] != $target[0]
			Events.trigger
				type: "cui-dragleave"
				node: globalDrag.dragoverTarget
				info:
					globalDrag: globalDrag
					originalEvent: ev

			globalDrag.dragoverTarget = null

		if not globalDrag.dragoverTarget
			globalDrag.dragoverTarget = $target
			# console.debug "target:", $target
			Events.trigger
				type: "cui-dragenter"
				node: globalDrag.dragoverTarget
				info:
					globalDrag: globalDrag
					originalEvent: ev

		# trigger our own dragover event on the correct target
		Events.trigger
			node: globalDrag.dragoverTarget
			type: "cui-dragover"
			info:
				globalDrag: globalDrag
				originalEvent: ev

		return

	cleanup_drag: (ev) ->
		if @isDestroyed()
			return

		globalDrag.$source.removeClass(@_dragClass)
		CUI.DOM.remove(globalDrag.helperNode)

	stop_drag: (ev) ->
		@__finish_drag(ev)
		@cleanup_drag(ev)

	__finish_drag: (ev) ->
		if not globalDrag.dragoverTarget
			return

		# CUI.debug "sending pf_dragleave", globalDrag.dragoverTarget
		# CUI.debug "pf_dragleave.event", globalDrag.dragoverTarget[0]

		CUI.Events.trigger
			node: globalDrag.dragoverTarget
			type: "cui-dragleave"
			info:
				globalDrag: globalDrag
				originalEvent: ev

		if not globalDrag.stopped
			# console.error "cui-drop", ev
			CUI.Events.trigger
				type: "cui-drop"
				node: globalDrag.dragoverTarget
				info:
					globalDrag: globalDrag
					originalEvent: ev

		CUI.Events.trigger
			node: globalDrag.dragoverTarget
			type: "cui-dragend"
			info:
				globalDrag: globalDrag
				originalEvent: ev

		globalDrag.dragoverTarget = null
		@

	end_drag: (ev) ->
		# CUI.debug globalDrag.dragoverTarget, ev.getType(), ev
		if @isDestroyed()
			return
		@__finish_drag(ev)
		@cleanup_drag(ev)
		@

	get_helper_pos: (ev, gd, diff) ->
		top: globalDrag.helperNodeStart.top + diff.y
		left: globalDrag.helperNodeStart.left + diff.x
		width: globalDrag.helperNodeStart.width
		height: globalDrag.helperNodeStart.height

	get_helper_contain_element: ->
		@_helper_contain_element

	position_helper: (ev, $target, diff) ->
		# console.debug "position helper", globalDrag.helperNodeStart, ev, $target, diff

		if not globalDrag.helperNode
			return

		helper_pos = @get_helper_pos(ev, globalDrag, diff)

		pos =
			x: helper_pos.left
			y: helper_pos.top
			w: helper_pos.width
			h: helper_pos.height

		helper_contain_element = @get_helper_contain_element(ev, $target, diff)

		if helper_contain_element
			dim_contain = CUI.DOM.getDimensions(helper_contain_element)

			if dim_contain.clientWidth == 0 or dim_contain.clientHeight == 0
				console.warn('Draggable[position_helper]: Containing element has no dimensions.', helper_contain_element);

			# pos is changed in place
			Draggable.limitRect pos,
				min_x: dim_contain.viewportLeft + dim_contain.borderLeftWidth
				max_x: dim_contain.viewportRight - dim_contain.borderRightWidth - globalDrag.helperNodeStart.marginHorizontal
				min_y: dim_contain.viewportTop + dim_contain.borderTopWidth
				max_y: dim_contain.viewportBottom - dim_contain.borderBottomWidth - globalDrag.helperNodeStart.marginVertical
		else
			dim_contain = globalDrag.helperNodeStart.body_dim

			Draggable.limitRect pos,
				min_x: dim_contain.borderLeftWidth
				max_x: dim_contain.scrollWidth - dim_contain.borderRightWidth - globalDrag.helperNodeStart.marginHorizontal
				min_y: dim_contain.borderTopWidth
				max_y: dim_contain.scrollHeight - dim_contain.borderBottomWidth - globalDrag.helperNodeStart.marginVertical

		# console.debug "limitRect", dump(pos), dim_contain

		helper_pos.top = pos.y
		helper_pos.left = pos.x

		helper_pos.dragDiff =
			x: helper_pos.left - globalDrag.helperNodeStart.left
			y: helper_pos.top - globalDrag.helperNodeStart.top

		# @_helper_set_pos?(globalDrag, helper_pos)

		if helper_pos.width != globalDrag.helperNodeStart.width
			new_width = helper_pos.width

		if helper_pos.height != globalDrag.helperNodeStart.height
			new_height = helper_pos.height

		CUI.DOM.setStyle globalDrag.helperNode,
			transform: globalDrag.helperNodeStart.transform+" translateX("+helper_pos.dragDiff.x+"px) translateY("+helper_pos.dragDiff.y+"px)"

		CUI.DOM.setDimensions globalDrag.helperNode,
			borderBoxWidth: new_width
			borderBoxHeight: new_height

		return

		# CUI.DOM.setStyle globalDrag.helperNode,
		# 	top: helper_pos.top
		# 	left: helper_pos.left

		# console.debug "FINAL helper pos:", globalDrag, diff,  "top", top, "left", left, dump(helper_pos)

	getCloneSourceForHelper: ->
		globalDrag.$source

	get_axis: ->
		@_axis

	get_helper: (ev, gd, diff) ->
		@_helper

	get_init_helper_pos: (node, gd, offset = top: 0, left: 0) ->
		top: gd.startCoordinates.pageY - offset.top
		left: gd.startCoordinates.pageX - offset.left

	init_helper: (ev, $target, diff) ->
		helper = @get_helper(ev, window.globalDrag, diff)

		if not helper
			return

		if helper == "clone"
			clone_source = @getCloneSourceForHelper()

			hn = clone_source.cloneNode(true)
			hn.classList.remove("cui-selected")

			# offset the layer to the click
			offset =
				top: globalDrag.start.top
				left: globalDrag.start.left
		else if CUI.isFunction(helper)
			hn = globalDrag.helperNode = helper(globalDrag)
			set_dim = null
		else
			hn = globalDrag.helperNode = helper

		if not hn
			return

		globalDrag.helperNode = hn

		CUI.DOM.addClass(hn, "cui-drag-drop-select-helper")

		document.body.appendChild(hn)

		start = @get_init_helper_pos(hn, globalDrag, offset)

		CUI.DOM.setStyle(hn, start)

		if helper == "clone"
			# set width & height
			set_dim = DOM.getDimensions(clone_source)

			# console.error "measureing clone", set_dim.marginBoxWidth, globalDrag.$source, dim

			DOM.setDimensions hn,
				marginBoxWidth: set_dim.marginBoxWidth
				marginBoxHeight: set_dim.marginBoxHeight


		dim = DOM.getDimensions(hn)

		# console.debug "globalDrag", globalDrag, offset, hn, set_dim.marginBoxWidth, set_dim.marginBoxHeight

		start.width = dim.borderBoxWidth
		start.height = dim.borderBoxHeight
		start.marginTop = dim.marginTop
		start.marginLeft = dim.marginLeft
		start.marginVertical = dim.marginVertical
		start.marginHorizontal = dim.marginHorizontal
		start.transform = dim.computedStyle.transform
		if start.transform == 'none'
			start.transform = ''
		start.body_dim = CUI.DOM.getDimensions(document.body)

		globalDrag.helperNodeStart = start


	# keep pos inside certain constraints
	# pos.fix is an Array containing any of "n","w","e","s"
	# limitRect: min_w, min_h, max_w, max_h, min_x, max_x, min_y, max_y
	# !!! The order of the parameters is how we want them, in Movable it
	# is different for compability reasons
	@limitRect: (pos, limitRect, defaults={}) ->
		pos.fix = pos.fix or []
		for k, v of defaults
			if isUndef(pos[k])
				pos[k] = v

		# CUI.debug "limitRect", pos, defaults, limitRect

		for key in [
			"min_w"
			"max_w"
			"min_h"
			"max_h"
			"min_x"
			"max_x"
			"min_y"
			"max_y"
			]
			value = limitRect[key]
			if isUndef(value)
				continue

			assert(not isNaN(value), "#{getObjectClass(@)}.limitRect", "key #{key} in pos isNaN", pos: pos, defaults: defaults, limitRect: limitRect)

			skey = key.substring(4)
			mkey = key.substring(0,3)
			if key == "max_x"
				value -= pos.w
			if key == "max_y"
				value -= pos.h

			diff = pos[skey] - value
			if mkey == "min"
				if diff >= 0
					continue
			if mkey == "max"
				if diff <= 0
					continue

			if skey == "y" and "n" in pos.fix
				pos.h -= diff
				continue
			if skey == "x" and "w" in pos.fix
				pos.w -= diff
				continue

			# console.debug "correcting #{skey} by #{diff} from #{pos[skey]}"

			pos[skey]-=diff

			if skey == "h" and "s" in pos.fix
				# CUI.debug "FIX y"
				pos.y += diff
			if skey == "w" and "e" in pos.fix
				# CUI.debug "FIX x"
				pos.x += diff
			if skey == "x" and "e" in pos.fix
				# CUI.debug "FIX w"
				pos.w += diff
			if skey == "y" and "s" in pos.fix
				# CUI.debug "FIX h"
				pos.h += diff

		# CUI.debug "limitRect AFTER", pos, diff
		return pos

