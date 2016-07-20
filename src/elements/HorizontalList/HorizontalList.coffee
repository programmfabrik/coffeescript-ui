class HorizontalList extends HorizontalLayout
	initOpts: ->
		super()
		@mergeOpt("maximize", default: false)
		@removeOpt("center")
		@addOpts
			content: {}

	readOpts: ->
		super()
		@_center =
			content: @_content

	getSupportedPanes: ->
		[]

