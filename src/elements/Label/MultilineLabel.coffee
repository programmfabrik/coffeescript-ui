class MultilineLabel extends Label

	constructor: (@opts={}) ->
		super(@opts)
		@addClass("cui-label")

	initOpts: ->
		super()
		@mergeOpt("multiline", default: true)


