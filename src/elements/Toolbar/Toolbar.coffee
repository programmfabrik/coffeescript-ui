###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

#Organizes/Layouts tools ({Button}s or other Elements) in a horizontal Toolbar
class CUI.Toolbar extends CUI.HorizontalLayout
	init: ->
		super()
		@addClass("cui-toolbar")

	initOpts: ->
		super()

		@removeOpt("maximize")
		@removeOpt("maximize_horizontal")
		@removeOpt("maximize_vertical")
		@addOpts
			maximize_horizontal:
				default: true
				mandatory: true
				check: Boolean

	hasFlexHandles: ->
		false

	getPanes: ->
		["left", "right"]
