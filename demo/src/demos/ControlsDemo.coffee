###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.ControlsDemo extends Demo
	getGroup: ->
		"Test"

	addControlExample: (text,control) ->
		CUI.dom.addClass(control.DOM, "cui-control")

		container_div = 
		CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div('cui-controls-demo-control-container'),
		CUI.dom.div('cui-controls-demo-text-baseline-debug')), CUI.dom.div('cui-controls-demo-text-bottomline-debug')), control.DOM), CUI.dom.div('cui-controls-demo-text-bottomline-debug'))

		@demo_table.addExample(text,container_div)

	showAlignmentTest: ->
		CUI.dom.addClass(@demo_table.table, "cui-controls-demo-show-debug-helpers")

	hideAlignmentTest: ->
		CUI.dom.removeClass(@demo_table.table, "cui-controls-demo-show-debug-helpers")

	controlFormHasChanged: ->
		#TODO get the previous option to avoid removing all classes
		for option in @__width_test_options
			CUI.dom.removeClass(@demo_table.table, option.value)
		CUI.dom.addClass(@demo_table.table, @__control_form_data.width_type)

		for option in @__size_test_options
			CUI.dom.removeClass(@demo_table.table, option.value)
		CUI.dom.addClass(@demo_table.table, @__control_form_data.size)

		if @__control_form_data.alignment_test
			@showAlignmentTest()
		else
			@hideAlignmentTest()

	display: ->

		@demo_table = new Demo.DemoTable("cui-controls-demo-table")

		@__width_test_options = [
			text: "no width"
			value: "cui-controls-demo-force-width-auto"
		,
			text: "100%"
			value: "cui-controls-demo-force-width-hundred-percent"
		,
			text: "flex grow: 1"
			value: "cui-controls-demo-force-flex-grow"
		,
			text: "flex column align stretch"
			value: "cui-controls-demo-force-column-align-stretch"
		,
			text: "flex column align flex-start"
			value: "cui-controls-demo-force-column-align-flex-start"
		,
			text: "flex column align flex-end"
			value: "cui-controls-demo-force-column-align-flex-end"
		,
			text: "fixed size big"
			value: "cui-controls-demo-force-width-constant"
		,
			text: "fixed size small"
			value: "cui-controls-demo-force-width-constant-small"
		]

		@__size_test_options = [
			text: "mini"
			value: "cui-controls-demo-force-size-mini"
		,
			text: "normal"
			value: "cui-controls-demo-force-size-normal"
		,
			text: "big"
			value: "cui-controls-demo-force-size-big"
		,
			text: "bigger"
			value: "cui-controls-demo-force-size-bigger"
		]

		@__control_form_data =
			width_type: @__width_test_options[0].value
			size: @__size_test_options[1].value
			alignment_test: false

		control_form = new CUI.Form
			horizontal: true
			data: @__control_form_data
			onDataChanged: =>
				@controlFormHasChanged()

			fields: [
				type: CUI.Select
				name: "width_type"
				form:
					label: "Layout"
				options: @__width_test_options
			,
				type: CUI.Select
				name: "size"
				form:
					label: "Size"
				options: @__size_test_options
			,
				type: CUI.Checkbox
				text: "Show Alignment Test."
				name: "alignment_test"
			]
		.start()

		#TODO not working, so we set default to false
		#@showAlignmentTest()

		tool_bar = new CUI.PaneToolbar
			center:
				content: control_form

		@__verticalLayout = new CUI.VerticalLayout
			top:
				content: tool_bar
			center:
				content: @demo_table.table


		@addControlExample(
			"label"
		,
			new CUI.Label
				text: "Label text"

		)


		button_bar = new CUI.Buttonbar(
			tooltip:
				text: "mixed buttons and labels"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Label(text: "Label")
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)
		@addControlExample('buttonbar',button_bar)

		button_flat = new CUI.Button
			appearance: "flat"
			text: "Button Flat"

		@addControlExample('button flat',button_flat )

		button = new CUI.Button
			text: "Button"

		@addControlExample('button',button)


		checkBox = new CUI.Checkbox
			name: "anyName"
			text: "Check this"
		.start()

		@addControlExample("checkbox",checkBox)

		#add datafields

		for field in @getFields()
			field.data = @__form_data
			data_field = CUI.DataField.new(field)
			data_field.start()
			@addControlExample( field.name, data_field )

		@__verticalLayout

	undisplay: ->
		@

	getFields: ->
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

		data_fields = []

		@__form_data =
			Output: "Output"
			Input: "Input"
			Textarea: "Textarea"
			Select: 4
			Checkbox: true
			Options: [2,3]
			OptionsRadio: 3
			DataTable: [
				yes_no: true
				number: 11
				input: "Horst"
			,
				yes_no: false
				number: 12
				input: "Henk"
			,
				yes_no: true
				number: 14
				input: "Torsten"
			]

		sel_opts = []
		for i in [0...10]
			sel_opts.push
				text: "Select: "+(i+1)
				value: i

		radio_opts = []
		for i in [0...1]
			radio_opts.push
				text: "Radio: "+(i+1)
				value: i

		options_opts = []
		for i in [0...1]
			options_opts.push
				text: "Option: "+(i+1)
				value: i


		fields = [
			type: CUI.Output
			name: "Output"
			form:
				right: new CUI.Label(text: "Hint 1")
		,
			type: CUI.Output
			placeholder: "OutputPlaceholder"
		,
			type: CUI.Input
			name: "Input"
		,
			type: CUI.FormButton
			text: "FormButton"
		,
			type: CUI.DateTime
			name: "DateTime"
		,
			type: CUI.Select
			options: sel_opts
			name: "Select FAILS 1px in firefox"
		,
			type: CUI.Checkbox
			text: "Check me!"
			name: "Checkbox"
			form:
				right: new CUI.Label(text: "Hint 2")
		,
			type: CUI.Options
			options: options_opts
			name: "Options"
		,
			type: CUI.Options
			radio: true
			options: radio_opts
			name: "OptionsRadio"
		,
			type: CUI.Input
			textarea: true
			name: "Textarea"
		,
			type: CUI.Output
			name: "Output"
		,
			type: CUI.MultiInput
			name: "MultiInputTextarea"
			textarea: true
			control: multi_input_control
			placeholder:
				"de-DE": "TEXTAREA de"
				"en-US": "TEXTAREA en"
				"fr-FR": "TEXTAREA fr"

		,
			type: CUI.MultiInput
			name: "MultiInput"
			control: multi_input_control
			placeholder:
				"de-DE": "INPUT de"
				"en-US": "INPUT en"
				"fr-FR": "INPUT fr"

		,
			form:
				label: "DataTable"
			type: CUI.DataTable
			rowMove: true
			name: "DataTable"
			fields: [
				form:
					label: "Eingabe"
				type: CUI.Input
				name: "input"
			,
				form:
					label: "Schräg?"
					rotate_90: true
				type: CUI.Checkbox
				name: "yes_no"
			,
				form:
					label: "Nummer"
					rotate_90: true
				type: CUI.NumberInput
				name: "number"
			]
		]

		for f in fields
			if not f.form
				f.form = {}
			if not f.form.label
				f.form.label = f.name

		fields



Demo.register(new Demo.ControlsDemo())