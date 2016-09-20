globalDrag = null

class CUI.Droppable extends CUI.DragDropSelect
	@cls = "droppable"

	initOpts: ->
		super()
		@addOpts
			accept:
				default: (ev, globalDrag, $target) ->
					true
				check: Function

			drop:
				default: (ev, info) =>
					pos = info.dropTargetPos or "on"
					CUI.alert(text: "You dropped me "+pos+": " + CUI.DOM.getAttribute(info.dropTarget, "class"))
				check: Function

			hoverClass:
				default: "cui-droppable"
				check: String

			dropHelper:
				mandatory: true
				default: false
				check: Boolean

			targetHelper:
				mandatory: true
				default: false
				check: Boolean

			selector:
				check: (v) =>
					isString(v) or CUI.isFunction(v)

			axis:
				mandatory: true
				default: "x"
				check: ["x", "y"]

	accept: (ev, info) ->
		@_accept(ev, info)

	destroy: ->
		@removeHelper()
		super()

	readOpts: ->
		super()
		if @_targetHelper
			assert(@_selector, "new Droppable", "opts.targetHelper needs opts.selector to be set.", opts: @opts)

		if @_dropHelper
			assert(not @_selector or @_targetHelper, "new Droppable", "opts.dropHelper does only work without opts.selector or with opts.targetHelper and opts.selector. needs opts.selector to be set.", opts: @opts)
			@__dropHelper = CUI.DOM.element("DIV", class: "cui-droppable-drop-helper cui-demo-node-copyable")

		return

	removeHelper: ->
		@resetMargin()
		if @__selectedTarget
			CUI.DOM.removeClass(@__selectedTarget, @_hoverClass)
			@__selectedTarget = null
		if @__dropHelper
			@__dropHelper.remove()
		CUI.DOM.removeAnimatedClone(@_element)

	resetMargin: ->
		if not @__resetMargin
			return

		CUI.DOM.setStyleOne(@__resetMargin, "margin", "")
		delete(@__resetMargin)
		delete(@__saveZoneDims)

	insideSaveZone: (coord) ->
		if not @__saveZoneDims
			return false

		buf = 10 # add extra 10 pixels
		for zone in @__saveZoneDims
			if (zone.viewportTopMargin - buf) <= coord.pageY <= (zone.viewportBottomMargin + buf) and
				(zone.viewportLeftMargin - buf) <= coord.pageX <= (zone.viewportRightMargin + buf)
					return true

		return false

	syncDropHelper: ->
		# drop helper goes on top
		dim = CUI.DOM.getDimensions(@_element)
		CUI.DOM.setDimensions @__dropHelper,
			contentBoxWidth: dim.borderBoxWidth
			contentBoxHeight: dim.borderBoxHeight

		document.body.appendChild(@__dropHelper)

		drop_helper_dim = CUI.DOM.getDimensions(@__dropHelper)

		CUI.DOM.setStyle @__dropHelper,
			position: "absolute"
			top: dim.viewportTop - drop_helper_dim.borderTopWidth - drop_helper_dim.marginTop
			left: dim.viewportLeft - drop_helper_dim.borderLeftWidth - drop_helper_dim.marginLeft

	syncTargetHelper: (ev, info) ->
		target = ev.getTarget()
		coord = getCoordinatesFromEvent(info.originalEvent)

		if ev.getType() == "cui-dragleave"
			new_target = info.originalEvent.getTarget()
			if not CUI.DOM.closest(new_target, @_element)
				# outside us
				@__dropTargetPos = undefined
				@__dropTarget = undefined
				@removeHelper()
				return

			if @_targetHelper or not @_selector
				# ignore the event
				return

		if not CUI.DOM.hasAnimatedClone(@_element)
			CUI.DOM.initAnimatedClone(@_element)

		if @__dropTarget == undefined
			for el in CUI.DOM.findElements(@_element, @_selector)
				el.__orig_dim = CUI.DOM.getDimensions(el)

			@__dropTargetPos = null
			@__dropTarget = null

		CUI.DOM.removeClass(@__selectedTarget, @_hoverClass)
		if @_selector
			@__selectedTarget = CUI.DOM.closest(target, @_selector)
		else
			@__selectedTarget = @_element

		if not @_targetHelper
			@__dropTarget = @__selectedTarget
			@__dropTargetPos = null

			if @_selector or not @__dropHelper
				CUI.DOM.addClass(@__selectedTarget, @_hoverClass)
			else
				@syncDropHelper()
			return

		# We have a targetHelper from here below

		if not @__selectedTarget
			if @insideSaveZone(coord)
				return

			@resetMargin()
			if @__dropHelper
				@__dropTarget = "last"
				@__dropTargetPos = "after"
				@syncDropHelper()
			else
				@__dropTargetPos = null
				@__dropTarget = null

			CUI.DOM.syncAnimatedClone(@_element)
			return

		@__dropHelper?.remove()

		dim = CUI.DOM.getDimensions(@__selectedTarget)

		if (@_axis == "x" and coord.pageX > dim.viewportCenterLeft) or
			(@_axis == "y" and coord.pageY > dim.viewportCenterTop)
				@__dropTargetPos = "after"
		else
			@__dropTargetPos = "before"

		# reset this after we measure, so that the
		# viewport is as the user sees it
		@resetMargin()

		dim = @__selectedTarget.__orig_dim

		if @_axis == "x"
			margin = dim.borderBoxWidth / 2
		else
			margin = dim.borderBoxHeight / 2

		if @_axis == "x"
			if  @__dropTargetPos == "after"
				margin_key = "marginRight"
			else
				margin_key = "marginLeft"
		else
			if  @__dropTargetPos == "after"
				margin_key = "marginBottom"
			else
				margin_key = "marginTop"

		# console.debug "margin_key", margin_key, "margin", margin, @__dropTargetPos, @_axis

		margin = margin + dim[margin_key]

		CUI.DOM.setStyleOne(@__selectedTarget, margin_key, margin)

		@__resetMargin = @__selectedTarget
		@__dropTarget = @__selectedTarget

		@__saveZoneDims = [dim, CUI.DOM.getDimensions(@__selectedTarget)]

		CUI.DOM.syncAnimatedClone(@_element)
		return

	init: ->
		# console.error "register droppable on", @element

		Events.listen
			node: @element
			type: "cui-drop"
			instance: @
			call: (ev) =>
				@removeHelper()

				# CUI.debug "cui-drop", ev.getCurrentTarget()
				if not @__dropTarget
					console.warn("No drop target.")
					return

				if @__dropTarget == "last"
					els = CUI.DOM.findElements(@_element, @_selector)
					dropTarget = els[els.length - 1]
				else
					dropTarget = @__dropTarget

				info =
					globalDrag: globalDrag
					dropTarget: dropTarget

				if @_targetHelper
					info.dropTargetPos = @__dropTargetPos

				console.debug "cui-drop", info
				if @accept(ev, info) != false
					ev.stopPropagation()
					@_drop(ev, info)

				@__dropTarget = undefined
				@__dropTargetPos = undefined
				return

		Events.listen
			node: @element
			type: ["cui-dragover", "cui-dragenter", "cui-dragleave"]
			instance: @
			call: (ev, info) =>
				ev.stopPropagation()

				@syncTargetHelper(ev, info)


Droppable = CUI.Droppable
