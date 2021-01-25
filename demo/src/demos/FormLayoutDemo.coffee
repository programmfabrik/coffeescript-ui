###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.FormLayoutDemo extends Demo

	getGroup: ->
		"Test"

	display: ->
		@demo_table = new Demo.DemoTable("cui-form-layout-demo")

		form_options =
			class: "cui-form-layout-demo-example-default"
		@demo_table.addExample("default", @createExampleForm(form_options))

		form_options =
			class: "cui-form-layout-demo-example-maximize-center"
		@demo_table.addExample("maximized center column with mixin", @createExampleForm(form_options))

		form_options =
			class: "cui-form-layout-demo-example-maximize-right"
		@demo_table.addExample("maximized right column with mixin", @createExampleForm(form_options))

		@demo_table.table


	createExampleForm: (form_options) ->
		select_options = [
			text: "data name 1"
			value: 1
		,
			text: "data name 2"
			value: 2
		]

		form_data =
			width_type: 1
			option: true

		default_form_options =
			type: CUI.Form
			horizontal: false
			data: form_data
			fields: [
				type: CUI.Select
				name: "width_type"
				form:
					label: "Layout"
				options: select_options
			,
				type: CUI.Checkbox
				text: "option"
				name: "option"
				form:
					label: "Simple Input"
			,
				placeholder: "INPUT"
				type: CUI.Input
				name: "simple_input"
				form:
					label: "text 1"
					right:
						label: "a simple text input"
			]

		# add form options to defaults
		for key,value of form_options
			default_form_options[key] = value

		form = CUI.DataField.new(default_form_options)
		form.start()
		form


Demo.register(new Demo.FormLayoutDemo())
