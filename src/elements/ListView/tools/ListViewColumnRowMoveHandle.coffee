###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ListViewColumnRowMoveHandle extends ListViewColumn

	getClass: ->
		if @getRow().isMovable() or CUI.__ng__
			"cui-list-view-row-move-handle"
		else
			""

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
		new Template(name: "list-view-tool-row-move-handle").DOM

