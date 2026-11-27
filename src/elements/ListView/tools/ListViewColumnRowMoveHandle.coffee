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

		tooltip = null
		moveTool = row.getListView().getRowMoveTool
			row: row
			element: cell
			# the tooltip of the handle stays behind when the row is dragged
			dragstart: =>
				tooltip?.hide()
				return

		if moveTool
			drag_handle = CUI.dom.children(moveTool.element)?[0]

		if CUI.ListView.defaults.row_move_handle_tooltip and drag_handle
			tooltip = new CUI.Tooltip
				text: CUI.ListView.defaults.row_move_handle_tooltip
				element: drag_handle
				# hidden while a row is dragged, see _handles.scss
				class: "row-move-handle-tooltip"

		return

	render: ->
		ui = @getRow()?.getListView()?._ui
		return CUI.dom.element("DIV",
			class: "cui-drag-handle-row"
			ui: if ui then "#{ui}.drag.handle"
		)

