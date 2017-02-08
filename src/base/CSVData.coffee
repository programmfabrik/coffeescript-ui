class CUI.CSVData extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			rows:
				check: (v) ->
					CUI.isArray(v) and v.length > 0

	readOpts: ->
		super()

		@__max_column_count = 0

		if @_rows
			@rows = @_rows
		else
			@rows = []

		@giveAllRowsSameNumberOfColumns()

		return

	# makes sure, all rows have the same length
	giveAllRowsSameNumberOfColumns: ->
		@__max_column_count = 0
		for row in @rows
			col_count = row.length
			if col_count > @__max_column_count
				@__max_column_count = col_count

		for row in @rows
			if row.length < @__max_column_count
				for idx in [row.length...@__max_column_count]
					row[idx] = null
		return

	getMaxColumnCount: ->
		@__max_column_count

	getRows: ->
		@rows

	getRow: (row_i) ->
		@rows[row_i]

	getRowsCount: ->
		@rows.length

	debug: ->
		console.debug "rows:", @rows

	toText: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "CSVData.toText",
			delimiter:
				mandatory: true
				default: ";"
				check: (v) =>
					CUI.isString(v) and v.length > 0
			quotechar:
				mandatory: true
				default: '"'
				check: (v) =>
					CUI.isString(v) and v.length > 0
			always_quote:
				mandatory: true
				default: true
				check: Boolean
			equal_columns:
				mandatory: true
				default: true
				check: Boolean
			newline:
				mandatory: true
				default: String.fromCharCode(10)
				check: (v) =>
					CUI.isString(v) and v.length > 0

		if opts.equal_columns
			@giveAllRowsSameNumberOfColumns()

		nl = String.fromCharCode(10)
		cr = String.fromCharCode(13)

		_rows = []
		for row in @rows
			_row = []

			for col, idx in row
				if idx > 0
					_row.push(opts.delimiter)

				if isEmpty(col)
					str = ""
				else
					str = ""+col

				if opts.always_quote
					quote = true
				else if str.indexOf(opts.delimiter) > -1
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
	parse: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "CSVData.parse",
			text:
				mandatory: true
				check: String
			delimiter:
				check: String
			quotechar:
				check: String

		@rows = []
		text = opts.text
		columns = []
		column_idx = 0
		column_chars = []
		len = text.length
		idx = 0
		in_quotes = false

		lines = 0

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
					lines = lines + 1
					@rows.push(columns)
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

						if lines%1000==0
							dfr.notify(row_count: lines, file_read_idx: idx, file_length: len)
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

			@giveAllRowsSameNumberOfColumns()
			dfr.resolve(row_count: lines, file_length: len)

		CUI.setTimeout
			ms: 0
			call: do_work

		dfr.done =>
			@debug()

		dfr.promise()