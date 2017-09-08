###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./BorderLayout.html'));

class CUI.BorderLayout extends CUI.Layout

	getName: ->
		"border-layout"

	getPanes: ->
		["north", "west", "east", "south"]

	getSupportedPanes: ->
		@getPanes()

	getTemplateMap: ->
		map = super()
		map.row = true
		map

	__init: ->
		super()

		if @_absolute
			CUI.dom.addClass(@getLayout().map.row, "cui-absolute")
			# we need listen to viewport resize
			CUI.Events.listen
				type: "viewport-resize"
				node: @getLayout().map.row
				call: (ev) =>
					ev.stopPropagation()
					CUI.Layout.setAbsolute(@getLayout().map.row)

		@