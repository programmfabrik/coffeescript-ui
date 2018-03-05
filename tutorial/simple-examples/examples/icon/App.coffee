class App
	constructor: ->

		body = new CUI.HorizontalLayout
			left:
				content: new CUI.Label
					centered: true
					text: "Left !!"
			center:
				content: new CUI.VerticalList
					content: [
							new CUI.Icon
								icon: "fa-building"
								fixed_width: true
						,
							new CUI.Icon
								icon: CUI.Icon.icon_map.camera
						,
							new CUI.Icon
								icon: "fa-times"
								tooltip: text: "Hello, I'm a tooltip"
						]
			right:
				content: new CUI.Label
					centered: true
					text: "Right"

		CUI.dom.append(document.body, body)

CUI.ready ->
	new App()