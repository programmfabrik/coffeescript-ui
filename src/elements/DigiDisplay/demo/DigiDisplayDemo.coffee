class DigiDisplayDemo extends Demo
	display: ->
		dd = new DigiDisplay
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

		dd

	undisplay: ->
		CUI.clearInterval(@__digiInterval)

Demo.register(new DigiDisplayDemo())