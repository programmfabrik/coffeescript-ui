###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DataTableNode extends CUI.ListViewRow

	initOpts: ->
		super()
		@addOpts
			dataTable:
				mandatory: true
				check: CUI.DataTable
			data:
				mandatory: true
				check: "PlainObject"
			check_changed_data:
				check: "PlainObject"
			rows:
				mandatory: true
				check: "Array"
			dataRowIdx:
				mandatory: true
				check: (v) ->
					v >= 0

	readOpts: ->
		super()
		@__dataTable = @_dataTable
		@__data = @_data
		@__check_changed_data = @_check_changed_data
		@__rows = @_rows

		CUI.util.assert(@__rows.indexOf(@__data) > -1, "new #{CUI.util.getObjectClass(@)}", "opts.data needs to be item in opts.rows Array", opts: @opts)
		@__fields = []
		for f in @__dataTable.getFieldList()
			fopts = f.getOpts()
			fopts.undo_support = false
			if CUI[f.getElementClass()]
				_f = new CUI[f.getElementClass()](fopts)
			else
				_f = new window[f.getElementClass()](fopts)

			_f.setForm(@)
			_f.setData(@__data)
			if f.hasData()
				if @__check_changed_data
					_f.setCheckChangedValue(@__check_changed_data[f.getName()])
				else
					_f.setCheckChangedValue(f.getDefaultValue())
			@__fields.push(_f)
			@addColumn(new CUI.ListViewColumn(element: _f.DOM))
		@

	remove: ->
		CUI.decide(@_dataTable._onBeforeRowRemove?.call(@, @__data))
		.done =>
			super()
			CUI.util.removeFromArray(@__data, @__rows)
			@_dataTable._onRowRemove?.call(@, @__data)
			@_dataTable.updateButtons()

	getDataTable: ->
		@_dataTable

	getFieldByIdx: (idx) ->
		@__fields[idx]

	getDataRowIdx: ->
		@_dataRowIdx

	getFieldsByName: (name) ->
		fields = []
		for f in @__fields
			if f.getName() == name
				fields.push(f)
		fields

	getFields: ->
		@__fields

	getData: ->
		@__data

	reload: ->
		for df in @__fields
			df.reload()

	addedToListView: ->
		for df in @__fields
			df.start()
		@
