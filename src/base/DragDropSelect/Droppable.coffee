###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Droppable extends CUI.DragDropSelect
	@cls = "droppable"

	initOpts: ->
		super()
		@addOpts
			accept:
				check: Function

			drop:
				default: (ev, info) =>
					pos = info.dropTargetPos or "on"
					CUI.alert(
						markdown: true,
						text: "You dropped me **"+pos+"**: " + CUI.DOM.getAttribute(info.dropTarget, "class")
					)
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

	accept: (ev, info) ->
		@_accept?(ev, info)

	destroy: ->
		@removeHelper()
		super()

	readOpts: ->
		super()
		if @_targetHelper
			assert(@_selector, "new Droppable", "opts.targetHelper needs opts.selector to be set.", opts: @opts)

		if @_dropHelper
			assert(not @_selector or @_targetHelper, "new Droppable", "opts.dropHelper does only work without opts.selector or with opts.targetHelper and opts.selector. needs opts.selector to be set.", opts: @opts)
			@__dropHelper = CUI.DOM.element("DIV", class: "cui-droppable-drop-helper")

		return

	removeHelper: ->
		@resetMargin()
		if @__selectedTarget
			CUI.DOM.removeClass(@__selectedTarget, @_hoverClass)
			@__selectedTarget = null

		if @__dropHelper
			# console.error "removing drop helper.."
			CUI.DOM.remove(@__dropHelper)

		if @_targetHelper
			for el in CUI.DOM.findElements(@_element, @_selector)
				el.classList.remove("cui-droppable-target-helper")

		# console.error "removing helper.."

		@__dropTarget = undefined
		@__dropTargetPos = undefined

	resetMargin: ->
		if not @__resetMargin
			return

		@__resetMargin.classList.remove(@__resetMargin.__target_helper_class)
		delete(@__resetMargin.__target_helper_class)
		delete(@__resetMargin)
		delete(@__saveZoneDims)

	insideSaveZone: (coord) ->
		if not @__saveZoneDims
			return false

		buf = 5 # add extra pixels
		for zone in @__saveZoneDims
			if (zone.viewportTopMargin - buf) <= coord.pageY <= (zone.viewportBottomMargin + buf) and
				(zone.viewportLeftMargin - buf) <= coord.pageX <= (zone.viewportRightMargin + buf)
					return true

		return false

	syncDropHelper: ->
		# drop helper goes on top
		dim = CUI.DOM.getDimensions(@_element)

		document.body.appendChild(@__dropHelper)

		CUI.DOM.setDimensions @__dropHelper,
			contentBoxWidth: dim.borderBoxWidth
			contentBoxHeight: dim.borderBoxHeight

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

			if CUI.DOM.closest(new_target, ".cui-drag-drop-select-droppable") != @_element
				# outside us
				@removeHelper()
				return true

			if @_targetHelper or not @_selector
				# ignore the event
				return

		acceptable = (dropTarget, dropTargetPos) =>
			info.dropTarget = dropTarget
			if @_targetHelper
				info.dropTargetPos = dropTargetPos

			if @accept(ev, info) == false
				@removeHelper()
				# console.error("Cannot accept drop here...")
				return false
			else
				return true

		if @__dropTarget == undefined
			# check axis
			last_dim = null
			@__axis = null
			for el in CUI.DOM.findElements(@_element, @_selector)
				dim = CUI.DOM.getDimensions(el)
				if last_dim and not @__axis
					if last_dim.viewportLeft == dim.viewportLeft
						@__axis = "y"

					if last_dim.viewportTop == dim.viewportTop
						@__axis = "x"

				if @_targetHelper
					el.classList.add("cui-droppable-target-helper")

				last_dim = dim

			if not @__axis
				@__axis = "x"

			@__dropTargetPos = null
			@__dropTarget = null

		CUI.DOM.removeClass(@__selectedTarget, @_hoverClass)
		if @_selector
			@__selectedTarget = CUI.DOM.closest(target, @_selector)
		else
			@__selectedTarget = @_element

		if not @_targetHelper

			if not acceptable(@__selectedTarget)
				@removeHelper()
				if @_selector and not @__selectedTarget
					# bubble
					return true
				return

			@__dropTarget = @__selectedTarget
			@__dropTargetPos = null

			CUI.DOM.addClass(@__selectedTarget, @_hoverClass)
			if @__dropHelper
				@syncDropHelper()

			return

		if not @__selectedTarget
			if @insideSaveZone(coord)
				console.info("Inside save zone...")
				return

			@resetMargin()
			if @__dropHelper
				if not acceptable(@_element)
					return

				@__dropTarget = @_element
				@__dropTargetPos = null
				@syncDropHelper()
				# console.debug "is acceptable..", @__dropHelper, DOM.isInDOM(@__dropHelper)
			else
				console.info("No selected target, no dropHelper...")
				@removeHelper()
				# bubble
				return true

			return

		# console.error "removing drop helper.."
		CUI.DOM.remove(@__dropHelper)

		dim = CUI.DOM.getDimensions(@__selectedTarget)

		if (@__axis == "x" and coord.pageX > dim.viewportCenterLeft) or
			(@__axis == "y" and coord.pageY > dim.viewportCenterTop)
				dropTargetPos = "after"
		else
			dropTargetPos = "before"

		dropTarget = @__selectedTarget

		if not acceptable(dropTarget, dropTargetPos)
			@removeHelper()
			return

		@__dropTarget = dropTarget
		@__dropTargetPos = dropTargetPos

		helper_cls = "cui-droppable-target-helper-"+@__axis+"--"+@__dropTargetPos

		if @__resetMargin == @__selectedTarget and @__selectedTarget.__target_helper_class == helper_cls
			; # target helper is still ok
		else
			@resetMargin()
			@__saveZoneDims = [ CUI.DOM.getDimensions(@__selectedTarget) ]
			@__selectedTarget.__target_helper_class = helper_cls
			@__selectedTarget.addClass(@__selectedTarget.__target_helper_class)
			@__saveZoneDims.push(CUI.DOM.getDimensions(@__selectedTarget))
			@__resetMargin = @__selectedTarget

		return

	init: ->
		# console.error "register droppable on", @element

		Events.listen
			node: @element
			type: "cui-dragend"
			instance: @
			call: (ev, info) =>
				@removeHelper()

		Events.listen
			node: @element
			type: "cui-drop"
			instance: @
			call: (ev, info) =>

				# console.debug "cui-drop event", ev, info, @__dropTarget

				# CUI.debug "cui-drop", ev.getCurrentTarget()
				if not @__dropTarget
					return

				# console.debug "cui-drop", info

				info.dropTarget = @__dropTarget
				if @_targetHelper
					info.dropTargetPos = @__dropTargetPos

				if @accept(ev, info) != false
					ev.stopPropagation()
					CUI.setTimeout
						call: =>
							@_drop(ev, info)

				return

		Events.listen
			node: @element
			type: ["cui-dragover", "cui-dragenter", "cui-dragleave"]
			instance: @
			call: (ev, info) =>

				@syncTargetHelper(ev, info)
				ev.stopPropagation()
				return

