###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DataTable extends CUI.DataFieldInput

	@defaults:
		plus_button_tooltip: null
		minus_button_tooltip: null

	initOpts: ->
		super()

		# VALUE can have __class in each row, this sets a class on the tree node

		@addOpts
			fields:
				mandatory: true
				check: (v) ->
					CUI.util.isArray(v) or CUI.util.isFunction(v)
			new_rows:
				default: "edit"
				check: ["edit", "append", "remove_only", "none"]
			no_header:
				check: Boolean
			# autoSizeGridX:
			#	default: false
			#	check: Boolean
			rowMove:
				default: false
				check: Boolean
			# used in DataTableNode
			onBeforeRowRemove:
				check: Function
			# used in DataTableNode
			onRowRemove:
				check: Function
			onRowSelect:
				check: Function
			onRowDeselect:
				check: Function
			onNodeAdd:
				check: Function
			onNewNodeAdd:
				check: Function
			footer_right:
				check: (v) ->
					CUI.util.isContent(v)
			# own buttons
			buttons:
				mandatory: true
				default: []
				check: (v) ->
					CUI.util.isArray(v)
			# if true custom buttons are appended to the default buttons
			# if false are prepended
			append_buttons:
				check: Boolean
				default: false
			chunk_size:
				default: 0
				mandatory: true
				check: (v) ->
					v >= 0
			padded:
				check: Boolean
				default: false
			onLoadPage:
				check: Function

	readOpts: ->
		super()
		@__navi_prev = null
		@__navi_next = null
		@__offset = 0
		CUI.util.assert(not (@_chunk_size and @_rowMove), "new CUI.DataTable", "opts.chunk_size and opts.rowMove are mutually exclusive.", opts: @opts)
		@

	getFieldList: ->
		@__fieldList

	getFieldsByName: (name, found_fields = []) ->
		for field in @getFieldList()
			if field.getName() == name
				found_fields.push(field)

			field.getFieldsByName?(name, found_fields)
		found_fields

	debug: ->
		super()
		@listView?.debug()

	getFieldOpts: ->
		field_opts = []
		for _field in @getArrayFromOpt("fields")
			field = CUI.util.copyObject(_field, true)
			if not field.form
				field.form = {}

			if not CUI.util.isString(field.form.label)
				field.form.label = field.name

			field_opts.push(field)

		field_opts

	init: ->
		@__fieldList = []
		for field in @getFieldOpts()
			if CUI.util.isFunction(field)
				_field = CUI.DataField.new(field(@))
			else
				_field = CUI.DataField.new(field)
			@__fieldList.push(_field)
		@

	disable: ->
		super()
		@listView?.setInactive(true, null)
		@

	enable: ->
		super()
		@listView?.setInactive(false, null)
		@

	getDefaultValue: ->
		[]

	addRow: (data={}, newRow=false) ->
		@rows.push(data)
		# console.debug "creating new data node"
		new_node = new CUI.DataTableNode
			dataTable: @
			data: data
			dataRowIdx: @rows.length-1
			rows: @rows

		@_onNodeAdd?(new_node)
		@storeValue(CUI.util.copyObject(@rows, true))
		if @_chunk_size > 0
			@__offset = Math.floor((@rows.length-1) / @_chunk_size) * @_chunk_size
			@displayValue()
		else
			@listView.appendRow(new_node)
		# console.debug "data-changed on CUI.DataTable PLUS storing values:", CUI.util.dump(@rows)

		@_onNewNodeAdd?(new_node)
		new_node

	updateButtons: ->
		if @listView.getSelectedRows().length == 0
			@minusButton.disable()
		else
			@minusButton.enable()

	getFooter: ->
		custom_buttons = @_buttons.slice(0)
		for btn in custom_buttons
			btn._data_table = @
		buttons = []
		if @_new_rows != "none"
			if @_new_rows != "remove_only"
				buttons.push
					icon: "plus"
					tooltip: text: CUI.DataTable.defaults.plus_button_tooltip
					group: "plus-minus"
					onClick: =>
						@addRow({}, true)

			@minusButton = new CUI.defaults.class.Button
				icon: "minus"
				group: "plus-minus"
				tooltip: text: CUI.DataTable.defaults.minus_button_tooltip
				disabled: true
				ui: if @_ui then "#{@_ui}.minus.button"
				onClick: =>
					finish = =>
						@storeValue(CUI.util.copyObject(@rows, true))
						@updateButtons()
						if @_chunk_size > 0
							@displayValue()

					promises = []
					for row in @listView.getSelectedRows()
						deletePromise = row.remove()
						if deletePromise and CUI.util.isPromise(deletePromise)
							promises.push(deletePromise)
					if promises.length > 0
						CUI.whenAll(promises).done( =>
							finish()
						)
					else
						finish()
					return

			buttons.push(@minusButton)

		if @_chunk_size > 0

			buttons.push
				onConstruct: (btn) =>
					@__navi_prev = btn
				icon: "left"
				disabled: true
				group: "navi"
				ui: if @_ui then "#{@_ui}.navigation.left.button"
				onClick: =>
					@__offset = @__offset - @_chunk_size
					@loadPage(@__offset / @_chunk_size)

			page_data = {}

			load_page = =>
				@loadPage(page_data.page - 1)

			@__navi_input = new CUI.NumberInput
				group: "navi"
				placeholder: "page"
				data: page_data
				name: 'page'
				ui: if @_ui then "#{@_ui}.navigation.input.button"
				onBlur: (input) =>
					input.setValue(null)
				onDataChanged: =>
					CUI.scheduleCallback
						ms: 1000
						call: load_page
					return

			.start()

			buttons.push(@__navi_input)

			buttons.push
				onConstruct: (btn) =>
					@__navi_next = btn
				icon: "right"
				disabled: true
				group: "navi"
				ui: if @_ui then "#{@_ui}.navigation.right.button"
				onClick: =>
					@__offset = @__offset + @_chunk_size
					@loadPage(@__offset / @_chunk_size)

		if custom_buttons.length
			if @_append_buttons
				buttons = buttons.concat(custom_buttons)
			else
				buttons = custom_buttons.concat(buttons)

		if buttons.length
			new CUI.Buttonbar(buttons: buttons)
		else
			return null

	render: ->
		cols = []
		colClasses = []
		maxis = []

		@headerRow = new CUI.ListViewHeaderRow()

		for f, idx in @__fieldList
			if f.getOpt("form")?.column == "maximize" or
				f instanceof CUI.DataTable
					maxis.push(idx)

		if maxis.length == 0
			# push the last as max
			maxis.push(@__fieldList.length-1)

		for f, idx in @__fieldList
			if CUI.util.idxInArray(idx, maxis) > -1
				cols.push("maximize")
			else if f.getOpt("form")?.column
				cols.push(f._form.column)
			else if f.isResizable()
				cols.push("auto")
			else
				cols.push("fixed")

			name = f.getName()
			label = f._form.label

			cls = []
			if name
				cls.push("cui-data-table-column-field-name-"+name)

			cls.push("cui-data-table-column-field-type-"+CUI.util.toDash(f.getElementClass()))
			if f._form?.rotate_90
				cls.push("cui-lv-td-rotate-90")

			colClasses.push(cls)

			@headerRow.addColumn new CUI.ListViewHeaderColumn
				rotate_90: f._form?.rotate_90
				label:
					text: label
					multiline: true

		@listView = new CUI.ListView
			class: "cui-lv--has-datafields"
			selectableRows: @_new_rows != "none"
			padded: @_padded
			ui: if @_ui then "#{@_ui}.list.view"
			onSelect: (ev, info) =>
				@_onRowSelect?(ev, info)
				@updateButtons()
			onDeselect: =>
				@_onRowDeselect?()
				@updateButtons()
			onRowMove: (display_from_i, display_to_i, after) =>
				fr = @listView.fixedRowsCount
				display_from_i = @__offset + display_from_i
				display_to_i = @__offset + display_to_i
				CUI.util.moveInArray(display_from_i-fr, display_to_i-fr, @rows, after)
				CUI.Events.trigger
					type: "data-changed"
					node: @listView

			cols: cols
			fixedRows: if @_no_header then 0 else 1
			footer_left: @getFooter()
			footer_right: @_footer_right
			fixedCols: 0
			colResize: if @_no_header then false else true
			colClasses: colClasses
			rowMove: @_rowMove
			# rowMovePlaceholder: not @_rowMove
			maximize: @_maximize
			maximize_horizontal: @_maximize_horizontal
			maximize_vertical: @_maximize_vertical

		if @isDisabled()
			@listView.setInactive(true, null)

		@replace(@listView.render())

		CUI.Events.listen
			type: "data-changed"
			node: @listView
			call: (ev, info) =>
				# we need hide our internal events and
				# present us as a whole
				ev.stopPropagation()
				# store value triggers a new data-changed
				# console.debug "data-changed on CUI.DataTable storing values:", CUI.util.dump(@rows)

				@storeValue(CUI.util.copyObject(@rows, true))
				return

		return super()

	loadPage: (page) ->
		maxPage = Math.floor(@rows?.length / @_chunk_size)
		if not CUI.util.isNumber(page) or maxPage < 0 or page > maxPage
			page = 0

		@__offset = page * @_chunk_size
		@displayValue()
		@_onLoadPage?(page)
		return

	displayValue: ->
		@listView.removeAllRows()
		if not @_no_header
			@listView.appendRow(@headerRow)

		@rows = CUI.util.copyObject(@getValue(), true)

		if @_chunk_size > 0
			len = @rows.length

			if @__offset >= len
				@__offset = Math.max(@__offset - @_chunk_size)

			page = Math.floor(@__offset / @_chunk_size)
			last_page = Math.ceil(len / @_chunk_size)-1

			sep = ' / '
			placeholder = (page+1)+sep+(last_page+1)

			@__navi_input.setMin(1)
			@__navi_input.setMax(last_page+1)
			@__navi_input.setValue(null)

			@__navi_input.setPlaceholder(placeholder)
			CUI.dom.setAttribute(@__navi_input.getElement(), "data-max-chars", (""+(last_page+1)).length*2+sep.length)

			if page > 0
				@__navi_prev.enable()
			else
				@__navi_prev.disable()

			if page < last_page
				@__navi_next.enable()
			else
				@__navi_next.disable()

		CUI.util.assert(CUI.util.isArray(@rows), "DataTable.displayValue", "\"value\" needs to be Array.", data: @getData(), value: @getValue())

		if @rows
			if @_chunk_size > 0
				rows_sliced = @rows.slice(@__offset, @__offset + @_chunk_size)
			else
				rows_sliced = @rows

			for row, idx in rows_sliced
				node = new CUI.DataTableNode
					dataTable: @
					data: row
					class: row.__class
					dataRowIdx: idx
					rows: @rows
					check_changed_data: @getInitValue()?[idx]
				@_onNodeAdd?(node)
				@listView.appendRow(node, true)
			@listView.appendDeferredRows()

		@
