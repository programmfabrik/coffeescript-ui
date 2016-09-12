class Popover extends Modal

	initOpts: ->
		super()
		@mergeOpt "placement",
			default: null

		@mergeOpt "pointer",
			default: "arrow"

	readOpts: ->

		super()

		if not @opts.backdrop?.policy
			@_backdrop.policy = "click-thru"

	disableAllButtons: ->
		super()
		@disableBackdropClick()

	enableAllButtons: ->
		super()
		@enableBackdropClick()


