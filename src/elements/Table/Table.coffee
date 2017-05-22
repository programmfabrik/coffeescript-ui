###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Table extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		# CUI.__ng__: when we only have "ng", use CUI.DOM.element instead

		cls = []

		if @_size == "mini"
			cls.push("cui-table--mini")

		if @_class
			cls.push(@_class)

		if @_flex
			cls.push("cui-table--flex")

		@__table = $table(cls.join(" "))

		@registerDOMElement(@__table, false)

		if @_header
			# add header column
			header = $tr("cui-table-header")
			for col in @__columns
				if col.text
					txt = col.text
				else
					txt = col.name

				th = $th("cui-table-th "+col.__class)
				th.textContent = txt
				header.appendChild(th)

			@__table.appendChild(header)

		for row in @_rows
			@addRow(row)
		@

	initOpts: ->
		super()
		is_array_of_maps = (v, check) =>
			if not CUI.isArray(v)
				return false
			for _v, idx in v
				if check
					v[idx] = CUI.Element.readOpts(_v, "new Table", check)
				else if not CUI.isPlainObject(_v)
					return false
			true

		@addOpts
			class:
				check: String
			header:
				mandatory: true
				default: true
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
					CUI.isArray(v)
			flex:
				default: false
				check: Boolean

			size:
				mandatory: true
				default: "normal"
				check: ["normal", "mini"]

	readOpts: ->
		super()
		if @_key_value
			assert(not @_columns and not @opts.hasOwnProperty("header"), "new Table", "opts.key_value cannot be set together with opts.header or opts.columns.", opts: @opts)
			@_header = false
			@__columns = [
				name: "key"
			,
				name: "value"
			]
		else
			@__columns = copyObject(@_columns, true)


		for col in @__columns
			if col.name
				col.__class = " cui-td--"+col.name
			else
				col.__class = ""

			if not isEmpty(col.class)
				col.__class += " "+col.class

		@

	addRow: (row) ->
		tr = $tr("cui-table-row")
		for col in @__columns
			td = $td("cui-table-td"+col.__class)
			value = row[col.name]
			if isString(value)
				CUI.DOM.addClass(td, "cui-td--text-content")
				td.textContent = value
			else
				CUI.DOM.append(td, value)
			tr.appendChild(td)
		@__table.appendChild(tr)
		@

	@keyValueRowsFromMap: (map) ->
		for k, v of map
			key: k
			value: v
