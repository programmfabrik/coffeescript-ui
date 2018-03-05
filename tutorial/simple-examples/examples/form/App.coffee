class App
	constructor: ->

		resultLabel = new CUI.Label(multiline: true)

		data = {}
		form = new CUI.Form
			data: data
			fields: [
				type: CUI.Input
				name: "name"
				regexp: "^([^0-9]*)$"
				form:
					label: "Name"
			,
				type: CUI.NumberInput
				name: "age"
				form:
					label: "Age"
			,
				type: CUI.Select
				name: "country"
				options: [
					value: "Germany"
				,
					value: "Argentina"
				]
				form:
					label: "Country"
			]
			onDataChanged: (data, field, event) =>
				console.log("----------------------")
				console.log("Data:", data)
				console.log("Field:", field)
				console.log("Event:", event)

				fieldName = field.getName()
				resultLabel.setText("Data changed! Input: #{fieldName} -> #{data[fieldName]}")
		form.start()

		button = new CUI.Button
			text: "Show data!"
			onClick: =>
				CUI.alert(text: CUI.util.dump(data))

		body = new CUI.HorizontalLayout
			left:
				content: new CUI.Label
					centered: true
					text: "Left !!"
			center:
				content: new CUI.VerticalList
					content: [form, button, resultLabel]
			right:
				content: new CUI.Label
					centered: true
					text: "Right"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()