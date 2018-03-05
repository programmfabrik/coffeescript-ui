class App
	constructor: ->

		modal = new CUI.Modal
			cancel: true
			fill_screen_button: true
			cancel_action: "hide"
			onToggleFillScreen: =>
				CUI.alert(text: "Fillscreen!")
			onCancel: =>
				CUI.alert(text: "Cancel!")
			pane:
				padded: true
				header_left: new CUI.Label
					text: "I'm the header"
				content: new CUI.Label
					icon: "fa-building"
					text: "Modal Content!"
				footer_right: [
					text: "Destroy!"
					onClick: =>
						modal.destroy()
				]

		openModal = new CUI.Button
			text: "Open modal!"
			onClick: =>
				modal.show()

		body = new CUI.HorizontalLayout
			left:
				content: new CUI.Label
					centered: true
					text: "Left"
			center:
				content: openModal
			right:
				content: new CUI.Label
					centered: true
					text: "Right"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()