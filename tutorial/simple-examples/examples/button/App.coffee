class App
	constructor: ->

		disableButton = new CUI.Button
			text: "Disable button"
			onClick: =>
				disableButton.disable()
				CUI.setTimeout(
					ms: 1000
					call: =>
						disableButton.enable()
				)

		spinnerButton = new CUI.Button
			text: "Spinner button"
			left: true
			onClick: =>
				spinnerButton.startSpinner()
				CUI.setTimeout(
					ms: 1000
					call: =>
						spinnerButton.stopSpinner()
				)

		menuButton = new CUI.Button
			text: "Menu button"
			icon: "fa-bars"
			menu:
				items: [
					text: "# 1"
				,
					new CUI.Button
						text: "# 2"
				,
					text: "Click me!"
					onClick: =>
						CUI.alert(text: "I'm a button!")
				,
					text: "Submenu"
					menu:
						items: [text: "#4"]
				]

		body = new CUI.HorizontalLayout
			auto_buttonbar: false
			left:
				content: new CUI.Label
					centered: true
					text: "Left !!"
			center:
				content: [
					disableButton
				,
					spinnerButton
				,
					menuButton
				,
					new CUI.Button
						text: "Group button #1"
						group: "some-group"
				,
					new CUI.Button
						text: "Group button #2"
						group: "some-group"
				,
					new CUI.Button
						text: "Group button #3"
						group: "some-group"
				]
			right:
				content: new CUI.Label
					centered: true
					text: "Right"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()