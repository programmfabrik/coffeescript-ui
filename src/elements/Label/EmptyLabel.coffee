###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.EmptyLabel extends CUI.MultilineLabel
	constructor: (@opts = {}) ->
		super(@opts)
		@addClass("cui-empty-label")

	readOpts: ->
		super()

