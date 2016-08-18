class LayerDemo extends Demo
	display: ->
		placements = Layer.kn
		@__data = {}

		if window.localStorage.CUILayerDemo
			try
				@__data = JSON.parse(window.localStorage.CUILayerDemo)
			catch ex
				console.error "LayerDemo", ex

			if not $.isPlainObject(@__data)
				@__data = {}
				@saveData()


		if not @__data.placements?.length
			init_placements = true
			@__data.placements = []

		placements_opts = []
		placement_opts = []
		for pm in CUI.Layer.knownPlacements
			placement_opts.push
				text: pm
				value: pm

			placements_opts.push
				text: pm
				value: pm

			if init_placements
				@__data.placements.push(pm)

		dt = new DemoTable()

		dt.addDivider("layer config")

		form = new Form
			maximize: false
			data: @__data
			onDataChanged: =>
				@saveData()

			fields: [
				form:
					label: "placement"
				type: Select
				name: "placement"
				options: placement_opts
			,
				form:
					label: "placements"
				type: Options
				horizontal: 4
				name: "placements"
				options: placements_opts
			,
				form:
					label: "fill_space"
				name: "fill_space"
				type: Select
				options: [
					value: null
					text: ""
				,
					value: "auto"
				,
					value: "both"
				,
					value: "horizontal"
				,
					value: "vertical"
				]
			,
				form:
					label: "pointer"
				name: "pointer"
				type: Select
				options: [
					value: null
					text: ""
				,
					value: "arrow"
				]
			,
				form:
					label: "backdrop"
				name: "backdrop_policy"
				type: Select
				options: [
					value: null
					text: ""
				,
					value: "click"
				,
					value: "click-thru"
				,
					value: "modal"
				,
					value: false
					text: "false"
				]
			,
				form:
					label: "backdrop blur"
				name: "backdrop_blur"
				type: Checkbox
			]

		dt.addRow(form.start().DOM)

		dt.addDivider("demo config")

		form2 = new Form
			maximize: false
			data: @__data
			onDataChanged: =>
				@saveData()
			fields: [
				form:
					label: "Auto Close (500ms)"
				type: Checkbox
				name: "auto_close"
			]

		dt.addRow(form2.start().DOM)


		buttons = []

		for btn in [
			["nw", "North West"]
			["sw", "South West"]
			["ne", "North East"]
			["se", "South East"]
			["c", "Center"]
		]
			buttons.push new Button
				class: "cui-layer-demo-start-button cui-layer-demo-start-button-"+btn[0]
				text: btn[1]
				onClick: (ev, btn) =>
					@openLayer(btn)

		vl = new VerticalLayout
			maximize: true
			auto_buttonbar: false
			top:
				content: dt.table
			center:
				content: buttons
				class: "cui-layer-demo-center"
		vl

	saveData: ->
		window.localStorage.CUILayerDemo = JSON.stringify(@__data)

	openLayer: (element) ->

		if @__data.backdrop_policy == false
			backdrop = false
		else
			if @__data.backdrop_policy
				backdrop =
					policy: @__data.backdrop_policy

			if @__data.backdrop_blur
				if not backdrop
					backdrop = {}
				backdrop.blur = true

		layer = new Layer
			element: element
			placements: @__data.placements
			placement: @__data.placement
			fill_space: @__data.fill_space
			pointer: @__data.pointer
			backdrop: backdrop

		content = new Label
			multiline: true
			text: "A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines."


		layer.append new SimplePane
			header_left: new Label(text: "Test-Layer")
			content: content
			footer_right:
				text: "Done"
				onClick: =>
					layer.destroy()

		layer.show()

		if @__data.auto_close
			CUI.setTimeout
				ms: 500
				call: =>
					layer.destroy()
		@

Demo.register(new LayerDemo())
