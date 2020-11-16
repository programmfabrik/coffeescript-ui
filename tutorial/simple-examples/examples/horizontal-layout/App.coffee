class App
	constructor: ->

		body = new CUI.HorizontalLayout
			left:
				content: new CUI.Label
					centered: true
					text: "Left !!"
			center:
				content: new CUI.Label
					centered: true
					size: "big"
					text: "Hello world!"
					icon: "fa-building"
			right:
				content: new CUI.Label
					centered: true
					text: "Right"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()