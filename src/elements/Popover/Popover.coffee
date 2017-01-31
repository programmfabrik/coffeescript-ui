###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

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

	@knownPlacements: ["s", "e", "w", "ws", "wn", "n", "se", "ne", "es", "en", "nw", "sw"]

	# disableAllButtons: ->
	# 	super()
	# 	@disableBackdropClick()

	# enableAllButtons: ->
	# 	super()
	# 	@enableBackdropClick()


