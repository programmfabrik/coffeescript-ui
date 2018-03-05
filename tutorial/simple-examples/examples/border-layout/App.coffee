class App
	constructor: ->

		body = new CUI.BorderLayout
			west:
				content: new CUI.Label
					centered: true
					text: "West"
			east:
				content: new CUI.Label
					centered: true
					text: "East"
			center:
				content: new CUI.Label
					centered: true
					size: "big"
					text: "Hello world!"
					icon: "fa-building"
			north:
				content: new CUI.Label
					centered: true
					text: "North"
			south:
				content: new CUI.Label
					centered: true
					text: "South"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()