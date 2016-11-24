class CUI.ListView extends CUI.SimplePane

	#Construct a new ListView.
	#
	# @param [Object] options for listview creation
	# @option options [String] TODO
	constructor: (@opts={}) ->
		super(@opts)

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
		@__lvClass = "cui-list-view-grid-#{@listViewCounter}"

		@__deferredRows = []
		@__isInDOM = false

		if CUI.__ng__
			# always use next gen layout
			@_autoLayout = 2

		switch @_autoLayout
			when true
				@addClass("cui-list-view cui-padding-reset cui-list-view-div-layout")
			when 2
				@addClass("cui-list-view")
			else
				@addClass("cui-list-view cui-padding-reset cui-list-view-table-layout")


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
				default: false
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
			tools:
				check: "Array"
			header:
				deprecated: true
			footer:
				deprecated: true
			autoLayout:
				default: true
				check: (v) ->
					if v == true or v == false or v == 2
						true
					else
						false
			setOpacity:
				default: true
				check: Boolean


	readOpts: ->
		if @opts.header
			@opts.header_center = @opts.header

		if @opts.footer
			@opts.footer_left = @opts.footer

		super()
		@tools = []
		@fixedColsCount = @_fixedCols
		@fixedRowsCount = @_fixedRows

		@__cols = @_cols.slice(0)

		if @_colClasses
			@__colClasses = @_colClasses.slice(0)

		if @_rowMove
			assert(not @_rowMovePlaceholder, "new ListView", "opts.rowMove cannot be used with opts.rowMovePlaceholder", opts: @opts)
			@tools.push(new ListViewRowMoveTool())

		if @_rowMove or @_rowMovePlaceholder
			@__cols.splice(0,0, "fixed")
			if not @__colClasses
				@__colClasses = []
			@__colClasses.splice(0,0, "cui-list-view-row-move-handle-column")

		assert(@fixedColsCount < @__cols.length, "new ListView", "opts.fixedCols must be less than column count.", opts: @opts)

		if @_colResize or (@fixedRowsCount > 0 and @_colResize != false)
			assert(@fixedRowsCount > 0, "new ListView", "Cannot enable col resize with no fixed rows.", opts: @opts)
			@tools.push(new ListViewColResizeTool())

		@__maxCols = []
		for col, col_i in @__cols
			assert(col in ["auto", "maximize", "fixed", "manual"], "new #{@__cls}", "Unkown type of col: \"#{col}\". opts.cols can only contain \"auto\" and \"maximize\" elements.")
			if col == "maximize"
				# assert(@_maximize, "new ListView", "maximized columns can only exist inside an maximized ListView", opts: @opts)
				assert(col_i >= @fixedColsCount, "new ListView", "maximized columns can only be in the non-fixed side of the ListView.", opts: @opts)

				if not CUI.__ng__
					assert(@__maximize_horizontal, "new ListView", "maximized columns need the ListView to be set to opts.maximize_horizontal == true", opts: @opts)

				@__maxCols.push(col_i)

		# CUI.debug @fixedColsCount, @fixedRowsCount, @__maxCols, @__cols, @tools

		@

	destroy: ->
		# CUI.error "#{getObjectClass(@)}.destroy list-view-#{@listViewCounter} called. This is NOT an error."
		delete(@colsOrder)
		delete(@rowsOrder)
		delete(@__fillRowQ3)
		@hideWaitBlock()
		@__isInDOM = null
		@__cssElement?.remove()
		@__cssElement = null
		if @__scheduleLayoutTimeout
			CUI.clearTimeout(@__scheduleLayoutTimeout)
		@listViewTemplate?.destroy()
		@__layoutIsStopped = false

		super()
		@

	getListViewClass: ->
		@__lvClass

	getGrid: ->
		@grid

	hasMovableRows: ->
		@_rowMove

	isInactive: ->
		!!@__inactive

	setInactive: (inactive, addClass="inactive") ->
		@__inactive = !!inactive
		if @grid
			if @__inactive
				@grid.addClass(addClass)
				@__inactiveWaitBlock = new WaitBlock(element: @grid, inactive: true).show()
			else
				@__inactiveWaitBlock?.destroy()
				@__inactiveWaitBlock = null
				@grid.removeClass(addClass)
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
		switch @_autoLayout
			when false, 2
				html.push("<style></style>")

		add_quadrant = (qi) =>
			html.push("<div cui-lv-quadrant=\"#{qi}\" class=\"cui-drag-scroll cui-list-view-grid-quadrant cui-lv-tbody cui-list-view-grid-quadrant-#{qi}\">")
			if @_autoLayout == false
				html.push("<table class=\"cui-list-view-grid-quadrant-table\"><tbody></tbody></table>")

			if qi in [2, 3]
				switch @_autoLayout
					when 2
						html.push("<div class=\"cui-lv-tr-fill-outer\"><div class=\"cui-lv-tr\">")
					else
						html.push("<div class=\"cui-list-view-grid-fills cui-list-view-grid-fills-#{qi} cui-list-view-grid-row\">")
				ft = @__getColsFromAndTo(qi)
				for col_i in [ft.from..ft.to] by 1
					cls = @__getColClass(col_i)
					switch @_autoLayout
						when 2
							html.push("<div class=\"#{cls} cui-lv-td cui-lv-td-fill cui-list-view-grid-fill-col-#{col_i}\"></div>")
						else
							html.push("<div class=\"cui-list-view-grid-cell-fill #{cls} cui-lv-td cui-lv-td-fill cui-list-view-grid-cell-col cui-list-view-grid-cell-col-#{col_i} cui-list-view-grid-fill-col-#{col_i}\"></div>")

				switch @_autoLayout
					when 2
						html.push("</div></div>")
					else
						html.push("</div>")

			html.push("</div>")
			return

		html.push("<div class=\"cui-list-view-grid-inner-top\">")
		add_quadrant(0)
		add_quadrant(1)
		html.push("</div>")

		html.push("<div class=\"cui-list-view-grid-inner-bottom\">")
		add_quadrant(2)
		add_quadrant(3)
		html.push("</div>")
		html.push("</div>")

		outer = @center()[0]
		outer.innerHTML = html.join("")
		@grid = $(outer.firstChild)

		@quadrant = [
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-0")[0]
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-1")[0]
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-2")[0]
			CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-3")[0]
		]

		if @_autoLayout
			@quadrantRows = @quadrant
			if @_autoLayout == 2
				@styleElement = CUI.DOM.matchSelector(outer, "style")[0]
		else
			@quadrantRows = [
				CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-0 > table > tbody")[0]
				CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-1 > table > tbody")[0]
				CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-2 > table > tbody")[0]
				CUI.DOM.matchSelector(outer, ".cui-list-view-grid-quadrant-3 > table > tbody")[0]
			]
			@styleElement = CUI.DOM.matchSelector(outer, "style")[0]

		@__fillRowQ3 = CUI.DOM.matchSelector(@grid[0], ".cui-list-view-grid-fills-3")[0]

		@__topQuadrants = $(CUI.DOM.matchSelector(outer, ".cui-list-view-grid-inner-top")[0])
		@__bottomQuadrants = $(CUI.DOM.matchSelector(outer, ".cui-list-view-grid-inner-bottom")[0])

		@__fillCells = []
		for col in [0..@colsCount-1] by 1
			@__fillCells.push(CUI.DOM.matchSelector(outer, ".cui-list-view-grid-fill-col-#{col}")[0])

		# CUI.debug "ListView[#{@listViewCounter}]:", "fixedCols:", @fixedColsCount, "fixedRow", @fixedRowsCount, "cols:", @colsCount, "rows:", @__deferredRows.length

		on_scroll = =>
			@__syncScrolling()
			@_onScroll?()

		Events.listen
			node: $(@quadrant[3])
			type: "scroll"
			call: on_scroll
			# (ev) =>
			# 	CUI.scheduleCallback
			# 		ms: 20
			# 		call: on_scroll
			# 	return

		@__currentScroll = top: 0, left: 0

		if @_selectableRows
			if @_autoLayout
				selector = ".#{@__lvClass} > div > .cui-list-view-grid-quadrant > .cui-list-view-grid-row"
			else
				selector = ".#{@__lvClass} > div > .cui-list-view-grid-quadrant > table > tbody > .cui-list-view-grid-row"

			Events.listen
				type: "click"
				node: @DOM
				selector: selector
				call: (ev) =>
					ev.stopPropagation()
					# CUI.debug "click on row", ev
					row = DOM.data(ev.getCurrentTarget(), "listViewRow")
					@selectRow(ev, row)
					return


		Events.listen
			type: "wheel"
			node: $(@quadrant[2])
			call: (ev) =>
				ev.preventDefault()
				if ev.wheelDeltaY() > 0
					@quadrant[3].scrollTop += 100

				if ev.wheelDeltaY() < 0
					@quadrant[3].scrollTop -= 100

				on_scroll()

		Events.listen
			type: "viewport-resize"
			node: @grid
			call: (ev, info) =>
				# console.error "ListView[##{@listViewCounter}][#{ev.getDebug()}]:",@DOM[0],"hasLayout: ", @__hasLayout, @, info

				if not @__hasLayout
					return

				if @_autoLayout == 2
					@__doNextGenLayout(resetRows: !!(info.css_load or info.tab))
				else
					@__scheduleLayout()
				return

		Events.listen
			type: "content-resize"
			node: @DOM
			call: (ev, info) =>
				# CUI.debug("ListView[##{@listViewCounter}] caught content resize, stop.")
				if not @_autoLayout
					return

				if not @__isInDOM
					return

				cell = DOM.closest(ev.getNode(), ".cui-list-view-grid-cell")

				if not cell
					return

				ev.stopPropagation()

				row = parseInt(cell.getAttribute("row"))
				col = parseInt(cell.getAttribute("col"))

				if @_autoLayout == 2
					if DOM.getAttribute(cell.parentNode, "cui-lv-tr-unmeasured")
						# row has not been measured
						return
					@__resetRowDim(row)
					@__doLayout()
					return

				if not @__cellDims.hasOwnProperty(row)
					# row has not been measured
					return

				@__resetRowDim(row)
				@__resetColWidth(col)

				if @layoutIsStopped()
					@__scheduleLayout()
				else
					# CUI.debug("ListView[#{@listViewCounter}]: caught content resize, if this happens to often, we need to scheduleLayout again, but for now we are layouting immediately.")
					@__doLayout()

				# @__scheduleLayout()

		@__registerTools()

		if CUI.defaults.debug
			@__addDebugControl()

		if @isInactive()
			@setInactive(true)

		if @__showWaitBlock
			@showWaitBlock()

		@appendDeferredRows()

		if @_setOpacity # and @_autoLayout != 2
			@grid[0].style.opacity = "0"
		DOM.waitForDOMInsert(node: @DOM)
		.done =>
			@__isInDOM = true
			if @rowsCount == 0
				@showWaitBlock(true)

			# if @_autoLayout
			# 	@__scheduleLayout()
			# else
			@__doLayout()
			if @_setOpacity # and @_autoLayout != 2
				@grid[0].style.opacity = "1"
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

		@quadrant[1].style.marginRight = @__getValue(width)
		@quadrant[2].style.marginBottom = @__getValue(height)
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
		@_selectableRows != false

	selectRowById: (row_id) ->
		@selectRow(null, @getListViewRow(row_id), true)

	selectRowByDisplayIdx: (row_display_idx) ->
		@selectRowById(@getRowIdx(row_display_idx))

	selectRow: (ev, row, no_deselect=false) ->
		assert(isNull(row) or row instanceof ListViewRow, "#{@__cls}.setSelectedRow", "Parameter needs to be instance of ListViewRow.", selectedRow: row)
		if @_selectableRows == true # only one row
			for _row in @getSelectedRows()
				if row == _row
					continue
				_row.deselect(ev)
		if row.isSelected()
			if not no_deselect
				row.deselect(ev)
			else
				row
		else
			row.select(ev)


	getCellByTarget: ($target) ->
		if $target.is(".cui-list-view-grid-cell")
			cell =
				col_i: parseInt($target.attr("col"))
				row_i: parseInt($target.attr("row"))

			# CUI.debug "getCellByTarget", $target[0], cell.col_i, cell.row_i

			# cell.$element = $target
			cell.display_col_i = @getDisplayColIdx(cell.col_i)
			cell.display_row_i = @getDisplayRowIdx(cell.row_i)
			cell
		else
			null

	toolCellSelector: ->
		"."+@__lvClass+"-cell"


	__registerTools: ->
		if @tools.length == 0
			return

		Events.listen
			node: @grid
			type: "mousemove"
			selector: @toolCellSelector()
			call: (ev) =>
				if window.globalDrag
					return

				info = $target: $(ev.getCurrentTarget())
				info.cell = @getCellByTarget(info.$target)

				# CUI.debug "mousemove on cell", info.cell
				if not info.cell
					# quadrant 4 + 5
					return

				info.cell.pos = elementGetPosition(getCoordinatesFromEvent(ev), info.$target)

				for t in @tools
					t.mousemoveEvent(ev, info)
					if ev.isImmediatePropagationStopped()
						break

		for t in @tools
			t.registerListView(@)
		@

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

		# CUI.debug("moveRow", from_i, to_i, after, trigger_row_moved)
		for row, idx in @getRow(from_i)
			$(@getRow(to_i)[idx])[func](row)

		display_from_i = @getDisplayRowIdx(from_i)
		display_to_i = @getDisplayRowIdx(to_i)

		@moveInOrderArray(from_i, to_i, @rowsOrder, after)

		@_onRowMove?(display_from_i, display_to_i, after)

		if trigger_row_moved
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
			DOM.addClass(row, cls)
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
		@__manualColWidths[col_i] = width
		delete(@__colWidths[col_i])
		@__doLayout(resetRows: true)
		@

	getRowHeight: (row_i) ->
		@__rowHeights[row_i]

	getColWidth: (col_i) ->
		@__colWidths[col_i]

	getCellGridRect: (col_i, row_i) ->

		get_cell = (_row_i, _col_i) =>
			if @__colspanRows[_row_i]?[_col_i] > 1
				null
			else
				@__cells[_row_i][_col_i]

		cell = get_cell(row_i, col_i)
		if cell
			return @getCellGridRectByNode(cell)

		# for colspanned columns we need to
		# check other cells for the correct measurements
		rect = {}
		for display_col_i in [0...@colsCount]
			_col_i = @getColIdx(display_col_i)
			cell = get_cell(row_i, _col_i)
			if not cell
				continue

			_rect = @getCellGridRectByNode(cell)
			rect.top = _rect.top
			rect.height = _rect.height
			break

		for display_row_i in [0...@rowsCount]
			_row_i = @getRowIdx(display_row_i)
			cell = get_cell(_row_i, col_i)
			if not cell
				continue

			_rect = @getCellGridRectByNode(cell)
			rect.left = _rect.left
			rect.width = _rect.width
			break

		if CUI.isEmptyObject(rect)
			return null

		rect

	getCellGridRectByNode: (_cell) ->
		assert(isElement(_cell), "ListView.getCellGridRectByNode", "Cell node needs to be instance of HTMLElement.", cell: _cell)

		if not @_autoLayout
			cell = _cell.parent() # this is the TD, we can measure
		else
			cell = _cell

		# get absolute position relative to the grid corner
		_pos_grid = @grid.offset()
		_rect = cell.rect()

		rect =
			left_abs: _rect.left
			top_abs: _rect.top
			left: _rect.left - _pos_grid.left
			top: _rect.top - _pos_grid.top

		# rect.rect = _rect
		rect.width = cell.outerWidth(true)
		rect.height = cell.outerHeight(true)

		# CUI.debug cell, rect
		rect

	getRowGridRect: (row_i) ->
		rect = @getCellGridRect(0, row_i)
		rect.width = @getGrid().width()
		rect

	appendRow: (row, _defer=!@grid) ->
		if _defer
			@__deferRow(row)
		else
			@__appendRows([row])

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
			DOM.remove(jQuery(row))

		delete(@__rows[row_i])
		@__resetRowDim(row_i)
		delete(@__cells[row_i])
		@__scheduleLayout()
		@

	appendDeferredRows: ->
		if @__deferredRows.length
			@__appendRows(@__deferredRows)
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

		if @__scheduleLayoutTimeout
			return

		# CUI.error "ListView[#{@listViewCounter}].__scheduleLayout", @
		@__scheduleLayoutTimeout = CUI.setTimeout =>
			@__scheduleLayoutTimeout = null

			if not @__hasLayout and @rowsCount > 0
				r = @grid.rect()
				# CUI.debug "not rendering list view #{@listViewCounter} width== 0 and height== 0", @rowsCount
				if r.width == 0 or r.height == 0
					CUI.error "ListView.__scheduleLayout, size of 0 x 0, not layouting."
					return

			# CUI.error "ListView[#{@listViewCounter}].__scheduleLayout doing layout", @
			# CUI.debug "rendering list view #{@listViewCounter}", @rowsCount
			@__doLayout()
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
		for el in DOM.findElements(@getGrid()[0], ".list-view-row-new")
			el.classList.remove("list-view-row-new")

		# console.error "ListView.__doLayout...##{@listViewCounter}", @, @__lvClass, @_autoLayout

		switch @_autoLayout
			when true
				@__doAutoLayout()
			when 2
				@__doNextGenLayout(opts)
			else
				@__doManualLayout()

		@hideWaitBlock(true)

		if not @__maximize_horizontal or not @__maximize_vertical
			dim = DOM.getDimensions(@DOM[0])
			if @__layoutDim
				if @__layoutDim.clientWidth != dim.clientWidth or
					@__layoutDim.clientHeight != dim.clientHeight
						# CUI.debug "ListView[#{@listViewCounter}]: dim changed, triggering content-resize."
						Events.trigger
							type: "content-resize"
							exclude_self: true
							node: @DOM

			@__layoutDim = dim

		@__hasLayout = true
		@


	__doNextGenLayout: (opts={}) ->
		# console.time "next-gen-layout"
		# FIXME: improve selectors, so they only catch the current table not nested ones
		#

		# console.debug "ListView##{@listViewCounter}.__doNextGenLayout..."

		if @grid.clientWidth == 0 or @grid.clientHeight == 0
			console.warn("ListView##{@listViewCounter}.__doNextGenLayout: clientWidth or clientHeight is 0, not layouting.")
			return

		# console.error "doing next gen layout", @listViewCounter

		css = []
		add_css = (col_i, width) =>
			css.push("."+@__lvClass+"-cell[col=\""+col_i+"\"] { width: #{width}px !important; flex: 0 0 auto !important;}")

		# set width on colspan cells
		col_width = []
		for fc, display_col_i in @__fillCells
			col_i = @getColIdx(display_col_i)
			manual_col_width = @__manualColWidths[col_i]
			if manual_col_width > 0
				add_css(col_i, manual_col_width)
				col_width[col_i] = manual_col_width
				fc.style.setProperty("width", manual_col_width+"px")
				fc.style.setProperty("flex", "0 0 auto")
			else
				col_width[col_i] = fc.offsetWidth
				fc.style.removeProperty("width")
				fc.style.removeProperty("flex")

		for row_i, row_info of @__colspanRows
			for col_i, colspan of row_info
				cell = DOM.matchSelector(@grid[0], "[row=\""+row_i+"\"][col=\""+col_i+"\"]")[0]
				width = 0
				for i in [0...colspan] by 1
					# we assume that colspanned columns
					# are never torn apart, so it is
					# safe to add "1" here
					width = width + col_width[parseInt(col_i)+i]

				if width == 0
					console.error "col width == 0", row_i, col_i, colspan, col_width
				# console.debug row_i, col_i, colspan, width

				dim = CUI.DOM.getDimensions(cell)
				if dim.computedStyle.boxSizing == "border-box"
					cell.style.setProperty("width", width+"px", "important")
				else
					cell.style.setProperty("width", (width - dim.paddingHorizontal - dim.borderHorizontal)+"px", "important")

		# CUI.info("ListView#"+@listViewCounter, "Set colspan cell styles.")

		@styleElement.innerHTML = css.join("\n")
		# CUI.info("ListView#"+@listViewCounter, "Set manual col widths.")

		if @fixedColsCount >  0
			# find unmeasured rows in Q2 & Q3 and set height
			# in Q2
			for qi in [0, 2]
				rows = []
				if opts.resetRows
					sel = ".cui-lv-tr-outer"
				else
					sel = "[cui-lv-tr-unmeasured=\""+@listViewCounter+"\"]"

				for row in DOM.matchSelector(@grid[0], "[cui-lv-quadrant='#{qi}'] "+sel)
					rows[parseInt(DOM.getAttribute(row, "row"))] = row
					DOM.removeAttribute(row, "cui-lv-tr-unmeasured")

				for row, idx in DOM.matchSelector(@grid[0], "[cui-lv-quadrant='#{qi+1}'] "+sel)
					row_i2 = parseInt(DOM.getAttribute(row, "row"))

					# console.debug "Set ROW", idx, row_i2, row.offsetHeight
					DOM.setDimensions(rows[row_i2], borderBoxHeight: row.offsetHeight)
					DOM.removeAttribute(row, "cui-lv-tr-unmeasured")

			# CUI.info("ListView#"+@listViewCounter, "Synced row heights in Q0 and Q1.")

		@__setMargins()
		# CUI.info("ListView#"+@listViewCounter, "Set margins on Q1 and Q2.")

		@__addRowsOddEvenClasses()
		# console.timeEnd "next-gen-layout"
		@

	__doManualLayout: ->
		css = []
		set_width_for_max_cols = []
		max_width = null

		# remove all styles from the table
		@styleElement.innerHTML = ""

		# dont set width on fill div
		@__fillRowQ3.style.width = ""

		add_css = (col_i, w) =>
			# adds the CSS for the TD column of the main table(s)
			css.push("td > div.#{@__lvClass}-cell.cui-list-view-grid-cell-col-#{col_i} { width: #{w}px; }")

		# set manual width in table cells
		# disable flex grow on manual set fill cells
		@__colWidths = []
		for fc, col_i in @__fillCells
			w = @__manualColWidths[col_i]
			if w >= 0
				add_css(col_i, w)
				fc.style.width = w+"px"
				@__colWidths[col_i] = w
				if col_i in @__maxCols
					# disable flex grow for a manually
					# set max column
					fc.style.flexGrow = "0"
			else
				fc.style.width = ""
				if col_i in @__maxCols
					fc.style.flexGrow = ""

		# measure the non-auto cells and non-manual-cells
		if @rowsCount > 0
			for fc, col_i in @__fillCells
				if @__manualColWidths[col_i] > 0 or col_i in @__maxCols
					# skip manual cols and maximized cols
					continue

				td = DOM.findElement(@grid[0], "td[col='#{col_i}']:not([colspan])")
				if not td
					CUI.warn("Col_i: no td found", @rowsCount, @grid, col_i, "td[col='#{col_i}']:not([colspan])")
					continue
				@__colWidths[col_i] = w = td.getBoundingClientRect().width
				# set fill div to measured width
				fc.style.width = w+"px"

		# now set the width of the maxed cols inside the table
		# measured in the fill divs
		for fc, col_i in @__fillCells
			if @__isMaximizedCol(col_i)
				@__colWidths[col_i] = w = fc.getBoundingClientRect().width
				add_css(col_i, w)

		# CUI.error "doManualLayout #{@listViewCounter}:", @DOM[0], @__colWidths
		# CUI.debug dump(css.join("\n"))

		@styleElement.innerHTML = css.join("\n")
		@__addRowsOddEvenClasses()
		@__setMargins()
		@

	__addRowsOddEvenClasses: ->
		if (@rowsCount - @fixedRowsCount)%2 == 0
			@grid.addClass("cui-list-view-grid-rows-even")
			@grid.removeClass("cui-list-view-grid-rows-odd")
		else
			@grid.removeClass("cui-list-view-grid-rows-even")
			@grid.addClass("cui-list-view-grid-rows-odd")
		@

	__doAutoLayout: ->

		# CUI.debug @__cellDims
		# return
		# txt = "ListView[#{@listViewCounter}].__doLayout #{@rowsCount}x#{@colsCount} #{@listViewCounter}"
		# console.time(txt)
		# CUI.debug "ListView[#{@listViewCounter}].__doLayout #{@rowsCount}x#{@colsCount}"
		# remeasure and apply styles for widths and heights of all cells
		@__measureCellDims()
		@__calculateDims()

		if @isDestroyed()
			return

		@__addStyle()
		# maintain an odd/even class to design the fill rows background
		@__addRowsOddEvenClasses()

		# set margins on q2 and q1 to reflect for a scrollbar in q3
		@__setMargins()
		# set scroll height
		if @__currentScroll.top > 0 or @__currentScroll.left > 0
			@__setScrolling(@__currentScroll)
			@__syncScrolling()
		@


	__getValue: (px) ->
		if not isNaN(parseFloat(px))
			px+"px"
		else if isNull(px)
			""
		else
			px

	hideWaitBlock: (internal=false) ->
		if not @grid
			@__showWaitBlock = false
		else if @__waitBlock
			if not internal or @__waitBlock.__internal
				@__waitBlock.destroy()
				delete(@__waitBlock)
		@

	showWaitBlock: (internal=false) ->
		if @__waitBlock
			return @

		if not @grid
			@__showWaitBlock = true
			return

		delete(@__showWaitBlock)
		@__waitBlock = new WaitBlock(element: @grid)
		@__waitBlock.__internal = internal
		@__waitBlock.show()
		@

	__debugRect: (func, ms) ->
		viewport = @grid.rect()
		@grid.rect(true, 500, "ListView[##{@listViewCounter}].#{func} #{ms}ms "+viewport.width+"x"+viewport.height)


	__appendRows: (rows) ->
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

		if @__isInDOM
			# this class hides the row, which is only necessary
			# if we are in DOM already
			new_cls = "list-view-row-new"
		else
			new_cls = ""

		# prepare html for all rows
		for row_i in [_row_i..row_i+listViewRows.length-1] by 1
			@__cells[row_i] = []
			@__rows[row_i] = []

			for qi, idx in @__getQuadrants(row_i)
				ft = @__getColsFromAndTo(qi)
				if ft.to < ft.from
					continue

				switch @_autoLayout
					when true
						html[qi].push("<div class=\"#{new_cls} cui-list-view-grid-row #{@__lvClass}-row cui-list-view-grid-row-#{row_i}\" row=\"#{row_i}\">")
					when 2
						html[qi].push("<div class=\"cui-lv-tr-outer cui-list-view-grid-row\" cui-lv-tr-unmeasured=\"#{@listViewCounter}\" row=\"#{row_i}\"><div class=\"cui-lv-tr\">")
					else
						html[qi].push("<tr class=\"#{new_cls} cui-list-view-grid-row #{@__lvClass}-row cui-list-view-grid-row-#{row_i}\" row=\"#{row_i}\">")

				for display_col_i in [ft.from..ft.to] by 1
					col_i = @getColIdx(display_col_i)
					[width, maxi] = @__getColWidth(row_i, col_i)
					cls = @__getColClass(col_i)
					switch @_autoLayout
						when true
							html[qi].push("<div class=\"cui-list-view-grid-cell cui-list-view-grid-cell-div #{@__lvClass}-cell cui-list-view-grid-cell-col cui-list-view-grid-cell-col-#{col_i} #{cls}\" col=\"#{col_i}\" row=\"#{row_i}\"></div>")
						when 2
							html[qi].push("<div class=\"cui-lv-td #{cls} #{@__lvClass}-cell cui-list-view-grid-cell\" col=\"#{col_i}\" row=\"#{row_i}\"></div>")
						else
							html[qi].push("<td class=\"cui-list-view-grid-cell-td #{cls}\" col=#{col_i} row=#{row_i}><div class=\"cui-list-view-grid-cell #{cls} #{@__lvClass}-cell cui-list-view-grid-cell-col cui-list-view-grid-cell-col-#{col_i}\" col=#{col_i} row=#{row_i}></div></td>")

				switch @_autoLayout
					when true
						html[qi].push("</div>")
					when 2
						html[qi].push("</div></div>")
					else
						html[qi].push("</tr>")

		find_cells_and_rows = (top) =>
			# find rows and cells in newly prepared html
			_cells = CUI.DOM.matchSelector(top, ".cui-list-view-grid-cell")
			for cell in _cells
				_col = parseInt(cell.getAttribute("col"))
				_row = parseInt(cell.getAttribute("row"))
				@__cells[_row][_col] = $(cell)

			_rows = CUI.DOM.matchSelector(top, ".cui-list-view-grid-row[row]")
			for row in _rows
				row_i = parseInt(row.getAttribute("row"))
				@__rows[row_i].push(row)

			return

		anchor_row_idx = 0
		for qi in [0..3]
			if html[qi].length == 0
				continue

			if @_autoLayout
				outer = document.createElement("div")
			else
				outer = document.createElement("tbody")

			outer.innerHTML = html[qi].join("")
			find_cells_and_rows(outer)

			if mode == "append"
				if @_autoLayout and qi in [2, 3]
					# the last row is the fill row, make sure to
					# insert our node before
					while node = outer.firstChild
						@quadrantRows[qi].insertBefore(node, @quadrantRows[qi].lastChild)
				else
					while node = outer.firstChild
						@quadrantRows[qi].appendChild(node)
				continue

			if mode == "prepend"
				while node = outer.lastChild
					@quadrantRows[qi].insertBefore(node, @quadrantRows[qi].firstChild)
				continue

			row = $(anchor_row[anchor_row_idx])

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
			fixedRows = @quadrantRows[1].childNodes
			if @fixedRowsCount < fixedRows.length
				if @fixedColsCount > 0
					_qi_s = [0,1]
				else
					_qi_s = [1]

				for i in [0...fixedRows.length-@fixedRowsCount] by 1
					for _qi in _qi_s
						if @quadrantRows[_qi+2].firstChild
							@quadrantRows[_qi+2].insertBefore(@quadrantRows[_qi].lastChild, @quadrantRows[_qi+2].firstChild)
						else
							@quadrantRows[_qi+2].appendChild(@quadrantRows[_qi].lastChild)

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
			if row_i >= @fixedRowsCount + @_rowMoveFixedRows
				listViewRow.prependColumn(new ListViewColumnRowMoveHandle())
			else
				listViewRow.prependColumn(new ListViewColumnRowMoveHandlePlaceholder())
		else if @_rowMovePlaceholder
			listViewRow.prependColumn(new ListViewColumnRowMoveHandlePlaceholder())

		_cols = listViewRow.getColumns()

		colspan_offset = 0
		for col, col_i in _cols
			node = col.render()

			cell = @__cells[row_i][col_i+colspan_offset]

			assert(cell, "ListView.__appendCells","Cell not found: row: "+row_i+" column: "+(col_i+colspan_offset+1)+". colsCount: "+@colsCount)

			if not isNull(node)
				cell.append(node)

			col.setElement(cell)

			colspan = col.getColspan()
			assert(col_i+colspan_offset+colspan-1 < @colsCount, "ListView.__appendCells", "Colspan #{colspan} exceeds cols count #{@colsCount}, unable to append cell.", row_i: row_i, col_i: col_i, colspan_offset: colspan_offset, colspan: colspan, column: col, row: listViewRow, ListView: @)
			if colspan > 1
				cell.attr("colspan", colspan)

				if not @_autoLayout
					cell.parent().attr("colspan", colspan)

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
					if not @_autoLayout
						@__cells[row_i][col_i+colspan_offset+1].parent().remove()
					else
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

		switch @_autoLayout
			when 2
				if col_i in @__maxCols
					cls.push("cui-lv-td-max")
			else
				if col_i in @__maxCols
					cls.push("cui-list-view-grid-cell-max")
				else
					cls.push("cui-list-view-grid-cell-standard")
		cls.join(" ")

	__resetRowDim: (row_i) ->
		delete(@__cellDims[row_i])
		delete(@__rowHeights[row_i])

		if @__rows[row_i]
			for row in @__rows[row_i]
				DOM.setAttribute(row, "cui-lv-tr-unmeasured", @listViewCounter)

		for display_col_i in [0..@colsCount-1]
			col_i = @getColIdx(display_col_i)
			@__resetCellStyle(row_i, col_i)
		@

	__resetCellStyle: (row_i, col_i) ->
		cell = @__cells[row_i]?[col_i]
		if cell
			cell[0].style.cssText = ""
		cell

	__resetColWidth: (col_i) ->
		for dim in @__cellDims
			if dim
				delete(dim[col_i])

		for display_row_i in [0..@rowsCount-1]
			row_i = @getRowIdx(display_row_i)
			@__resetCellStyle(row_i, col_i)

		@__fillCells[col_i].style.cssText = ""

		# null hints the calculateDims method
		# to check all rows for this column
		@__colWidths[col_i] = null
		@

	__resetCellDims: (col_i) ->
		@__cellDims = []
		@__colWidths = []
		@__rowHeights = []

	__measureCellDims: ->
		# console.error "measure cell dims, rows count", @rowsCount
		# console.time "measure"
		for display_row_i in [0..@rowsCount-1] by 1
			row_i = @getRowIdx(display_row_i)
			if not @__cellDims[row_i]
				@__cellDims[row_i] = []
			for display_col_i in [0..@colsCount-1] by 1
				col_i = @getColIdx(display_col_i)
				if @__cellDims[row_i][col_i]
					continue
				cell = @__cells[row_i][col_i]
				if not cell # or @__colspanRows[row_i]?[col_i] > 1
					# the cell might be missing, if it is a colspanned cell
					@__cellDims[row_i][col_i] = [0,0]
				else
					rect = cell[0].getBoundingClientRect()
					if @__colspanRows[row_i]?[col_i] > 1
						# ignore the width for colspan rows
						@__cellDims[row_i][col_i] = [0, rect.height]
					else
						@__cellDims[row_i][col_i] = [rect.width, rect.height]
				# console.debug "ListView #{row_i}/#{col_i}:", @__cellDims[row_i][col_i]
		# console.timeEnd "measure"

		@

	__calculateDims: ->
		txt = "ListView[#{@listViewCounter}].__calculateDims[#{@listViewCounter}]: "+@rowsCount+" rows. "
		# console.time(txt)

		for display_row_i in [0..@rowsCount-1] by 1
			row_i = @getRowIdx(display_row_i)
			if @__rowHeights.hasOwnProperty(row_i)
				continue
			calcHeight = -1
			for display_col_i in [0..@colsCount-1] by 1
				col_i = @getColIdx(display_col_i)
				height = @__cellDims[row_i][col_i][1]
				if height > calcHeight
					calcHeight = height

			@__rowHeights[row_i] = calcHeight


		for display_col_i in [0..@colsCount-1] by 1
			col_i = @getColIdx(display_col_i)
			if @__colWidths[col_i] != null and @__colWidths.hasOwnProperty(col_i)
				; # continue

			# if not @_measure_fixed_rows_only or (@fixedRowsCount == 0 or @__colWidths[col_i] == null)
			rowsCount = @rowsCount
			# else
			# 	rowsCount = @fixedRowsCount

			manualWidth = @__manualColWidths[col_i]
			if manualWidth >= 0
				calcWidth = manualWidth
			else
				calcWidth = -1
				for display_row_i in [0..rowsCount-1] by 1
					row_i = @getRowIdx(display_row_i)
					width = @__cellDims[row_i][col_i][0]
					if width > calcWidth
						calcWidth = width
			@__colWidths[col_i] = calcWidth
			# CUI.debug rowsCount, display_col_i, calcWidth

		# CUI.debug("colWidths:", @__colWidths, "rowHeights:", @__rowHeights)
		@

	__getMostCommonIntegerInArray: (values) ->
		# counter to find the most common row height
		stats = {}
		for v in values
			if not stats[v]
				stats[v] = 1
			else
				stats[v]++

		mostCommon = null
		max_count = 0
		for v, count of stats
			if count > max_count
				mostCommon = v
				max_count = count

		parseInt(mostCommon)

	# __removeCss: ->
	# 	$("style."+@__lvClass).remove()

	# calculate sum of array values,
	# skip undefined or null
	__calcSum: (arr) ->
		sum = 0
		for item in arr
			if isNull(item)
				continue
			sum += item
		sum

	__isMaximizedCol: (col_i) ->
		col_i in @__maxCols and not @__manualColWidths.hasOwnProperty(col_i)

	# used for debug menu only
	__removeStyle: ->
		for display_col_i in [0..@colsCount-1] by 1
			col_i = @getColIdx(display_col_i)
			@__fillCells[col_i].style.cssText = ""
			for display_row_i in [0..@rowsCount-1] by 1
				row_i = @getRowIdx(display_row_i)
				@__resetCellStyle(row_i, col_i)
		@

	__addStyle: ->
		set_width = (sty, width, maxi) =>
			if width == -1
				sty.minWidth = ""
				sty.flexGrow = ""
				sty.width = ""
			else if maxi
				sty.minWidth = @__getValue(width)
				sty.flexGrow = 1
			else
				sty.minWidth = ""
				sty.flexGrow = ""
				sty.width = @__getValue(width)

		for display_row_i in [0..@rowsCount-1] by 1
			row_i = @getRowIdx(display_row_i)
			for display_col_i in [0..@colsCount-1] by 1
				col_i = @getColIdx(display_col_i)

				if @getColdef(col_i) == "manual"
					if not (@__colspanRows[row_i]?[col_i] > 1)
						continue

				if @_autoLayout and display_row_i == 0
					[width, maxi] = @__getColWidth(null, col_i)
					set_width(@__fillCells[col_i].style, width, maxi)

				cell = @__cells[row_i][col_i]
				if not cell
					continue

				[width, maxi] = @__getColWidth(row_i, col_i)
				set_width(cell[0].style, width, maxi)
				cell[0].style.height = @__getValue(@__rowHeights[row_i])
		@

	# __addCss: ->

	# 	assert($("style."+@_lvClass).length == 0, "ListView.addCss", "removeCss first")

	# 	# CUI.debug "cell dims", cell_dims

	# 	css = []
	# 	sel = ".#{@__lvClass} > div > div >"

	# 	mostCommonHeight = @__getMostCommonIntegerInArray(@__rowHeights)
	# 	mostCommonWidth = @__getMostCommonIntegerInArray(@__colWidths)

	# 	if mostCommonHeight > 0
	# 		css.push("#{sel} .cui-list-view-grid-row > .cui-list-view-grid-cell { height: #{@__getValue(mostCommonHeight)};}")

	# 	if mostCommonWidth > 0
	# 		css.push("#{sel} .cui-list-view-grid-row > .cui-list-view-grid-cell-col { width: #{@__getValue(mostCommonWidth)};}")

	# 	for display_row_i in [0..@rowsCount-1] by 1
	# 		row_i = @getRowIdx(display_row_i)
	# 		height = @__rowHeights[row_i]
	# 		if height == mostCommonHeight
	# 			continue
	# 		css.push("#{sel} .cui-list-view-grid-row-#{row_i} > .cui-list-view-grid-cell { height: #{@__getValue(height)};}")

	# 	push_css = (col_i, width, maximize, row_i = null) =>
	# 		if row_i != null
	# 			row_sel = "-#{row_i}"
	# 		else
	# 			row_sel = ""
	# 		if maximize
	# 			css.push("#{sel} .cui-list-view-grid-row#{row_sel} > .cui-list-view-grid-cell-col-#{col_i} {
	# 				min-width: #{@__getValue(width)};
	# 				flex-grow: 1 !important;
	# 				-webkit-flex-grow: 1 !important;
	# 			}")
	# 		else
	# 			css.push("#{sel} .cui-list-view-grid-row#{row_sel} > .cui-list-view-grid-cell-col-#{col_i} { width: #{@__getValue(width)}; }")

	# 	for display_col_i in [0..@colsCount-1] by 1
	# 		col_i = @getColIdx(display_col_i)
	# 		width = @__colWidths[col_i]
	# 		if width == mostCommonWidth
	# 			continue
	# 		push_css(col_i, width, @__isMaximizedCol(col_i))


	# 	# CUI.debug "colWidths:", @__colWidths, "rowHeight:", @__rowHeights, "manualColWidths:", @__manualColWidths

	# 	# CSS for the colspanned cells
	# 	for _row_i, cols of @__colspanRows
	# 		row_i = parseInt(_row_i)
	# 		for _col_i of cols
	# 			col_i = parseInt(_col_i)
	# 			[width, maxi] = @__getColWidth(row_i, col_i)
	# 			push_css(col_i, width, maxi, row_i)

	# 	# CUI.debug css.join("\n")

	# 	$("head").append($element("style", @__lvClass).html(css.join("\n")))

	# 	return

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
				# ,
				# 	text: "removeCss"
				# 	onClick: (ev) =>
				# 		@__debugCall "__removeCss", =>
				# 			@__manualColWidths = []
				# 			@__removeCss(ev)
				,
					text: "measure"
					onClick: =>
						@__debugCall "__measureCellDims", =>
							@__resetCellDims()
							@__measureCellDims()
							@__calculateDims()
							CUI.debug(@__cellDims)
							CUI.debug("colWidths:", @__colWidths, "rowHeights:", @__rowHeights)
				,
				# 	text: "addCss"
				# 	onClick: (ev) =>
				# 		@__debugCall "__addCss", =>
				# 			@__addCss(ev)
				# ,
					text: "addStyle"
					onClick: (ev) =>
						@__debugCall "__addStyle", =>
							@__addStyle(ev)
				,
					text: "removeStyle"
					onClick: (ev) =>
						@__debugCall "__removeStyle", =>
							@__removeStyle(ev)
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
					text: "showWaitBlock"
					onClick: (ev) =>
						@showWaitBlock()
				,
					text: "hideWaitBlock"
					onClick: (ev) =>
						@hideWaitBlock()
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
				#,
				#	content:
				#		$pre().html(dump(@opts))
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


ListView = CUI.ListView
