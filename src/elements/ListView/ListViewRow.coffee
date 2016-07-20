class ListViewRow extends Element

	initOpts: ->
		super()
		@addOpts
			columns:
				check: Array
			selectable:
				check: Boolean
			class:
				check: String

	readOpts: ->
		super()

		if @_columns
			@columns = @_columns
			for col, idx in @columns
				if col
					@setColumn(idx, col)
		else
			@columns = []

		# keep track of classes using a dummy
		# div which is detached from DOM
		if @_selectable == false
			@setSelectable(false)
		else
			@setSelectable(true)

		if @_class
			@__class = @_class
		else
			@__class = null

		@row_i = null

	addColumn: (column) ->
		assert(column instanceof ListViewColumn,"ListViewRow.addColumn", "column must be instance of ListViewColumn", column: column)
		@columns.push(column)
		column.setRow(@)
		@

	setColumn: (idx, column) ->
		assert(column instanceof ListViewColumn,"ListViewRow.addColumn", "column must be instance of ListViewColumn", column: column)
		@columns[idx] = column
		column.setRow(@)
		@


	prependColumn: (column) ->
		assert(column instanceof ListViewColumn,"ListViewRow.prependColumn", "column must be instance of ListViewColumn", column: column)
		@columns.splice(0,0,column)
		column.setRow(@)
		@

	setSelectable: (on_off) ->
		@__selectable = on_off

	isSelectable: ->
		@__selectable and @listView?.hasSelectableRows()

	isMovable: (ev) ->
		@listView.hasMovableRows()

	removeColumns: ->
		# CUI.debug "this", @, @columns
		for c in @columns
			c.setRow()
		@columns.splice(0)

	getColumns: ->
		@columns

	setRowIdx: (@row_i) ->
		@

	getDOMNodes: ->
		@listView?.getRow(@row_i)

	getRowIdx: ->
		@row_i

	scrollIntoView: ->
		@getDOMNodes()[0]?.scrollIntoView()
		@

	getDisplayRowIdx: ->
		@listView?.getDisplayRowIdx(@row_i)

	addedToListView: ->

	setListView: (@listView) ->

	getListView: ->
		@listView

	__selectableClass: "cui-list-view-row-selectable"

	# used while node is rendered
	getClass: ->
		if @isSelectable()
			@__selectableClass+" "+@__class
		else
			@__class

	# use this before node is rendered
	setClass: (@__class) ->

	# use this after node is rendered
	addClass: (cls) ->
		@listView?.rowAddClass(@row_i, cls)

	# use this after node is rendered
	removeClass: (cls) ->
		@listView?.rowRemoveClass(@row_i, cls)

	select: (ev) ->
		if @selected
			CUI.debug "already selected", @
			return
		if not @isSelectable()
			CUI.debug "not selectable", @
			return
		@selected = true

		if not @listView
			return

		@listView.rowAddClass(@row_i, ListViewRow.defaults.selected_class)

		@listView._onSelect? ev,
			originalEvent: ev
			listView: @listView
			row: @

		@

	deselect: (ev) ->
		if not @listView.hasSelectableRows()
			return
		if not @selected
			return

		@listView?.rowRemoveClass(@row_i, ListViewRow.defaults.selected_class)
		@selected = false

		@listView?._onDeselect? ev,
			originalEvent: ev
			listView: @listView
			row: @

		@

	isSelected: ->
		!!@selected


	remove: ->
		@listView.removeRow(@row_i)

	@defaults:
		selected_class: "cui-selected"
