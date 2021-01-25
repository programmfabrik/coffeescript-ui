###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.Playground extends Demo
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
			copy_opts = CUI.util.copyObject(opts, true)
			for k, v of ele_opt
				if not copy_opts.hasOwnProperty(k)
					copy_opts[k] = v

			elements.push(new cls(copy_opts))
		elements

	getLayoutTab: ->

		hl = new CUI.HorizontalLayout
			left:
				flexHandle:
					hidden: false
				content: CUI.dom.text("Left Side")

			center: {}
			right:
				flexHandle:
					hidden: false
				content: new CUI.SimplePane
					header_center: new CUI.Label(text: "CUI.SimplePane")
					header_right:
						icon: "close"
					content: new CUI.Label(text: "Content")
					footer_right:
						text: "Ok"

		treeDemo = new Demo.ListViewTreeDemo()

		tree = new CUI.ListViewTree
			cols: ["auto", "maximize", "auto", "auto"]
			fixedRows: 1
			fixedCols: 1
			root: new Demo.ListViewTreeDemoNode(demo: treeDemo)
			selectable: true

		hl.replace(tree.render(), "left")
		tree.appendRow(new Demo.ListViewTreeDemoHeaderNode())
		tree.root.open()

		shc = new CUI.StickyHeaderControl(element: hl.center())

		sticky_flow = []

		for i in [0...10]
			sticky_flow.push(new CUI.StickyHeader(text: "Header "+i, level: 0, control: shc))
			for j in [0..Math.ceil(Math.random()*10)]
				sticky_flow.push(@getMultiLabel())
				if Math.random() > 0.7
					sticky_flow.push(new CUI.StickyHeader(level: 1, text: "Sub-Header", control: shc))

		hl.append(sticky_flow, "center")


		hl

	getLayerTab: ->
		dt = new Demo.DemoTable()
		dt.addExample("Buttons",
			new CUI.Buttonbar(buttons: @getButtons())
		)

		dt.addExample("Layer",
			new CUI.Buttonbar(buttons: [
				text: "Popover"
				onClick: (ev, btn) =>
					pop = new CUI.Popover
						element: btn
						cancel: true
						pane:
							header_left:
								new CUI.Label(text: "Popover")
							content: new CUI.MultilineLabel
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
					pop = new CUI.Popover
						element: btn
						placement: "n"
						placements: ["n"] # force north, so we see the blur effect
						cancel: true
						backdrop:
							policy: "click-thru"
							blur: true
						pane:
							header_left:
								new CUI.Label(text: "Popover")
							content: new CUI.MultilineLabel
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
					mod = new CUI.Modal
						# element: btn
						cancel: true
						pane:
							header_left:
								new CUI.Label(text: "Modal")
							content: new CUI.MultilineLabel
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
					btn.___tt = new CUI.Tooltip
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
					btn.___tt = new CUI.Tooltip
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
			new CUI.Buttonbar(buttons: [
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
		form = new CUI.Form
			fields: [
				form:
					label: "Output"
				type: CUI.Output
				text: "Output"
			,
				form:
					label: "Input"
				type: CUI.Input
				placeholder: "Placeholder"
			,
				form:
					label: "Textarea (Wide)"
					use_field_as_label: true
				type: CUI.Input
				textarea: true
				placeholder: "Long CUI.Output"
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
				type: CUI.Form
				horizontal: true
				fields: =>
					fields = []
					for i in [0..10]
						fields.push
							type: CUI.Checkbox
							text: "H "+i
					fields
			,
				form:
					label: "Form (Horizontal 4)"
				type: CUI.Form
				horizontal: 4
				fields: =>
					fields = []
					for i in [0..10]
						fields.push
							type: CUI.Checkbox
							text: "H4 - "+i
					fields
			,
				form:
					label: "Inline Form"
				type: CUI.Form

				fields: =>
					fields = []
					for i in [0..10]
						if i % 4 == 0
							fields.push
								type: CUI.Form
								fields:
									({
										type: CUI.Input
										form:
											label: "Inner Input "+i
									} for i in [0..5])
						else if i % 7 == 0
							fields.push
								type: CUI.Form
								fields:
									({
										type: CUI.Input
									} for i in [0..5])
						else
							fields.push
								type: CUI.Input
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

		multi_input_control = new CUI.MultiInputControl
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


		fields.push new CUI.Input
			form:
				label: "Input"
			name: "input"
			placeholder: "CUI.Input"

		fields.push new CUI.Input
			form:
				label: "Input [Content-Size]"
			name: "input"
			content_size: true

		fields.push new CUI.Input
			form:
				label: "Input [Textarea]"
			name: "textarea"
			textarea: true
			placeholder: "CUI.Input [Textarea]"

		fields.push new CUI.Input
			form:
				label: "Input [Textarea | Content-Size]"
			name: "textarea"
			textarea: true
			content_size: true
			placeholder: "CUI.Input [Textarea | Content-Size]"

		last_tooltip = null

		fields.push new CUI.Slider
			form:
				label: "Slider"
			name: "slider"
			min: 1
			max: 1000
			value: 300
			onDragging: (slider, value) =>
				last_tooltip = new CUI.Tooltip
					on_hover: false
					text: value+''
					element: slider.getHandle()
				.show()
			onDrop: =>
				last_tooltip?.hideTimeout()
			onUpdate: (slider, value) =>
				console.info("CUI.Slider: New value:", value)

		fields.push new CUI.Output
			form:
				label: "Output"
			text: "Simple CUI.Output"

		fields.push new CUI.Password
			form:
				label: "Input [Password]"
			name: "password"

		fields.push new CUI.MultiInput
			form:
				label: "MultiInput"
			spellcheck: true
			control: multi_input_control

		fields.push new CUI.MultiInput
			form:
				label: "MultiInput [Textarea]"
			spellcheck: true
			textarea: true
			control: multi_input_control

		fields.push new CUI.DateTime
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

		fields.push new CUI.Select
			form:
				label: "Select"
			name: "select"
			options: select_opts

		select_mini_opts = []
		for i in [0...10]
			select_mini_opts.push
				text: "Mini "+(i+1)
				value: i

		fields.push new CUI.Select
			form:
				label: "Select"
			name: "select_mini"
			options: select_mini_opts


		fields.push new CUI.DataTable
			name: "table"
			form:
				label: "DataTable"
			name: "data_table"
			fields: [
				form:
					label: "Column A"
				type: CUI.Input
				name: "a"
			,
				form:
					label: "Column B"
				type: CUI.Checkbox
				text: "Checkbox"
				name: "b"
			]

		fields.push new CUI.DataTable
			name: "table"
			rowMove: true
			name: "data_table_sortable"
			form:
				label: "DataTable [sortable]"
			fields: [
				form:
					label: "Column A"
				type: CUI.Input
				name: "a"
			,
				form:
					rotate_90: true
					label: "Column B"
				type: CUI.Checkbox
				text: "Checkbox"
				name: "b"
			]


		form = [
			new CUI.Form(data: data, maximize: false, fields: fields).start()
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
		fu = new CUI.FileUpload
			url: "FileUpload.php"

		controls = [
			new CUI.Block
				text: "Buttons"
				content: [
					new CUI.Buttonbar(buttons: @getButtons())
				,
					new CUI.Buttonbar(buttons: @getButtons(group: "A"))
				,
					new CUI.Buttonbar(buttons: @getButtons(appearance: "flat"))
				,
					new CUI.Buttonbar(buttons: @getButtons(icon: "refresh"))
				,
					new CUI.Buttonbar(buttons: @getButtons(icon: "play", appearance: "flat"))
				,
					new CUI.Buttonbar(buttons: [
						new CUI.FileUploadButton
							icon: "upload"
							fileUpload: fu
							text: "File Upload"
					,
						new CUI.ButtonHref
							icon: "share"
							href: "https://www.programmfabrik.de"
							target: "_blank"
							text: "www.programmfabrik.de"
					])
				,
					new CUI.Buttonbar(buttons: [
						new CUI.FileUploadButton
							appearance: "flat"
							fileUpload: fu
							text: "File Upload"
					,
						new CUI.ButtonHref
							appearance: "flat"
							href: "https://www.programmfabrik.de"
							target: "_blank"
							text: "www.programmfabrik.de"
					])

				]
		,
			new CUI.Block
				text: "Labels"
				content: [
					@getLabel(text: "Simple")
				,
					@getLabel(markdown: true, text: "Simple **Markdown**")
				,
					new CUI.EmptyLabel(text: "Empty Label")
				,
					@getMultiLabel()
				]
		,
			new CUI.Panel
				text: "Panel Test"
				content: @getMultiLabel()
		]

	display: ->

		tabs = new CUI.Tabs
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


		md = new Demo.MenuDemo()
		md.listenOnNode(tabs)
		tabs

	@longText: """Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
					Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.

					Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim."""



Demo.register(new Demo.Playground())