CUI.Template.loadTemplateText(require('./Sudoku.html'));

class Demo.Sudoku extends Demo
	getGroup: ->
		"Demo"

	display: ->
		@start()
		@tmpl

	getSum: (board) ->
		sum = 0
		for row in [0...9]
			for col in [0...9]
				sum = sum + (board[row]?[col]?.number or 0)
		sum

	draw: (board) ->
		possibles = @getPossibles(board)

		sum = @getSum(board)

		for row in [0...9]
			for col in [0...9]
				@cells[row][col].textContent = possibles[row][col].join(" ")

				type = board[row][col]?.type or "empty"
				if sum == 405 and type != "start"
					type = "solved"

				@cells[row][col].setAttribute("board", type)

		return

	flatten: (items) ->
		flat = []
		for row in [0...9]
			for col in [0...9]
				item = items[row]?[col]
				if item
					flat.push(row: row, col: col, item: item)
		flat

	getBlock: (row, col) ->

		info = {}

		info.block_number = Math.floor(row/3)*3+Math.floor(col/3)
		info.block_row = Math.floor(info.block_number / 3)
		info.block_col = info.block_number - Math.floor(info.block_number / 3) * 3

		info.row = row - info.block_row * 3
		info.col = col - info.block_col * 3
		info.number = info.row * 3 + info.col

		info


	getPossibles: (board) ->

		possibles = []

		for row in [0...9]
			possibles[row] = []
			for col in [0...9]
				possibles[row][col] = [1,2,3,4,5,6,7,8,9]

		for item in @flatten(board)
			row = item.row
			col = item.col
			number = item.item.number
			block = @getBlock(row, col)

			# remove the number from rows
			for i in [0...9]
				if i == col
					continue

				idx = possibles[row][i].indexOf(number)
				if idx > -1
					if possibles[row][i].length == 1
						throw "invalid: number: #{number} row: #{row} col: #{i}"

					possibles[row][i].splice(idx, 1)

			# remove the number from columns
			for i in [0...9]
				if i == row
					continue

				idx = possibles[i][col].indexOf(number)
				if idx > -1
					if possibles[i][col].length == 1
						throw "invalid: number: #{number} row: #{i} col: #{col}"

					possibles[i][col].splice(idx, 1)


			# remove the number from the block
			for i in [0...9]
				if i == block.number
					continue

				row_i = Math.floor(i/3)
				col_i = i - row_i * 3

				_row = block.block_row * 3 + row_i
				_col = block.block_col * 3 + col_i

				# console.debug "i:", i, "row i", row_i, "col_i", col_i, "row::", _row, "col::", _col

				idx = possibles[_row][_col].indexOf(number)
				if idx > -1
					if possibles[_row][_col].length == 1
						throw "invalid: number: #{number} row: #{_row} col: #{_col}"

					possibles[_row][_col].splice(idx, 1)

			idx = possibles[row][col].indexOf(number)
			if idx == -1
				console.debug "row:", row, "col:", col, "number:", number, possibles[row][col]
				throw "invalid: number: #{number} row: #{row} col: #{col}"

			possibles[row][col] = [number]

		return possibles

	registerKeys: ->
		CUI.Events.listen
			type: "keyup"
			node: window
			call: (ev) =>
				code = ev.keyCode()

				if not @cursor
					return

				row = parseInt(@cursor.dataset.row)
				col = parseInt(@cursor.dataset.col)

				if code == 27 # Esc
					@set(@board, row, col, null)
					@draw(@board)
					return

				if code == 32 # Space
					@setNextPossible()
					return

				if 49 <= code <= 57
					number = code - 48
					@set(@board, @cursor_row, @cursor_col, number)
					@draw(@board)
					return

				console.debug "code:", code
				return

	setNextPossible: ->
		if not @cursor
			return

		row = parseInt(@cursor.dataset.row)
		col = parseInt(@cursor.dataset.col)

		item = @board[row]?[col]
		if item?.type == 'start'
			return

		console.debug "item:", item

		number = item?.number or 0

		@set(@board, row, col, null)

		possible = @getPossibles(@board)[row][col]

		idx = possible.indexOf(number)

		console.debug "number:", number, "idx:", idx, "possible:", possible

		for i in [idx+1..possible.length]
			# the last "i" is undefined in possible
			if @set(@board, row, col, possible[i])
				break

		@draw(@board)

	drawGrid: ->
		grid = CUI.dom.element("DIV", class: "grid")

		CUI.Events.listen
			type: "click"
			node: grid
			call: =>
				@setNextPossible()

		@cells = []

		for row in [0...9]
			@cells[row] = []

			row_div = CUI.dom.element("DIV", class: "row", "data-row": row)
			CUI.dom.append(grid, row_div)

			for col in [0...9]

				cell_div = CUI.dom.element("DIV", class: "cell", "data-col": col)

				CUI.dom.append(row_div, cell_div)

				@cells[row][col] = cell_div

				cell_div.dataset.col = col
				cell_div.dataset.row = row

				CUI.Events.listen
					type: "mouseenter"
					node: cell_div
					call: (ev) =>
						target = ev.getCurrentTarget()
						@setCursor(target.parentNode.getAttribute("data-row"), target.getAttribute("data-col"))

				CUI.Events.listen
					type: "mouseleave"
					node: cell_div
					call: (ev) =>
						@setCursor()
		grid

	start: ->

		@tmpl = new CUI.Template
			name: "sudoku"
			map:
				board: true
				choose: true
				explain: true

		explain = new CUI.Label
			text: "Halten Sie die Maus über das Feld und drücken Sie **1**-**9**, **Leertaste** (valide Versuche durchprobieren), **Esc** (Aus Spiel nehmen)."
			size: "mini"
			multiline: true
			markdown: true

		@tmpl.append(explain, "explain")


		@registerKeys()
		@tmpl.append(@drawGrid(), 'board')
		@setCursor(0, 0)

		@boards = @loadBoards()
		@data = board_idx: 0

		@drawControls()

		@initBoard(@boards[0])


	loadBoards: ->
		boards = [
			name: "Neues Spiel"
			board: []
			new: true
		]

		# fixed
		for board in [
			name: 'Simple'
			values: '409250300000600219070038006005402600090000080003506100100720040587004000002015703'
			demo: true
		,
			name: 'Will Shortz'
			values: '039500000000800070000010904100400003000000000007000860006708200010090005000001008'
			demo: true
		,
			name: 'Star Burst'
			values: '000000000000003085001020000000507000004000100090000000500000073002010000000040009'
			demo: true
		,
			name: "World's Hardest Sudoku"
			values: '800000000003600000070090200050007000000045700000100030001000068008500010090000400'
			demo: true
		]
			board.board = b = []
			for value, idx in board.values.split('')
				if value == '0'
					continue

				row = Math.floor(idx / 9)
				col = idx - row * 9

				if not b[row]
					b[row] = []

				b[row][col] =
					number: parseInt(value)
					type: 'start'

			boards.push(board)


		for board in @load()
			boards.push(board)

		console.debug "boards loaded", boards

		boards

	drawControls: ->
		opts = []

		for board, idx in @boards
			txt = board.name

			opts.push
				text: txt
				value: idx
				_demo: board.demo
				_new: board.new

		opts.sort (a, b) ->
			if a._new
				a_txt = "00"
			else if a._demo
				a_txt = "01"+a.text
			else
				a_txt = a.text

			if b._new
				b_txt = "00"
			else if b._demo
				b_txt = "01"+b.text
			else
				b_txt = b.text

			a_txt.localeCompare(b_txt)

		idx_first_own = CUI.util.idxInArray(null, opts, (v) -> not v._demo and not v._new)

		opts.splice(1, 0, label: "Demo Spiele")
		if idx_first_own > -1
			opts.splice(idx_first_own+1, 0, label: "Eigene Spiele")

		choose = new CUI.Select
			data: @data
			name: "board_idx"
			options: opts
			onDataChanged: =>
				@initBoard(@boards[@data.board_idx])

		@save_btn = new CUI.Button
			icon: "fa-save"
			tooltip: text: "Board speichern"
			onClick: =>
				@saveBoard()

		@del_btn = new CUI.Button
			icon: 'trash'
			tooltip: text: "Board löschen."
			onClick: =>
				CUI.confirm
					text: "Board wirklich löschen?"
				.done =>
					@deleteBoard()

		@solve_btn = new CUI.Button
			icon_inactive: 'fa-rocket'
			icon_active: 'fa-rocket fa-spin'
			tooltip: text: "Spiel lösen (mit ALT, ohne Visiualisierung)."
			activate_initial: false
			switch: true
			onActivate: (btn, flags, ev) =>
				if ev.hasModifierKey()
					ms = 0
				else
					ms = 50

				CUI.setTimeout
					call: =>
						@solveBoard(ms)
						.always =>
							@solve_btn.deactivate()
				return

		@empty_btn = new CUI.Button
			icon: "fa-eraser"
			tooltip: text: "Gesetze Felder leeren."
			activate_initial: false
			onClick: =>
				@emptyBoard()

		choose.start()

		@tmpl.replace(new CUI.Buttonbar(buttons: [choose, @save_btn, @del_btn, @solve_btn, @empty_btn]), 'choose')

	setStatus: (board) ->
		if board.demo
			@save_btn.disable()
			@del_btn.disable()
		else if board.new
			@del_btn.disable()
			@save_btn.enable()
		else
			@save_btn.enable()
			@del_btn.enable()
		@

	solveBoard: (ms) ->
		@log("Solving with "+ms+"ms delay.")

		start = Date.now()

		@solveIterations = 0
		@solve(@board, ms)
		.done =>
			end = Date.now()
			@log("Solved in **"+(end-start)+"ms**.")

			@draw(@board)

			CUI.setTimeout
				ms: 1000
				call: =>
					for item in @flatten(@board)
						if item.item.type == 'guess'
							item.item.type = 'set'
					@draw(@board)
		.fail =>
			end = Date.now()
			if not @solve_btn.isActive()
				@log("Stopped solving after **"+(end-start)+"ms**.")
			else
				@log("Failed solving after **"+(end-start)+"ms**.")

	emptyBoard: ->
		for row in [0...9]
			for col in [0...9]
				if @board[row]?[col]?.type != 'start'
					@board[row][col] = null
		@draw(@board)


	saveBoard: ->
		save = =>
			boards = @boards.slice(1)
			CUI.util.removeFromArray(null, boards, (v) => v.demo)
			@save(boards)
			@drawControls()
			@initBoard(@boards[@data.board_idx])

		if @boards[@data.board_idx].new
			CUI.prompt(text: "Name des Boards")
			.done (name) =>
				@boards.push(board: @board, name: name)
				@data.board_idx = @boards.length - 1
				save()
		else
			cb = @boards[@data.board_idx]
			CUI.prompt(text: "Name des Boards", default: cb.name)
			.done (name) =>
				cb.board = CUI.util.copyObject(@board, true)
				cb.name = name
				save()

	deleteBoard: ->
		if @data.board_idx == 0
			return

		@boards.splice(@data.board_idx, 1)
		@save(@boards.slice(1))
		@data.board_idx = 0
		@drawControls()
		@initBoard(@boards[@data.board_idx])


	initBoard: (_board) ->

		lb = CUI.util.copyObject(_board.board, true)
		values = []

		@board = []
		for row in [0...9]
			@board[row] = []
			for col in [0...9]
				@board[row][col] = null
				if lb[row]?[col]
					values.push(lb[row][col].number)
					@board[row][col] = lb[row][col]
					@board[row][col].type = 'start'
				else
					values.push(0)

		console.info("Board", _board.name, values.join(''))
		@draw(@board)
		@setStatus(_board)

	next: (ms = 50) ->

		if ms == 0
			return CUI.resolvedPromise()

		dfr = new CUI.Deferred()

		CUI.setTimeout
			ms: ms
			call: =>
				dfr.resolve()

		dfr.promise()

	shuffle: (arr) ->
		for i in [arr.length-1...0] by -1
			t = arr[i]
			j = Math.floor(Math.random() * (i + 1))
			arr[i] = arr[j]
			arr[j] = t
		arr

	solve: (board, ms = 50, level = 0, sets = []) ->

		debug = (set) =>
			output = []
			possible = possibles[set.row][set.col]

			if possible.length == 1
				return possible[0]

			for number, idx in possible
				if number == set.number
					output.push(number+"<")
				else
					output.push(number)

			output.join("")

		path_debug = =>
			output = []
			for set, _level in sets
				if _level == level
					break
				output.push(set.debug)
			output.join("|")

		if not @solve_btn.isActive()
			return CUI.rejectedPromise()

		dfr = new CUI.Deferred()

		possibles = @getPossibles(board)

		items = @flatten(possibles)
		items.sort (a, b) =>
			CUI.util.compareIndex(a.item.length, b.item.length)

		idx = 0
		while idx < items.length
			item = items[idx]
			if board[item.row][item.col]
				items.splice(idx, 1)
				continue
			idx = idx + 1

		if items.length == 0
			dfr.resolve()
			return dfr.promise()

		item = items[0]
		idx = item.item.length

		# @shuffle(item.item)

		next_number = =>

			idx = idx - 1
			if idx == -1
				dfr.reject()
				return

			number = item.item[idx]

			# console.debug "level:", level, "item:", idx, "item_idx:", item_idx, "choices:", item.item.join(" "), "number:", number, "row:", item.row, "col:", item.col, "bad:", bad_sets[level].length
			#
			if ms > 0
				sets[level] = null

				dbg = level+"["+@solveIterations+"]: "
				if level == 0
					dbg += debug(number: number, row: item.row, col: item.col)
				else
					dbg += path_debug()+"|"+debug(number: number, row: item.row, col: item.col)

			if @set(board, item.row, item.col, number, 'guess')

				if ms > 0
					sets[level] = number: number, row: item.row, col: item.col
					sets[level].debug = debug(sets[level])
					console.debug(dbg)
					@draw(board)

				@next(ms)
				.done =>
					@solve(board, ms, level+1, sets)
					.done(dfr.resolve)
					.fail =>
						if not @solve_btn.isActive()
							return dfr.reject()

						@set(board, item.row, item.col, null)
						if ms > 0
							@draw(board)
							sets[level] = null
						@next(ms).done(next_number)

				return
			else
				@solveIterations = @solveIterations + 1
				if ms > 0
					console.debug(dbg+" **FAILED**")

				# console.debug level, sets, bad_sets
				# console.error "error setting..."
				@next(ms).done(next_number)

			return

		next_number()
		return dfr.promise()


	setCursor: (@cursor_row, @cursor_col) ->
		if @cursor
			@cursor.classList.remove("cursor")
			@cursor = null

		if not (@cursor_row and @cursor_col)
			return

		@cursor = @cells[@cursor_row][@cursor_col]
		@cursor.classList.add("cursor")

	set: (board, row, col, number, type = 'set') ->
		if not number
			board[row][col] = null
			return true

		possibles = @getPossibles(board)
		if number in possibles[row][col]
			board[row][col] = type: type, number: number
			try
				@getPossibles(board)
				return true
			catch ex
				board[row][col] = null
				return false
		else
			return false

	save: (boards) ->
		CUI.setLocalStorage('boards', boards)

	load: ->
		CUI.getLocalStorage('boards') or []


Demo.register(new Demo.Sudoku())
