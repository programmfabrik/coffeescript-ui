class ListViewRowMoveTool extends ListViewHoverTool

	mousemove: (ev) =>
		if not @info.cell
			return

		if ev.isImmediatePropagationStopped()
			return

		if @info.cell.display_row_i < @lV.fixedRowsCount
			return

		if @info.$target.is(".cui-list-view-row-move-handle[allow-row-move]")
			if not @lV.getListViewRow(@info.cell.row_i).isMovable(ev)
				return
			ev.stopImmediatePropagation()
			rect = @lV.getCellGridRectByNode(@info.$target)
			rect.width = @lV.getGrid().width()
			@movableDiv = @createMovableDiv("row-move-marker", true, rect)
			Movable.getInstance(@movableDiv[0]).startDrag(ev, @movableDiv)

		return

	startDrag: ->
		@movableTargetDiv = @appendMarker("row-move-target")
		@movableMarkers = @markRow()
		# get first row
		@__rect_top = @lV.getRowGridRect(@lV.getRowIdx(@lV.fixedRowsCount))

	doDrag: (ev, $target, diff, movable) ->

		x = 0
		y = diff.y + movable.start.y

		y = Math.max(y, @__rect_top.top)

		# rect_bottom can change due to open/close of tree nodes while dragging
		rect_bottom = @lV.getRowGridRect(@lV.getRowIdx(@lV.rowsCount-1))
		y = Math.min(y, rect_bottom.top)

		movable.setElementCss(x: x, y: y)

		cell = @lV.getCellByTarget($target)

		if cell
			cell.clientX = ev.clientX()
			cell.clientY = ev.clientY()

			if cell.display_row_i >= @lV.fixedRowsCount
				@showHorizontalTargetMarker(cell)
		return

	endDrag: ->
		# CUI.debug "end drag...", @target
		if not @target
			return

		source_node = @lV.getListViewRow(@info.cell.row_i)
		target_node = @lV.getListViewRow(@target.row_i)
		if source_node.moveRow
			source_node.moveRow(@lV, target_node, @target.after)
		else
			@lV.moveRow(@info.cell.row_i, @target.row_i, @target.after)


	showHorizontalTargetMarker: (cell) ->

		@showHorizontalTargetMarkerSetTarget(cell)

		# if @target.after and cell.display_row_i < @lV.rowsCount-1
		#	cell.display_row_i++
		#	@target.row_i = @lV.getRowIdx(cell.display_row_i)
		#	@target.after = false

		# check if the move targets the source
		if @target.row_i == @info.cell.row_i or
			(@target.before_row_i == @info.cell.row_i and @target.after == false) or
				(@target.after_row_i == @info.cell.row_i and @target.before == false)

			@target = null
			@movableTargetDiv.hide()
		else
			@movableTargetDiv.css
				display: "block"
				left: @target.left
				top: @target.top
				width: @target.width


	showHorizontalTargetMarkerSetTarget: (cell) ->
		@target = row_i: cell.row_i

		# find out if the mouse points to the upper half or
		# lower half of the row

		row_rect = @lV.getRowGridRect(cell.row_i)

		if @info.cell.display_row_i > 0
			@target.before_row_i = @lV.getRowIdx(@info.cell.display_row_i-1)
		if @info.cell.display_row_i < @lV.rowsCount-1
			@target.after_row_i = @lV.getRowIdx(@info.cell.display_row_i+1)

		diff = cell.clientY - row_rect.top_abs

		# CUI.debug diff, cell.clientY, row_rect.top, row_rect.top_abs

		# before
		if diff < row_rect.height / 2
			@target.after = false
			@target.top = row_rect.top
		else
			@target.after = true
			@target.top = row_rect.top + row_rect.height

		# console.debug "target:", @target.before_row_i, @target.row_i, @target.after_row_i, @target.after

		@target.width = row_rect.width
		@target.left = row_rect.left

		return

