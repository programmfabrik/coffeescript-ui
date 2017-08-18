###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewColResize extends CUI.ListViewDraggable

	initOpts: ->
		super()
		@removeOpt("helper")
		@addOpts
			row:
				mandatory: true
				check: ListViewRow
			column:
				mandatory: true
				check: ListViewColumn

	readOpts: ->
		super()
		@__row_i = @_row.getRowIdx()
		@__display_row_i = @_row.getDisplayRowIdx()
		@__listView = @_row.getListView()
		@__col_i = @_column.getColumnIdx()

		Events.listen
			type: "dblclick"
			node: @_element
			instance: @
			call: (ev) =>
				console.debug "list view", @__listView, @__col_i, @__row_i
				@__listView.resetColWidth(@__col_i)

		return

	get_axis: ->
		"x"

	get_cursor: (gd) ->
		"ew-resize"

	get_helper: (ev, gd, diff) ->
		@get_marker("cui-lv-col-resize")

	get_init_helper_pos: ->
		rect = @__listView.getCellGridRect(@__row_i, @__col_i)
		@__contentWidthAdjust = rect.contentWidthAdjust

		left: rect.left_abs
		top: rect.top_abs
		width: rect.width
		height: @__listView.getGrid().offsetHeight


	get_helper_pos: (ev, $target, diff) ->
		helper_pos = super(ev, $target, diff)
		# left stays
		helper_pos.left = CUI.globalDrag.helperNodeStart.left
		@__new_width = CUI.globalDrag.helperNodeStart.width + diff.x
		helper_pos.width = @__new_width

		helper_pos

	start_drag: (ev, $target, diff) ->
		super(ev, $target, diff)

		@__inital_width = @__listView.getManualColWidth(@__col_i)
		@

	do_drag: (ev, $target, diff) ->
		super(ev, $target, diff)
		if CUI.browser.ie
			return

		@__setColWidth(@__new_width)

	stop_drag: (ev) ->
		super(ev)
		if @__inital_width
			@__listView.setColWidth(@__col_i, @__initial_width)
		else
			@__listView.resetColWidth(@__col_i)

	__setColWidth: (width) ->
		@__listView.setColWidth(@__col_i, width - @__contentWidthAdjust)

	end_drag: (ev) ->
		super(ev)
		@__setColWidth(@__new_width)

	destroy: ->
		Events.ignore(instance: @)
		super()
