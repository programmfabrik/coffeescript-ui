###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewColumnRowMoveHandle extends CUI.ListViewColumn

	setElement: (cell) ->
		super(cell)

		row = @getRow()

		if not row.isMovable()
			return

		moveTool = row.getListView().getRowMoveTool
			row: row
			element: cell

		if moveTool
			drag_handle = CUI.dom.children(moveTool.element)?[0]

		if CUI.ListView.defaults.row_move_handle_tooltip and drag_handle
			new CUI.Tooltip
				text: CUI.ListView.defaults.row_move_handle_tooltip
				element: drag_handle

		return

	render: ->
		ui = @getRow()?.getListView()?._ui
		return CUI.dom.element("DIV",
			class: "cui-drag-handle-row"
			ui: if ui then "#{ui}.drag.handle"
		)

