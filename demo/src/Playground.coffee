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
		,
			primary: true
			text: "Primary"
		])

	getOptions: (opts = {}) ->
		@getElements(CUI.Options, opts, [
			min_checked: 0
			options: [
				text: "One"
			,
				disabled: true
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
			text: Playground.longText
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
		dt.addExample("Buttons",
			new Buttonbar(buttons: @getButtons())
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
				text: "Popover (Blur)"
				onClick: (ev, btn) =>
					pop = new Popover
						element: btn
						placement: "n"
						placements: ["n"] # force north, so we see the blur effect
						cancel: true
						backdrop:
							policy: "click-thru"
							blur: true
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
						# element: btn
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
			,
				text: "Tooltip (Short)"
				switch: true
				activate_initial: false
				onActivate: (btn) =>
					btn.___tt = new Tooltip
						element: btn
						text: "Tooltip with short Text"
						on_click: false
						on_hover: false
					.show()
				onDeactivate: (btn) =>
					btn.___tt.destroy()
					delete(btn.___tt)
			,
				text: "Tooltip (Long)"
				switch: true
				activate_initial: false
				onActivate: (btn) =>
					btn.___tt = new Tooltip
						element: btn
						text: Playground.longText
						on_click: false
						on_hover: false
					.show()
				onDeactivate: (btn) =>
					btn.___tt.destroy()
					delete(btn.___tt)
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
				text: "CUI.toaster"
				onClick: =>
					ms = 3000
					steps = 100
					toaster = CUI.toaster
						show_ms: ms
						text: "Toaster 100!"
					c = 0
					counter = =>
						c = c + 1
						CUI.setTimeout
							ms: ms / steps
							call: =>
								toaster.setText("Toaster! "+(steps-c))
								if c < steps
									counter()
					counter()
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

	getFormsTab: ->
		form = new Form
			fields: [
				form:
					label: "Output"
				type: Output
				text: "Output"
			,
				form:
					label: "Input"
				type: Input
				placeholder: "Placeholder"
			,
				form:
					label: "Textarea (Wide)"
					use_field_as_label: true
				type: Input
				textarea: true
				placeholder: "Long Output"
			,
				form:
					label: "Options (Horizontal)"
				type: CUI.Options
				horizontal: true
				options: @getNumberOptions((v) -> text: ""+v, value: v)
			,
				form:
					label: "Options (Horizontal 4)"
				type: CUI.Options
				horizontal: 4
				options: @getNumberOptions((v) -> text: ""+v, value: v)
			,
				form:
					label: "Form (Horizontal)"
				type: Form
				horizontal: true
				fields: =>
					fields = []
					for i in [0..10]
						fields.push
							type: Checkbox
							text: "H "+i
					fields
			,
				form:
					label: "Form (Horizontal 4)"
				type: Form
				horizontal: 4
				fields: =>
					fields = []
					for i in [0..10]
						fields.push
							type: Checkbox
							text: "H4 - "+i
					fields
			,
				form:
					label: "Inline Form"
				type: Form

				fields: =>
					fields = []
					for i in [0..10]
						if i % 4 == 0
							fields.push
								type: Form
								fields:
									({
										type: Input
										form:
											label: "Inner Input "+i
									} for i in [0..5])
						else if i % 7 == 0
							fields.push
								type: Form
								fields:
									({
										type: Input
									} for i in [0..5])
						else
							fields.push
								type: Input
								form:
									label: "Input "+i
					fields
			]

		form.start()

	getNumberOptions: (func) ->
		opts = []
		for i in [100..120]
			opts.push(func(i))
		opts


	getInputsTab: ->
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
			options_sorted: [2,4]
			table: []
			select: 21
			select_mini: 5
			data_table: [
				a: "Henk"
				b: true
			,
				a: "Henk 1"
				b: true
			,
				a: "Henk 2"
				b: false
			]
			data_table_sortable: [
				a: "Thomas"
				b: true
			,
				a: "Henk"
				b: false
			,
				a: "Torsten"
				b: true
			]


		fields.push @getOptions(
			form:
				label: "Options [Radio]"
			radio: true
		)

		fields.push @getOptions(
			form:
				label: "Options [Checkbox]"
			radio: false
		)

		fields.push @getOptions(
			form:
				label: "Options [Sortable]"
			radio: false
			options: [
				text: "One"
				value: 1
			,
				text: "Two"
				value: 2
			,
				text: "Three"
				value: 3
			,
				text: "Four"
				value: 4
			,
				text: "Five"
				value: 5
			,
				text: "Six"
				value: 6
			]

			name: "options_sorted"
			sortable: true
			sortable_hint: "Sort checked options, unchecked are sorted alphabetically"
		)


		fields.push @getOptions(
			form:
				label: "Options [Horizontal]"
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
				label: "Input [Content-Size]"
			name: "input"
			content_size: true

		fields.push new Input
			form:
				label: "Input [Textarea]"
			name: "textarea"
			textarea: true
			placeholder: "CUI.Input [Textarea]"

		fields.push new Input
			form:
				label: "Input [Textarea | Content-Size]"
			name: "textarea"
			textarea: true
			content_size: true
			placeholder: "CUI.Input [Textarea | Content-Size]"


		fields.push new Output
			form:
				label: "Output"
			text: "Simple Output"

		fields.push new Password
			form:
				label: "Input [Password]"
			name: "password"

		fields.push new MultiInput
			form:
				label: "MultiInput"
			spellcheck: true
			control: multi_input_control

		fields.push new MultiInput
			form:
				label: "MultiInput [Textarea]"
			spellcheck: true
			textarea: true
			control: multi_input_control

		fields.push new DateTime
			form:
				label: "DateTime"

		select_opts = []
		icons = ["", "play", "audio", "left", "right"]

		for i in [0...100]
			if i % 20 == 0
				select_opts.push
					divider: true

			else if i % 10 == 0
				select_opts.push
					label:
						text: "Label "+i

			else
				select_opts.push
					text: "Opt "+(i+1)
					value: i
					icon: icons[Math.floor(Math.random()*4)]

		fields.push new Select
			form:
				label: "Select"
			name: "select"
			options: select_opts

		select_mini_opts = []
		for i in [0...10]
			select_mini_opts.push
				text: "Mini "+(i+1)
				value: i

		fields.push new Select
			form:
				label: "Select"
			name: "select_mini"
			options: select_mini_opts


		fields.push new DataTable
			name: "table"
			form:
				label: "DataTable"
			name: "data_table"
			fields: [
				form:
					label: "Column A"
				type: Input
				name: "a"
			,
				form:
					label: "Column B"
				type: Checkbox
				text: "Checkbox"
				name: "b"
			]

		fields.push new DataTable
			name: "table"
			rowMove: true
			name: "data_table_sortable"
			form:
				label: "DataTable [sortable]"
			fields: [
				form:
					label: "Column A"
				type: Input
				name: "a"
			,
				form:
					rotate_90: true
					label: "Column B"
				type: Checkbox
				text: "Checkbox"
				name: "b"
			]


		form = [
			new Form(data: data, maximize: false, fields: fields).start()
		]

	getTableTab: ->
		table = new CUI.Table
			columns: [
				name: "a"
				text: "a"
				class: "a-class"
			,
				name: "b"
				text: "b"
				class: "b-class"
			]
			rows: [
				a: "a0"
				b: "b0"
			,
				a: "a1"
				b: "b1"
			]

		for i in [2..5]
			table.addRow
				a: "a"+i
				b: "b"+i

		table

	getControlsTab: ->
		fu = new FileUpload
			url: "FileUpload.php"

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
				,
					new Buttonbar(buttons: [
						new FileUploadButton
							icon: "upload"
							fileUpload: fu
							text: "File Upload"
					,
						new ButtonHref
							icon: "share"
							href: "https://www.programmfabrik.de"
							target: "_blank"
							text: "www.programmfabrik.de"
					])
				,
					new Buttonbar(buttons: [
						new FileUploadButton
							appearance: "flat"
							fileUpload: fu
							text: "File Upload"
					,
						new ButtonHref
							appearance: "flat"
							href: "https://www.programmfabrik.de"
							target: "_blank"
							text: "www.programmfabrik.de"
					])

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
				text: "Inputs"
				content: @getInputsTab()
			,
				text: "Forms"
				content: @getFormsTab()
			,
				text: "Layer"
				content: @getLayerTab()
			,
				text: "Layout"
				content: @getLayoutTab()
			,
				text: "Table"
				content: @getTableTab()
			]


		md = new MenuDemo()
		md.listenOnNode(tabs)
		tabs

	@longText: """Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
					Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.

					Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim."""



Demo.register(new Playground())