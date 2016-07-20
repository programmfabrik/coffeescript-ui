class CUIDemo extends Demo
	display: ->

		# output a control bar
		#
		#
		@__control_data =
			container: "none"
			layout: "VerticalLayout_max_true"
			show_me: true
		#

		control_form = new Form
			horizontal: true
			data: @__control_data
			onDataChanged: =>
				@renderIt()

			fields: [
				type: Select
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
				type: Select
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
				type: Checkbox
				text: "Show me the details."
				name: "show_me"
			]

		.start()

		control_bar = new PaneToolbar
			center:
				content: control_form

		@__verticalLayout = new VerticalLayout
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

			content = [new Form
				horizontal: horizontal
				maximize: maximize
				data: @__form_data
				fields: fields
			.start()]
		else if cnt == "none"
			content = []
			for f in fields
				f.data = @__form_data
				df = DataField.new(f)
				df.start()
				content.push(df)

		lbl = new Label(text: "Layout: " + @__control_data.layout)
		lbl_bottom = new Label(text: "The other end.")
		lay = @__control_data.layout

		if lay.match("max_false")
			maximize = false
		else if cnt.match("max_true")
			maximize = true

		if lay.startsWith("VerticalLayout")
			layout = new VerticalLayout
				maximize: maximize
				top:
					content: lbl
				center:
					content: content
				bottom:
					content: lbl_bottom
		else if lay.startsWith("HorizontalLayout")
			layout = new HorizontalLayout
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
			@__verticalLayout.center().addClass("cui-demo-show-me")
		else
			@__verticalLayout.center().removeClass("cui-demo-show-me")

		@__verticalLayout.replace(layout, "center")



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
			type: MultiInput
			name: "MultiInput"
			control: multi_input_control
			placeholder:
				"de-DE": "INPUT de"
				"en-US": "INPUT en"
				"fr-FR": "INPUT fr"
		,
			type: FormButton
			text: "FormButton"
		,
			type: DateTime
			name: "DateTime"
		,
			type: Input
			textarea: true
			name: "Textarea"
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
			type: Select
			options: sel_opts
			name: "Select"
		,
			type: Form
			horizontal: true
			fields: [
				type: Select
				options: sel_opts
				name: "Select Left"
			,
				type: Select
				options: sel_opts
				name: "Select Right"
			]
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

	undisplay: ->


Demo.register(new CUIDemo())