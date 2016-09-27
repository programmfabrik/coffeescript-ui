class ListViewTreeRowMoveTool extends ListViewRowMoveTool

	initOpts: ->
		super()
		@addOpts
			rowMoveWithinNodesOnly:
				check: Boolean

	mousemove: (ev) ->
		return if not @info.cell

		lvr = @lV.getListViewRow(@info.cell.row_i)
		if lvr not instanceof ListViewTreeNode
			return
		super(ev)


	startDrag: ->
		super()

		@blockedRows = [@info.cell.row_i]

		lvr = @lV.getListViewRow(@info.cell.row_i)
		height = @lV.getRowHeight(lvr.getRowIdx())

		for row, idx in lvr.getRowsToMove()
			row_i = row.getRowIdx()
			@blockedRows.push(row_i)
			height += @lV.getRowHeight(row_i)
			@movableMarkers.push(@markRow(row_i)[0])

		@movableDiv.css(height: height)

	showHorizontalTargetMarker: (cell) ->

		@showHorizontalTargetMarkerSetTarget(cell)
		@blockedAfterRows = [@target.before_row_i]
		@blockedBeforeRows = [@target.after_row_i]

		node = @lV.getListViewRow(@info.cell.row_i)

		# CUI.debug "moving node", @info.cell.row_i, node.getChildIdx(), node.getRowIdx()

		if (ci = node.getChildIdx()) < node.father.children.length-1
			@blockedBeforeRows.push(node.father.children[ci+1].getRowIdx())

		if not @allowRowMove()
			@target = null
			@movableTargetDiv.hide()
		else
			@movableTargetDiv.css
				display: "block"
				left: @target.left
				top: @target.top
				width: @target.width
				height: @target.height


	allowRowMove: ->
		allow = true
		# CUI.debug @target.row_i, @target.after, @blockedBeforeRows, @blockedRows, @blockedAfterRows

		if @target.row_i in @blockedRows or
			(@target.row_i in @blockedAfterRows and @target.after) or
				(@target.row_i in @blockedBeforeRows and not @target.after)
			return false

		[ from_node, to_node, new_father ] = @lV.getNodesForMove(@info.cell.row_i, @target.row_i, @target.after)

		if @_rowMoveWithinNodesOnly and new_father
			return false

		# ask the source node, if it is ok to move it
		if not from_node.allowRowMove(to_node, new_father, @target.after)
			return false

		return true
