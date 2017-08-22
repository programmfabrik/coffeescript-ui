class CUI.DataForm extends CUI.DataTable

	render: ->
		CUI.DataFieldInput::render.call(@)

		Events.listen
			type: "data-changed"
			node: @DOM
			call: =>
				@__updateView()

		if @_rowMove
			new CUI.Sortable
				element: @DOM
				selector: ".cui-data-form-row-move-handle"
				create: (ev, target) ->
					data = CUI.DOM.data(target, "data")
					if not data
						return false
					if data._new
						ev.stopPropagation()
						return false
					return true
				allowSort: (ev, from_idx, to_idx) =>
					!!@rows[to_idx]
				sorted: (ev, from_idx, to_idx) =>
					console.debug from_idx, ">", to_idx
					moveInArray(from_idx, to_idx, @rows, from_idx < to_idx)
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
					isPosInt(v)

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


	readOpts: ->
		super()
		@__rowRegistry = []


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

		CUI.DOM.setAttribute(new_form.DOM, "cui-form-depth", @getFormDepth() + 1)
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
		@storeValue(copyObject(@rows, true))

	__updateEmptyInRows: ->
		for row in @rows
			if @rowHasUserData(row)
				delete(row._empty)
			else
				row._empty = true

	hasUserData: ->
		# console.debug "have user data", @getValue()
		if not super()
			return false

		rows = @getValue()

		if rows.length == 0
			return false

		for row in rows
			if not row._empty
				return true

		return false

	rowHasUserData: (row) ->
		for f in @getFieldList()
			f.clearData().setData(row)
			if f.hasUserData(row)
				return true
		return false

	renderAsBlock: ->
		@getFieldList().length > 1

	displayValue: ->
		@rows = @getValue()
		# console.warn "display", @_name, rows.length

		@empty()
		for row in @rows
			@__appendRow(row)

		# console.warn "initData", @__data, @_name
		@__appendNewRow()
		@__updateButtons()
		return

	__appendNewRow: ->
		if @_new_rows not in ["edit", "append"]
			return

		@__appendRow(_new: true)

	__updateButtons: ->
		for row in @rows
			info = @__findRowInfo(row)
			info.trash?.show()
			if @rows.length >= 2
				info.move?.show()
			else
				info.move?.hide()
		return

	__findRowInfo: (row) ->
		idx = idxInArray(null, @__rowRegistry, (v) ->
			v.data == row
		)
		assert(idx > -1, "DataForm.__removeRow", "row not found", row: row, registry: @__rowRegistry)
		info = @__rowRegistry[idx]
		info.idx = idx
		info

	__removeRow: (row) ->
		info = @__findRowInfo(row)
		CUI.DOM.remove(info.dom)
		@__rowRegistry.splice(info.idx, 1)
		removeFromArray(row, @rows)
		@__storeValue()
		@

	__appendRow: (data) ->
		if @_rowMove
			move = new CUI.Icon
				class: "cui-data-form-row-move-handle"
				icon: "fa-reorder"

		if @_new_rows != "none"
			trash = new CUI.defaults.class.Button
				icon: "fa-minus"
				appearance: "flat"
				onMouseenter: =>
					hl.addClass("cui-data-form-row--trash")
				onMouseleave: =>
					hl.removeClass("cui-data-form-row--trash")
				onClick: =>
					@_onRowRemove?.call(@, data)
					@__removeRow(data)
					@__updateView()

		hl = new CUI.HorizontalLayout
			maximize_vertical: false
			class: "cui-data-form-row"
			maximize_horizontal: @___maximize_horizontal
			left:
				content: move
			right:
				content: trash
			center:
				content: @getForm(data).start()

		CUI.DOM.data(hl.DOM, "data", data)

		if data._new
			move?.hide()
			trash?.hide()

		@__rowRegistry.push
			data: data
			dom: hl.DOM
			trash: trash
			move: move

		@append(hl)
