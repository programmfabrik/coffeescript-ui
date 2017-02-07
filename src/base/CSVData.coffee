class CUI.CSVData extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			rows:
				check: (v) ->
					CUI.isArray(v) and v.length > 0
			header_rows:
				mandatory: true
				default: 0
				check: (v) ->
					v >= 0

	readOpts: ->
		super()
		@column_names = []
		if @_rows
			@rows = @_rows
			if @_header_rows
				for header_row_i in [0...@_header_rows]
					@column_names[header_row_i] = []
					for col in @rows[header_row_i]
						@column_names[header_row_i].push(col)

				for row_i in [@_header_rows...@rows.length]
					row = @rows[row_i]
					row.columns = []
					for header_row_i in [0...@_header_rows]
						row.columns[header_row_i] = {}
						for col, col_i in row
							col_name = @column_names[header_row_i][col_i]
							if col_name
								row.columns[header_row_i][col_name] = col
		else
			@rows = []
		return

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