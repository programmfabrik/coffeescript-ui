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

		if not @getRow().isMovable()
			return

		if CUI.ListView.defaults.row_move_handle_tooltip
			new Tooltip
				text: CUI.ListView.defaults.row_move_handle_tooltip
				element: cell

		Events.listen
			type: ["mousedown"]
			node: cell
			call: (ev, info) ->
				# CUI.debug ev.getType(), info
				cell.attr("allow-row-move", "1")

				Events.listen
					type: "mouseup"
					node: window
					only_once: true
					capture: true
					call: ->
						cell.removeAttr("allow-row-move")
		return

	render: ->
		new Template(name: "list-view-tool-row-move-handle").DOM

