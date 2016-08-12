globalDrag = null

class Draggable extends DragDropSelect
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
					v == "clone" or isElement(v) or CUI.isFunction(v)

			set_helper_pos:
				check: Function

			dragend:
				check: Function

			dragstart:
				check: Function

			dragging:
				check: Function

			create:
				default: -> true
				check: Function

			axis:
				check: ["x","y"]

			helper_remove_always:
				check: Boolean

			helper_parent:
				default: "document"
				check: ["document", "parent"]

			threshold:
				default: 2
				check: (v) ->
					v >= 0

			ms:
				default: 50
				check: (v) ->
					# must be multiple of 50
					v % 50 == 0 and v > 0

			selector:
				check: (v) =>
					isString(v) or CUI.isFunction(v)

	destroy: ->
		super()
		if not globalDrag
			return
		# CUI.debug "element remove during globalDrag, removing event handlers"
		globalDrag.helperNode?.remove()
		globalDrag = null


	init: ->
		# CUI.debug "Draggable", @options.selector

		@element.addClass("no-user-select")

		Events.listen
			type: "mouseisdown"
			node: @element
			instance: @
			selector: @_selector
			call: (ev) =>
				# CUI.debug getObjectClass(@), "drag drop mouseisdown...", ev.getUniqueId(), ev.getMilliseconds(), ev.isImmediatePropagationStopped()
				if ev.getButton() > 0
					# ignore if not the main button
					return

				if window.globalDrag
					# ignore if dragging is in progress
					return


				switch ev.getMilliseconds()
					when @_ms
						# hint possible click event listeners like Sidebar to
						# not execute the click anymore...
						#
						position = elementGetPosition(getCoordinatesFromEvent(ev), $(ev.getTarget()))
						dim = DOM.getDimensions(ev.getTarget())

						if position.left - dim.scrollLeftScaled > dim.clientWidthScaled
							console.warn "mouseisdown on a vertical scrollbar..."
							return

						if position.top - dim.scrollTopScaled > dim.clientHeightScaled
							console.warn "mouseisdown on a horizontal scrollbar..."
							return

						target = ev.getCurrentTarget()
						target_dim = DOM.getDimensions(target)
						if not DOM.isInDOM(target) or target_dim.clientWidth == 0 or target_dim.clientHeight == 0
							return


						$target = $(target)

						# CUI.debug "attempting to start drag", ev.getUniqueId(), $target[0]

						@startDrag(ev, $target)
					else
						return
				return

	startDrag: (ev, $target) ->

		position = elementGetPosition(getCoordinatesFromEvent(ev), $target)

		overwrite_options = {}
		globalDrag = @_create?(ev, overwrite_options, $target)

		if globalDrag == false
			CUI.debug("not creating drag handle, opts.create returned 'false'.", ev)
			return

		for k, v of overwrite_options
			@["_#{k}"] = v

		if isNull(globalDrag) or globalDrag == true
			globalDrag = {}

		assert($.isPlainObject(globalDrag), "DragDropSelect.create", "returned data must be a plain object", data: globalDrag)
		init =
			$source: $target
			startEvent: ev
			startCoordinates: getCoordinatesFromEvent(ev)
			startScroll:
				top: $target[0].scrollTop
				left: $target[0].scrollLeft
			start: position
			threshold: @_threshold

		# CUI.debug "drag drop init", init

		for k, v of init
			globalDrag[k] = v

		# CUI.debug "starting drag...", globalDrag

		ev.stopImmediatePropagation()
		# ev.preventDefault()

		@before_drag(ev, $target)

		ref = new Dummy() # instance to easily remove events

		kill_timeout = =>
			if globalDrag.autoRepeatTimeout
				CUI.clearTimeout(globalDrag.autoRepeatTimeout)
				globalDrag.autoRepeatTimeout = null

		$target = null

		dragover_scroll = (mousemoveEvent) =>

			# the mousemove event is repeated automatically
			# the _counter provides a way for users to figure out if the event
			# is a repeated one or not
			if not mousemoveEvent.hasOwnProperty("_counter")
				mousemoveEvent._counter = 0
			else
				mousemoveEvent._counter++

			# send our own scroll event
			Events.trigger
				type: "dragover-scroll"
				node: $target
				info:
					mousemoveEvent: mousemoveEvent

			globalDrag.autoRepeatTimeout = CUI.setTimeout
				ms: 100
				track: false
				call: =>
					dragover_scroll(mousemoveEvent)

		Events.listen
			node: document
			type: "mousemove"
			instance: ref
			call: (ev) =>
				if not globalDrag
					return

				# this prevents chrome from focussing element while
				# we drag
				ev.preventDefault()

				# remove selection in firefox
				if document.selection
					document.selection.empty()
				else
					window.getSelection().removeAllRanges()

				# ok, in firefox the target of the mousemove
				# event is WRONG while dragging. we need to overwrite
				# this with elementFromPoint, true story :(
				pointTarget = ev.getPointTarget()
				kill_timeout()

				if not pointTarget
					return

				$target = $(pointTarget)
				dragover_scroll(ev)

				if globalDrag.dragend
					return

				coordinates = getCoordinatesFromEvent(ev)
				diff =
					x: coordinates.pageX - globalDrag.startCoordinates.pageX
					y: coordinates.pageY - globalDrag.startCoordinates.pageY

				diff.x += globalDrag.$source[0].scrollLeft - globalDrag.startScroll.left
				diff.y += globalDrag.$source[0].scrollTop - globalDrag.startScroll.top

				if Math.abs(diff.x) >= globalDrag.threshold or
					Math.abs(diff.y) >= globalDrag.threshold or
					globalDrag.dragStarted
						if not globalDrag.dragStarted
							CUI.DOM.preventEvent(globalDrag.startEvent.getCurrentTarget(), "click")
							# CUI.debug "start drag", diff
							@_dragstart?(ev, globalDrag)
							@do_drag(ev, $target, diff)
							globalDrag.dragStarted = true
						else
							@do_drag(ev, $target, diff)
						@_dragging?(ev, $target, diff)
				return

		cleanup = =>
			kill_timeout()
			Events.ignore
				instance: ref
			globalDrag = null

		Events.listen
			node: document
			type: ["mouseup", "keyup"]
			capture: true
			instance: ref
			call: (ev) =>
				if ev.getType() == "keyup" and ev.keyCode() == 83 and ev.altKey() # ALT-S
					CUI.warn("Stopping Drag and Drop")
					cleanup()
					return

				if not (ev.getType() != "keyup" or ev.keyCode() == 27)
					return

				# CUI.debug "mouseup/keyup: ", ev.getType()
				ev.preventDefault()
				# CUI.debug "draggable", ev.type
				#
				globalDrag.dragend = true
				if globalDrag.dragStarted
					@end_drag(ev)
					@_dragend?(ev, globalDrag, @)
				cleanup()
				# CUI.debug "mouseup, resetting drag stuff"
				#
		return

	# call after first mousedown
	before_drag: ->

	# do drag
	# first call
	do_drag: (ev, $target, diff) ->
		if isUndef(globalDrag.helperNode)
			@init_helper()

		# position helper
		@position_helper(ev)

		if globalDrag.dragoverTarget and globalDrag.dragoverTarget[0] != $target[0]
			Events.trigger
				type: "cui-dragleave"
				node: globalDrag.dragoverTarget

			globalDrag.dragoverTarget = null

		if not globalDrag.dragoverTarget
			globalDrag.dragoverTarget = $target
			Events.trigger
				type: "cui-dragenter"
				node: globalDrag.dragoverTarget

		# trigger our own dragover event on the correct target
		Events.trigger
			node: globalDrag.dragoverTarget
			type: "cui-dragover"

		return

	# find_target: (ev, $target=$(ev.getTarget())) ->
	# 	# hide helper and a drag-drop-select-transparent div
	# 	# if necessaray
	# 	$hide = $target.closest(".cui-drag-drop-select-transparent")
	# 	if $hide.length
	# 		# hide helper and determine the "real" target
	# 		oldDisplay = $hide[0].style.display
	# 		$hide.css(display: "none")
	# 		$target = @find_target(ev, $(document.elementFromPoint(ev.clientX(), ev.clientY())))
	# 		$hide.css(display: oldDisplay)
	# 	$target

	end_drag: (ev) ->
		# CUI.debug globalDrag.dragoverTarget, ev.getType(), ev

		if globalDrag.dragoverTarget
			# CUI.debug "sending pf_dragleave", globalDrag.dragoverTarget
			# CUI.debug "pf_dragleave.event", globalDrag.dragoverTarget[0]

			CUI.Events.trigger
				node: globalDrag.dragoverTarget
				type: "cui-dragleave"

			if ev.getType() == "mouseup"
				drop_event = CUI.Event.require
					type: "cui-drop"
					node: globalDrag.dragoverTarget
					info:
						originalEvent: ev

				CUI.Events.trigger(drop_event)

				if drop_event.isPropagationStopped()
					remove_helper = true

				# it can happen that the trigger deletes globalDrag by removing the
				# draggable element, so we need to check if that has happened and
				# do nothing in case
				if not globalDrag
					return

			globalDrag.dragoverTarget = null

		# animate the helperNode back to its origin
		if globalDrag.helperNode
			if (remove_helper or @_helper_remove_always) and globalDrag.helperNode
				globalDrag.helperNode.remove()
			else
				gd = globalDrag
				helperNode = gd.helperNode
				gd.helperNode.animate
					top: "#{globalDrag.helperNodeStart.top}px"
					left: "#{globalDrag.helperNodeStart.left}px"
				,
					duration: 400
					complete: =>
						helperNode.remove()
						gd.$source.removeClass(@_dragClass)
			globalDrag.helperNode = null
		else
			globalDrag.$source.removeClass(@_dragClass)

		@

	# FIXME: the helper needs to use the "diff" provided by do_drag to
	# position itself. by doing that we are then able
	# to put axis/x and axis/y in do_drag as a featured functionality

	position_helper: (ev) ->
		if globalDrag.helperNode
			if (ev.pageY() or ev.pageX()) == 0
				globalDrag.helperNode.css(display: "none")
			else
				$p = globalDrag.helperNode.parent()
				if not CUI.DOM.isPositioned($p[0])
					parentRelPos = $p.relativePosition()
				else
					parentRelPos = top: 0, left: 0

				position = elementGetPosition(getCoordinatesFromEvent(ev), $p)

				if @_helper_parent == "parent"
					$contain = globalDrag.helperNode.parent()
				else
					$contain = $(document.body)

				# CUI.debug @_helper_parent, position, $contain[0].scrollHeight, globalDrag.helperNodeStart
				if @_axis == "x"
					top = globalDrag.helperNodeStart.top
				else
					top = position.top + (globalDrag.helperOffset?.top or 0) - globalDrag.helperNode.cssInt("border-top-width")
					top_overlap = top - ($contain[0].scrollHeight - globalDrag.helperNodeStart.height - $contain.cssInt("paddingBottom"))
					top_underlap = $contain.cssInt("paddingTop") - top
					# CUI.debug "top", $contain[0].scrollHeight, top, top_overlap, top_underlap

					# dont let the helper overlap the containment
					if top_overlap > 0
						top -= top_overlap
					else if top_underlap > 0
						top += top_underlap

					top += parentRelPos.top

				if @_axis == "y"
					left = globalDrag.helperNodeStart.left
				else
					left = position.left + (globalDrag.helperOffset?.left or 0) - globalDrag.helperNode.cssInt("border-left-width")
					left_overlap = left - ($contain[0].scrollWidth - globalDrag.helperNodeStart.width - $contain.cssInt("paddingRight"))
					left_underlap = $contain.cssInt("paddingLeft") - left

					# CUI.debug "left", $contain[0].scrollWidth, globalDrag.helperNodeStart.width, left, left_overlap, left_underlap
					# dont let the helper overlap the containment
					if left_overlap > 0
						left -= left_overlap
					else if left_underlap > 0
						left += left_underlap

					left += parentRelPos.left

				# CUI.debug "FINAL:", "top", top, "left", left

				get_diff = =>
					x: helper_pos.left - globalDrag.helperNodeStart.left
					y: helper_pos.top - globalDrag.helperNodeStart.top

				# top = ev.originalEvent.pageY + globalDrag.helperOffset.top - offset.top
				# left = ev.originalEvent.pageX + globalDrag.helperOffset.left - offset.left
				helper_pos =
					left: left
					top: top
					start:
						left: globalDrag.helperNodeStart.left
						top: globalDrag.helperNodeStart.top

				helper_pos.dragDiff = get_diff()

				@_set_helper_pos?(globalDrag, helper_pos)

				globalDrag.dragDiff = get_diff()

				globalDrag.helperNode.css
					display: ""
					top: "#{helper_pos.top}px"
					left: "#{helper_pos.left}px"


	get_clone: ($el) ->
		clone = $($el[0].cloneNode(true))
		clone.css
			# marginLeft: 0
			# marginRight: 0
			# marginTop: 0
			# marginBottom: 0
			width: "#{$el.width()}px"
			height: "#{$el.height()}px"

		dim = DOM.getDimensions($el[0])
					# fix width / height
		DOM.setDimensions clone[0],
			marginBoxWidth: dim.marginBoxWidth
			marginBoxHeight: dim.marginBoxHeight

		clone

	init_helper: ->
		$el = globalDrag.$source
		# CUI.debug "init helper", $el[0]
		if @_helper == "clone"
			globalDrag.helperNode = @get_clone($el)

			globalDrag.helperOffset =
				top: -globalDrag.start.top
				left: -globalDrag.start.left

		else if CUI.isFunction(@_helper)
			try
				globalDrag.helperNode = @_helper(globalDrag)
				if isEmpty(globalDrag.helperNode)
					throw new Error("opts.helper did not return a helper node.")
			catch e
				CUI.error(e)
				globalDrag.helperNode = $span().text("Helper Node Not Found")
		else
			globalDrag.helperNode = null

		if globalDrag.helperNode
			globalDrag.helperNode.addClass("drag-drop-select-helper")

			Events.listen
				type: "contextmenu"
				node: globalDrag.helperNode
				call: (ev) =>
					ev.preventDefault()
					ev.stopPropagation()
					return false

			switch @_helper_parent
				when "document"
					relPos = $el.offset()
					$(document.body).append(globalDrag.helperNode)
				when "parent"
					parents = CUI.DOM.parentsUntil($el[0], (node) => CUI.DOM.isPositioned(node))
					assert(parents.length > 0, "Draggable.init_helper", "no parents found for DOM node", node: $el[0])
					scroll = top: 0, left: 0
					for p in parents
						scroll.top += p.scrollTop
						scroll.left += p.scrollLeft

					relPos = $el.relativePosition()

					relPos.top -= scroll.top
					relPos.left -= scroll.left

					parents[parents.length-1].appendChild(globalDrag.helperNode[0])

			CUI.debug @_helper_parent, "relative position", relPos

			if @_helper != "clone"
				relPos.left += globalDrag.start.left
				relPos.top += globalDrag.start.top


			globalDrag.helperNode.addClass("cui-drag-drop-select-transparent")
			globalDrag.helperNode.addClass("no-user-select")

			globalDrag.helperNode.css
				top: -1000
				left: -1000
				position: "absolute"


			globalDrag.helperNode.css
				top: "#{relPos.top}px"
				left: "#{relPos.left}px"
				zIndex: 99999

			dim = DOM.getDimensions(globalDrag.helperNode[0])

			relPos.width = dim.marginBoxWidth
			relPos.height = dim.marginBoxHeight

			relPos.marginTop = dim.marginTop
			relPos.marginLeft = dim.marginLeft

			globalDrag.helperNodeStart = relPos


		# CUI.debug "drag class", @options.dragClass
		$el.addClass(@_dragClass)
