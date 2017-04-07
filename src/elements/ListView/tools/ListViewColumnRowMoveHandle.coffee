###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ListViewColumnRowMoveHandle extends ListViewColumn

	setElement: (cell) ->
		super(cell)

		row = @getRow()

		if not row.isMovable()
			return

		if CUI.ListView.defaults.row_move_handle_tooltip
			new Tooltip
				text: CUI.ListView.defaults.row_move_handle_tooltip
				element: cell


		row.getListView().getRowMoveTool
			row: row
			element: cell

		return

	render: ->
		CUI.DOM.element("DIV", class: "cui-drag-handle-row")

