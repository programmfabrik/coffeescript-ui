###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
class Demo.CUIDemo extends Demo
	getName: ->
		"Form Elements"

	getGroup: ->
		"Test"

	display: ->

		# output a control bar
		#
		#
		@__control_data =
			container: "none"
			layout: "VerticalLayout_max_true"
			show_me: true
		#

		control_form = new CUI.Form
			horizontal: true
			data: @__control_data
			onDataChanged: =>
				@renderIt()

			fields: [
				type: CUI.Select
				name: "layout"
				form:
					label: "Layout"
				options: [
					text: "VerticalLayout Max: True"
					value: "VerticalLayout_max_true"
				,
					text: "VerticalLayout Max: False"
					value: "VerticalLayout_max_false"
				,
					text: "HorizontalLayout Max: True"
					value: "HorizontalLayout_max_true"
				,
					text: "HorizontalLayout Max: False"
					value: "HorizontalLayout_max_false"
				,
					text: "Kein Layout"
					value: "none"
				]
			,
				type: CUI.Select
				name: "container"
				form:
					label: "Container"
				options: [
					text: "Form Vertical Max: True"
					value: "form_vertical_max_true"
				,
					text: "Form Vertical Max: False"
					value: "form_vertical_max_false"
				,
					text: "Form Horizontal Max: True"
					value: "form_horizontal_max_true"
				,
					text: "Form Horizontal Max: False"
					value: "form_horizontal_max_false"
				,
					text: "Form Horizontal [3] Max: True"
					value: "form_horizontal_3_max_true"
				,
					text: "Form Horizontal [3] Max: False"
					value: "form_horizontal_3_max_false"
				,
					text: "Kein Container"
					value: "none"
				]
			,
				type: CUI.Checkbox
				text: "Show me the details."
				name: "show_me"
			]

		.start()

		control_bar = new CUI.PaneToolbar
			center:
				content: control_form

		@__verticalLayout = new CUI.VerticalLayout
			top:
				content: control_bar
			center:
				class: "cui-demo-layout"

		@renderIt()
		@__verticalLayout

	renderIt: ->

		fields = @getFields()

		cnt = @__control_data.container
		if cnt.startsWith("form_")
			if cnt.match("horizontal_3")
				horizontal = 3
			else if cnt.match("horizontal")
				horizontal = true
			else
				horizontal = undefined

			if cnt.match("max_false")
				maximize = false
			else if cnt.match("max_true")
				maximize = true

			content = [new CUI.Form
				horizontal: horizontal
				maximize: maximize
				data: @__form_data
				fields: fields
			.start()]
		else if cnt == "none"
			content = []
			for f in fields
				f.data = @__form_data
				df = CUI.DataField.new(f)
				df.start()
				content.push(df)

		lbl = new CUI.Label(text: "Layout: " + @__control_data.layout)
		lbl_bottom = new CUI.Label(text: "The other end.")
		lay = @__control_data.layout

		if lay.match("max_false")
			maximize = false
		else if cnt.match("max_true")
			maximize = true

		if lay.startsWith("VerticalLayout")
			layout = new CUI.VerticalLayout
				maximize: maximize
				top:
					content: lbl
				center:
					content: content
				bottom:
					content: lbl_bottom
		else if lay.startsWith("HorizontalLayout")
			layout = new CUI.HorizontalLayout
				maximize: maximize
				left:
					content: lbl
				center:
					content: content
				right:
					content: lbl_bottom
		else
			content.splice(0,0,lbl)
			layout = content

		if @__control_data.show_me
			CUI.dom.addClass(@__verticalLayout.center(), "cui-demo-show-me")
		else
			@__verticalLayout.center().removeClass("cui-demo-show-me")

		@__verticalLayout.replace(layout, "center")



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
		for i in [0...5]
			radio_opts.push
				text: "Radio: "+(i+1)
				value: i

		options_opts = []
		for i in [0...5]
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
			type: CUI.MultiInput
			name: "MultiInput"
			control: multi_input_control
			placeholder:
				"de-DE": "INPUT de"
				"en-US": "INPUT en"
				"fr-FR": "INPUT fr"
		,
			type: CUI.FormButton
			text: "FormButton"
		,
			type: CUI.DateTime
			name: "DateTime"
		,
			type: CUI.Input
			textarea: true
			name: "Textarea"
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
			type: CUI.Select
			options: sel_opts
			name: "Select"
		,
			type: CUI.Form
			horizontal: true
			fields: [
				type: CUI.Select
				options: sel_opts
				name: "Select Left"
			,
				type: CUI.Select
				options: sel_opts
				name: "Select Right"
			]
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
			form:
				label: "DataTable"
			type: CUI.DataTable
			rowMove: true
			name: "DataTable"
			fields: [
				form:
					label: "Eingabe"
				type:  CUI.Input
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

	undisplay: ->


Demo.register(new Demo.CUIDemo())