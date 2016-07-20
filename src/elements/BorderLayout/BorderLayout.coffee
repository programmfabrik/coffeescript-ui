class BorderLayout extends Layout

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
			@getLayout().map.row.addClass("cui-absolute")
			# we need listen to viewport resize
			Events.listen
				type: "viewport-resize"
				node: @getLayout().map.row
				call: (ev) =>
					ev.stopPropagation()
					Layout.setAbsolute(@getLayout().map.row)

		@