###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewDraggable extends CUI.Draggable

	initOpts: ->
		super()
		@removeOpt("helper")
		@addOpts
			row:
				mandatory: true
				check: CUI.ListViewRow

	readOpts: ->
		super()
		@__row_i = @_row.getRowIdx()

	get_marker: (cls="") ->
		CUI.DOM.element("DIV", class: "cui-lv-draggable "+cls)

