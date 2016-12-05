###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ControlsDemo extends Demo
	getGroup: ->
		"Test"

	addControlExample: (text,control) ->
		control.addClass("cui-control")

		container_div = $div('cui-controls-demo-control-container')
		.append($div('cui-controls-demo-text-baseline-debug'))
		.append($div('cui-controls-demo-text-bottomline-debug'))
		.append(control.DOM)
		.append($div('cui-controls-demo-text-bottomline-debug'))

		@demo_table.addExample(text,container_div)

	showAlignmentTest: ->
		@demo_table.table.addClass("cui-controls-demo-show-debug-helpers")

	hideAlignmentTest: ->
		@demo_table.table.removeClass("cui-controls-demo-show-debug-helpers")

	controlFormHasChanged: ->
		#TODO get the previous option to avoid removing all classes
		for option in @__width_test_options
			@demo_table.table.removeClass(option.value)
		@demo_table.table.addClass(@__control_form_data.width_type)

		for option in @__size_test_options
			@demo_table.table.removeClass(option.value)
		@demo_table.table.addClass(@__control_form_data.size)

		if @__control_form_data.alignment_test
			@showAlignmentTest()
		else
			@hideAlignmentTest()

	display: ->

		@demo_table = new DemoTable("cui-controls-demo-table")

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

		control_form = new Form
			horizontal: true
			data: @__control_form_data
			onDataChanged: =>
				@controlFormHasChanged()

			fields: [
				type: Select
				name: "width_type"
				form:
					label: "Layout"
				options: @__width_test_options
			,
				type: Select
				name: "size"
				form:
					label: "Size"
				options: @__size_test_options
			,
				type: Checkbox
				text: "Show Alignment Test."
				name: "alignment_test"
			]
		.start()

		#TODO not working, so we set default to false
		#@showAlignmentTest()

		tool_bar = new PaneToolbar
			center:
				content: control_form

		@__verticalLayout = new VerticalLayout
			top:
				content: tool_bar
			center:
				content: @demo_table.table


		@addControlExample(
			"label"
		,
			new Label
				text: "Label text"

		)


		button_bar = new Buttonbar(
			tooltip:
				text: "mixed buttons and labels"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Label(text: "Label")
				new Button(text: "groupB", group: "groupB")
			]
		)
		@addControlExample('buttonbar',button_bar)

		button_flat = new Button
			appearance: "flat"
			text: "Button Flat"

		@addControlExample('button flat',button_flat )

		button = new Button
			text: "Button"

		@addControlExample('button',button)


		checkBox = new Checkbox
			name: "anyName"
			text: "Check this"
		.start()

		@addControlExample("checkbox",checkBox)

		#add datafields

		for field in @getFields()
			field.data = @__form_data
			data_field = DataField.new(field)
			data_field.start()
			@addControlExample( field.name, data_field )

		@__verticalLayout

	undisplay: ->
		@

	getFields: ->
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
			type: Output
			name: "Output"
			form:
				right: new Label(text: "Hint 1")
		,
			type: Output
			placeholder: "OutputPlaceholder"
		,
			type: Input
			name: "Input"
		,
			type: FormButton
			text: "FormButton"
		,
			type: DateTime
			name: "DateTime"
		,
			type: Select
			options: sel_opts
			name: "Select FAILS 1px in firefox"
		,
			type: Checkbox
			text: "Check me!"
			name: "Checkbox"
			form:
				right: new Label(text: "Hint 2")
		,
			type: Options
			options: options_opts
			name: "Options"
		,
			type: Options
			radio: true
			options: radio_opts
			name: "OptionsRadio"
		,
			type: Input
			textarea: true
			name: "Textarea"
		,
			type: Output
			name: "Output"
		,
			type: MultiInput
			name: "MultiInputTextarea"
			textarea: true
			control: multi_input_control
			placeholder:
				"de-DE": "TEXTAREA de"
				"en-US": "TEXTAREA en"
				"fr-FR": "TEXTAREA fr"

		,
			type: MultiInput
			name: "MultiInput"
			control: multi_input_control
			placeholder:
				"de-DE": "INPUT de"
				"en-US": "INPUT en"
				"fr-FR": "INPUT fr"

		,
			form:
				label: "DataTable"
			type: DataTable
			rowMove: true
			name: "DataTable"
			fields: [
				form:
					label: "Eingabe"
				type: Input
				name: "input"
			,
				form:
					label: "Schräg?"
					rotate_90: true
				type: Checkbox
				name: "yes_no"
			,
				form:
					label: "Nummer"
					rotate_90: true
				type: NumberInput
				name: "number"
			]
		]

		for f in fields
			if not f.form
				f.form = {}
			if not f.form.label
				f.form.label = f.name

		fields



Demo.register(new ControlsDemo())