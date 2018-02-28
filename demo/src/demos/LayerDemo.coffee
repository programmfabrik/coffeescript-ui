###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.LayerDemo extends Demo
	display: ->
		placements = CUI.Layer::knownPlacements
		@__data = {}

		if window.localStorage.CUILayerDemo
			try
				@__data = JSON.parse(window.localStorage.CUILayerDemo)
			catch ex
				console.error "LayerDemo", ex

			if not CUI.isPlainObject(@__data)
				@__data = {}
				@saveData()

		if not @__data.placements?.length
			init_placements = true
			@__data.placements = []

		placements_opts = []
		placement_opts = []
		for pm in CUI.Layer::knownPlacements
			placement_opts.push
				text: pm
				value: pm

			placements_opts.push
				text: pm
				value: pm

			if init_placements
				@__data.placements.push(pm)

		dt = new Demo.DemoTable()

		dt.addDivider("layer config")

		form = new CUI.Form
			maximize: false
			data: @__data
			onDataChanged: (data, element, ev) =>
				@saveData(ev)
			fields: [
				form:
					label: "placement"
				type: CUI.Select
				name: "placement"
				options: placement_opts
			,
				form:
					label: "placements"
				type: CUI.Options
				horizontal: 4
				name: "placements"
				options: placements_opts
			,
				form:
					label: "fill_space"
				name: "fill_space"
				type: CUI.Select
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
				type: CUI.Select
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
				type: CUI.Select
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
				type: CUI.Checkbox
			]

		dt.addRow(form.start().DOM)

		dt.addDivider("demo config")

		form2 = new CUI.Form
			maximize: false
			data: @__data
			onDataChanged: (data, element, ev) =>
				@saveData(ev)
			fields: [
				form:
					label: "Auto Open & Close (500ms)"
				type: CUI.Checkbox
				name: "auto_open_close"
			,
				form:
					label: "Layer Width"
				type: CUI.Select
				name: "layer_width"
				options: (text: k, value: k for k in ["", "25%", "50%", "75%"])
			]

		dt.addRow(form2.start().DOM)

		@__buttons = []

		if @__data.hasOwnProperty("button_idx")
			button_idx = @__data.button_idx
		else
			button_idx = 0

		for btn, idx in [
			["nw", "North West"]
			["sw", "South West"]
			["ne", "North East"]
			["se", "South East"]
			["c", "Center"]
		]
			do (btn, idx) =>
				@__buttons.push new CUI.Button
					radio: "a"
					active: idx == button_idx
					onActivate: =>
						@__data.button_idx = idx
					onDeactivate: (btn) =>
						@__data.button_idx = idx
					class: "cui-layer-demo-start-button cui-layer-demo-start-button-"+btn[0]
					text: btn[1]
					onClick: (ev, btn) =>
						@openLayer(ev, btn)

		vl = new CUI.VerticalLayout
			maximize: true
			auto_buttonbar: false
			top:
				content: dt.table
			center:
				content: @__buttons
				class: "cui-layer-demo-center"
		vl

	saveData: (ev) ->
		window.localStorage.CUILayerDemo = JSON.stringify(@__data)
		if @__data.auto_open_close
			@openLayer(ev, @__buttons[@__data.button_idx])

	openLayer: (ev, element) ->

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

		layer = new CUI.Layer
			element: element
			placements: @__data.placements
			placement: @__data.placement
			fill_space: @__data.fill_space
			pointer: @__data.pointer
			backdrop: backdrop

		content = new CUI.Label
			multiline: true
			text: "A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines."

		sp = new CUI.SimplePane
			header_left: new CUI.Label(text: "Test-Layer")
			maximize: false
			content: content
			footer_right:
				text: "Done"
				onClick: =>
					layer.destroy()

		CUI.dom.setStyle(sp.DOM,
			width: @__data.layer_width
		)

		CUI.dom.append(layer.DOM, sp.DOM)

		layer.show(ev)

		if @__data.auto_open_close
			CUI.setTimeout
				ms: 500
				call: =>
					layer.destroy()
		@

Demo.register(new Demo.LayerDemo())
