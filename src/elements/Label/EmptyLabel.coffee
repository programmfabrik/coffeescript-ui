class EmptyLabel extends MultilineLabel
	constructor: (@opts = {}) ->
		super(@opts)
		@addClass("cui-empty-label")

	readOpts: ->

		#change default
		if isUndef( @opts.appearance ) and @opts.centered
			@opts.size = "big"

		super()

