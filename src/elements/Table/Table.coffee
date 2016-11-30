class CUI.Table extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		# CUI.__ng__: when we only have "ng", use CUI.DOM.element instead

		cls = []

		if @_size == "mini"
			cls.push("cui-table--mini")

		if @_class
			cls.push(@_class)

		@__table = $table(cls.join(" "))

		@registerDOMElement(@__table, false)

		# add header column
		header = $tr("cui-table-header")
		for col in @_columns
			if col.text
				txt = col.text
			else
				txt = col.name
			th = $th("cui-table-th "+col.class)
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
			rows:
				mandatory: true
				default: []
				check: is_array_of_maps

			size:
				mandatory: true
				default: "normal"
				check: ["normal", "mini"]

	addRow: (row) ->
		tr = $tr("cui-table-row")
		for col in @_columns
			td = $td("cui-table-td "+col.class)
			CUI.DOM.append(td, row[col.name])
			tr.appendChild(td)
		@__table.appendChild(tr)
		@
