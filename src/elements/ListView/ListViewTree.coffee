class CUI.ListViewTree extends CUI.ListView
	constructor: (@opts={}) ->
		super(@opts)

		@root.setTree(@)
		#

	initOpts: ->
		super()
		@addOpts
			rowMoveWithinNodesOnly:
				check: Boolean
			children:
				check: Array
			selectable:
				check: Boolean
			# dont display a tree hierarchy
			no_hierarchy:
				default: false
				check: Boolean
			root:
				check: (v) ->
					v instanceof ListViewRow
			onOpen:
				check: Function
			onClose:
				check: Function



	readOpts: ->
		super()

		if not @_root
			lv_opts = {}
			if @_children
				lv_opts.children = @_children
			else if @_getChildren
				lv_opts.getChildren = @_getChildren
			else
				lv_opts.children = []

			@root = new ListViewTreeNode(lv_opts)
		else
			assert(@_root instanceof ListViewTreeNode, "new ListViewTree", "opts.root must be instance of ListViewTreeNode", opts: @opts)
			@root = @_root

		# replace RowMoveTool with ours
		for t, idx in @tools
			if t instanceof ListViewRowMoveTool
				@tools[idx] = new ListViewTreeRowMoveTool
					rowMoveWithinNodesOnly: @_rowMoveWithinNodesOnly
					# tree: @
		@

	isSelectable: ->
		@_selectable

	hasSelectableRows: ->
		@_selectable

	isNoHierarchy: ->
		@_no_hierarchy

	triggerNodeDeselect: (ev, node) ->
		info =
			ev: ev
			node: node
			listView: @

		@_onDeselect?(ev, info)
		Events.trigger
			node: @
			type: "row_deselected"

	triggerNodeSelect: (ev, node) ->
		info =
			ev: ev
			node: node
			listView: @

		@_onSelect?(ev, info)
		Events.trigger
			node: @
			type: "row_selected"

	render: (do_open) ->
		if do_open != false
			CUI.error("ListViewTree.render called with do_open == #{do_open}, only \"false\" is supported. The automatic root.open() is deprecated and will be removed in a future version.")
			do_open = true

		super()

		if do_open
			@root.open()

		# this uses the capture phase, don't interfer with the
		# click, if we have nothing to do
		Events.listen
			node: @DOM
			capture: true
			type: ["click", "dragover-scroll"]
			call: (ev, info) =>
				# CUI.debug "ListViewTree[event]",ev.getType(),info
				# console.warn "ListViewTree", ev.getType(), @DOM
				# dragover fires multiple times, so we need to prevent
				# this node from open multiple times
				$target = $(ev.getTarget())


				_row = $target.closest(".cui-list-view-grid-row")
				# _row = $target.closest(".#{@__lvClass}-row")
				_handle = $target.closest(".cui-tree-node-handle")
				node = DOM.data(_row, "listViewRow")

				# console.error "tree event", ev, _row, _handle, node

				if not node or node.isLoading?()
					return

				prep_target = =>
					if ev.getType() == "click"
						_handle.css(opacity: 0.5)
						return true
					if info.mousemoveEvent._done
						# CUI.debug "event is done, not doing anything"
						return false
					if info.mousemoveEvent._counter % 2 == 0
						_handle.css(opacity: "")
					else
						_handle.css(opacity: 0.5)
					# CUI.debug "ev.mousemoveEvent._counter #{ev.mousemoveEvent._counter} #{ev.mousemoveEvent._done}"
					info.mousemoveEvent._counter > 4

				run_trigger = (action) =>
					if ev.ctrlKey() and ev.getType() == "click"
						action_on_node(action+"Recursively", node)
					else
						action_on_node(action, node)
					return

				action_on_node = (action, _node) =>
					console.time("#{@__uniqueId}: action on node #{action}")
					info.mousemoveEvent?._done = true
					ev.stopPropagation()

					hide_spinner = null
					spinner_timeout = CUI.setTimeout
						ms: 500
						call: =>
							node.showSpinner()
							spinner_timeout = null
							hide_spinner = true

					@stopLayout()

					ret = _node[action]()
					ret.done =>
						switch action
							when "open"
								@_onOpen?(ev, node: node)
							when "close"
								@_onClose?(ev, node: node)

					ret.always =>
						if spinner_timeout
							CUI.clearTimeout(spinner_timeout)

						if hide_spinner
							node.hideSpinner()

						@startLayout()

					return ret
					# console.timeEnd("#{@__uniqueId}: action on node #{action}")

				if _handle.hasClass("cui-tree-node-is-closed") # and not $target.hasClass("no-children")
					if prep_target()
						run_trigger("open")
						return
				else if _handle.hasClass("cui-tree-node-is-open")
					if prep_target()
						run_trigger("close")
						return

		# this is the bubble phase, note that the click
		# is stopped here by "select" and "deselect" below
		Events.listen
			node: @DOM
			type: ["click"]
			call: (ev, info)  =>
				if ev.hasModifierKey(true)
					return

				$target = $(ev.getTarget())
				_row = $target.closest(".cui-list-view-grid-row")
				# _row = $target.closest(".#{@__lvClass}-row")
				node = DOM.data(_row, "listViewRow")

				if not node or node.isLoading?()
					return

				# FIXME: This code needs to go away and use the select/deselect mechanism
				# of ListView
				#

				if node.isSelected?()
					node.deselect?(ev)
				else
					node.select?(ev)
				return

		if @_no_hierarchy
			@grid.addClass("cui-list-view-tree-no-hierarchy")
		else
			@grid.addClass("cui-list-view-tree-hierarchy")

		@DOM

	getNodesForMove: (from_i, to_i, after) ->
		from_node = @getListViewRow(from_i)
		to_node = @getListViewRow(to_i)

		assert(from_node, "ListViewTree.moveRow", "from_i node not found", from_i: from_i)
		assert(to_node, "ListViewTree.moveRow", "to_i node not found", to_i: to_i)

		if from_node.father == to_node.father and not (to_node.is_open and after)
			new_father = null
		else if (to_node.is_open and after)
			new_father = to_node
		else
			new_father = to_node.father

		if new_father == from_node.father
			new_father = null

		[ from_node, to_node, new_father ]

	moveRow: (from_i, to_i, after) ->
		# console.error "moveRow", "from_i:", from_i, "to_i:", to_i, "after:", after, "display_from_i:", @getDisplayRowIdx(from_i), "display_to_i:", @getDisplayRowIdx(to_i)
		[ from_node, to_node, new_father ] = @getNodesForMove(from_i, to_i, after)

		promise = from_node.moveNodeBefore(to_node, new_father, after)

		assert(isPromise(promise), "ListViewTree.moveRow", "moveNodeBefore needs to return a Promise", promise: promise)
		promise.done =>
			super(from_i, to_i, after, false)
			# move row in data structure
			if from_node.father == to_node.father and not (to_node.is_open and after)
				moveInArray(from_node.getChildIdx(), to_node.getChildIdx(), from_node.father.children, after)
			else
				from_node.father.removeChild(from_node)
				# the node is open and we want to put it after, so
				# this means that open node is the new father
				if to_node.is_open and after
					to_node.children.splice(0,0,from_node)
					from_node.setFather(to_node)
				else
					if not after
						to_node.father.children.splice(to_node.getChildIdx(),0,from_node)
					else
						to_node.father.children.splice(to_node.getChildIdx()+1,0,from_node)

					from_node.setFather(to_node.father)

			from_node.reload()
			new_father?.reload()

			from_node.moveNodeAfter(to_node, new_father, after)

			Events.trigger
				node: @grid
				type: "row_moved"
				info:
					from_i: from_i
					to_i: to_i
					after: after

		promise

	getRootChildren: ->
		@root.children

	getSelectedNode: (key="selectedNode") ->
		@root[key]

	prependNode: (node) ->
		@addNode(node, false)

	addNode: (node, append=true) ->
		assert(node instanceof ListViewTreeNode, "#{getObjectClass(@)}.addNode", "Node must be instance of ListViewTreeNode", node: node)
		promise = @root.addNode(node, append)
		Events.trigger
			node: @
			type: "row_added"
			info:
				node: node
		promise

	openTreeNodeByRowDisplayIndex: (index) ->

		row_index = @getRowIdx(index)
		row = @getRow(row_index)
		DOM.data(row[0], "listViewRow").open()


CUI.Events.registerEvent
	bubble: true
	type: [
		"row_removed"
		"row_added"
		"row_moved"
		"row_selected"
		"row_deselected"
	]


ListViewTree = CUI.ListViewTree
