class App
	constructor: ->
		body = new CUI.VerticalLayout
			top:
				content: new CUI.Label
					centered: true
					text: "I'm a header"
			center:
				content: new CUI.HorizontalLayout
					left:
						content: new CUI.HorizontalList
							content: [
								new CUI.Label
									centered: true
									text: "Label #1"
							,
								new CUI.Label
									centered: true
									text: "Label #2"
							,
								new CUI.Label
									centered: true
									text: "Label #3"
							]
					center:
						content: new CUI.BorderLayout
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
					right:
						content: new CUI.VerticalList
							content: [
								new CUI.Label
									centered: true
									text: "Label #1"
							,
								new CUI.Label
									centered: true
									text: "Label #2"
							,
								new CUI.Label
									centered: true
									text: "Label #3"
							]
			bottom:
				content: new CUI.Label
					centered: true
					text: "This is the bottom"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()