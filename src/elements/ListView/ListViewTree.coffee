###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewTree extends CUI.ListView
	constructor: (@opts={}) ->
		super(@opts)
		assert(@root instanceof ListViewTreeNode, "new ListViewTree", "opts.root must be instance of ListViewTreeNode", opts: @opts)
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
				deprecated: true
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
		if @_selectable != undefined
			assert(@_selectableRows == undefined, "new ListViewTree", "opts.selectable cannot be used with opts.selectableRows, use selectableRows only.", opts: @opts)
			@__selectableRows = @_selectable
		@

	getRowMoveTool: (opts = {}) ->
		opts.rowMoveWithinNodesOnly = @_rowMoveWithinNodesOnly
		new CUI.ListViewTreeRowMove(opts)

	initListView: ->
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
			@root = @_root

		@

	# isSelectable: ->
	# 	@_selectable

	isSelectable: ->
		!!@__selectableRows

	# hasSelectableRows: ->
	# 	@_selectable

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

		handle_event = (ev) =>

			node = DOM.data(DOM.closest(ev.getCurrentTarget(), ".cui-lv-tree-node"), "listViewRow")

			if node not instanceof ListViewTreeNode or node.isLoading() or node.isLeaf()
				return

			# This needs to be immediate, "super" listens on the same node
			ev.stopImmediatePropagation()

			if ev instanceof CUI.DragoverScrollEvent
				if ev.getCount() % 50 == 0
					@toggleNode(ev, node)
			else
				@toggleNode(ev, node)
			return

		super()

		Events.listen
			node: @DOM
			selector: ".cui-tree-node-handle"
			capture: true
			type: ["click", "dragover-scroll"]
			call: (ev) =>
				handle_event(ev)

		Events.listen
			node: @DOM
			selector: ".cui-lv-tree-node"
			type: ["click"]
			call: (ev) =>
				handle_event(ev)

		if do_open
			@root.open()

		if @_no_hierarchy
			@grid.addClass("cui-list-view-tree-no-hierarchy")
		else
			@grid.addClass("cui-list-view-tree-hierarchy")

		@DOM

	toggleNode: (ev, node) ->

		if node.isOpen()
			@__runTrigger(ev, "close", node)
		else
			@__runTrigger(ev, "open", node)

		return


	__runTrigger: (ev, action, node) ->
		if ev.ctrlKey()
			@__actionOnNode(ev, action+"Recursively", node)
		else
			@__actionOnNode(ev, action, node)
		return


	__actionOnNode: (ev, action, node) =>
		hide_spinner = null
		spinner_timeout = CUI.setTimeout
			ms: 500
			call: =>
				node.showSpinner()
				spinner_timeout = null
				hide_spinner = true

		@stopLayout()

		ret = node[action]()
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

	# selectRow: (ev, row) ->
	# 	row.select(ev)

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
			display_from_i = @getDisplayRowIdx(from_i)
			display_to_i = @getDisplayRowIdx(to_i)

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
			@_onRowMove?(display_from_i, display_to_i, after)

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
