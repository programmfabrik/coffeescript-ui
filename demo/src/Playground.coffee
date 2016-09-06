class Playground extends Demo
	getGroup: ->
		""

	getName: ->
		"Playground"

	getButtons: (opts ={}) ->
		@getElements(CUI.Button, opts, [
			text: "Button"
		,
			disabled: true
			text: "Disabled"
		,
			switch: true
			active: true
			text: "Switch"
		,
			switch: true
			disabled: true
			active: true
			text: "Disabled & Active"
		])

	getOptions: (opts = {}) ->
		@getElements(CUI.Options, opts, [
			min_checked: 0
			options: [
				text: "One"
			,
				text: "Two"
			,
				text: "Three"
			]
		])[0]

	getLabel: (opts = {}) ->
		label = @getElements(CUI.Label, opts, [{}])[0]
		label

	getMultiLabel: ->
		@getLabel(
			multiline: true
			text: """Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
					Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.

					Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim."""
		)

	getElements: (cls, opts={}, ele_opts) ->
		elements = []
		for ele_opt in ele_opts
			copy_opts = copyObject(opts, true)
			for k, v of ele_opt
				if not copy_opts.hasOwnProperty(k)
					copy_opts[k] = v

			elements.push(new cls(copy_opts))
		elements

	getLayoutTab: ->

		hl = new HorizontalLayout
			left:
				flexHandle:
					hidden: false
				content: $text("Left Side")

			center: {}
			right:
				flexHandle:
					hidden: false
				content: new SimplePane
					header_center: new Label(text: "CUI.SimplePane")
					header_right:
						icon: "close"
					content: new Label(text: "Content")
					footer_right:
						text: "Ok"

		treeDemo = new ListViewTreeDemo()

		tree = new ListViewTree
			cols: ["auto", "maximize", "auto", "auto"]
			fixedRows: 1
			fixedCols: 1
			root: new ListViewTreeDemoNode(demo: treeDemo)
			selectable: true

		hl.replace(tree.render(false), "left")
		tree.appendRow(new ListViewTreeDemoHeaderNode())
		tree.root.open()

		shc = new StickyHeaderControl(element: hl.center())

		sticky_flow = []

		for i in [0...10]
			sticky_flow.push(new StickyHeader(text: "Header "+i, level: 0, control: shc))
			for j in [0..Math.ceil(Math.random()*10)]
				sticky_flow.push(@getMultiLabel())
				if Math.random() > 0.7
					sticky_flow.push(new StickyHeader(level: 1, text: "Sub-Header", control: shc))

		hl.append(sticky_flow, "center")


		hl

	getLayerTab: ->
		dt = new DemoTable()
		dt.addExample("Buttons & Tooltips",
			new Buttonbar(buttons: @getButtons
				tooltip:
					text: "Tooltip!"
			)
		)
		dt.addExample("Layer",
			new Buttonbar(buttons: [
				text: "Popover"
				onClick: (ev, btn) =>
					pop = new Popover
						element: btn
						cancel: true
						pane:
							header_left:
								new Label(text: "Popover")
							content: new MultilineLabel
								markdown: true
								text: """# Markdown\n\nYo Test Test"""
							footer_right:
								text: "Ok"
								onClick: =>
									pop.destroy()
					pop.show()
			,
				text: "Modal"
				onClick: (ev, btn) =>
					mod = new Modal
						element: btn
						cancel: true
						pane:
							header_left:
								new Label(text: "Modal")
							content: new MultilineLabel
								markdown: true
								text: """# Markdown\n\nYo Test Test"""
							footer_right:
								text: "Ok"
								onClick: =>
									mod.destroy()
					mod.show()

			])
		)

		dt.addExample("Confirmations",
			new Buttonbar(buttons: [
				text: "CUI.alert"
				onClick: =>
					CUI.alert(
						title: "Alert"
						text: "Alert!"
					)
			,
				text: "CUI.problem"
				onClick: =>
					CUI.problem(
						title: "Problem"
						text: "This is going to be a problem!"
					)
			,
				text: "CUI.confirm"
				onClick: =>
					CUI.confirm(
						title: "Confirmation"
						text: "Yes or No?"
					)
			,
				text: "CUI.prompt"
				onClick: =>
					CUI.prompt(
						title: "Question"
						text: "What's your name?"
					)
			])
		)
		dt.table

	getFormTab: ->
		fields = []

		multi_input_control = new MultiInputControl
			user_control: true
			preferred_key: "de-DE"
			keys: [
				name: "de-DE"
				tag: "DE"
				enabled: true
			,
				name: "en-US"
				tag: "EN"
			,
				name: "fr-FR"
				tag: "FR"
			]


		data =
			input: ""
			textarea: ""
			password: ""
			table: []


		fields.push @getOptions(
			form:
				label: "Options[Radio]"
			radio: true
		)

		fields.push @getOptions(
			form:
				label: "Options[Checkbox]"
			radio: false
		)

		fields.push @getOptions(
			form:
				label: "Options[Horizontal]"
			radio: true
			horizontal: true
		)


		fields.push new Input
			form:
				label: "Input"
			name: "input"
			placeholder: "CUI.Input"

		fields.push new Input
			form:
				label: "Input[Textarea]"
			name: "textarea"
			textarea: true
			placeholder: "CUI.Input[Textarea]"

		fields.push new Output
			form:
				label: "Output"
			text: "Simple Output"

		fields.push new Password
			form:
				label: "Input[Password]"
			name: "password"

		fields.push new MultiInput
			form:
				label: "MultiInput"
			spellcheck: true
			control: multi_input_control

		fields.push new MultiInput
			form:
				label: "MultiInput[Textarea]"
			spellcheck: true
			textarea: true
			control: multi_input_control

		fields.push new DateTime
			form:
				label: "DateTime"

		select_opts = []
		for i in [0...100]
			select_opts.push
				text: "Opt "+(i+1)
				value: ""+i

		fields.push new Select
			form:
				label: "Select"
			options: select_opts

		fields.push new DataTable
			name: "table"
			form:
				label: "DataTable"
			fields: [
				form:
					label: "Column A"
				type: Input
			,
				form:
					label: "Column B"
				type: Checkbox
				text: "Checkbox"
			]

		form = [
			new Form(data: data, maximize: false, fields: fields).start()
		]

	getControlsTab: ->

		controls = [
			new Block
				text: "Buttons"
				content: [
					new Buttonbar(buttons: @getButtons())
				,
					new Buttonbar(buttons: @getButtons(group: "A"))
				,
					new Buttonbar(buttons: @getButtons(appearance: "flat"))
				,
					new Buttonbar(buttons: @getButtons(icon: "refresh"))
				,
					new Buttonbar(buttons: @getButtons(icon: "play", appearance: "flat"))
				]
		,
			new Block
				text: "Labels"
				content: [
					@getLabel(text: "Simple")
				,
					@getLabel(markdown: true, text: "Simple **Markdown**")
				,
					new EmptyLabel(text: "Empty Label")
				,
					@getMultiLabel()
				]
		,
			new Panel
				text: "Panel Test"
				content: @getMultiLabel()
		]

	display: ->

		tabs = new Tabs
			maximize: true
			tabs: [
				text: "Controls"
				content: @getControlsTab()
			,
				text: "Form"
				content: @getFormTab()
			,
				text: "Layer"
				content: @getLayerTab()
			,
				text: "Layout"
				content: @getLayoutTab()
			]


		md = new MenuDemo()
		md.listenOnNode(tabs)
		tabs




Demo.register(new Playground())