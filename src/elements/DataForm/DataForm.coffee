class CUI.DataForm extends CUI.DataTable

	render: ->
		CUI.DataFieldInput::render.call(@)

		if @_has_add_button
			addButton = new CUI.Button
				icon: "plus"
				onClick: =>
					lastRow = @__rowRegistry[@__rowRegistry.length - 1]?.data
					if lastRow and lastRow._new
						delete lastRow._new
						@rows.push(lastRow)

					@__appendRow(_new: true)
					@__updateView()
					@__removeEmptyRows()
					@__storeValue()

		@__verticalLayout = new CUI.VerticalLayout
			maximize_horizontal: @__maximize_horizontal
			center: content: undefined
			bottom: content: addButton

		@append(@__verticalLayout)

		CUI.Events.listen
			type: "data-changed"
			node: @DOM
			call: =>
				@__updateView()

		if @_rowMove
			new CUI.Sortable
				element: @__verticalLayout.center()
				selector: ".cui-drag-handle-row"
				create: (ev, target) ->
					data = CUI.dom.data(target, "data")
					if not data
						return false
					if data._new
						ev.stopPropagation()
						return false
					return true
				allowSort: (ev, from_idx, to_idx) =>
					!!@rows[to_idx]
				sorted: (ev, from_idx, to_idx) =>
					CUI.util.moveInArray(from_idx, to_idx, @rows, from_idx < to_idx)
					@__storeValue()
					@__updateView()

		@

	initOpts: ->
		super()
		@addOpts
			level:
				default: 0
				mandatory: true
				check: (v) ->
					CUI.util.isPosInt(v)
			has_add_button:
				check: Boolean
				default: false

		@removeOpt("onNodeAdd")
		@removeOpt("footer_right")
		@removeOpt("buttons")
		@removeOpt("chunk_size")

	init: ->
		super()
		if @getFieldList().length > 1
			@addClass('cui-data-form--multiple-fields')
		else
			@removeClass('cui-data-form--multiple-fields')

		if @_rowMove
			@addClass('cui-data-form--movable-rows')

		if @_has_add_button
			@addClass('cui-data-form--add-button')

	readOpts: ->
		super()
		@__rowRegistry = []
		@

	getFieldOpts: ->
		field_opts = super()
		for fopts in field_opts
			if fopts.type == CUI.DataForm
				fopts.level = @_level+1

			if field_opts.length == 1
				delete(fopts.form.label)

		field_opts

	getForm: (data) ->
		fields = []

		for fopts in @getFieldOpts()
			if fopts.type == CUI.DataForm
				fopts.level = @_level+1
			fields.push(fopts)

		new_form = new CUI.SimpleForm
			fields: fields
			data: data
			onDataChanged: (data, element, ev) =>
				if data._new
					# we need to create a new row
					delete(data._new)
					@rows.push(data)
					@__appendNewRow()

				ev.stopPropagation()
				@__removeEmptyRows()
				@__storeValue()

		# CUI.dom.setAttribute(new_form.DOM, "cui-form-depth", @getFormDepth() + 1)
		new_form

	__updateView: ->
		@__updateButtons()

	__removeEmptyRows: ->
		@__updateEmptyInRows()

		# makes sure that one empty row is at the end and not more
		while @rows.length > 0
			row = @rows[@rows.length-1]
			if row._empty
				# remove row
				@__removeRow(row)
			else
				break
		@

	__storeValue: ->
		@storeValue(CUI.util.copyObject(@rows, true))

	__updateEmptyInRows: ->
		for row in @rows
			if @rowHasUserData(row)
				delete(row._empty)
			else
				row._empty = true
		return

	hasUserData: (data) ->

		if not super(data)
			return false

		rows = data[@getName()]

		if rows.length == 0
			return false

		for row in rows
			if @rowHasUserData(row)
				return true

		return false

	rowHasUserData: (row) ->
		for f in @getFieldList()
			if f.hasUserData(row)
				return true

		return false

	renderAsBlock: ->
		@getFieldList().length > 1

	displayValue: ->
		@rows = @getValue()
		# console.warn "display", @_name, rows.length

		@__verticalLayout.empty("center")
		for row in @rows
			@__appendRow(row)

		# console.warn "initData", @__data, @_name
		@__appendNewRow()
		@__updateButtons()
		return

	__appendNewRow: ->
		if @_new_rows not in ["edit", "append"]
			return

		if @_has_add_button and @rows.length > 0
			return
		@__appendRow(_new: true)

	__updateButtons: ->
		for row in @rows
			info = @__findRowInfo(row)
			info.trash?.show()
			if @rows.length >= 2
				CUI.dom.removeClass(info.move, 'is-hidden')
			else
				CUI.dom.addClass(info.move, 'is-hidden')
		return

	__findRowInfo: (row) ->
		idx = CUI.util.idxInArray(null, @__rowRegistry, (v) ->
			v.data == row
		)
		CUI.util.assert(idx > -1, "DataForm.__removeRow", "row not found", row: row, registry: @__rowRegistry)
		info = @__rowRegistry[idx]
		info.idx = idx
		info

	__removeRow: (row) ->
		info = @__findRowInfo(row)
		CUI.dom.remove(info.dom)
		@__rowRegistry.splice(info.idx, 1)
		CUI.util.removeFromArray(row, @rows)
		@__storeValue()
		@

	__appendRow: (data) ->
		if @_rowMove
			move = CUI.dom.element("DIV", class: "cui-drag-handle-row")

		if @_new_rows != "none"
			trash = new CUI.defaults.class.Button
				icon: "fa-trash-o"
				appearance: "flat"

				onMouseenter: =>
					CUI.dom.addClass(hl, "cui-data-form-row--trash")
				onMouseleave: =>
					CUI.dom.removeClass(hl, "cui-data-form-row--trash")
				onClick: =>
					CUI.decide(@_onBeforeRowRemove?.call(@, data))
					.done =>
						@__removeRow(data)
						@_onRowRemove?.call(@, data)
						@__updateView()
					return

		hl = new CUI.HorizontalLayout
			maximize_vertical: false
			class: "cui-data-form-row"
			maximize_horizontal: @__maximize_horizontal
			left:
				content: move
			right:
				content: trash
			center:
				content: @getForm(data).start()

		CUI.dom.data(hl.DOM, "data", data)

		if data._new and not @_has_add_button
			CUI.dom.addClass(move, 'is-hidden')
			trash.hide()

		@__rowRegistry.push
			data: data
			dom: hl.DOM
			trash: trash
			move: move

		@__verticalLayout.append(hl, "center")
		return
