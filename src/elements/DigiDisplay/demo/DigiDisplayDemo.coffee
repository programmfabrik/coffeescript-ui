class DigiDisplayDemo extends Demo
	getGroup: ->
		"Extra"

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

		[
			Demo.dividerLabel("digi time")
		,
			dd
		]

	undisplay: ->
		CUI.clearInterval(@__digiInterval)

Demo.register(new DigiDisplayDemo())