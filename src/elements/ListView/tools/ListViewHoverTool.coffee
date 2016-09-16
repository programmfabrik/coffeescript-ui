class ListViewHoverTool extends ListViewTool

	threshold: 5

	mousemoveEvent: (ev, @info) ->
		if ev.isImmediatePropagationStopped()
			CUI.debug "prop is stopped"
			return

		if @__hasMarker
			@removeMarker()

		@mousemove(ev)

	mousemove: (ev) ->
		CUI.debug("ListViewHoverTool mousemove must be overwritten", ev)

	startDrag: (ev, $target, diff, movable) ->
		CUI.debug("ListViewHoverTool startDrag must be overwritten")

	doDrag: (ev, $target, diff, movable) ->
		CUI.debug("ListViewHoverTool doDrag must be overwritten")

	endDrag: ->
		CUI.debug("ListViewHoverTool endDrag must be overwritten")

	createMovableDiv: (tname, transparent, css) ->
		# CUI.debug "createMovableDiv", dump(css)
		md = @appendMarker(tname, transparent, css)

		Events.listen
			type: "mouseleave"
			node: md
			call: =>
				@removeMarker()

		md.appendTo(@lV.getGrid())

		# @movableTargetDiv = $div("movable-target-div no-user-select").hide().appendTo(@lV.getGrid())
		# CUI.debug("createMovableDiv", css, @movableDiv[0])
		new Movable
			element: md
			start_drag: (ev, $target, diff, movable) =>
				@startDrag(ev, $target, diff, movable)

			do_drag: (ev, $target, diff, movable) =>
				@doDrag(ev, $target, diff, movable)

			dragend: (ev, globalDrag, movable) =>
				@removeMarker(true)
				if ev.getType() == "mouseup"
					@endDrag()
		md

	markRow: (row_i = @info.cell.row_i) ->
		rect = @lV.getRowGridRect(row_i)
		# CUI.debug("markRow", row_i, rect)
		@appendMarker "row-marker", true,
			top: rect.top
			left: rect.left
			width: rect.width
			height: rect.height

	markCol: (col_i = @info.cell.col_i) ->
		rect = @lV.getCellGridRect(col_i, 0)
		@appendMarker "col-marker", true,
			top: rect.top
			left: rect.left
			width: rect.width
			height: @lV.getGrid().height()

	appendMarker: (tname, transparent=true, css=null) ->
		tmpl = new Template(name: "list-view-tool-#{tname}")
		tmpl.addClass("cui-list-view-tool cui-demo-node-copyable")
		if transparent
			tmpl.addClass("cui-list-view-tool cui-drag-drop-select-transparent")
		if css
			tmpl.DOM.css(css)
		tmpl.DOM.appendTo(@lV.getGrid())
		@__hasMarker = true
		tmpl.DOM

	removeMarker: (force = false) ->
		if not force and globalDrag
			return false

		@__hasMarker = false
		for el in CUI.DOM.matchSelector(document.documentElement, ".cui-list-view-tool:not(.cui-demo-node-copy)")
			el.remove()

		return true
