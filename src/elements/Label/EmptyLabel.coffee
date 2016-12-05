###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class EmptyLabel extends MultilineLabel
	constructor: (@opts = {}) ->
		super(@opts)
		@addClass("cui-empty-label")

	readOpts: ->

		#change default
		if isUndef( @opts.appearance ) and @opts.centered
			@opts.size = "big"

		super()

