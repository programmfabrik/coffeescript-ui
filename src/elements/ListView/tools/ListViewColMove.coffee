###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewColMove extends CUI.ListViewDraggable

	initOpts: ->
		super()
		@removeOpt("helper")
		@addOpts
			row:
				mandatory: true
				check: CUI.ListViewRow
			column:
				mandatory: true
				check: CUI.ListViewColumn

	readOpts: ->
		super()
		@__row_i = @_row.getRowIdx()
		@__display_row_i = @_row.getDisplayRowIdx()
		@__listView = @_row.getListView()
		@__col_i = @_column.getColumnIdx()
		@__display_col_i = @__listView.getDisplayColIdx(@__col_i)

	get_helper: (ev, gd, diff) ->
		helper = @get_marker("cui-lv-col-move")
		# Make the helper more visible and copy the header content
		headerCell = @_column.getElement()
		if headerCell
			helper.innerHTML = headerCell.innerHTML

		CUI.dom.setStyle(helper,
			backgroundColor: "rgba(255, 102, 0, 0.9)"
			border: "2px solid #ff6600"
			borderRadius: "4px"
			opacity: "0.9"
			color: "white"
			fontWeight: "bold"
			textAlign: "center"
			lineHeight: "normal"
			padding: "4px"
		)
		helper

	get_helper_contain_element: ->
		@__listView.getGrid()

	get_axis: ->
		"x"

	get_cursor: (gd) ->
		"move"

	get_init_helper_pos: (node, gd) ->
		# Get the position directly from the header cell element
		headerCell = @_column.getElement()
		if headerCell
			rect = CUI.dom.getRect(headerCell)
			return {
				top: rect.top
				left: rect.left
				width: rect.width
				height: rect.height
			}

		# Fallback to ListView method if direct element access fails
		rect = @__listView.getCellGridRect(@__row_i, @__col_i)
		top: rect.top_abs
		left: rect.left_abs
		width: rect.width
		height: rect.height

	init_helper: ->
		@movableTargetDiv = @get_marker("cui-lv-col-move-target")
		CUI.dom.append(@__listView.getGrid(), @movableTargetDiv)
		super()

	do_drag: (ev, $target, diff) ->
		super(ev, $target, diff)

		cell = @__listView.getCellByTarget($target)

		if cell
			cell.clientX = ev.clientX()
			cell.clientY = ev.clientY()

			# Only allow dropping on header row and non-fixed columns
			if cell.display_row_i == 0 and cell.display_col_i >= @__listView.fixedColsCount
				@showVerticalTargetMarker(cell)
			else
				# Hide target marker if not over valid drop zone
				CUI.dom.setStyle(@movableTargetDiv, display: "none")
				@target = null

		return

	showVerticalTargetMarker: (cell) ->
		# Don't show marker if trying to drop on the same column
		if cell.col_i == @__col_i
			CUI.dom.setStyle(@movableTargetDiv, display: "none")
			@target = null
			return

		# Get the header cell directly from DOM instead of using getCellGridRect
		headerCells = CUI.dom.matchSelector(@__listView.getGrid(), ".cui-lv-th")
		targetHeaderCell = null

		for headerCell in headerCells
			if parseInt(CUI.dom.getAttribute(headerCell, "col")) == cell.col_i
				targetHeaderCell = headerCell
				break

		if not targetHeaderCell
			CUI.dom.setStyle(@movableTargetDiv, display: "none")
			@target = null
			return

		# Get position from the actual DOM element
		rect = CUI.dom.getRect(targetHeaderCell)

		# Use quarters for better control - more permissive than thirds but still intuitive
		# Left 40% = before, right 40% = after, middle 20% = prefer the closer edge
		leftBoundary = rect.left + rect.width * 0.3
		rightBoundary = rect.left + rect.width * 0.7

		if cell.clientX < leftBoundary
			showAfter = false  # Insert before
		else if cell.clientX > rightBoundary
			showAfter = true   # Insert after
		else
			# In the middle 40% - choose based on which edge is closer
			middle = rect.left + rect.width / 2
			showAfter = cell.clientX > middle

		# Calculate position relative to the grid container
		gridRect = CUI.dom.getRect(@__listView.getGrid())

		if showAfter
			left = rect.left + rect.width - gridRect.left
		else
			left = rect.left - gridRect.left

		top = rect.top - gridRect.top

		# Make the marker more visible - only show it in the header area
		CUI.dom.setStyle(@movableTargetDiv,
			display: "block"
			left: left + "px"
			top: top + "px"
			width: "4px"
			height: rect.height + "px"
			backgroundColor: "#ff6600"
			borderRadius: "2px"
			boxShadow: "0 0 8px rgba(255, 102, 0, 0.6)"
			zIndex: "1000"
		)

		@target =
			col_i: cell.col_i
			after: showAfter

	cleanup_drag: (ev) ->
		super(ev)
		CUI.dom.remove(@movableTargetDiv)
		@movableTargetDiv = null

	end_drag: (ev) ->
		super(ev)

		if not @target
			return

		source_col_i = @__col_i
		target_col_i = @target.col_i

		# Don't move if source and target are the same
		if source_col_i == target_col_i
			return

		CUI.globalDrag.noClickKill = true

		@__listView.moveCol(source_col_i, target_col_i, @target.after)

	destroy: ->
		super()

CUI.ready ->
	CUI.Events.registerEvent
		type: "column_moved"
		bubble: true
