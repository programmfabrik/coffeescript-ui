###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewColMove extends CUI.ListViewDraggable

	initOpts: ->
		super()
		@addOpts
			column:
				mandatory: true
				check: CUI.ListViewHeaderColumn

	readOpts: ->
		super()
		@__listView = @_row.getListView()
		@__col_i = @_column.getColumnIdx()

	get_helper: ->
		@get_marker("cui-lv-col-move")

	get_helper_contain_element: ->
		@__listView.getGrid()

	get_axis: ->
		"x"

	get_init_helper_pos: ->
		rect = @__listView.getCellGridRect(@__row_i, @__col_i)
		grid_rect = CUI.dom.getRect(@__listView.getGrid())

		top: rect.top_abs
		left: rect.left_abs
		width: rect.width
		height: grid_rect.bottom - rect.top_abs

	init_helper: ->
		@movableTargetDiv = @get_marker("cui-lv-col-move-target")
		CUI.dom.append(@__listView.getGrid(), @movableTargetDiv)
		CUI.dom.hideElement(@movableTargetDiv)
		super()

	do_drag: (ev, $target, diff) ->
		super(ev, $target, diff)
		@__setTarget(ev.clientX())
		return

	__setTarget: (clientX) ->
		@target = null

		for column in @_row.getColumns()
			if column not instanceof CUI.ListViewHeaderColumn or not column.isMovable()
				continue

			rect = CUI.dom.getRect(column.getElement())
			if clientX < rect.left or clientX > rect.right
				continue

			target =
				col_i: column.getColumnIdx()
				after: clientX > rect.left + rect.width / 2
				rect: rect
			break

		if not target or @__isNoop(target)
			CUI.dom.hideElement(@movableTargetDiv)
			return

		@target = target

		grid_rect = CUI.dom.getRect(@__listView.getGrid())
		left = if target.after then target.rect.right else target.rect.left

		CUI.dom.showElement(@movableTargetDiv)
		CUI.dom.setStyle @movableTargetDiv,
			left: left - grid_rect.left
			top: target.rect.top - grid_rect.top
			height: grid_rect.bottom - target.rect.top
		return

	# dropping on the source column or next to it leaves the order as it is
	__isNoop: (target) ->
		display_from = @__listView.getDisplayColIdx(@__col_i)
		display_to = @__listView.getDisplayColIdx(target.col_i)

		display_to == display_from or
			(display_to == display_from - 1 and target.after) or
			(display_to == display_from + 1 and not target.after)

	cleanup_drag: (ev) ->
		super(ev)
		CUI.dom.remove(@movableTargetDiv)
		@movableTargetDiv = null

	end_drag: (ev) ->
		super(ev)

		if not @target
			return

		@__listView.moveCol(@__col_i, @target.col_i, @target.after)
		return
