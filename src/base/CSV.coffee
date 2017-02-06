class CUI.CSV extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			delimiter:
				mandatory: true
				check: String
				default: ","
			quotechar:
				mandatory: true
				check: String
				default: '"'

	toString: (rows, nl=String.fromCharCode(10)) ->

		nl = String.fromCharCode(10)
		cr = String.fromCharCode(13)

		console.debug "rows:", rows, _rows

		_rows = []
		for row in rows
			_row = []

			for col, idx in row
				if idx > 0
					_row.push(@_delimiter)

				str = ""+col

				if str.indexOf(@_delimiter) > -1
					quote = true
				else if str.indexOf(@_quotechar) > -1
					quote = true
				else if str.indexOf(nl) > -1
					quote = true
				else if str.indexOf(cr) > -1
					quote = true
				else
					quote = false

				if quote
					_row.push(@_quotechar+str.replace(new RegExp(escapeRegExp(@_quotechar), "g"), @_quotechar+@_quotechar)+@_quotechar)
				else
					_row.push(str)

			_rows.push(_row.join(""))

		_rows.join(nl)


	# parse csv info array
	parse: (text) ->
		rows = []
		columns = []
		column_idx = 0
		column_chars = []
		len = text.length
		idx = 0
		in_quotes = false

		console.info("CUI.CSV.parse:", len, "chars. delimiter: ", @_delimiter, "quotechar:", @_quotechar)

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

				if char == @_quotechar
					if in_quotes
						if text[idx+1] == @_quotechar
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

				if char == @_delimiter
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

			@__rows = rows
			dfr.resolve(rows)

		CUI.setTimeout
			ms: 0
			call: do_work

		dfr.done (rows) =>
			console.debug "text parsed", @, rows.length

		dfr.promise()