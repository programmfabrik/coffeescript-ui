class App
	constructor: ->
		body = new CUI.VerticalLayout
			top:
				content: new CUI.Label
					centered: true
					text: "I'm a header"
			center:
				content: new CUI.Label
					centered: true
					size: "big"
					text: "Hello world!"
					icon: "fa-building"
			bottom:
				content: new CUI.Label
					centered: true
					text: "This is the bottom"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()