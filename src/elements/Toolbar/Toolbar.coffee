#Organizes/Layouts tools ({Button}s or other Elements) in a horizontal Toolbar
class Toolbar extends HorizontalLayout
	init: ->
		super()
		@addClass("cui-toolbar")
		
	hasFlexHandles: ->
		false

	getPanes: ->
		["left", "right"]
