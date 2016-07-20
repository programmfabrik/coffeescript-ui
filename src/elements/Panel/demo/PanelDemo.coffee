class PanelDemo extends Demo
	display: ->
		p1 = new Panel
			text: "Panel title"
			content: @getBlindText(3)

		p2 = new Panel
			text: "Schröders Katze"
			closed: true
			content: @getBlindText(5)

		[ p1.DOM, p2.DOM ]

	undisplay: ->


Demo.register(new PanelDemo())
