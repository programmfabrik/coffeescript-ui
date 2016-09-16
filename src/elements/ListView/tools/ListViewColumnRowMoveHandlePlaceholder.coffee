class ListViewColumnRowMoveHandlePlaceholder extends ListViewColumnEmpty

	initOpts: ->
		super()
		@removeOpt("class")

	readOpts: ->
		super()
		@_class = "cui-list-view-no-row-move-placeholder"
