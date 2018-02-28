###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.PanelDemo extends Demo
	display: ->
		p1 = new CUI.Panel
			text: "Panel title"
			content: @getBlindText(3)

		p2 = new CUI.Panel
			text: "Schröders Katze"
			closed: true
			content: @getBlindText(5)

		[ p1.DOM, p2.DOM ]

	undisplay: ->


Demo.register(new Demo.PanelDemo())
