###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListView extends CUI.SimplePane

	@defaults:
		row_move_handle_tooltip: "Drag to move row"

	#Construct a new ListView.
	#
	# @param [Object] options for listview creation
	# @option options [String] TODO
	constructor: (@opts={}) ->
		super(@opts)
		@initListView()

	initListView: ->

		@fixedColsCount = @_fixedCols
		@fixedRowsCount = @_fixedRows

		@__cols = @_cols.slice(0)

		if @_colClasses
			@__colClasses = @_colClasses.slice(0)

		if @_rowMove
			assert(not @_rowMovePlaceholder, "new ListView", "opts.rowMove cannot be used with opts.rowMovePlaceholder", opts: @opts)

		if @_rowMove or @_rowMovePlaceholder
			@__cols.splice(0,0, "fixed")
			if not @__colClasses
				@__colClasses = []
			@__colClasses.splice(0,0, "cui-lv-row-move-handle-column")

		assert(@fixedColsCount < @__cols.length, "new ListView", "opts.fixedCols must be less than column count.", opts: @opts)

		if @_colResize
			@__colResize = true
		else if @fixedRowsCount > 0 and @_colResize == undefined
			@__colResize = true

		if @__colResize
			assert(@fixedRowsCount > 0, "new ListView", "Cannot enable col resize with no fixed rows.", opts: @opts)

		@__maxCols = []
		for col, col_i in @__cols
			assert(col in ["auto", "maximize", "fixed", "manual"], "new #{@__cls}", "Unkown type of col: \"#{col}\". opts.cols can only contain \"auto\" and \"maximize\" elements.")
			if col == "maximize"
				# assert(@_maximize, "new ListView", "maximized columns can only exist inside an maximized ListView", opts: @opts)
				assert(col_i >= @fixedColsCount, "new ListView", "maximized columns can only be in the non-fixed side of the ListView.", opts: @opts)
				@__maxCols.push(col_i)

		if @__maximize_horizontal and @__maxCols.length == 0
			# auto-max the last column
			len = @__cols.length - 1
			if len >= @fixedColsCount
				@__maxCols.push(len)
				@__cols[len] = 'maximize'

		# CUI.debug @fixedColsCount, @fixedRowsCount, @__maxCols, @__cols, @tools
		@rowsCount = 0
		@colsCount = @__cols.length

		@listViewCounter = ListView.counter++

		# @cssUniqueId = "list-view-#{@listViewCounter}-style"

		@__manualColWidths = []
		@__colspanRows = {}

		@colsOrder = []
		for col_i in [0...@colsCount]
			@colsOrder.push(col_i)
		@rowsOrder = []

		@__maxRowIdx = -1

		@__resetCellDims()

		@__cells = []
		@__rows = []
		@__lvClass = "cui-lv-#{@listViewCounter}"

		@__deferredRows = []
		@__isInDOM = false

		@__doLayoutBound = =>
			@__doLayout()

		@addClass("cui-list-view")


	initOpts: ->
		super()

		@addOpts
			colClasses:
				check: "Array"
			cols:
				mandatory: true
				check: "Array"
			fixedCols:
				default: 0
				check: "Integer"
			fixedRows:
				default: 0
				check: "Integer"
			# this adds an extra column at the beginning
			# it also adds a dummy colClasses item if colClasses
			# are set
			rowMove:
				default: false
				check: Boolean
			rowMoveFixedRows:
				default: 0
				check: "Integer"
			# if set, add a rowMovePlaceholder to
			# all rows
			rowMovePlaceholder:
				default: false
				check: Boolean
			colResize:
				check: Boolean
			selectableRows:
				check: (v) ->
					v == false or v == true or v == "multiple"
			onSelect:
				check: Function
			onDeselect:
				check: Function
			onRowMove:
				check: Function
			onScroll:
				check: Function
			header:
				deprecated: true
			footer:
				deprecated: true


	readOpts: ->
		if @opts.header
			@opts.header_center = @opts.header

		if @opts.footer
			@opts.footer_left = @opts.footer

		super()
		@__selectableRows = @_selectableRows
		@

	destroy: ->
		# CUI.error "#{getObjectClass(@)}.destroy list-view-#{@listViewCounter} called. This is NOT an error."
		delete(@colsOrder)
		delete(@rowsOrder)
		delete(@__fillRowQ3)
		# @hideWaitBlock()
		@__isInDOM = null
		CUI.scheduleCallbackCancel(call: @__doLayoutBound)
		@listViewTemplate?.destroy()
		@__layoutIsStopped = false

		super()
		@

	getListViewClass: ->
		@__lvClass

	getGrid: ->
		@grid

	hasResizableColumns: ->
		@__colResize

	hasMovableRows: ->
		@_rowMove

	isInactive: ->
		!!@__inactive

	setInactive: (inactive, addClass="inactive") ->
		@__inactive = !!inactive
		if @grid
			if @__inactive
				CUI.DOM.addClass(@grid, addClass)
				@__inactiveWaitBlock = new WaitBlock(element: @grid, inactive: true).show()
			else
				@__inactiveWaitBlock?.destroy()
				@__inactiveWaitBlock = null
				CUI.DOM.removeClass(@grid, addClass)
		@

	render: ->
		assert(not @grid, "ListView.render", "ListView already rendered", opts: @opts)
		html = []

		cls = ["cui-list-view-grid", @__lvClass]

		if @_fixedCols == 1 and (@_rowMove or @_rowMovePlaceholder)
			cls.push("cui-list-view-grid-fixed-col-has-only-row-move-handle")

		if @_rowMovePlaceholder
			cls.push("cui-list-view-has-row-move-placeholder")

		if @_rowMove
			cls.push("cui-list-view-has-row-move")

		if @__maxCols.length > 0
			cls.push("cui-list-view-grid-has-maximized-columns")

		if @fixedColsCount > 0
			cls.push("cui-list-view-grid-has-fixed-cols")

		if @fixedRowsCount > 0
			cls.push("cui-list-view-grid-has-fixed-rows")

		html.push("<div class=\"")
		html.push(cls.join(" "))
		html.push("\">")
		html.push("<style></style>")

		add_quadrant = (qi) =>
			if qi is 3
				# add tabindex="-1"
				html.push("<div cui-lv-quadrant=\"#{qi}\" class=\"cui-drag-scroll cui-list-view-grid-quadrant cui-lv-tbody cui-list-view-grid-quadrant-#{qi} #{@__lvClass}-quadrant\" tabindex=\"-1\">")
			else
				html.push("<div cui-lv-quadrant=\"#{qi}\" class=\"cui-drag-scroll cui-list-view-grid-quadrant cui-lv-tbody cui-list-view-grid-quadrant-#{qi} #{@__lvClass}-quadrant\">")

			if qi in [2, 3]
				html.push("<div class=\"cui-lv-tr-fill-outer\"><div class=\"cui-lv-tr\">")
				ft = @__getColsFromAndTo(qi)
				for col_i in [ft.from..ft.to] by 1
					cls = @__getColClass(col_i)
					html.push("<div class=\"#{cls} cui-lv-td cui-lv-td-fill cui-list-view-grid-fill-col-#{col_i}\"></div>")
				html.push("</div></div>")
			html.push("</div>")
			return

		if @fixedColsCount > 0 and @fixedRowsCount > 0
			html.push("<div class=\"cui-list-view-grid-inner-top\">")
			add_quadrant(0)
			add_quadrant(1)
			html.push("</div>")

			html.push("<div class=\"cui-list-view-grid-inner-bottom\">")
			add_quadrant(2)
			add_quadrant(3)
			html.push("</div>")
		else if @fixedColsCount > 0
			html.push("<div class=\"cui-list-view-grid-inner-bottom\">")
			add_quadrant(2)
			add_quadrant(3)
			html.push("</div>")
		else if @fixedRowsCount > 0
			html.push("<div class=\"cui-list-view-grid-inner-top\">")
			add_quadrant(1)
			html.push("</div>")
			html.push("<div class=\"cui-list-view-grid-inner-bottom\">")
			add_quadrant(3)
			html.push("</div>")
		else
			add_quadrant(3)

		html.push("</div>")

		outer = @center()
		outer.innerHTML = html.join("")
		@grid = outer.firstChild

		@quadrant = [
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-0")[0]
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-1")[0]
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-2")[0]
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-3")[0]
		]

		@styleElement = CUI.DOM.matchSelector(outer, "style")[0]

		@__fillRowQ3 = CUI.DOM.matchSelector(@grid, ".cui-list-view-grid-fills-3")[0]

		@__topQuadrants = CUI.DOM.matchSelector(outer, ".cui-list-view-grid-inner-top")[0]

		if (@fixedColsCount == 0 and @fixedRowsCount == 0 ) # we only have Q3
			@__bottomQuadrants = @quadrant[3]
		else
			@__bottomQuadrants = CUI.DOM.matchSelector(outer, ".cui-list-view-grid-inner-bottom")[0]

		@__fillCells = []
		for col in [0..@colsCount-1] by 1
			@__fillCells.push(CUI.DOM.matchSelector(outer, ".cui-list-view-grid-fill-col-#{col}")[0])

		# CUI.debug "ListView[#{@listViewCounter}]:", "fixedCols:", @fixedColsCount, "fixedRow", @fixedRowsCount, "cols:", @colsCount, "rows:", @__deferredRows.length

		on_scroll = =>
			@__syncScrolling()
			@_onScroll?()

		Events.listen
			node: @quadrant[3]
			type: "scroll"
			call: on_scroll
			# (ev) =>
			# 	CUI.scheduleCallback
			# 		ms: 20
			# 		call: on_scroll
			# 	return

		@__currentScroll = top: 0, left: 0

		if @hasSelectableRows()

			selector = "."+@__lvClass+"-quadrant > .cui-lv-tr-outer"

			# Events.listen
			# 	type: ["touchstart"]
			# 	node: @DOM
			# 	call: (ev) =>
			# 		# console.debug "touchstart prevent default", @DOM
			# 		ev.preventDefault()

			Events.listen
				type: ["click"]
				node: @DOM
				selector: selector
				call: (ev) =>
					row = DOM.data(ev.getCurrentTarget(), "listViewRow")
					if not row.isSelectable()
						return
					ev.stopImmediatePropagation()
					ret = @selectRow(ev, row)
					return


		if @quadrant[2]
			Events.listen
				type: "wheel"
				node: @quadrant[2]
				call: (ev) =>
					scroll_delta = 100

					if ev.wheelDeltaY() > 0
						if @quadrant[3].scrollTop == (@quadrant[3].scrollHeight - @quadrant[3].offsetHeight)
							# at bottom
							return

						@quadrant[3].scrollTop += scroll_delta

					else if ev.wheelDeltaY() < 0
						if @quadrant[3].scrollTop == 0
							# at top
							return

						@quadrant[3].scrollTop -= scroll_delta
					else
						return

					ev.preventDefault()
					on_scroll()
					return

		Events.listen
			type: "viewport-resize"
			node: @grid
			call: (ev, info) =>
				# console.error "ListView[##{@listViewCounter}][#{ev.getDebug()}]:",@DOM[0],"hasLayout: ", @__hasLayout, @, info
				if not @__hasLayout
					return

				@__doLayout(resetRows: !!(info.css_load or info.tab))
				return

		Events.listen
			type: "content-resize"
			node: @DOM
			call: (ev, info) =>
				if not @__isInDOM
					return

				cell = DOM.closest(ev.getNode(), ".cui-lv-td")

				if not cell
					return

				ev.stopPropagation()

				row = parseInt(cell.getAttribute("row"))
				col = parseInt(cell.getAttribute("col"))

				if @fixedColsCount > 0 and DOM.getAttribute(cell.parentNode, "cui-lv-tr-unmeasured")
					# row has not been measured
					return

				@__resetRowDim(row)
				@__scheduleLayout()
				return

		if CUI.defaults.debug
			@__addDebugControl()

		if @isInactive()
			@setInactive(true)

		# if @__showWaitBlock
		# 	@showWaitBlock()

		@appendDeferredRows()

		DOM.waitForDOMInsert(node: @DOM)
		.done =>
			@__isInDOM = true
			@__doLayout()
		@DOM

	__getScrolling: ->
		dim =
			top: @quadrant[3].scrollTop
			left: @quadrant[3].scrollLeft
			height: @quadrant[3].scrollHeight
		dim

	getScrollingContainer: ->
		@quadrant[3]

	__setScrolling: (scroll) ->
		@quadrant[3].scrollTop = scroll.top
		@quadrant[3].scrollLeft = scroll.left

	__syncScrolling: ->

		@__currentScroll = @__getScrolling()
		# CUI.debug "__syncScrolling", @__currentScroll

		if @fixedColsCount > 0
			@quadrant[2].scrollTop = @__currentScroll.top
		if @fixedRowsCount > 0
			@quadrant[1].scrollLeft = @__currentScroll.left

		if @__fillRowQ3
			@__fillRowQ3.style.width = ""
			@__fillRowQ3.style.width = @__getValue(@__fillRowQ3.scrollWidth)
		@

	__setMargins: ->
		width = @quadrant[3].offsetWidth - @quadrant[3].clientWidth
		height = @quadrant[3].offsetHeight -  @quadrant[3].clientHeight

		@quadrant[1]?.style.marginRight = @__getValue(width)
		@quadrant[2]?.style.marginBottom = @__getValue(height)
		@

	getSelectedRows: ->
		# console.time "getSelectedRows"
		sel_rows = []
		for row_i in @rowsOrder
			listViewRow = @getListViewRow(row_i)
			if listViewRow.isSelected()
				sel_rows.push(listViewRow)
		# console.timeEnd "getSelectedRows"
		sel_rows

	hasSelectableRows: ->
		!!@__selectableRows

	selectRowById: (row_id) ->
		@selectRow(null, @getListViewRow(row_id), true)

	selectRowByDisplayIdx: (row_display_idx) ->
		@selectRowById(@getRowIdx(row_display_idx))

	selectRow: (ev, row, no_deselect=false) ->
		assert(isNull(row) or row instanceof ListViewRow, "#{@__cls}.setSelectedRow", "Parameter needs to be instance of ListViewRow.", selectedRow: row)

		dfr = new CUI.Deferred()

		do_select = =>
			if row.isSelected()
				if not no_deselect
					row.deselect(ev, row).done(dfr.resolve).fail(dfr.reject)
				else
					dfr.resolve()
			else
				row.select(ev).done(dfr.resolve).fail(dfr.reject)
			return

		if @__selectableRows == true # only one row
			promises = []
			for _row in @getSelectedRows()
				if row == _row
					# we handle this in do_select
					continue

				ret = _row.deselect(ev, row)
				if isPromise(ret)
					promises.push(ret)
			CUI.when(promises).done(do_select).fail(dfr.reject)
		else
			do_select()

		dfr.promise()

	getCellByTarget: ($target) ->
		if CUI.DOM.is($target, ".cui-lv-td")
			cell =
				col_i: parseInt($target.getAttribute("col"))
				row_i: parseInt($target.getAttribute("row"))

			# CUI.debug "getCellByTarget", $target[0], cell.col_i, cell.row_i

			# cell.$element = $target
			cell.display_col_i = @getDisplayColIdx(cell.col_i)
			cell.display_row_i = @getDisplayRowIdx(cell.row_i)
			cell
		else
			null

	getRowMoveTool: (opts = {}) ->
		new CUI.ListViewRowMove(opts)

	getListViewRow: (row_i) ->
		DOM.data(@getRow(row_i)[0], "listViewRow")

	getDisplayColIdx: (col_i) ->
		@colsOrder.indexOf(parseInt(col_i))

	getDisplayRowIdx: (row_i) ->
		@rowsOrder.indexOf(parseInt(row_i))

	getColIdx: (display_col_i) ->
		assert(CUI.isArray(@colsOrder), "ListView[#{@listViewCounter}].getColIdx", "colsOrder Array is missing", this: @, display_col_i: display_col_i)
		@colsOrder[display_col_i]

	getRowIdx: (display_row_i) ->
		@rowsOrder[display_row_i]

	moveInOrderArray: (from_i, to_i, array, after) ->
		display_from_i = array.indexOf(from_i)
		display_to_i = array.indexOf(to_i)

		moveInArray(display_from_i, display_to_i, array, after)
		null

	moveRow: (from_i, to_i, after=false, trigger_row_moved=true) ->

		assert(from_i >= @fixedRowsCount and to_i >= @fixedRowsCount, "ListView.moveRow", "from_i and to_i must not be in flexible area of the list view", from_i: from_i, to_i: to_i, fixed_i: @fixedRowsCount)

		if after
			func = "after"
		else
			func = "before"

		# console.debug "moveRow", from_i, to_i, after, @rowsOrder.join(",")
		for row, idx in @getRow(from_i)
			@getRow(to_i)[idx][func](row)

		display_from_i = @getDisplayRowIdx(from_i)
		display_to_i = @getDisplayRowIdx(to_i)

		@moveInOrderArray(from_i, to_i, @rowsOrder, after)

		if trigger_row_moved
			@_onRowMove?(display_from_i, display_to_i, after)
			Events.trigger
				type: "row_moved"
				node: @grid
				info:
					from_i: from_i
					to_i: to_i
					display_from_i: display_from_i
					display_to_i: display_to_i
					after: after
		@


	rowAddClass: (row_i, cls) ->
		rows = @getRow(row_i)
		if not rows
			return
		for row in rows
			CUI.DOM.addClass(row, cls)
		@

	rowRemoveClass: (row_i, cls) ->
		rows = @getRow(row_i)
		if not rows
			return
		for row in rows
			DOM.removeClass(row, cls)
		@

	getColdef: (col_i) ->
		@__cols[col_i]

	getColsCount: ->
		@colsCount

	resetColWidth: (col_i) ->
		# CUI.debug "resetColWidth", col_i
		delete(@__manualColWidths[col_i])
		@__resetColWidth(col_i)
		@__doLayout(resetRows: true)
		@

	setColWidth: (col_i, width) ->
		# CUI.debug "setColWidth", col_i, width
		@__manualColWidths[col_i] = Math.max(5, width)
		delete(@__colWidths[col_i])
		@__doLayout(resetRows: true)
		@

	getManualColWidth: (col_i) ->
		@__manualColWidths[col_i]

	getRowHeight: (row_i) ->
		@__rows[row_i][0].offsetHeight

	getColWidth: (col_i) ->
		@__colWidths[col_i]

	getCellGridRect: (row_i, col_i) ->

		cell = @__cells[row_i]?[col_i]
		if not cell
			return null

		grid_rect = CUI.DOM.getRect(@grid)
		pos_grid =
			top: grid_rect.top
			left: grid_rect.left
		dim = CUI.DOM.getDimensions(cell)

		rect =
			left_abs: dim.clientBoundingRect.left
			top_abs: dim.clientBoundingRect.top
			left: dim.clientBoundingRect.left - pos_grid.left
			top: dim.clientBoundingRect.top - pos_grid.top
			width: dim.borderBoxWidth
			height: dim.borderBoxHeight
			contentWidthAdjust: dim.contentWidthAdjust
			contentHeightAdjust: dim.contentHeightAdjust

		# console.debug "dim:", cell, rect
		rect


	getRowGridRect: (row_i) ->
		_rect =
			width: 0

		for row in @__rows[row_i]
			dim = CUI.DOM.getDimensions(row)
			_rect.width = _rect.width + dim.borderBoxWidth

			if not _rect.hasOwnProperty("height")
				_rect.height = dim.borderBoxHeight
				_rect.top = dim.clientBoundingRect.top

			if not _rect.hasOwnProperty("left")
				_rect.left = dim.clientBoundingRect.left

		grid_rect = CUI.DOM.getRect(@grid)
		_pos_grid =
			top: grid_rect.top
			left: grid_rect.left

		rect =
			left_abs: _rect.left
			top_abs: _rect.top
			left: _rect.left - _pos_grid.left
			top: _rect.top - _pos_grid.top
			height: _rect.height

		rect.width = CUI.DOM.width(@getGrid())
		return rect

		# rect = @getCellGridRect(0, row_i)
		# rect.width = @getGrid().width()
		# rect

	appendRow: (row, _defer=!@grid) ->
		if _defer
			@__deferRow(row)
		else
			@appendRows([row])

	prependRow: (row) ->
		assert(not @isDestroyed(), "ListView.prependRow", "ListView #{@listViewCounter} is already destroyed.")
		row_i = ++@__maxRowIdx
		@rowsCount++
		@rowsOrder.splice(0, 0, row_i)
		@__addRow(row_i, row, "prepend")

	replaceRow: (row_i, row) ->
		@__addRow(row_i, row, "replace")

	insertRowAt: (display_row_i, row) ->
		assert(not @isDestroyed(), "ListView.insertRowAfter", "ListView #{@listViewCounter} is already destroyed.")
		# CUI.debug "insertRowAt", display_row_i, @rowsCount
		if display_row_i == @rowsCount or @rowsCount == 0
			@appendRow(row)
		else if display_row_i == 0
			@prependRow(row)
		else
			@insertRowBefore(@getRowIdx(display_row_i), row)

	insertRowAfter: (sibling_row_i, row) ->
		assert(not @isDestroyed(), "ListView.insertRowAfter", "ListView ##{@listViewCounter} is already destroyed.")
		sibling_display_row_i = @getDisplayRowIdx(sibling_row_i)
		assert(sibling_display_row_i > -1, "ListView.insertRowAfter", "ListView ##{@listViewCounter}: Row #{sibling_row_i} not found.", row_i: sibling_row_i, row: row, rowsCount: @rowsCount)
		row_i = ++@__maxRowIdx
		@rowsCount++
		@rowsOrder.splice(sibling_display_row_i+1, 0, row_i)
		@__addRow(row_i, row, "after", sibling_row_i)

	insertRowBefore: (sibling_row_i, row) ->
		assert(not @isDestroyed(), "ListView.insertRowBefore", "ListView ##{@listViewCounter} is already destroyed.")

		sibling_display_row_i = @getDisplayRowIdx(sibling_row_i)
		if sibling_display_row_i == 0
			return @prependRow(row)
		before_row_i = @getRowIdx(sibling_display_row_i-1)
		row_i = ++@__maxRowIdx
		@rowsCount++
		@rowsOrder.splice(sibling_display_row_i, 0, row_i)
		@__addRow(row_i, row, "after", before_row_i)

	removeAllRows: ->
		for row_i in @rowsOrder.slice(0)
			@removeRow(row_i)
		@__scheduleLayout()
		@

	removeDeferredRow: (listViewRow) ->
		count = removeFromArray(listViewRow, @__deferredRows)
		assert(count == 1, "ListView.removeListViewRow", "row not found", listViewRow: listViewRow)
		@

	removeRow: (row_i) ->
		assert(row_i != null and row_i >= 0, "ListView.removeRow", "row_i must be >= 0", row_i: row_i)
		display_row_i = @getDisplayRowIdx(row_i)
		assert(display_row_i > -1, "ListView.removeRow", "display_row_id not found for row_i", row_i: row_i)

		@rowsOrder.splice(display_row_i, 1)
		@rowsCount--
		delete(@__colspanRows[row_i])
		for row in @getRow(row_i)
			CUI.DOM.remove(row)

		delete(@__rows[row_i])
		@__resetRowDim(row_i)
		delete(@__cells[row_i])
		@__scheduleLayout()
		@

	appendDeferredRows: ->
		if @__deferredRows.length
			@appendRows(@__deferredRows)
			@__deferredRows = []
		@

	getRow: (row_i) ->
		@__rows[row_i]

	getBottom: ->
		@__bottomQuadrants

	getTop: ->
		@__topQuadrants

	__scheduleLayout: ->
		# console.error "ListView.__scheduleLayout", @__lvClass
		if not @__isInDOM
			return

		if @layoutIsStopped()
			@__layoutAfterStart = true
			return

		CUI.scheduleCallback(ms: 10, call: @__doLayoutBound)
		@

	layoutIsStopped: ->
		@__layoutIsStopped

	stopLayout: ->
		# CUI.error @getUniqueId(), "stopping layout..."
		if @__layoutIsStopped
			false
		else
			@__layoutIsStopped = true
			true

	startLayout: ->
		# CUI.error @getUniqueId(), "starting layout..."
		if @__layoutAfterStart
			@__layoutAfterStart = false
			@__doLayout()
		@__layoutIsStopped = null
		@

	__doLayout: (opts={}) ->

		css = []
		add_css = (col_i, width) =>
			css.push("."+@__lvClass+"-cell[col=\""+col_i+"\"] { width: #{width}px !important; flex: 0 0 auto !important;}")
		# console.debug @__fillCells.length, @__maxCols, @getColIdx(@__fillCells.length-2), @__manualColWidths[col_i]
		has_max_cols = false
		has_manually_sized_column =  false

		# set width on colspan cells
		@__colWidths = []
		for fc, display_col_i in @__fillCells
			col_i = @getColIdx(display_col_i)
			manual_col_width = @__manualColWidths[col_i]
			if manual_col_width > 0
				has_manually_sized_column =  true

				add_css(col_i, manual_col_width)
				fc.style.setProperty("width", manual_col_width+"px")
				fc.style.setProperty("flex", "0 0 auto")
			else
				if col_i in @__maxCols
					has_max_cols = true

				fc.style.removeProperty("width")
				fc.style.removeProperty("flex")

		for fc, display_col_i in @__fillCells
			col_i = @getColIdx(display_col_i)
			@__colWidths[col_i] = fc.offsetWidth

		if @__maximize_horizontal
			if not has_max_cols and has_manually_sized_column
				CUI.DOM.addClass(@grid, "cui-lv--max-last-col")
			else
				CUI.DOM.removeClass(@grid, "cui-lv--max-last-col")

		@styleElement.innerHTML = css.join("\n")

		for row_i, row_info of @__colspanRows
			for col_i, colspan of row_info
				cell = DOM.matchSelector(@grid, "."+@__lvClass+"-cell[row=\""+row_i+"\"][col=\""+col_i+"\"]")[0]
				width = 0
				for i in [0...colspan] by 1
					# we assume that colspanned columns
					# are never torn apart, so it is
					# safe to add "1" here
					width = width + @__colWidths[parseInt(col_i)+i]

				# console.debug row_i, col_i, colspan, width

				dim = CUI.DOM.getDimensions(cell)
				if dim.computedStyle.boxSizing == "border-box"
					cell.style.setProperty("width", width+"px", "important")
				else
					cell.style.setProperty("width", (width - dim.paddingHorizontal - dim.borderHorizontal)+"px", "important")

		if @fixedColsCount >  0
			# find unmeasured rows in Q2 & Q3 and set height
			# in Q2
			for qi in [0, 2]
				rows = []
				if opts.resetRows
					sel = ".cui-lv-tr-outer"
				else
					sel = "[cui-lv-tr-unmeasured=\""+@listViewCounter+"\"]"

				for row in DOM.matchSelector(@grid, "."+@__lvClass+"-quadrant[cui-lv-quadrant='#{qi}'] > "+sel)
					rows[parseInt(DOM.getAttribute(row, "row"))] = row
					DOM.removeAttribute(row, "cui-lv-tr-unmeasured")

				for row, idx in DOM.matchSelector(@grid, "."+@__lvClass+"-quadrant[cui-lv-quadrant='#{qi+1}'] > "+sel)
					row_i2 = parseInt(DOM.getAttribute(row, "row"))
					DOM.prepareSetDimensions(rows[row_i2])
					row.__offsetHeight = row.offsetHeight

				for row, idx in DOM.matchSelector(@grid, "."+@__lvClass+"-quadrant[cui-lv-quadrant='#{qi+1}'] > "+sel)
					row_i2 = parseInt(DOM.getAttribute(row, "row"))
					DOM.setDimensions(rows[row_i2], borderBoxHeight: row.__offsetHeight)
					delete(row.__offsetHeight)
					DOM.removeAttribute(row, "cui-lv-tr-unmeasured")



		@__setMargins()

		@__addRowsOddEvenClasses()

		if not @__maximize_horizontal or not @__maximize_vertical
			Events.trigger
				type: "content-resize"
				exclude_self: true
				node: @DOM

		@__hasLayout = true
		@


	__addRowsOddEvenClasses: ->
		if (@rowsCount - @fixedRowsCount)%2 == 0
			CUI.DOM.addClass(@grid, "cui-list-view-grid-rows-even")
			CUI.DOM.removeClass(@grid, "cui-list-view-grid-rows-odd")
		else
			CUI.DOM.removeClass(@grid, "cui-list-view-grid-rows-even")
			CUI.DOM.addClass(@grid, "cui-list-view-grid-rows-odd")
		@


	__getValue: (px) ->
		if not isNaN(parseFloat(px))
			px+"px"
		else if isNull(px)
			""
		else
			px

	hideWaitBlock: ->
		if @__waitBlock
			@__waitBlock.destroy()
			delete(@__waitBlock)
		@

	showWaitBlock: ->
		if @__waitBlock
			return @
		@__waitBlock = new WaitBlock(element: @DOM)
		@__waitBlock.show()
		@

	__debugRect: (func, ms) ->
		viewport = @grid.rect()
		@grid.rect(true, 500, "ListView[##{@listViewCounter}].#{func} #{ms}ms "+viewport.width+"x"+viewport.height)

	appendRows: (rows) ->
		assert(not @isDestroyed(), "ListView.appendRow", "ListView #{@listViewCounter} is already destroyed.")
		for row, idx in rows
			row_i = ++@__maxRowIdx
			if idx == 0
				start_row_i = row_i

			@rowsCount++
			@rowsOrder.push(row_i)

		@__addRows(start_row_i, rows)
		@

	__getColsFromAndTo: (qi) ->
		switch qi
			when 0, 2
				from: 0
				to: @fixedColsCount-1
			when 1, 3
				from: @fixedColsCount
				to: @colsCount-1

	__deferRow: (row) ->
		@__deferredRows.push(row)

	__addRow: (row_i, listViewRow=null, mode="append", sibling_row_i=null) ->
		@__addRows(row_i, [listViewRow], mode, sibling_row_i)

	# return the two quadrant pairs for the
	# given row.
	__getQuadrants: (row_i) ->
		if @getDisplayRowIdx(row_i) < @fixedRowsCount
			[0,1]
		else
			[2,3]

	__addRows: (_row_i, listViewRows=[], mode="append", sibling_row_i=null) ->
		assert(@grid, "ListView.__addRows", "ListView.render has not been called yet.", row_i: _row_i, listView: @)

		assert(mode in ["append", "prepend", "after", "replace"], "ListView.__addRows", "mode \"#{mode}\" not supported", row_i: _row_i)

		txt = "ListView[#{@listViewCounter}].__addRows: Adding "+listViewRows.length+" rows, starting at #{_row_i}."

		# CUI.debug("__addRows", _row_i, listViewRows, mode, sibling_row_i)

		html = [[],[],[],[]]

		# if @__hasLayout
		#	@__prepareForLayout()

		_mode = mode

		if _mode == "after" and @getDisplayRowIdx(_row_i) == @fixedRowsCount
			# sibling is in other quadrant
			mode = "prepend"

		if mode in ["replace", "after"]
			switch mode
				when "replace"
					assert(listViewRows.length == 1, "ListView.__addRows", "Can only use mode \"#{mode}\" on one row", listViewRows: listViewRows)
					row_i = _row_i
					@__resetRowDim(row_i)
				when "after"
					row_i = sibling_row_i

			anchor_row = @__rows[row_i]
			assert(anchor_row.length >= 1, "ListView.__addRows", "anchor row #{row_i} for mode #{mode} not found.", rows: @__rows, row_i: row_i, mode: _mode, mode_used: mode)
			# CUI.debug("__addRows", anchor_row, row_i)

		# prepare html for all rows
		for row_i in [_row_i..row_i+listViewRows.length-1] by 1
			@__cells[row_i] = []
			@__rows[row_i] = []

			for qi in @__getQuadrants(row_i)
				ft = @__getColsFromAndTo(qi)

				if ft.to < ft.from
					continue

				if @fixedColsCount > 0
					html[qi].push("<div class=\"cui-lv-tr-outer\" cui-lv-tr-unmeasured=\"#{@listViewCounter}\" row=\"#{row_i}\"><div class=\"cui-lv-tr\">")
				else
					html[qi].push("<div class=\"cui-lv-tr-outer\" row=\"#{row_i}\"><div class=\"cui-lv-tr\">")

				for display_col_i in [ft.from..ft.to] by 1
					col_i = @getColIdx(display_col_i)
					[width, maxi] = @__getColWidth(row_i, col_i)
					cls = @__getColClass(col_i)
					html[qi].push("<div class=\"cui-lv-td #{cls} #{@__lvClass}-cell\" col=\"#{col_i}\" row=\"#{row_i}\"></div>")

				html[qi].push("</div></div>")

		find_cells_and_rows = (top) =>
			# find rows and cells in newly prepared html
			_cells = CUI.DOM.matchSelector(top, ".cui-lv-td")
			for cell in _cells
				_col = parseInt(cell.getAttribute("col"))
				_row = parseInt(cell.getAttribute("row"))
				@__cells[_row][_col] = cell

			_rows = CUI.DOM.matchSelector(top, ".cui-lv-tr-outer")

			for row in _rows
				row_i = parseInt(row.getAttribute("row"))
				@__rows[row_i].push(row)

			return

		anchor_row_idx = 0
		for qi in [0..3]
			if html[qi].length == 0
				continue

			outer = document.createElement("div")

			outer.innerHTML = html[qi].join("")
			find_cells_and_rows(outer)

			if mode == "append"
				if qi in [2, 3]
					# the last row is the fill row, make sure to
					# insert our node before
					while node = outer.firstChild
						@quadrant[qi].insertBefore(node, @quadrant[qi].lastChild)
				else
					while node = outer.firstChild
						@quadrant[qi].appendChild(node)

				continue

			if mode == "prepend"
				while node = outer.lastChild
					@quadrant[qi].insertBefore(node, @quadrant[qi].firstChild)
				continue

			row = anchor_row[anchor_row_idx]

			# CUI.debug "qi", qi, anchor_row, anchor_row.length, html[qi]
			anchor_row_idx++

			if mode == "after"
				while node = outer.lastChild
					row.after(node)
				continue

			if mode == "replace"
				node = outer.firstChild
				CUI.DOM.replaceWith(row, node)

		# check for overflow in fixed qudrant
		if @fixedRowsCount > 0
			fixedRows = @quadrant[1].childNodes
			if @fixedRowsCount < fixedRows.length
				if @fixedColsCount > 0
					_qi_s = [0,1]
				else
					_qi_s = [1]

				for i in [0...fixedRows.length-@fixedRowsCount] by 1
					for _qi in _qi_s
						if @quadrant[_qi+2].firstChild
							@quadrant[_qi+2].insertBefore(@quadrant[_qi].lastChild, @quadrant[_qi+2].firstChild)
						else
							@quadrant[_qi+2].appendChild(@quadrant[_qi].lastChild)

		for listViewRow, idx in listViewRows
			if isPromise(listViewRow)
				do (idx) =>
					listViewRow.done (_listViewRow) =>
						@__appendCells(_listViewRow, _row_i+idx)
			else
				@__appendCells(listViewRow, _row_i+idx)

		@__scheduleLayout()

		# console.timeEnd(txt)
		@


	__appendCells: (listViewRow, row_i) ->
		assert(listViewRow instanceof ListViewRow, "ListView.addRow", "listViewRow needs to be instance of ListViewRow or Deferred which returns a ListViewRow", listViewRow: listViewRow)

		listViewRow.setRowIdx(row_i).setListView(@)

		for row in @__rows[row_i]
			DOM.data(row, "listViewRow", listViewRow)

		listViewRow.addClass((listViewRow.getClass() or "")+" "+toDash(getObjectClass(listViewRow)))

		if @_rowMove
			if @getDisplayRowIdx(row_i) >= @fixedRowsCount + @_rowMoveFixedRows
				if listViewRow.getColumns()[0] not instanceof ListViewColumnRowMoveHandle
					listViewRow.prependColumn(new ListViewColumnRowMoveHandle())
			else
				if listViewRow.getColumns()[0] not instanceof ListViewColumnRowMoveHandlePlaceholder
					listViewRow.prependColumn(new ListViewColumnRowMoveHandlePlaceholder())
		else if @_rowMovePlaceholder
			if listViewRow.getColumns()[0] not instanceof ListViewColumnRowMoveHandlePlaceholder
				listViewRow.prependColumn(new ListViewColumnRowMoveHandlePlaceholder())

		_cols = listViewRow.getColumns()

		colspan_offset = 0
		for col, col_i in _cols
			node = col.render()

			cell = @__cells[row_i][col_i+colspan_offset]

			assert(cell, "ListView.__appendCells", "Cell not found: row: "+row_i+" column: "+(col_i+colspan_offset+1)+". colsCount: "+@colsCount, row: listViewRow)

			if not isNull(node)
				CUI.DOM.append(cell, node)

			col.setColumnIdx(col_i)
			col.setElement(cell)

			colspan = col.getColspan()
			assert(col_i+colspan_offset+colspan-1 < @colsCount, "ListView.__appendCells", "Colspan #{colspan} exceeds cols count #{@colsCount}, unable to append cell.", row_i: row_i, col_i: col_i, colspan_offset: colspan_offset, colspan: colspan, column: col, row: listViewRow, ListView: @)
			if colspan > 1
				cell.setAttribute("colspan", colspan)

				# we remember the colspan here for the addCss
				# class, its important to do this before we change
				# colspan_offset
				if not @__colspanRows[row_i]
					@__colspanRows[row_i] = {}
				@__colspanRows[row_i][col_i+colspan_offset] = colspan

				# delete the real column ids which are supposed
				# to hide to the right of us
				# if they are not in order, this is not our problem
				# at this point
				for i in [1...colspan]
					@__cells[row_i][col_i+colspan_offset+1].remove()
					delete(@__cells[row_i][col_i+colspan_offset+1])
					colspan_offset++


		assert(_cols.length+colspan_offset <= @colsCount, "ListView.addRow", "ListViewRow provided more columns (#{_cols.length+colspan_offset}) than colsCount (#{@colsCount}) is set to", colsCount: @colsCount, cols: _cols)
		listViewRow.addedToListView(@__rows[row_i])

		return

	__getColClass: (col_i) ->
		col_cls = @__colClasses?[col_i]
		cls = []
		if CUI.isArray(col_cls)
			cls.push.apply(cls, col_cls)
		else if not isEmpty(col_cls)
			cls.push(col_cls)

		if col_i in @__maxCols
			cls.push("cui-lv-td-max")
		cls.join(" ")

	__resetRowDim: (row_i) ->
		delete(@__cellDims[row_i])
		delete(@__rowHeights[row_i])

		if @fixedColsCount > 0 and @__rows[row_i]
			for row in @__rows[row_i]
				DOM.setAttribute(row, "cui-lv-tr-unmeasured", @listViewCounter)

		for display_col_i in [0..@colsCount-1]
			col_i = @getColIdx(display_col_i)
			@__resetCellStyle(row_i, col_i)
		@

	__resetCellStyle: (row_i, col_i) ->
		cell = @__cells[row_i]?[col_i]
		if cell
			CUI.DOM.setStyleOne(cell, "cssText", "")
		cell

	__resetColWidth: (col_i) ->
		for dim in @__cellDims
			if dim
				delete(dim[col_i])

		for display_row_i in [0..@rowsCount-1]
			row_i = @getRowIdx(display_row_i)
			@__resetCellStyle(row_i, col_i)

		@__fillCells[col_i].style.cssText = ""
		@

	__resetCellDims: (col_i) ->
		@__cellDims = []
		@__colWidths = []
		@__rowHeights = []

	__isMaximizedCol: (col_i) ->
		col_i in @__maxCols and not @__manualColWidths.hasOwnProperty(col_i)

	@counter: 0

	# use row_i == null to not check for colspan
	__getColWidth: (row_i, col_i) ->
		colspan = @__colspanRows[row_i]?[col_i]
		if colspan > 1
			accWidth = 0
			maxi = false
			for _col_i in [col_i..col_i+colspan-1] by 1
				if @__isMaximizedCol(_col_i)
					maxi = true
				accWidth += @__colWidths[_col_i]
			[accWidth, maxi]
		else
			[@__colWidths[col_i], @__isMaximizedCol(col_i)]



	__debugCall: (name, func) ->
		if not CUI.defaults.debug
			return func()

		getMs = ->
			(new Date()).getTime()

		start = getMs()
		func()
		end = getMs()
		@__debugRect(name, end - start)

	__addDebugControl: ->
		Events.listen
			type: "contextmenu"
			node: @DOM
			call: (ev) =>
				if not (ev.altKey() and not (ev.ctrlKey() or ev.shiftKey() or ev.metaKey()))
					return

				ev.preventDefault()
				ev.stopPropagation()

				@grid.rect(true, 500)

				get_maximize_text = (name, on_off) =>
					name+": "+(if on_off then "ON" else "OFF")

				items = [
					label: "ListView[##{@listViewCounter}] Debug Menu"
				,
					text: "layout"
					onClick: =>
						@__debugCall "__doLayout", =>
							@__doLayout(resetRows: true)
				,
					text: "flash"
					onClick: =>
						@grid.rect(true, 1000, "ListView[##{@listViewCounter}]")
				,
					text: "debug"
					onClick: =>
						@__debugCall "debug", =>
							CUI.debug("ListView[##{@listViewCounter}]", @)
							CUI.debug("opts:", @opts)
							CUI.debug("manualColWidths:", dump(@__manualColWidths))
							CUI.debug("colWidths:", dump(@__colWidths), "rowHeights:", @__rowHeights)
				,
					text: "appendRow"
					onClick: =>
						lv = new ListViewRow()
						for col, display_col_i in @_cols
							col_i = @getColIdx(display_col_i)
							lv.addColumn(new ListViewColumn(text: @getColdef(col_i)+" "+@rowsCount))
						@appendRow(lv)
				,
					text: "removeRow"
					onClick: =>
						@removeRow(@getRowIdx(@rowsCount-1))
				,
					text: "close"
					onClick: =>
						@__control.destroy()
				]

				(new Menu
					auto_close_after_click: false
					itemList:
						items: items
					show_at_position:
						top: ev.pageY()
						left: ev.pageX()
				).show()
				return false
		@

