###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Table extends CUI.DOMElement
	constructor: (opts) ->
		super(opts)

		# CUI.__ng__: when we only have "ng", use CUI.dom.element instead

		cls = []

		if @_size == "mini"
			cls.push("cui-table--mini")

		if @_class
			cls.push(@_class)

		if @_flex
			cls.push("cui-table--flex")

		if @_bordered
			cls.push("cui-table--bordered")

		@__table = CUI.dom.table(cls.join(" "))

		@registerDOMElement(@__table, false)

		CUI.Layout::maximizeAddClasses.call(@)

		if @_header
			# add header column
			header = CUI.dom.tr("cui-table-header")
			for col in @__columns
				if col.text
					txt = col.text
				else
					txt = col.name

				th = CUI.dom.th("cui-table-th "+col.__class)
				th.textContent = txt
				header.appendChild(th)

			@__table.appendChild(header)

		for row in @_rows
			@addRow(row)
		@

	initOpts: ->
		super()
		is_array_of_maps = (v, check) =>
			if not CUI.util.isArray(v)
				return false
			for _v, idx in v
				if check
					v[idx] = CUI.Element.readOpts(_v, "new CUI.Table", check)
				else if not CUI.util.isPlainObject(_v)
					return false
			true

		@addOpts
			class:
				check: String
			header:
				mandatory: true
				default: true
				check: Boolean
			bordered:
				default: false
				check: Boolean
			columns:
				check: (v) ->
					is_array_of_maps v,
						class:
							mandatory: true
							check: String
							default: ""
						name:
							mandatory: true
							check: String
						text:
							check: String
			key_value:
				mandatory: true
				default: false
				check: Boolean
			rows:
				mandatory: true
				default: []
				check: (v) ->
					CUI.util.isArray(v)
			flex:
				default: false
				check: Boolean

			size:
				mandatory: true
				default: "normal"
				check: ["normal", "mini"]
			maximize:
				default: false
				check: Boolean
			maximize_horizontal:
				default: false
				check: Boolean
			maximize_vertical:
				default: false
				check: Boolean

	readOpts: ->
		super()
		if @_key_value
			CUI.util.assert(not @_columns and not @opts.hasOwnProperty("header"), "new CUI.Table", "opts.key_value cannot be set together with opts.header or opts.columns.", opts: @opts)
			@_header = false
			@__columns = [
				name: "key"
			,
				name: "value"
			]
		else
			@__columns = CUI.util.copyObject(@_columns, true)


		for col in @__columns
			if col.name
				col.__class = " cui-td--"+col.name
			else
				col.__class = ""

			if not CUI.util.isEmpty(col.class)
				col.__class += " "+col.class

		CUI.Layout::maximizeReadOpts.call(@)
		@

	addRow: (row) ->
		tr = CUI.dom.tr("cui-table-row")
		for col, col_idx in @__columns
			td = CUI.dom.td("cui-table-td"+col.__class)
			value = row[col.name]
			if value == undefined
				value = row[col_idx]

			if CUI.util.isString(value)
				CUI.dom.addClass(td, "cui-td--text-content")
				td.textContent = value
			else
				CUI.dom.append(td, value)
			tr.appendChild(td)
		@__table.appendChild(tr)
		@

	@keyValueRowsFromMap: (map) ->
		for k, v of map
			key: k
			value: v
