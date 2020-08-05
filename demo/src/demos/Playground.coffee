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
								primary: true
								onClick: =>
									mod.destroy()
					mod.show()
			])
		)

		dt.addExample("Tooltip",
			new CUI.Buttonbar(buttons: [
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
			,
				text: "Placement West"
				switch: true
				activate_initial: false
				onActivate: (btn) =>
					btn.___tt = new CUI.Tooltip
						element: btn
						text: "Tooltip with short Text"
						on_click: false
						on_hover: false
						placement: "w"
					.show()
				onDeactivate: (btn) =>
					btn.___tt.destroy()
					delete(btn.___tt)
			,
				text: "Placement East"
				switch: true
				activate_initial: false
				onActivate: (btn) =>
					btn.___tt = new CUI.Tooltip
						element: btn
						text: "Tooltip with short Text"
						on_click: false
						on_hover: false
						placement: "e"
					.show()
				onDeactivate: (btn) =>
					btn.___tt.destroy()
					delete(btn.___tt)
			,
				text: "Placement SW"
				switch: true
				activate_initial: false
				onActivate: (btn) =>
					btn.___tt = new CUI.Tooltip
						element: btn
						text: "Tooltip with short Text Tooltip with short Text"
						on_click: false
						on_hover: false
						placement: "sw"
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
				tooltip: text: "de-DE"
			,
				name: "en-US"
				tag: "EN"
				tooltip: text: "en-US"
			,
				name: "fr-FR"
				tag: "FR"
				tooltip: text: "fr-FR"
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
			name: "MultiInput"
			form:
				label: "MultiInput"
			spellcheck: true
			control: multi_input_control

		fields.push new CUI.MultiInput
			name: "MultiInputTextarea"
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
		ttab = new Demo.DemoTable()

		table = @getTableDefault()
		ttab.addExample("Default Table with Border", table)

		table = @getTableZebra()
		ttab.addExample("Zebra Table maximized", table)

		table = @getTableKeyvalue()
		ttab.addExample("Flex Table with Border and key/value", table)

	getTableZebra: ->
		table = new CUI.Table
			class: 'cui-maximize-horizontal cui-demo-table-zebra'
			columns: [
				name: "a"
				text: "alpha"
				class: "a-class"
			,
				name: "b"
				text: "beta"
				class: "b-class"
			,
				name: "c"
				text: "gamma"
				class: "c-class"
			,
				name: "d"
				text: "delta"
				class: "d-class"
			]
			rows: [
				a: "a0"
				b: "b0"
				c: "Hello"
				d: "world"
			,
				a: "a1"
				b: "b1"
				c: "how"
				d: "are you"
			]

		for i in [2..5]
			table.addRow
				a: "a"+i
				b: "b"+i

		table

	getTableDefault: ->
		table = new CUI.Table
			columns: [
				name: "a"
				text: "alpha"
				class: "a-class"
			,
				name: "b"
				text: "beta"
				class: "b-class"
			,
				name: "c"
				text: "gamma"
				class: "c-class"
			,
				name: "d"
				text: "delta"
				class: "d-class"
			]
			rows: [
				a: "a0"
				b: "b0"
				c: "Hello"
				d: "world"
			,
				a: "a1"
				b: "b1"
				c: "how"
				d: "are you"
			]

		for i in [2..5]
			table.addRow
				a: "a"+i
				b: "b"+i

		table

	getTableKeyvalue: ->
		table = new CUI.Table
			flex: true
			key_value: true

		someInfoData = [
			key: "compiled"
			value: "pdf document, 3 pages, 727.5 kB"
		,
			key: "compiled_create_date"
			value: "1489755602.23"
		,
			key: "compiled_create_date_iso8601"
			value: "2017-03-17 T13:00:02+00:00"
		,
			key: "compiled_create_date_source"
			value: "m"
		,
			key: "extension"
			value: "pdf"
		,
			key: "fileclass"
			value: "office"
		]

		for info in someInfoData
			table.addRow
				key: info.key
				value: info.value

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

	getIconsTab: ->
		dt = new Demo.DemoTable()

		# Font Awesome Icons
		icons = ["play", "fa-angle-left", "fa-angle-right", "fa-angle-up", "fa-angle-down", "fa-angle-double-up", "fa-angle-double-down"]
		dt.addExample("Single Icon",
			new CUI.Block
				class: "cui-demo-icons"
				text: "Font Awesome icons that are customized"
				content: @getIconCollection(icons)
		)

		# All Font Awesome Icons
		icons = [
			"fa-crop",
			"fa-arrows-alt",
			"fa-warning",
			"fa-slack",
			"fa-file",
			"fa-filter",
			"fa-sliders",
			"fa-refresh",
			"fa fa-file-archive-o",
			"fa-rotate-right",
			"fa-rotate-left",
			"fa-arrows-v",
			"fa-arrows-h",
			"fa-calendar-plus-o",
			"fa-question",
			"fa-question",
			"fa-question",
			"fa-cog",
			"fa-download",
			"fa-download",
			"fa-question",
			"fa-upload",
			"fa-envelope-o",
			"fa-envelope",
			"fa-floppy-o",
			"fa-heart",
			"fa-user",
			"fa-clock-o",
			"fa-plus",
			"fa-pencil",
			"fa-files-o",
			"fa-search",
			"fa-share",
			"fa-play",
			"fa-music",
			"fa-play",
			"fa-stop",
			"fa-print",
			"fa-minus",
			"fa-caret-right",
			"fa-caret-down",
			"fa-ellipsis-h",
			"fa-ellipsis-v",
			"fa-bars",
			"fa-info-circle",
			"fa-bolt",
			"fa-check",
			"fa-warning",
			"fa-legal",
			"fa-cloud",
			"fa-angle-left",
			"fa-angle-right",
			"fa-angle-right",
			"fa-search-plus",
			"fa-search-minus",
			"fa-compress",
			"fa-expand",
			"fa-envelope-o",
			"fa-file-text",
			"fa-file-text-o",
			"fa-bullhorn",
			"fa-angle-left",
			"fa-angle-right",
			"fa-angle-down",
			"fa-angle-up",
			"fa-caret-up",
			"fa-caret-down",
			"fa-camera",
			"fa-list-ul",
			"fa-picture-o",
		]
		dt.addExample("Single Icon",
			new CUI.Block
				class: "cui-demo-icons"
				text: "All Font Awesome icons"
				content: @getIconCollection(icons)
		)

		# SVG Icons
		icons = [
			"svg-arrow-right",
			"svg-close",
			"svg-drupal",
			"svg-easydb",
			"svg-external-link",
			"svg-falcon-io",
			"svg-folder-shared-upload",
			"svg-folder-shared",
			"svg-folder-upload",
			"svg-folder",
			"svg-grid",
			"svg-hierarchy",
			"svg-info-circle",
			"svg-multiple",
			"svg-popup",
			"svg-reset",
			"svg-rows",
			"svg-select-all",
			"svg-select-pages",
			"svg-spinner",
			"svg-table",
			"svg-tag-o",
			"svg-trash",
			"svg-typo3",
			"svg-easydb",
			"svg-fylr-logo",
		]
		dt.addExample("Single Icon",
			new CUI.Block
				class: "cui-demo-icons"
				text: "SVG icons"
				content: @getIconCollection(icons)
		)

		asset_icons = [
			"svg-asset-missing",
			"svg-asset-failed",
		]
		
		dt.addExample("Asset Icons",
			new CUI.Block
				class: "cui-demo-icons cui-demo-asset-icons"
				text: "Asset icons"
				content: @getIconCollection(asset_icons)
		)

		dt.addExample("Icon in Buttons",
			new CUI.Buttonbar(buttons: @getButtons(icon: "download"))
		)

		dt.addExample("SVG Spinner",
			new CUI.Label
				text: "Label"
				icon: "spinner"
		)

		dt.addExample("FA Spinner",
			new CUI.Label
				text: "Label"
				icon: "fa-spinner"
		)

		dt.addExample("Times Thin, regular font icon (not FA)",
			new CUI.Label
				text: "Close"
				icon: "fa-times-thin"
		)

	getIconCollection: (icons = []) ->
		icon_container = CUI.dom.div("cui-demo-icon-container")

		for i in icons
			icon_wrap = CUI.dom.div("cui-demo-icon")
			icon = new CUI.Icon
				icon: i

			new CUI.Tooltip
				element: icon_wrap
				show_ms: 1000
				hide_ms: 200
				text: i

			CUI.dom.append(icon_wrap, icon.DOM)
			CUI.dom.append(icon_container, icon_wrap)

		icon_container


	display: ->

		tabs = new CUI.Tabs
			maximize: true
			tabs: [
				text: "Controls"
				content: @getControlsTab()
				class: "cui-demo-playground-tab-control"
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
			,
				text: "Icons"
				content: @getIconsTab()
			]


		md = new Demo.MenuDemo()
		md.listenOnNode(tabs)
		tabs

	@longText: """Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
					Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.

					Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim."""



Demo.register(new Demo.Playground())
