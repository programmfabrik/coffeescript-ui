class DataTable extends DataFieldInput
	constructor: (@opts) ->
		super(@opts)
		@addClass("cui-padding-reset")

	initOpts: ->
		super()
		@addOpts
			fields:
				mandatory: true
				check: (v) ->
					CUI.isArray(v) or CUI.isFunction(v)
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
			onRowRemove:
				check: Function
			onNodeAdd:
				check: Function
			maximize:
				check: Boolean
			maximize_horizontal:
				check: Boolean
				default: false
			maximize_vertical:
				check: Boolean
				default: false
			footer_right:
				check: (v) ->
					isContent(v)

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

	init: ->
		@__fieldList = []
		for field in @getArrayFromOpt("fields")
			_field = DataField.new(field)
			@__fieldList.push(_field)

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

	render: ->
		super()
		cols = []
		colClasses = []

		@headerRow = new ListViewHeaderRow()

		for f in @__fieldList
			if f._form?.column
				cols.push(f._form.column)
			else if f.isResizable()
				cols.push("auto")
			else
				cols.push("fixed")

			name = f.getName()
			label = f._form?.label
			if isNull(label)
				label = name

			cls = []
			if name
				cls.push("cui-data-table-column-field-name-"+name)

			cls.push("cui-data-table-column-field-type-"+toDash(f.getElementClass()))
			if f._form?.rotate_90
				cls.push("cui-lv-td-rotate-90")

			colClasses.push(cls)

			@headerRow.addColumn new ListViewHeaderColumn
				rotate_90: f._form?.rotate_90
				label:
					text: label
					multiline: true

		buttons = []
		if @_new_rows != "none"
			if @_new_rows != "remove_only"
				buttons.push
					icon: "plus"
					group: "plus-minus"
					onClick: =>
						@rows.push(d={})
						# CUI.debug "creating new data node"
						new_node = new DataTableNode
							dataTable: @
							data: d
							rows: @rows

						@_onNodeAdd?(node)
						@listView.appendRow(new_node)
						# CUI.debug "data-changed on DataTable PLUS storing values:", dump(@rows)
						@storeValue(copyObject(@rows, true))

			buttons.push @minusButton = new CUI.defaults.class.Button
				icon: "minus"
				group: "plus-minus"
				disabled: true
				onClick: =>
					for row in @listView.getSelectedRows()
						row.remove()
					@storeValue(copyObject(@rows, true))
					return

		if buttons.length
			footer = new Buttonbar(buttons: buttons)

		updateMinusButton = =>
			if @listView.getSelectedRows().length == 0
				@minusButton.disable()
			else
				@minusButton.enable()

		@listView = new ListView
			selectableRows: @_new_rows != "none"
			onSelect: updateMinusButton
			onDeselect: updateMinusButton
			onRowMove: (display_from_i, display_to_i, after) =>
				fr = @listView.fixedRowsCount
				moveInArray(display_from_i-fr, display_to_i-fr, @rows, after)
				Events.trigger
					type: "data-changed"
					node: @listView

			cols: cols
			fixedRows: if @_no_header then 0 else 1
			footer_left: footer
			footer_right: @_footer_right
			fixedCols: if @_rowMove then 1 else 0
			colResize: if @_no_header then false else true
			colClasses: colClasses
			rowMove: @_rowMove
			maximize: @_maximize
			maximize_horizontal: @_maximize_horizontal
			maximize_vertical: @_maximize_vertical

		if @isDisabled()
			@listView.setInactive(true, null)

		@replace(@listView.render())

		Events.listen
			type: "data-changed"
			node: @listView
			call: (ev, info) =>
				# we need hide our internal events and
				# present us as a whole
				ev.stopPropagation()
				# store value triggers a new data-changed
				# CUI.debug "data-changed on DataTable storing values:", dump(@rows)

				@storeValue(copyObject(@rows, true))
				return

		@


	displayValue: ->
		@listView.removeAllRows()
		if not @_no_header
			@listView.appendRow(@headerRow)

		@rows = copyObject(@getValue(), true)

		assert(CUI.isArray(@rows), "DataTable.displayValue", "\"value\" needs to be Array.", data: @getData(), value: @getValue())

		if @rows
			for row, idx in @rows
				node = new DataTableNode
					dataTable: @
					data: row
					rows: @rows
					check_changed_data: @getInitValue()?[idx]
				@_onNodeAdd?(node)
				@listView.appendRow(node, true)
			@listView.appendDeferredRows()

		@
