class CUI.CSVData extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			rows:
				check: (v) ->
					CUI.isArray(v) and v.length > 0

			header_rows:
				mandatory: true
				default: null
				check: (v) ->
					v >= 0 or v == null

			column_name_prefix:
				mandatory: true
				default: "column "
				check: String

	readOpts: ->
		super()
		@column_names = []

		@__max_column_count = 0
		@__header_rows = undefined

		if @_rows
			@rows = @_rows
			for row in @rows
				col_count = row.length
				if col_count > @__max_column_count
					@__max_column_count = col_count
		else
			@rows = []

		if @_header_rows >= 0
			@readHeaderRows(@_header_rows)

		return

	readHeaderRows: (@__header_rows) ->

		@column_names = [[]]
		for col_i in [0...@__max_column_count] by 1
			@column_names[0].push(@_column_name_prefix+(col_i+1))

		for header_row_i in [0...@__header_rows] by 1
			@column_names[header_row_i+1] = []
			for col in @rows[header_row_i]
				@column_names[header_row_i+1].push(col)

		for row_i in [0...@rows.length] by 1
			row = @rows[row_i]
			row.columns = [{}]

			# map to first line by "idx"
			for col, col_i in row
				row.columns[0][@column_names[0][col_i]] = col

			for i in [col_i...@__max_column_count] by 1
				row.columns[0][@column_names[0][col_i]] = null # add empty columns

			if row_i < @__header_rows
				continue

			for header_row_i in [0...@__header_rows] by 1
				row.columns[header_row_i+1] = {}
				for col, col_i in row
					col_name = @column_names[header_row_i+1][col_i]
					if col_name
						row.columns[header_row_i+1][col_name] = col
		return

	getMaxColumnCount: ->
		@__max_column_count

	getRows: ->
		@rows

	getColumnNames: (header_row) ->
		assert(@__header_rows >= 0, "CSVData.getColumnNames", "readHeaderRows needs to be called before calling this.", CSVData: @)
		@column_names[header_row]

	getRowsByHeader: (header_row = 0) ->
		assert(@__header_rows >= 0, "CSVData.getRowsByHeader", "readHeaderRows needs to be called before calling this.", CSVData: @)

		rows = []
		for row, idx in @rows
			if idx < @__header_rows
				continue
			rows.push(row.columns[header_row])
		rows

	getRow: (row_i) ->
		@rows[row_i + (@__header_rows or 0)]

	getRecord: (row_i, header_row) ->
		@getRow(row_i).columns[header_row]

	getRowsCount: ->
		@rows.length - (@__header_rows or 0)


	debug: ->
		console.debug "rows:", @rows, "column_names:", @column_names

	toText: (_opts) ->
		opts = CUI.Element.readOpts _opts, "CSVData.toText",
			delimiter:
				mandatory: true
				check: (v) =>
					CUI.isString(v) and v.length > 0
			quotechar:
				mandatory: true
				check: (v) =>
					CUI.isString(v) and v.length > 0
			newline:
				mandatory: true
				default: String.fromCharCode(10)
				check: (v) =>
					CUI.isString(v) and v.length > 0

		nl = String.fromCharCode(10)
		cr = String.fromCharCode(13)

		_rows = []
		for row in @rows
			_row = []

			for col, idx in row
				if idx > 0
					_row.push(opts.delimiter)

				str = ""+col

				if str.indexOf(opts.delimiter) > -1
					quote = true
				else if str.indexOf(opts.quotechar) > -1
					quote = true
				else if str.indexOf(nl) > -1
					quote = true
				else if str.indexOf(cr) > -1
					quote = true
				else
					quote = false

				if quote
					_row.push(opts.quotechar+str.replace(new RegExp(escapeRegExp(opts.quotechar), "g"), opts.quotechar+opts.quotechar)+opts.quotechar)
				else
					_row.push(str)

			_rows.push(_row.join(""))

		_rows.join(opts.newline)


	# parse csv info array
	@parse: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "CSVData.parse",
			text:
				mandatory: true
				check: String
			header_rows:
				mandatory: true
				default: 0
				check: (v) ->
					v >= 0
			delimiter:
				check: String
			quotechar:
				check: String

		text = opts.text
		rows = []
		columns = []
		column_idx = 0
		column_chars = []
		len = text.length
		idx = 0
		in_quotes = false

		auto_quotechars = ['"',"'"]
		auto_delimiters = [",",";","\t"]

		if not isEmpty(opts.delimiter)
			delimiter = opts.delimiter
		else
			delimiter = null

		if not isEmpty(opts.quotechar)
			quotechar = opts.quotechar
		else
			quotechar = null

		console.info("CUI.CSV.parse:", len, "chars. delimiter:", delimiter or "detect", "quotechar:", quotechar or "detect")

		dfr = new CUI.Deferred()

		do_work = =>

			end_column = =>
				columns[column_idx] = column_chars.join("")
				column_chars.splice(0)
				column_idx = column_idx + 1

			end_row = =>
				if columns.length > 0
					rows.push(columns)
					columns = []

				column_idx = 0

			while (idx < len)
				char = text.charAt(idx)
				# console.debug "char:", idx, char, text.charCodeAt(idx)

				if quotechar == null and char in auto_quotechars
					quotechar = char
					console.info("CSVData.parse: detected quotechar:", quotechar)

				if delimiter == null and char in auto_delimiters
					delimiter = char
					console.info("CSVData.parse: detected delimiter:", delimiter)

				if char == quotechar
					if in_quotes
						if text[idx+1] == quotechar
							column_chars.push(char)
							idx = idx + 2
							continue
						else
							# end quote
							in_quotes = false
							idx = idx + 1
							continue
					else
						in_quotes = true
						idx = idx + 1
						continue

				if char == delimiter
					if in_quotes
						column_chars.push(char)
						idx = idx + 1
						continue
					else
						end_column()
						idx = idx + 1
						continue

				charCode = text.charCodeAt(idx)
				nextCharCode = text.charCodeAt(idx+1)

				# do we have a line ending
				if charCode == 13 or charCode == 10

					if in_quotes
						column_chars.push(String.fromCharCode(10))
					else
						end_column()
						end_row()

						if rows.length%1000==0
							dfr.notify(idx, rows)
							CUI.setTimeout
								ms: 10
								call: do_work
							return

					if (charCode == 13 and nextCharCode == 10)
						idx = idx + 2
					else
						idx = idx + 1

					continue

				column_chars.push(char)
				idx = idx + 1

			if column_chars.length > 0
				end_column()

			if columns.length > 0
				end_row()

			csv_data = new CUI.CSVData
				rows: rows
				header_rows: opts.header_rows

			dfr.resolve(csv_data)

		CUI.setTimeout
			ms: 0
			call: do_work

		dfr.done (csv_data) =>
			csv_data.debug()

		dfr.promise()