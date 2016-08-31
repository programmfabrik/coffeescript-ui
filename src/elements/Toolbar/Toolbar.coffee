#Organizes/Layouts tools ({Button}s or other Elements) in a horizontal Toolbar
class Toolbar extends HorizontalLayout
	init: ->
		super()
		@addClass("cui-toolbar")

	initOpts: ->
		super()

		if CUI.__ng__
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
