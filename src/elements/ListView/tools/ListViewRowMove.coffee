###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewRowMove extends CUI.ListViewDraggable

	initOpts: ->
		super()
		@removeOpt("helper")
		@addOpts
			row:
				mandatory: true
				check: CUI.ListViewRow

	readOpts: ->
		super()
		@__row_i = @_row.getRowIdx()
		@__display_row_i = @_row.getDisplayRowIdx()
		@__listView = @_row.getListView()

	get_helper: (ev, gd, diff) ->
		@get_marker("cui-lv-row-move")

	get_helper_contain_element: ->
		@__listView.getBottom()

	get_axis: ->
		"y"

	get_init_helper_pos: (node, gd) ->
		rect = @__listView.getRowGridRect(@__row_i)

		top: rect.top_abs
		left: rect.left_abs
		width: rect.width
		height: rect.height

	init_helper: ->
		@movableTargetDiv = @get_marker("cui-lv-row-move-target")
		CUI.dom.append(@__listView.getGrid(), @movableTargetDiv)
		super()

	do_drag: (ev, $target, diff) ->

		super(ev, $target, diff)

		cell = @__listView.getCellByTarget($target)

		if cell
			cell.clientX = ev.clientX()
			cell.clientY = ev.clientY()

			if cell.display_row_i >= @__listView.fixedRowsCount
				@showHorizontalTargetMarker(cell)



		return


	cleanup_drag: (ev) ->
		super(ev)
		CUI.dom.remove(@movableTargetDiv)
		@movableTargetDiv = null

	end_drag: (ev) ->
		super(ev)

		# CUI.debug "end drag...", @target
		if not @target
			return

		source_node = @_row
		target_node = @__listView.getListViewRow(@target.row_i)

		CUI.globalDrag.noClickKill = true

		if source_node.moveRow
			source_node.moveRow(@__listView, target_node, @target.after)
		else
			@__listView.moveRow(@__row_i, @target.row_i, @target.after)


	showHorizontalTargetMarker: (cell) ->

		@showHorizontalTargetMarkerSetTarget(cell)

		# if @target.after and cell.display_row_i < @lV.rowsCount-1
		#	cell.display_row_i++
		#	@target.row_i = @lV.getRowIdx(cell.display_row_i)
		#	@target.after = false

		# check if the move targets the source
		if @target.row_i == @__row_i or
			(@target.before_row_i == @__row_i and @target.after == false) or
				(@target.after_row_i == @__row_i and @target.before == false)

			@target = null
			CUI.dom.hideElement(@movableTargetDiv)
		else
			CUI.dom.showElement(@movableTargetDiv)
			CUI.dom.setStyle @movableTargetDiv,
				# display: "block"
				left: @target.left
				top: @target.top
				width: @target.width


	showHorizontalTargetMarkerSetTarget: (cell) ->
		@target = row_i: cell.row_i

		# find out if the mouse points to the upper half or
		# lower half of the row

		row_rect = @__listView.getRowGridRect(cell.row_i)

		# console.warn "row rect", cell.row_i, row_rect

		if @__display_row_i > 0
			@target.before_row_i = @__listView.getRowIdx(@__display_row_i-1)
		if @__display_row_i < @__listView.rowsCount-1
			@target.after_row_i = @__listView.getRowIdx(@__display_row_i+1)

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

