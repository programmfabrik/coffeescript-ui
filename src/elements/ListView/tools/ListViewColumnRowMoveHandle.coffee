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

