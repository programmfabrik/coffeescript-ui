class App

		bodyHorizontalList = new CUI.HorizontalList
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

		bodyVerticalList = new CUI.VerticalList
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

		CUI.dom.append(document.body, bodyHorizontalList)
		CUI.dom.append(document.body, bodyVerticalList)

CUI.ready ->
	new App()