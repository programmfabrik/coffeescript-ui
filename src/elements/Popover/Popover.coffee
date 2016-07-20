class Popover extends Modal

	readOpts: ->

		if isUndef(@opts.pointer)
			@opts.pointer = "arrow"

		if isUndef(@opts.placement)
			@opts.placement = null

		super()

		if not @opts.backdrop?.policy
			@_backdrop.policy = "click-thru"

	disableAllButtons: ->
		super()
		@disableBackdropClick()

	enableAllButtons: ->
		super()
		@enableBackdropClick()

	getPlacements: ->
		return Layer::getPlacements.apply(@, arguments)

	getPositioner: ->
		Layer::getPositioner.apply(@, arguments)

