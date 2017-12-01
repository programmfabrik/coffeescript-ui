###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewTreeNode extends CUI.ListViewRow

	initOpts: ->
		super()
		@addOpts
			children:
				check: Array
			open:
				check: Boolean
			html: {}
			colspan:
				check: (v) ->
					v > 0
			getChildren:
				check: Function

	readOpts: ->
		super()
		@setColspan(@_colspan)
		if @_children
			@children = @opts.children
			@initChildren()

		if @_open
			@do_open = true
		else
			@do_open = false

		@is_open = false
		@html = @_html
		@__loadingDeferred = null

	setColspan: (@colspan) ->

	getColspan: ->
		@colspan

	# overwrite with Method
	getChildren: null

	# overwrite with Method
	hasChildren: null

	isLeaf: ->
		leaf = (if @children
			false
		else if @opts.getChildren
			false
		else if @getChildren
			if @opts.leaf or (@hasChildren and not @hasChildren())
				true
			else
				false
		else
			true)
		# console.debug CUI.util.getObjectClass(@), "isLeaf?",leaf, @hasChildren?(), @opts.leaf, @
		leaf

	getClass: ->
		cls = super()
		cls = cls + " cui-lv-tree-node"
		cls

	isSelectable: ->
		@getTree?().isSelectable() and @__selectable and not @isRoot()

	getFather: ->
		@father

	setFather: (new_father) ->
		CUI.util.assert(new_father == null or new_father instanceof CUI.ListViewTreeNode, "#{CUI.util.getObjectClass(@)}.setFather", "father can only be null or instanceof CUI.ListViewTreeNode", father: new_father)
		CUI.util.assert(new_father != @, "#{CUI.util.getObjectClass(@)}.setFather", "father cannot be self", node: @, father: new_father)
		# console.debug @, new_father
		if new_father
			CUI.util.assert(@ not in new_father.getPath(true), "#{CUI.util.getObjectClass(@)}.setFather", "father cannot any of the node's children", node: @, father: new_father)

		if not new_father and @selected
			@setSelectedNode(null)
			@selected = false

		if @father and not new_father
			# copy tree, since we are a new root node
			tree = @getTree()
			@father = new_father
			if tree
				@setTree(tree)
		else
			@father = new_father

		# if @children
		# 	for c in @children
		# 		c.setFather(@)
		@

	isRoot: ->
		not @father

	setTree: (@tree) ->
		CUI.util.assert(@isRoot(), "#{CUI.util.getObjectClass(@)}.setTree", "node must be root node to set tree", tree: @tree, opts: @opts)
		CUI.util.assert(@tree instanceof CUI.ListViewTree, "#{CUI.util.getObjectClass(@)}.setTree", "tree must be instance of ListViewTree", tree: @tree, opts: @opts)

	getRoot: (call=0) ->
		CUI.util.assert(call < 100, "ListViewTreeNode.getRoot", "Recursion detected.")
		if @father
			@father.getRoot(call+1)
		else
			@

	dump: (lines=[], depth=0) ->
		padding = []
		for pad in [0...depth]
			padding.push("  ")
		lines.push(padding.join("")+@dumpString())
		if @children
			for c in @children
				c.dump(lines, depth+1)

		if depth==0
			return "\n"+lines.join("\n")+"\n"

	dumpString: ->
		@getNodeId()

	getTree: (call=0) ->
		CUI.util.assert(call < 100, "ListViewTreeNode.getTree", "Recursion detected.")
		if @isRoot()
			@tree
		else
			@getRoot().getTree(call+1)

	# find tree nodes, using the provided compare
	# function
	find: (eq_func=null, nodes=[]) ->
		if not eq_func or eq_func.call(@, @)
			nodes.push(@)
		if @children
			for c in @children
				c.find(eq_func, nodes)

		nodes

	# filters the children by function
	filter: (filter_func, filtered_nodes = []) ->
		save_children = @children?.slice(0)
		if @father and filter_func.call(@, @)
			# this means we have to be removed and our children
			# must be attached in our place to our father
			our_idx = @getChildIdx()
			filtered_nodes.push(@)
			father = @getFather()
			CUI.ListViewTreeNode::remove.call(@, true, false)  # keep children array, no de-select
			for c, idx in save_children
				father.children.splice(our_idx+idx, 0, c)
				c.setFather(father)

			# console.debug "removed ", @, our_idx, save_children

		if save_children
			for c in save_children
				c.filter(filter_func, filtered_nodes)

		filtered_nodes

	getPath: (include_self=false, path=[], call=0) ->
		CUI.util.assert(call < 100, "ListViewTreeNode.getPath", "Recursion detected.")

		if @father
			@father.getPath(true, path, call+1)

		if include_self
			path.push(@)

		return path

	getChildIdx: ->
		if @isRoot()
			"root"
		else
			ci = @father.children.indexOf(@)
			CUI.util.assert(ci > -1, "#{CUI.util.getObjectClass(@)}.getChildIdx()", "Node not found in fathers children Array", node: @, father: @father, "father.children": @father.children)
			ci

	getNodeId: (include_self=true) ->
		path = @getPath(include_self)
		(p.getChildIdx() for p in path).join(".")

	getOpenChildNodes: (nodes=[]) ->
		if @children and @is_open
			for node in @children
				nodes.push(node)
				node.getOpenChildNodes(nodes)
		nodes

	getRowsToMove: ->
		@getOpenChildNodes()

	isRendered: ->
		if (@isRoot() and @getTree()?.getGrid()) or @__is_rendered
			true
		else
			false

	sort: (func, level=0) ->
		if not @children?.length
			return
		@children.sort(func)
		for node in @children
			node.sort(func, level+1)
		if level == 0 and @isRendered()
			@reload()
		@

	close: ->
		CUI.util.assert(@father, "ListViewTreeNode.close()", "Cannot close root node", node: @)

		CUI.util.assert(not @isLoading(), "ListViewTreeNode.close", "Cannot close node, during opening...", node: @, tree: @getTree())
		@do_open = false
		if @father.is_open
			# console.debug "closing node", @node_element
			@removeFromDOM(false)
			@replaceSelf()
			# @getTree().layout()
			# @element.trigger("tree", type: "close")

		CUI.resolvedPromise()

	# remove_self == false only removs children
	removeFromDOM: (remove_self=true) ->
		@abortLoading()
		# console.debug "remove from DOM", @getNodeId(), @is_open, @children?.length, remove_self
		if @is_open
			@do_open = true
			if @children
				for c in @children
					c.removeFromDOM()
		else
			@do_open = false

		if remove_self
			# console.debug "removing ", @getUniqueId(), @getDOMNodes()?[0], @__is_rendered, @getRowIdx()
			if @__is_rendered
				tree = @getTree()
				if tree and not tree.isDestroyed()
					if @getRowIdx() == null
						if not @isRoot()
							tree.removeDeferredRow(@)
					else
						tree.removeRow(@getRowIdx())

				@__is_rendered = false

		@is_open = false
		@

	# getElement: ->
	# 	@element

	# replaces node_element with a new render of ourself
	replaceSelf: ->
		if @father
			if tree = @getTree()
				# layout_stopped = tree.stopLayout()
				tree.replaceRow(@getRowIdx(), @render())
				if @selected
					tree.rowAddClass(@getRowIdx(), CUI.ListViewRow.defaults.selected_class)
				# if layout_stopped
				# 	tree.startLayout()
			return CUI.resolvedPromise()
		else if @is_open
			# root node
			@removeFromDOM(false) # tree.removeAllRows()
			return @open()
		else
			return CUI.resolvedPromise()

	# opens all children and grandchilden
	openRecursively: ->
		@__actionRecursively("open")

	closeRecursively: ->
		@__actionRecursively("close")

	__actionRecursively: (action) ->
		dfr = new CUI.Deferred()
		if @isLeaf()
			return dfr.resolve().promise()

		if action == "open"
			ret = @getLoading()
			if not ret
				ret = @open()
		else
			ret = @close()

		ret.done =>
			promises = []
			for child in @children
				promises.push(child["#{action}Recursively"]())
			CUI.when(promises)
			.done(dfr.resolve)
			.fail(dfr.reject)
		.fail(dfr.reject)
		dfr.promise()

	isOpen: ->
		!!@is_open

	isLoading: ->
		!!@__loadingDeferred

	getLoading: ->
		@__loadingDeferred

	abortLoading: ->
		if not @__loadingDeferred
			return

		# console.error("ListViewTreeNode.abortLoading: Aborting chunk loading.")
		if @__loadingDeferred.state == 'pending'
			@__loadingDeferred.reject()
		@__loadingDeferred = null
		return

	# resolves with the opened node
	open: ->

		# we could return loading_deferred here
		CUI.util.assert(not @isLoading(), "ListViewTreeNode.open", "Cannot open node #{@getUniqueId()}, during opening. This can happen if the same node exists multiple times in the same tree.", node: @)

		if @is_open
			return CUI.resolvedPromise()

		# console.error @getUniqueId(), "opening...", "is open:", @is_open, open_counter

		@is_open = true
		@do_open = false

		dfr = @__loadingDeferred = new CUI.Deferred()

		# console.warn("Start opening", @getUniqueId(), dfr.getUniqueId())

		do_resolve = =>
			if @__loadingDeferred.state() == "pending"
				@__loadingDeferred.resolve(@)
			@__loadingDeferred = null

		do_reject = =>
			if @__loadingDeferred.state() == "pending"
				@__loadingDeferred.reject(@)
			@__loadingDeferred = null

		load_children = =>
			CUI.util.assert(CUI.isArray(@children), "ListViewTreeNode.open", "children to be loaded must be an Array", children: @children, listViewTreeNode: @)

			# console.debug @._key, @getUniqueId(), "children loaded", @children.length

			if @children.length == 0
				if not @isRoot()
					@replaceSelf()
				do_resolve()
				return

			@initChildren()

			CUI.chunkWork.call @,
				items: @children
				chunk_size: 5
				timeout: 1
				call: (items) =>
					CUI.chunkWork.call @,
						items: items
						chunk_size: 1
						timeout: -1
						call: (_items) =>
							# console.error @getUniqueId(), open_counter, @__open_counter, "chunking work"
							if dfr != @__loadingDeferred
								# we are already in a new run, exit
								return false
							@__appendNode(_items[0], true) # , false, true))

			.done =>
				# console.error @getUniqueId(), open_counter, @__open_counter, "chunking work DONE"
				if dfr != @__loadingDeferred
					return

				if not @isRoot()
					@replaceSelf()
				do_resolve()
			.fail =>
				# console.error @getUniqueId(), open_counter, @__open_counter, "chunking work FAIL"
				if dfr != @__loadingDeferred
					return

				for c in @children
					c.removeFromDOM()
				do_reject()

			return

		if @children
			load_children()
		else
			func = @opts.getChildren or @getChildren
			if func
				ret = func.call(@)
				if CUI.isArray(ret)
					@children = ret
					load_children()
				else
					CUI.util.assert(CUI.util.isPromise(ret), "#{CUI.util.getObjectClass(@)}.open", "returned children are not of type Promise or Array", children: ret)
					ret
					.done (@children) =>
						if dfr != @__loadingDeferred
							return
						load_children()
						return
					.fail(do_reject)
			else
				if not @isRoot()
					@replaceSelf()
				do_resolve()

		dfr.promise()

	prependChild: (node) ->
		@addNode(node, false)

	addChild: (node) ->
		@addNode(node, true)

	prependSibling: (node) ->
		idx = @getChildIdx()
		@father.addNode(node, idx)

	appendSibling: (node) ->
		idx = @getChildIdx()+1
		if idx > @father.children.length-1
			@father.addNode(node)
		else
			@father.addNode(node, idx)

	initChildren: ->
		for node, idx in @children
			for _node, _idx in @children
				if idx == _idx
					continue
				CUI.util.assert(_node != node, "ListViewTreeNode.initChildren", "Must have every child only once.", node: @, child: node)

			node.setFather(@)
		return

	# add node adds the node to our children array and
	# actually visually appends it to the ListView
	# however, it does not visually appends it, if the root node
	# is not yet "open".

	addNode: (node, append=true) ->
		CUI.util.assert(not @isLoading(), "ListViewTreeNode.addNode", "Cannot add node, during loading.", node: @)

		if not @children
			@children = []

		CUI.util.assert(CUI.isArray(@children), "Tree.addNode","Cannot add node, children needs to be an Array in node", node: @, new_node: node)

		for _node in @children
			CUI.util.assert(_node != node, "ListViewTreeNode.addNode", "Must have every child only once.", node: @, child: _node)

		if append == true
			@children.push(node)
		else
			@children.splice(append,0,node)

		node.setFather(@)

		# if @is_open
		# 	# we are already open, append the node
		# 	return @__appendNode(node, append)
		# else
		# 	return CUI.resolvedPromise(node)

		if not @is_open
			if @isRoot() or not @isRendered()
				return CUI.resolvedPromise(node)
			# open us, since we have just added a child node
			# we need to open us
			# make sure to return the addedNode
			dfr = new CUI.Deferred()
			@open()
			.done =>
				dfr.resolve(node)
			.fail =>
				dfr.reject(node)
			promise = dfr.promise()
		else
			# we are already open, so simply append the node
			promise = @__appendNode(node, append)

		promise


	# resolves with the appended node
	__appendNode: (node, append=true) -> # , assume_open=false) ->
		CUI.util.assert(node instanceof CUI.ListViewTreeNode, "ListViewTreeNode.__appendNode", "node must be instance of ListViewTreeNode", node: @, new_node: node)
		CUI.util.assert(node.getFather() == @, "ListViewTreeNode.__appendNode", "node added must be child of current node", node: @, new_node: node)

		# console.debug ".__appendNode: father: ", @getUniqueId()+"["+@getNodeId()+"]", "child:", node.getUniqueId()+"["+node.getNodeId()+"]"

		if append == false
			append = 0

		tree = @getTree()

		if tree?.isDestroyed()
			return CUI.rejectedPromise(node)

		if not @isRendered()
			return CUI.resolvedPromise(node)

		# console.warn "appendNode", @getUniqueId(), "new:", node.getUniqueId(), "father open:", @getFather()?.isOpen()

		child_idx = node.getChildIdx()
		if @isRoot()
			if append == true or @children.length == 1 or append+1 == @children.length
				tree.appendRow(node.render())
			else
				CUI.util.assert(@children[append+1], @__cls+".__addNode", "Node not found", children: @children, node: @, append: append)
				tree.insertRowBefore(@children[append+1].getRowIdx(), node.render())
		else if child_idx == 0
			# this means the added node is the first child, we
			# always add this after
			tree.insertRowAfter(@getRowIdx(), node.render())
		else if append != true
			tree.insertRowBefore(@children[append+1].getRowIdx(), node.render())
		else
			# this last node is the node before us, we need to see
			# if is is opened and find the last node opened
			last_node = @children[child_idx-1]
			child_nodes = last_node.getOpenChildNodes()

			if child_nodes.length
				last_node = child_nodes[child_nodes.length-1]

			# if last_node.getRowIdx() == null
			# 	console.error "row index is not there", tree, @is_open, @getNodeId(), child_idx, @children
			# 	_last_node = @children[child_idx-1]
			# 	console.debug "last node", _last_node, _last_node.isRendered()
			# 	console.debug "child nodes", child_nodes, last_node.isRendered()

			tree.insertRowAfter(last_node.getRowIdx(), node.render())

		if node.selected
			tree.rowAddClass(node.getRowIdx(), CUI.ListViewRow.defaults.selected_class)

		if node.do_open
			node.open()
		else
			CUI.resolvedPromise(node)

	remove: (keep_children_array=false, select_after=true) ->
		dfr = new CUI.Deferred()
		select_after_node = null

		remove_node = =>
			# console.debug "remove", @getNodeId(), @father.getNodeId(), @element
			@removeFromDOM()
			@father?.removeChild(@, keep_children_array)

			if tree = @getTree()
				CUI.Events.trigger
					node: tree
					type: "row_removed"

				if select_after_node
					select_after_node.select()
						.done(dfr.resolve).fail(dfr.reject)
				else
					dfr.resolve()
			else
				dfr.resolve()
			return

		if select_after and not @isRoot()
			children = @getFather().children
			if children.length > 1
				child_idx = @getChildIdx()
				if child_idx == 0
					select_after = 1
				else
					select_after = Math.min(children.length-2, child_idx-1)

			if select_after != null
				select_after_node = children[select_after]

		if @isSelected()
			@deselect().fail(dfr.reject).done(remove_node)
		else
			remove_node()

		dfr.promise()

	removeChild: (child, keep_children_array=false) ->
		CUI.util.removeFromArray(child, @children)
		if @children.length == 0 and not @isRoot()
			@is_open = false
			if not keep_children_array
				# this hides the "open" icon
				@children = null

		# console.error "removeChild...", @children?.length, keep_children_array, @isRoot()
		@update()
		child.setFather(null)

	deselect: (ev, new_node) ->
		if not @getTree().isSelectable()
			return CUI.resolvedPromise()

		@check_deselect(ev, new_node)
		.done =>
			@setSelectedNode()
			@removeSelectedClass()
			@selected = false
			@getTree().triggerNodeDeselect(ev, @)

	allowRowMove: ->
		true

	check_deselect: (ev, new_node) ->
		CUI.resolvedPromise()

	isSelected: ->
		!!@selected

	addSelectedClass: ->
		@getTree().rowAddClass(@getRowIdx(), CUI.ListViewRow.defaults.selected_class)

	removeSelectedClass: ->
		@getTree().rowRemoveClass(@getRowIdx(), CUI.ListViewRow.defaults.selected_class)

	setSelectedNode: (node = null, key = @getSelectedNodeKey()) ->
		@getRoot()[@getSelectedNodeKey()] = node

	getSelectedNode: (key = @getSelectedNodeKey()) ->
		@getRoot()?[key] or null

	getSelectedNodeKey: ->
		"selectedNode"

	select: (ev) ->
		dfr = new CUI.Deferred()
		if ev and @getTree?().isSelectable()
			ev.stopPropagation?()

		dfr.done =>
			@getTree().triggerNodeSelect(ev, @)

		if not @isSelectable()
			# console.debug "row is not selectable", "row:", @, "tree:", @getTree()
			return dfr.reject().promise()

		if @isSelected()
			return dfr.resolve().promise()

		# console.debug "selecting node", sel_node

		do_select = =>
			@setSelectedNode(@)
			# console.error "openUpwards", @getNodeId(), @is_open
			@openUpwards()
			.done =>
				@addSelectedClass()
				@selected = true
				dfr.resolve()
			.fail(dfr.reject)

		# the selected node is not us, so we ask the other
		# node
		sel_node = @getSelectedNode()

		if sel_node
			sel_node.check_deselect(ev, @)
			.done =>
				# don't pass event, so no check is performed
				#console.debug "selected node:", sel_node
				sel_node.deselect(null, @)
				.done =>
					do_select()
				.fail(dfr.reject)
			.fail(dfr.reject)
		else
			do_select()

		# console.debug "selecting node",
		dfr.promise()

	# resolves with the innermost node
	openUpwards: (level=0) ->
		dfr = new CUI.Deferred()

		if @isRoot()
			if @isLoading()
				@getLoading()
				.done =>
					dfr.resolve(@)
				.fail =>
					dfr.reject(@)
			else if @is_open
				dfr.resolve(@)
			else
				# if root is not open, we reject all promises
				# an tell our callers to set "do_open"
				dfr.reject(@)
			# not opening root
		else
			promise = @father.openUpwards(level+1)
			promise.done =>
				if not @is_open and level > 0
					if @isLoading()
						_promise = @getLoading()
					else
						_promise = @open()
					_promise
					.done =>
						dfr.resolve(@)
					.fail =>
						dfr.reject(@)
				else
					dfr.resolve(@)

			promise.fail =>
				# remember to open
				@do_open = true
				if level == 0
					# on the last level we resolve fine
					dfr.resolve(@)
				else
					dfr.reject(@)

		dfr.promise()

	level: ->
		if @isRoot()
			0
		else
			@father.level()+1

	renderContent: ->
		if CUI.isFunction(@html)
			@html.call(@opts, @)
		else if @html
			@html
		else
			new CUI.EmptyLabel(text: "<empty>").DOM

	update: (update_root=false) =>
		# console.debug "updating ", @element?[0], @children, @getFather(), update_root, @isRoot(), @getTree()

		if not update_root and (not @__is_rendered or @isRoot())
			# dont update root
			return CUI.resolvedPromise()

		tree = @getTree()
		layout_stopped = tree?.stopLayout()
		@replaceSelf()
		.done =>
			if layout_stopped
				tree.startLayout()

	reload: ->
		# console.debug "ListViewTreeNode.reload:", @isRoot(), @is_open
		CUI.util.assert(not @isLoading(), "ListViewTreeNode.reload", "Cannot reload node, during opening...", node: @, tree: @getTree())

		if @isRoot()
			@replaceSelf()
		else if @is_open
			@close()
			@do_open = true
			@open()
		else
			if @opts.children
				@children = null
			@update()

	showSpinner: ->
		if @__is_rendered
			CUI.dom.empty(@__handleDiv)
			CUI.dom.append(@__handleDiv, new CUI.Icon(icon: "spinner").DOM)
		@

	hideSpinner: ->
		if @__is_rendered
			CUI.dom.empty(@__handleDiv)
			if @__handleIcon
				CUI.dom.append(@__handleDiv, new CUI.Icon(icon: @__handleIcon).DOM)
			else
		@

	render: ->
		CUI.util.assert(not @isRoot(), "ListViewTreeNode.render", "Unable to render root node.")
		@removeColumns()

		element = CUI.dom.div("cui-tree-node level-#{@level()}")
		@__is_rendered = true

		# Space for the left side
		for i in [1...@level()] by 1
			CUI.dom.append(element, CUI.dom.div("cui-tree-node-spacer"))

		# Handle before content
		cls = ["cui-tree-node-handle"]

		if @is_open
			@__handleIcon = "tree_close"
			cls.push("cui-tree-node-is-open")
		else if @isLeaf()
			@__handleIcon = null
			cls.push("cui-tree-node-is-leaf")
		else
			@__handleIcon = "tree_open"
			cls.push("cui-tree-node-is-closed")

		if @children?.length == 0
			cls.push("cui-tree-node-no-children")

		@__handleDiv = CUI.dom.div(cls.join(" "))
		if @__handleIcon
			CUI.dom.append(@__handleDiv, new CUI.Icon(icon: @__handleIcon).DOM)

		CUI.dom.append(element, @__handleDiv)

		# push the tree element as the first column
		@prependColumn new CUI.ListViewColumn
			element: element
			class: "cui-tree-node-column cui-tree-node-level-#{@level()}"
			colspan: @getColspan()

		# nodes can re-arrange the order of the columns
		# so we call them last

		# append Content
		contentDiv = CUI.dom.div("cui-tree-node-content")
		content = @renderContent()
		if CUI.isArray(content)
			for con in content
				CUI.dom.append(contentDiv, con)
		else
			CUI.dom.append(contentDiv, content)
		CUI.dom.append(element, contentDiv)
		@


	moveToNewFather: (new_father, new_child_idx) ->
		old_father = @father
		old_father.removeChild(@)

		new_father.children.splice(new_child_idx, 0, @)
		@setFather(new_father)

		old_father.reload()
		new_father.reload()


	# needs to return a promise
	moveNodeBefore: (to_node, new_father, after) ->
		CUI.resolvedPromise()

	moveNodeAfter: (to_node, new_father, after) ->
