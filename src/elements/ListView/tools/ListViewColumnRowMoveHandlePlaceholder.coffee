###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ListViewColumnRowMoveHandlePlaceholder extends ListViewColumnEmpty

	initOpts: ->
		super()
		@removeOpt("class")

	readOpts: ->
		super()
		@_class = "cui-list-view-no-row-move-placeholder"
