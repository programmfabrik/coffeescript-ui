###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.sorg
###

class CUI.VerticalList extends CUI.VerticalLayout
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

