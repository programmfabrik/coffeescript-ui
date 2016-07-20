class CUIPlayground extends Demo
	constructor: (@opts={}) ->
		super(@opts)
		@__game_steps = []
		@__games = []
		@__games_data =
			per_game: []
			game: 0

	addGame: (game) ->
		CUI.debug "adding game", game,  @__games.length, @getGameByName(game.name())
		if @getGameByName(game.name())
			CUI.alert(text: "game already exists.")
			return
		game.idx = @__games.length
		@__games.push(game)
		@__games_data.per_game[game.idx] = {}
		@

	getGameByName: (name) ->
		for game in @__games
			CUI.debug game.name(), name
			if game.name() == name
				return game
		null

	display: ->
		@__playground = $div("cui-playground-playground cui-playground-allow-cursor", "cui-playground-cursor": 0)
		@__playground_cursor = $div("cui-playground-cursor").appendTo(@__playground)
		Events.listen
			type: "click"
			node: @__playground_cursor[0]
			call: (ev) =>
				@__playground_cursor.detach()
				@__playground.addClass("cui-playground-select-cursor")
				ev.stopPropagation()
				@renderGameControl()
				for el in DOM.findElements(@__playground[0], ".cui-playground-allow-cursor")
					cursor_idx = DOM.getAttribute(el, "cui-playground-cursor")
					cs_div = $div("cui-playground-cursor-select")
					do (cursor_idx) =>
						Events.listen
							type: "click"
							node: cs_div
							call: (ev) =>
								@__playground.removeClass("cui-playground-select-cursor")
								@__playground.find(".cui-playground-cursor-select").remove()
								@setCursor(cursor_idx)
								ev.stopPropagation()
								return

					el.appendChild(cs_div[0])
				return

		@__cursor_places = 1

		Events.listen
			type: "click"
			call: (ev) =>
				target = ev.getTarget()
				# CUI.debug "clicked on", ev.getTarget(), DOM.findElement(@__playground[0], ":focus")

		@addGame(new VerticalLayoutPlaygroundGame(playground: @))
		@addGame(new LabelPlaygroundGame(playground: @))

		@__right_layout = new VerticalLayout
			top:
				flexHandle:
					hidden: false
					closed: false
			center:
				content: $text("center")

		@__layout = new HorizontalLayout
			center:
				content: @__playground
			right:
				flexHandle:
					hidden: false
					closed: false
				content: @__right_layout

		@renderGameControl()

		CUI.DOM.waitForDOMInsert(node: @__layout.DOM[0])
		.done =>
			@setCursor(0)

		@__layout


	renderGameControl: (_step) ->
		CUI.debug "render game control", _step

		if not isNull(_step)
			# ok jQuery is shorter for this...
			@__playground.find(".cui-playground-game-has-control").removeClass("cui-playground-game-has-control")

			game_div = DOM.findElement(@__playground[0], "[cui-playground-game-step=\"#{_step}\"]")
			game_div.classList.add("cui-playground-game-has-control")
			@__playground.addClass("cui-playground-a-game-has-control")
			@__playground.removeClass("cui-playground-no-game-has-control")
		else
			@__playground.addClass("cui-playground-no-game-has-control")
			@__playground.removeClass("cui-playground-a-game-has-control")

		game_control = new VerticalLayout
			top:
				content: null

		update_game_options = (game, data) =>
			fields = game.getFields()
			for f in fields
				f.undo_and_changed_support = false
				if f.default
					data[f.name] = f.default
					delete(f.default)
				if not f.form
					f.form = {}
				if not f.form.label
					f.form.label = f.name

			form = new Form
				fields: fields
				data: data
			.start()
			game_control.replace(form, "center")


		if isNull(_step)
			game_opts = []
			for game, idx in @__games
				game_opts.push
					value: idx
					text: game.name()

			game_control_form = new Form
				data: @__games_data
				fields: [
					type: Form
					horizontal: true
					fields: [
						type: Select
						options: game_opts
						name: "game"
						onDataChanged: =>
							game = @__games[@__games_data.game]
							update_game_options(game, @__games_data.per_game[game.idx])
					,
						type: FormButton
						text: "Add"
						onClick: =>
							game = @__games[@__games_data.game]
							@__game_steps.push
								cursor: @getCursor()
								game: game.name()
								data: copyObject(@__games_data.per_game[game.idx], true)

							@renderPlayground()
					]
				]

			update_game_options(@__games[0], @__games_data.per_game[0])

		else
			step = @__game_steps[_step]
			game_data = copyObject(step.data)
			game = @getGameByName(step.game)
			game_control_form = new Form
				horizontal: true
				fields: [
					type: Output
					text: game.name()
				,
					type: FormButton
					text: "Update"
				]
			update_game_options(game, game_data)

		game_control.replace(game_control_form.start(), "top")
		@__right_layout.replace(game_control, "top")
		game_control


	setCursor: (@__cursor=0) ->
		cursor_div = DOM.findElement(@__layout.DOM[0], "[cui-playground-cursor=\"#{@__cursor}\"]")
		if not cursor_div
			CUI.alert(text: "Cursor DIV not found.")
		else
			cursor_div.appendChild(@__playground_cursor[0])
		@

	getCursor: ->
		@__cursor

	renderPlayground: ->
		CUI.debug "render playground", dump(@__game_steps)
		@__playground.empty()
		@__cursor_places = 1

		for step, step_idx in @__game_steps
			@setCursor(step.cursor)
			game = @getGameByName(step.game)
			if not game
				CUI.alert(text: "Game not found: "+step.game)
				continue
			@renderGame(game, step.data, step_idx)

		@setCursor(@__cursor_places-1)

	renderGame:(game, data, step_idx) ->
		div = game.render(data)
		div.classList.add("cui-playground-game")
		DOM.setAttribute(div, "cui-playground-game-step", step_idx)

		Events.listen
			type: "click"
			node: div
			call: (ev) =>
				if div.classList.contains("cui-playground-game-has-control")
					div.classList.remove("cui-playground-game-has-control")
					@renderGameControl()
					CUI.debug "clicked on game second time", step_idx, DOM.data(div)
				else
					@renderGameControl(step_idx)
					CUI.debug "clicked on game", step_idx, DOM.data(div)
				ev.stopPropagation()
				return

		for el in DOM.findElements(div, ".cui-playground-allow-cursor")
			DOM.setAttribute(el, "cui-playground-cursor", @__cursor_places++)

		DOM.data div,
			game: game
			data: data

		assert(CUI.DOM.isInDOM(@__playground_cursor[0]), "CUIPlayground.renderGame", "Cursor needs to be in DOM.")
		@__playground_cursor.before(div)
		@


class PlaygroundGame extends Element
	initOpts: ->
		super()
		@addOpts
			playground:
				mandatory: true
				check: CUIPlayground

	name: ->
		"<game>"

	render: (data) ->
		assert(false, @__cls+".render", "Needs implementation.")

	getFields: ->
		[]

	# set by the playground
	idx: -1

class VerticalLayoutPlaygroundGame extends PlaygroundGame
	name: ->
		"VerticalLayout"

	getFields: ->
		fields = []
		for k in ["top", "center", "bottom"]
			fields.push
				type: Input
				name: k
				default: k
				form:
					label: k
		fields.push
			type: Checkbox
			name: "maximize"
			default: true
			form:
				label: "maximize"
		fields

	render: (data) ->
		new VerticalLayout
			maximize: data.maximize
			top:
				content: $text(data.top)
			center:
				class: "cui-playground-allow-cursor"
				content: $text(data.center)
			bottom:
				content: $text(data.bottom)
		.DOM[0]


class LabelPlaygroundGame extends PlaygroundGame
	getFields: ->
		fields = [
			type: Input
			name: "text"
			default: "Label"
		]

	name: ->
		"Label"

	render: (data) ->
		new Label
			text: data.text
		.DOM[0]


Demo.register(new CUIPlayground())