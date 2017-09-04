###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

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
					v == "clone" or CUI.util.isElement(v) or CUI.isFunction(v) or null

			helper_contain_element:
				check: (v) ->
					CUI.util.isElement(v)

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
					CUI.util.isString(v) or CUI.isFunction(v)

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
			CUI.Events.ignore(instance: @__ref)
			@__ref = null

		if CUI.globalDrag?.instance == @
			CUI.globalDrag = null
		return

	destroy: ->
		super()
		CUI.DOM.remove(CUI.globalDrag?.helperNode)
		@__cleanup()
		@

	init: ->
		# CUI.debug "Draggable", @options.selector
		CUI.util.assert(not @_helper_contain_element or CUI.DOM.closest(@_element, @_helper_contain_element), "new CUI.sDraggable", "opts.helper_contain_element needs to be parent of opts.element", opts: @opts)

		CUI.DOM.addClass(@element, "no-user-select")

		CUI.Events.listen
			type: @__event_types.start
			node: @element
			# capture: true
			instance: @
			selector: @_selector
			call: (ev) =>
				if ev.getButton() > 0 and ev.getType() == "mousedown"
					# ignore if not the main button
					return

				if CUI.globalDrag
					# ignore if dragging is in progress
					return

				# console.debug CUI.util.getObjectClass(@), "[mousedown]", ev.getUniqueId(), @element

				# hint possible click event listeners like Sidebar to
				# not execute the click anymore...
				#
				position = CUI.util.elementGetPosition(CUI.util.getCoordinatesFromEvent(ev), ev.getTarget())
				dim = CUI.DOM.getDimensions(ev.getTarget())

				if dim.clientWidthScaled > 0 and position.left - dim.scrollLeftScaled > dim.clientWidthScaled
					console.warn("Mousedown on a vertical scrollbar, not starting drag.")
					return

				if dim.clientHeightScaled > 0 and position.top - dim.scrollTopScaled > dim.clientHeightScaled
					console.warn("Mousedown on a horizontal scrollbar, not starting drag.")
					return

				target = ev.getCurrentTarget()
				target_dim = CUI.DOM.getDimensions(target)
				if not CUI.DOM.isInDOM(target) or target_dim.clientWidth == 0 or target_dim.clientHeight == 0
					return

				if CUI.DOM.closest(ev.getTarget(), "input,textarea,select")
					return

				$target = target

				# console.debug "attempting to start drag", ev, $target
				@init_drag(ev, $target)
				return

	init_drag: (ev, $target) ->

		if not $target
			# if subclasses screw with $target, this can happen
			return

		CUI.globalDrag = @_create?(ev, $target)

		# ev.getMousedownEvent?().preventDefault()

		if CUI.globalDrag == false
			# CUI.debug("not creating drag handle, opts.create returned 'false'.", ev, @)
			return

		# ev.preventDefault()

		if CUI.util.isNull(CUI.globalDrag) or CUI.globalDrag == true
			CUI.globalDrag = {}

		CUI.util.assert(CUI.isPlainObject(CUI.globalDrag), "CUI.Draggable.init_drag", "returned data must be a plain object", data: CUI.globalDrag)
		point = CUI.util.getCoordinatesFromEvent(ev)
		position = CUI.util.elementGetPosition(point, $target)

		init =
			$source: $target
			startEvent: ev
			startCoordinates: point
			instance: @
			startScroll:
				top: $target.scrollTop
				left: $target.scrollLeft
			start: position # offset to the $target
			threshold: @_threshold

		for k, v of init
			CUI.globalDrag[k] = v

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

			CUI.Events.trigger
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

		CUI.Events.listen
			node: document
			type: @__event_types.move
			instance: @__ref
			call: (ev) =>
				if not CUI.globalDrag
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

				$target = pointTarget

				if CUI.globalDrag.ended
					return

				coordinates = CUI.util.getCoordinatesFromEvent(ev)

				diff =
					x: coordinates.pageX - CUI.globalDrag.startCoordinates.pageX
					y: coordinates.pageY - CUI.globalDrag.startCoordinates.pageY
					eventPoint: coordinates

				switch @get_axis()
					when "x"
						diff.y = 0
					when "y"
						diff.x = 0

				diff.bare_x = diff.x
				diff.bare_y = diff.y

				diff.x += CUI.globalDrag.$source.scrollLeft - CUI.globalDrag.startScroll.left
				diff.y += CUI.globalDrag.$source.scrollTop - CUI.globalDrag.startScroll.top

				if Math.abs(diff.x) >= CUI.globalDrag.threshold or
					Math.abs(diff.y) >= CUI.globalDrag.threshold or
					CUI.globalDrag.dragStarted

						CUI.globalDrag.dragDiff = diff

						if not CUI.globalDrag.dragStarted
							CUI.globalDrag.startEvent.preventDefault()

							@__startDrag(ev, $target, diff)

							if @_get_cursor
								document.body.setAttribute("data-cursor", @_get_cursor(CUI.globalDrag))
							else
								document.body.setAttribute("data-cursor", @getCursor())

						moveEvent = ev
						dragover_scroll()

						@do_drag(ev, $target, diff)
						@_dragging?(ev, CUI.globalDrag, diff)
				return

		end_drag = (ev, stop = false) =>

			start_target = CUI.globalDrag.$source
			start_target_parents = CUI.DOM.parents(start_target)

			CUI.globalDrag.ended = true

			document.body.removeAttribute("data-cursor")

			if stop
				CUI.globalDrag.stopped = true
				@stop_drag(ev)
				@_dragstop?(ev, CUI.globalDrag, @)
			else
				@end_drag(ev)
				@_dragend?(ev, CUI.globalDrag, @)

			if @isDestroyed()
				# this can happen if any of the
				# callbacks cleanup / reload
				return

			noClickKill = CUI.globalDrag.noClickKill

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

			CUI.Events.listen
				type: "click"
				capture: true
				only_once: true
				node: window
				call: (ev) ->
					# console.error "Killing click after drag", ev.getTarget()
					return ev.stop()

			return

		CUI.Events.listen
			node: document
			type: ["keyup"]
			capture: true
			instance: @__ref
			call: (ev) =>
				if not CUI.globalDrag.dragStarted
					@__cleanup()
					return

				if ev.keyCode() == 27
					# console.error "stopped.."
					end_drag(ev, true)
					return ev.stop()

				return

		CUI.Events.listen
			node: document
			type: @__event_types.end
			capture: true
			instance: @__ref
			call: (ev) =>
				# console.debug "event received: ", ev.getType()
				# CUI.debug "draggable", ev.type
				if not CUI.globalDrag
					return

				if not CUI.globalDrag.dragStarted
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
		@_dragstart?(ev, CUI.globalDrag)
		@init_helper(ev, $target, diff)
		CUI.DOM.addClass(CUI.globalDrag.$source, @_dragClass)
		@start_drag(ev, $target, diff)
		CUI.globalDrag.dragStarted = true

	# call after first mousedown
	before_drag: ->

	start_drag: (ev, $target, diff) ->

	# do drag
	# first call
	do_drag: (ev, $target, diff) ->

		# position helper
		@position_helper(ev, $target, diff)

		if CUI.globalDrag.dragoverTarget and CUI.globalDrag.dragoverTarget != $target
			CUI.Events.trigger
				type: "cui-dragleave"
				node: CUI.globalDrag.dragoverTarget
				info:
					globalDrag: CUI.globalDrag
					originalEvent: ev

			CUI.globalDrag.dragoverTarget = null

		if not CUI.globalDrag.dragoverTarget
			CUI.globalDrag.dragoverTarget = $target
			# console.debug "target:", $target
			CUI.Events.trigger
				type: "cui-dragenter"
				node: CUI.globalDrag.dragoverTarget
				info:
					globalDrag: CUI.globalDrag
					originalEvent: ev

		# trigger our own dragover event on the correct target
		CUI.Events.trigger
			node: CUI.globalDrag.dragoverTarget
			type: "cui-dragover"
			info:
				globalDrag: CUI.globalDrag
				originalEvent: ev

		return

	cleanup_drag: (ev) ->
		if @isDestroyed()
			return

		CUI.DOM.removeClass(CUI.globalDrag.$source, @_dragClass)
		CUI.DOM.remove(CUI.globalDrag.helperNode)

	stop_drag: (ev) ->
		@__finish_drag(ev)
		@cleanup_drag(ev)

	__finish_drag: (ev) ->
		if not CUI.globalDrag.dragoverTarget
			return

		# CUI.debug "sending pf_dragleave", CUI.globalDrag.dragoverTarget
		# CUI.debug "pf_dragleave.event", CUI.globalDrag.dragoverTarget

		CUI.Events.trigger
			node: CUI.globalDrag.dragoverTarget
			type: "cui-dragleave"
			info:
				globalDrag: CUI.globalDrag
				originalEvent: ev

		if not CUI.globalDrag.stopped
			# console.error "cui-drop", ev
			CUI.Events.trigger
				type: "cui-drop"
				node: CUI.globalDrag.dragoverTarget
				info:
					globalDrag: CUI.globalDrag
					originalEvent: ev

		CUI.Events.trigger
			node: CUI.globalDrag.dragoverTarget
			type: "cui-dragend"
			info:
				globalDrag: CUI.globalDrag
				originalEvent: ev

		CUI.globalDrag.dragoverTarget = null
		@

	end_drag: (ev) ->
		# CUI.debug CUI.globalDrag.dragoverTarget, ev.getType(), ev
		if @isDestroyed()
			return
		@__finish_drag(ev)
		@cleanup_drag(ev)
		@

	get_helper_pos: (ev, gd, diff) ->
		top: CUI.globalDrag.helperNodeStart.top + diff.y
		left: CUI.globalDrag.helperNodeStart.left + diff.x
		width: CUI.globalDrag.helperNodeStart.width
		height: CUI.globalDrag.helperNodeStart.height

	get_helper_contain_element: ->
		@_helper_contain_element

	position_helper: (ev, $target, diff) ->
		# console.debug "position helper", CUI.globalDrag.helperNodeStart, ev, $target, diff

		if not CUI.globalDrag.helperNode
			return

		helper_pos = @get_helper_pos(ev, CUI.globalDrag, diff)

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
			CUI.Draggable.limitRect pos,
				min_x: dim_contain.viewportLeft + dim_contain.borderLeftWidth
				max_x: dim_contain.viewportRight - dim_contain.borderRightWidth - CUI.globalDrag.helperNodeStart.marginHorizontal
				min_y: dim_contain.viewportTop + dim_contain.borderTopWidth
				max_y: dim_contain.viewportBottom - dim_contain.borderBottomWidth - CUI.globalDrag.helperNodeStart.marginVertical
		else
			dim_contain = CUI.globalDrag.helperNodeStart.body_dim

			CUI.Draggable.limitRect pos,
				min_x: dim_contain.borderLeftWidth
				max_x: dim_contain.scrollWidth - dim_contain.borderRightWidth - CUI.globalDrag.helperNodeStart.marginHorizontal
				min_y: dim_contain.borderTopWidth
				max_y: dim_contain.scrollHeight - dim_contain.borderBottomWidth - CUI.globalDrag.helperNodeStart.marginVertical

		# console.debug "limitRect", CUI.util.dump(pos), dim_contain

		helper_pos.top = pos.y
		helper_pos.left = pos.x

		helper_pos.dragDiff =
			x: helper_pos.left - CUI.globalDrag.helperNodeStart.left
			y: helper_pos.top - CUI.globalDrag.helperNodeStart.top

		if helper_pos.width != CUI.globalDrag.helperNodeStart.width
			new_width = helper_pos.width

		if helper_pos.height != CUI.globalDrag.helperNodeStart.height
			new_height = helper_pos.height

		CUI.DOM.setStyle CUI.globalDrag.helperNode,
			transform: CUI.globalDrag.helperNodeStart.transform+" translateX("+helper_pos.dragDiff.x+"px) translateY("+helper_pos.dragDiff.y+"px)"

		CUI.DOM.setDimensions CUI.globalDrag.helperNode,
			borderBoxWidth: new_width
			borderBoxHeight: new_height

		return


	getCloneSourceForHelper: ->
		CUI.globalDrag.$source

	get_axis: ->
		@_axis

	get_helper: (ev, gd, diff) ->
		@_helper

	get_init_helper_pos: (node, gd, offset = top: 0, left: 0) ->
		top: gd.startCoordinates.pageY - offset.top
		left: gd.startCoordinates.pageX - offset.left

	init_helper: (ev, $target, diff) ->
		helper = @get_helper(ev, CUI.globalDrag, diff)

		if not helper
			return

		if helper == "clone"
			clone_source = @getCloneSourceForHelper()

			hn = clone_source.cloneNode(true)
			hn.classList.remove("cui-selected")

			# offset the layer to the click
			offset =
				top: CUI.globalDrag.start.top
				left: CUI.globalDrag.start.left
		else if CUI.isFunction(helper)
			hn = CUI.globalDrag.helperNode = helper(CUI.globalDrag)
			set_dim = null
		else
			hn = CUI.globalDrag.helperNode = helper

		if not hn
			return

		CUI.globalDrag.helperNode = hn

		CUI.DOM.addClass(hn, "cui-drag-drop-select-helper")

		document.body.appendChild(hn)

		start = @get_init_helper_pos(hn, CUI.globalDrag, offset)

		CUI.DOM.setStyle(hn, start)

		if helper == "clone"
			# set width & height
			set_dim = CUI.DOM.getDimensions(clone_source)

			# console.error "measureing clone", set_dim.marginBoxWidth, CUI.globalDrag.$source, dim

			CUI.DOM.setDimensions hn,
				marginBoxWidth: set_dim.marginBoxWidth
				marginBoxHeight: set_dim.marginBoxHeight


		dim = CUI.DOM.getDimensions(hn)

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

		CUI.globalDrag.helperNodeStart = start


	# keep pos inside certain constraints
	# pos.fix is an Array containing any of "n","w","e","s"
	# limitRect: min_w, min_h, max_w, max_h, min_x, max_x, min_y, max_y
	# !!! The order of the parameters is how we want them, in Movable it
	# is different for compability reasons
	@limitRect: (pos, limitRect, defaults={}) ->
		pos.fix = pos.fix or []
		for k, v of defaults
			if CUI.util.isUndef(pos[k])
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
			if CUI.util.isUndef(value)
				continue

			CUI.util.assert(not isNaN(value), "#{CUI.util.getObjectClass(@)}.limitRect", "key #{key} in pos isNaN", pos: pos, defaults: defaults, limitRect: limitRect)

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
