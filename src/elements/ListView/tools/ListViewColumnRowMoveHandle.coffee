class ListViewColumnRowMoveHandle extends ListViewColumn

	getClass: ->
		if @getRow().isMovable()
			"cui-list-view-row-move-handle"
		else
			""

	setElement: (cell) ->
		super(cell)

		Events.listen
			type: ["mousedown"]
			node: cell
			call: (ev, info) ->
				# CUI.debug ev.getType(), info
				cell.attr("allow-row-move", "1")

				Events.listen
					type: "mouseup"
					node: document.documentElement
					only_once: true
					capture: true
					call: ->
						cell.removeAttr("allow-row-move")

				Events.listen
					type: "click"
					node: cell
					only_once: true
					call: (ev, info) ->
						ev.stopPropagation()
						return
		return

	render: ->
		new Template(name: "list-view-tool-row-move-handle").DOM

