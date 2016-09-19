globalDrag = null

class CUI.Droppable extends CUI.DragDropSelect
	@cls = "droppable"

	initOpts: ->
		super()
		@addOpts
			accept:
				default: ->
				check: Function

			drop:
				default: (ev, info, $el) =>
					CUI.alert(text: "You dropped me on: "+$el.attr("class"))
				check: Function

			hoverClass:
				default: "cui-droppable"
				check: String

			dropHelper:
				default: ""
				check: String

			positioners:
				default: false
				check: Boolean

			selector:
				check: (v) =>
					isString(v) or CUI.isFunction(v)

	accept: (ev) ->
		if @_positioners
			globalDrag.positioner = @getPositioner(ev)

		$target = $(ev.getCurrentTarget())
		@_accept(ev, globalDrag, $target)

	initDropHelper: ($target) ->
		@dropHelper = $div("#{@_dropHelper} cui-droppable-drop-helper cui-drag-drop-select-transparent")
		# CUI.debug "adding drop helper", $target[0], @dropHelper[0]
		@dropHelper.css(position: "absolute")
		if CUI.DOM.isPositioned($target[0])
			@dropHelper.css(top: 0, left: 0)
		else
			@dropHelper.css($target.relativePosition())
		@dropHelper.appendTo($target)
		@dropHelper.css
			width: $target.outerWidth(true)
			height: $target.outerHeight(true)
		@

	hideDropHelper: ->
		if not @dropHelper
			return
		DOM.hideElement(@dropHelper[0])

	showDropHelper: ($target) ->
		if not @dropHelper
			if @_dropHelper
				@initDropHelper($target)
			return
		DOM.showElement(@dropHelper[0])

	removeDropHelper: ->
		# CUI.debug "removing drop helper", @getUniqueId(), @dropHelper?[0]
		if not @dropHelper
			return
		@dropHelper.remove()
		@dropHelper = null

	destroy: ->
		@removeDropHelper()
		super()

	init: ->
		# console.error "register droppable on", @element
		Events.listen
			node: @element
			type: ["cui-dragenter", "cui-drop", "cui-dragleave", "cui-dragover"]
			call: (ev) =>
				console.debug ev.getType(), ev


		Events.listen
			node: @element
			type: "cui-drop"
			instance: @
			selector: @_selector
			call: (ev) =>
				# CUI.debug "cui-drop", ev.getCurrentTarget()
				if @accept(ev) != false
					ev.stopPropagation()
					# this registered for any of the available droppable
					@_drop(ev, globalDrag, $(ev.getCurrentTarget()))
				return

		Events.listen
			node: @element
			type: "cui-dragenter"
			instance: @
			selector: @_selector
			call: (ev, info) =>
				ev.stopPropagation()
				$target = $(ev.getCurrentTarget())
				# CUI.debug "cui-dragenter", ev.getCurrentTarget()
				if @_positioners
					@preparePositioners($target)

				if @accept(ev) == false
					return

				$target.addClass(@_hoverClass)
				@showDropHelper($target)
				return

		Events.listen
			node: @element
			type: "cui-dragleave"
			instance: @
			selector: @_selector
			call: (ev, info) =>
				# CUI.debug ev.type, ev.currentTarget, @element[0], @dropHelper?[0]
				ev.stopPropagation()
				$target = $(ev.getCurrentTarget())
				# CUI.debug "cui-dragleave", ev.getCurrentTarget()
				if @_positioners
					@removePositioners()
				$target.removeClass(@_hoverClass)
				@removeDropHelper()
				return

		Events.listen
			node: @element
			type: "cui-dragover"
			instance: @
			selector: @_selector
			call: (ev, info) =>
				ev.stopPropagation()
				$target = $(ev.getCurrentTarget())
				# CUI.debug "cui-dragover", ev.getCurrentTarget()

				switch @accept(ev)
					when false
						$target.removeClass(@_hoverClass)
						@hideDropHelper()
						if @_positioners
							@before.remove()
							@after.remove()
					when "positioner"
						$target.removeClass(@_hoverClass)
						@hideDropHelper()
						switch globalDrag.positioner.position
							when "before"
								@after.remove()
								@parent.append(@before)
							when "after"
								@before.remove()
								@parent.append(@after)
					else
						if @_positioners
							@before.remove()
							@after.remove()
						$target.addClass(@_hoverClass)
						@showDropHelper()
				return


	removePositioners: ->
		@parent.find(".cui-positioner.break").remove()
		@before = null
		@after = null

	preparePositioners: ($el) ->
		@parent = $($el.offsetParent)
		assert @parent.length, "Droppable.preparePositioners", "No parent found for element", element: $el
		# @makeElementRelative @parent

		if @before
			return

		#CUI.debug "preparing positioners", @parent

		# determine if horizontal or vertical
		if Math.floor(@parent[0].clientWidth / $el.outerWidth(true)) > 1
			@direction = "vertical"
		else
			@direction = "horizontal"


		# add a before and after break
		@before = $div("break cui-positioner before #{@direction}")
		@after = $div("break cui-positioner after #{@direction}")

		@offset = $el.offset()

		pos = $el.position()
		pos.left += @parent[0].scrollLeft
		pos.left += parseInt($el.css("margin-left"))
		pos.top += @parent[0].scrollTop
		pos.top += parseInt($el.css("margin-top"))
		dim =
			width: $el.outerWidth(false)
			height: $el.outerHeight(false)

		@offset.bottom = @offset.top + dim.height
		@offset.right = @offset.left + dim.width

		# append to DOM tree, so we get the correct measurements
		@before.css(opacity: 0)
		@after.css(opacity: 0)

		@parent.append(@after)
		@parent.append(@before)

		# CUI.debug @before, @before.outerHeight(true), @before.outerWidth(true)
		switch @direction
			when "horizontal"
				@before.css
					top: pos.top - @before.outerHeight(true)
					left: pos.left
					width: dim.width

				@after.css
					top: pos.top + dim.height
					left: pos.left
					width: dim.width
			when "vertical"
				@before.css
					top: pos.top
					left: pos.left - @before.outerWidth(true)
					height: dim.height

				@after.css
					top: pos.top
					left: pos.left + dim.width
					height: dim.height

		@after.remove()
		@before.remove()

		@after.css opacity: ""
		@before.css opacity: ""


	# returns distance and name of the active positioner
	getPositioner: (ev) ->
		# CUI.debug "getPositioner", ev.originalEvent.pageX, ev.originalEvent.pageY, @offset
		switch @direction
			when "horizontal"
				dist_before = ev.pageY() - @offset.top
				dist_after = @offset.bottom - ev.pageY()
			when "vertical"
				dist_before = ev.pageX() - @offset.left
				dist_after = @offset.right - ev.pageX()

		if dist_before > dist_after
			position: "after", distance: dist_after
		else
			position: "before", distance: dist_before


Droppable = CUI.Droppable
