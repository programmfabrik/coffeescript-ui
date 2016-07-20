class ListViewRowResizeTool extends ListViewHoverTool
	mousemove: (ev) =>
		return if not @info.cell

		if @info.cell.pos.top <= @lV.opts.threshold and @info.cell.display_row_i > 0
			@info.cell.row_i = @lV.getRowIdx(@info.cell.display_row_i-1)
			resize = true

		if @info.cell.pos.top >= @lV.getRowHeight(@info.cell.row_i) - @lV.opts.threshold or resize
			ev.stopImmediatePropagation()
			@info.cell.height = @lV.getRowHeight(@info.cell.row_i)
			@createMovableDiv
				cursor: "row-resize"
				display: "block"
				left: @lV.getColLeftAbsolute(@info.cell.col_i)
				width: @lV.getColWidth(@info.cell.col_i)
				height: @lV.opts.threshold*2
				top: @lV.getRowHeight(@info.cell.row_i)-@lV.opts.threshold+@lV.getRowTopAbsolute(@info.cell.row_i)

			Events.listen
				node: @movableDiv
				type: "dblclick"
				call: (ev) =>
					@lV.resetRowHeight(@info.cell.row_i)
					@movableDiv.remove()

	startDrag: (ev, $target, diff, movable) =>
		@new_height = null
		@movableDiv.css
			left: 0
			width: @lV.viewport.width-@lV.scrollbar.vertical
		@markRow()

	doDrag: (ev, $target, diff, movable) =>
		x = 0
		y = diff.y + movable.start.y
		new_height = diff.y + @info.cell.height + movable.scrollDeltaY

		if new_height < 10
			@new_height = 10
			return

		@movableMarkers.css height: new_height
		@new_height = new_height
		movable.setElementCss x: x, y: y


	endDrag: =>
		return if not @new_height

		@lV.setRowHeight(@info.cell.row_i, @new_height)
