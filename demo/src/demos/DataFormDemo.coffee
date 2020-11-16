class Demo.DataFormDemo extends Demo
	display: ->
		data =
			rowsV: []

		fieldsV = [
			type: CUI.Input
			name: "input"
		,
			type: CUI.Checkbox
			name: "boolean"
		,
			type: CUI.DateTime
			name: "datetime"
		,
			type: CUI.DataForm
			name: "datatable"
			rowMove: true
			form:
				label: "inner data"
			fields: [
				type: CUI.Input
				name: "input"
			,
				type: CUI.Checkbox
				name: "boolean"
			,
				type: CUI.DateTime
				name: "datetime"
			,
				type: CUI.Form
				name: "inner_inner"
				render_as_block: true
				form: label: "Inner Form"
				fields: [
					type: CUI.Input
					name: "from"
					form: label: "From"
				,
					type: CUI.Input
					name: "to"
					form: label: "To"
				]
			]
		]


		form = new CUI.Form
			data: data
			fields: [
				type: CUI.Input
				form:
					label: "text1"
				name: "text1"
			,
				type: CUI.Input
				form:
					label: "text2"
				name: "text2"
			,
				type: CUI.DataForm
				form:
					label: "words (fixed)"
				name: "rowsS"
				fields: [
					type: CUI.Input
					name: "word"
				]
			,
				type: CUI.DataForm
				form:
					label: "words (movable)"
				name: "rowsS2"
				rowMove: true
				fields: [
					type: CUI.Input
					name: "word"
				]
			,
				type: CUI.DataForm
				form:
					label: "top data"
				name: "rowsV"
				rowMove: false
				onRowRemove: (data) =>
					console.debug "row was removed:", data
				fields: fieldsV
			]
			onDataChanged: (data) =>
				; # @logTxt(CUI.util.dump(data))

		[
			form.start()
		]


Demo.register(new Demo.DataFormDemo())