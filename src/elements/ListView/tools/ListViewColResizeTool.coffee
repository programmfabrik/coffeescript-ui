class ListViewColResizeTool extends ListViewHoverTool
	mousemove: (ev) =>

		return if not @info.cell

		# CUI.debug "col resize tool mousemove...", ev, @info, @info.cell.row_i, @lV.fixedRowsCount

		if @info.cell.row_i >= @lV.fixedRowsCount
			return

		if @info.cell.pos.left <= @threshold and @info.cell.display_col_i > 0
			@info.cell.col_i = @lV.getColIdx(@info.cell.display_col_i-1)
			resize = true

		# CUI.debug "getCellGridRect", @info.cell.col_i, @info.cell.row_i, @info.cell.pos, resize

		if @info.cell.pos.left >= @lV.getColWidth(@info.cell.col_i) - @threshold or resize
			# CUI.debug @lV.getColdef(@info.cell.col_i), @info.cell.col_i
			#
			coldef = @lV.getColdef(@info.cell.col_i)
			if coldef == "fixed"
				return

			# CUI.debug "getCellGridRect", @info.cell.col_i, @info.cell.row_i #, rect.left, rect.width
			rect = @lV.getCellGridRect(@info.cell.col_i, @info.cell.row_i)

			# CUI.debug @info.cell.col_i, @info.cell.row_i, rect

			if not rect
				return

			CUI.debug "ListViewColResizeTool:", "left:", @info.cell.pos.left, "width:", rect.width, "threshold:", @threshold

			# if coldef == "maximize"
			# 	# for 100% columns the actual width is greater than the reported
			# 	# width so we need to double check
			# 	if not (@info.cell.pos.left >= rect.width - @threshold)
			# 		return

			ev.stopImmediatePropagation()

			@info.cell.width = rect.width

			# CUI.debug "Create movable DIV", rect.left, rect.width

			@movableDiv = @createMovableDiv "col-resize-marker", false,
				left: rect.left + rect.width
				top: 0
				height: @lV.getGrid().height()

			Events.listen
				node: @movableDiv
				type: "dblclick"
				call: (ev) =>
					@movableDiv.remove()
					@lV.resetColWidth(@info.cell.col_i)

	startDrag: (ev, $target, diff, movable) ->
		@new_width = null
		@markedCol = @markCol()

	doDrag: (ev, $target, diff, movable) ->
		x = diff.x + movable.start.x
		y = 0

		new_width = diff.x + @info.cell.width # + movable.scrollDeltaX
		# CUI.debug "width", @info.cell.width, diff.x, new_width

		if new_width < 10
			@new_width = 10
			return

		@markedCol.css(width: new_width)
		@new_width = new_width
		movable.setElementCss(x: x, y: y)


	endDrag: ->
		return if not @new_width
		@lV.setColWidth(@info.cell.col_i, @new_width)
