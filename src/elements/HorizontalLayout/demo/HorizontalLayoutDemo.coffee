class HorizontalLayoutDemo extends Demo
	display: ->
		hl = new VerticalLayout
			top:
				content: "left"
			right:
				content: "right"
			bottom:
				content: "center"

Demo.register(new HorizontalLayoutDemo())