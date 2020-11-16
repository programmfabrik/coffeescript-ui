###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

moment = require('moment')

class Demo.DigiDisplayDemo extends Demo
	getGroup: ->
		"Extra"

	display: ->
		dd = new CUI.DigiDisplay
			digits: [
				mask: "[0-9]"
			,
				mask: "[0-9]"
			,
				static: ":"
			,
				mask: "[0-9]"
			,
				mask: "[0-9]"
			,
				static: ":"
			,
				mask: "[0-9]"
			,
				mask: "[0-9]"
			]

		@__digiInterval = CUI.setInterval ->
			dd.display(moment().format("HH:mm:ss"))
		,
			1000

		[
			Demo.dividerLabel("digi time")
		,
			dd
		]

	undisplay: ->
		CUI.clearInterval(@__digiInterval)

Demo.register(new Demo.DigiDisplayDemo())