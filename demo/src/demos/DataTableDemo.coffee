class Demo.DataTableDemo extends Demo
	display: ->
		data =
			rowsH: [{}]

		fieldsH = [
			type: CUI.Input
			name: "input"
		,
			type: CUI.Checkbox
			name: "boolean"
		,
			type: CUI.DateTime
			name: "datetime"
		,
			type: CUI.DataTable
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
			]
		]

		dtH = new CUI.DataTable
			fields: fieldsH
			name: "rowsH"
			data: data
			new_rows: "append"
			onDataChanged: (data) =>
				; # @log(CUI.util.dump(data.rowsH))

		[
			dtH.start()
		]


Demo.register(new Demo.DataTableDemo())