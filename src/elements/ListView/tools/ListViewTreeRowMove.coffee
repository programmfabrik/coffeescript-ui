###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewTreeRowMove extends CUI.ListViewRowMove

	initOpts: ->
		super()
		@addOpts
			rowMoveWithinNodesOnly:
				check: Boolean

	get_init_helper_pos: (node, gd) ->
		pos = super(node, gd)

		@blockedRows = [@__row_i]

		height = @__listView.getRowHeight(@__row_i)

		for row, idx in @_row.getRowsToMove()
			row_i = row.getRowIdx()
			@blockedRows.push(row_i)
			height += @__listView.getRowHeight(row_i)

		pos.height = height
		pos

	showHorizontalTargetMarker: (cell) ->

		@showHorizontalTargetMarkerSetTarget(cell)
		@blockedAfterRows = [@target.before_row_i]
		@blockedBeforeRows = [@target.after_row_i]

		node = @_row

		# CUI.debug "moving node", @info.cell.row_i, node.getChildIdx(), node.getRowIdx()

		if (ci = node.getChildIdx()) < node.father.children.length-1
			@blockedBeforeRows.push(node.father.children[ci+1].getRowIdx())

		if not @allowRowMove()
			@target = null
			CUI.dom.hideElement(@movableTargetDiv)
		else
			CUI.dom.showElement(@movableTargetDiv)
			CUI.dom.setStyle @movableTargetDiv,
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

		[ from_node, to_node, new_father ] = @__listView.getNodesForMove(@__row_i, @target.row_i, @target.after)

		if @_rowMoveWithinNodesOnly and new_father
			return false

		# ask the source node, if it is ok to move it
		if not from_node.allowRowMove(to_node, new_father, @target.after)
			return false

		return true
