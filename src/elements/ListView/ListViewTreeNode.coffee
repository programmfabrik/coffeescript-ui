class ListViewTreeNode extends ListViewRow

	initOpts: ->
		super()
		@addOpts
			children:
				check: Array
			open:
				check: Boolean
			html: {}
			getChildren:
				check: Function

	readOpts: ->
		super()
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
		# CUI.debug getObjectClass(@), "isLeaf?",leaf, @hasChildren?(), @opts.leaf, @
		leaf

	isSelectable: ->
		@getTree?().isSelectable() and @__selectable

	getFather: ->
		@father

	setFather: (new_father) ->
		assert(new_father == null or new_father instanceof ListViewTreeNode, "#{getObjectClass(@)}.setFather", "father can only be null or instanceof ListViewTreeNode", father: new_father)
		assert(new_father != @, "#{getObjectClass(@)}.setFather", "father cannot be self", node: @, father: new_father)
		# CUI.debug @, new_father
		if new_father
			assert(@ not in new_father.getPath(true), "#{getObjectClass(@)}.setFather", "father cannot any of the node's children", node: @, father: new_father)

		if not new_father and @selected
			@getRoot()?.selectedNode = null
			@selected = false

		if @father and not new_father
			# copy tree, since we are a new root node
			tree = @getTree()
			@father = new_father
			if tree
				@setTree(tree)
		else
			@father = new_father

		if @children
			for c in @children
				c.setFather(@)
		@

	isRoot: ->
		not @father

	setTree: (@tree) ->
		assert(@isRoot(), "#{getObjectClass(@)}.setTree", "node must be root node to set tree", tree: @tree, opts: @opts)
		assert(@tree instanceof ListViewTree, "#{getObjectClass(@)}.setTree", "tree must be instance of ListViewTree", tree: @tree, opts: @opts)

	getRoot: (call=0) ->
		assert(call < 100, "ListViewTreeNode.getRoot", "Recursion detected.")
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
		assert(call < 100, "ListViewTreeNode.getTree", "Recursion detected.")
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
			ListViewTreeNode::remove.call(@, true, false)  # keep children array, no de-select
			for c, idx in save_children
				father.children.splice(our_idx+idx, 0, c)
				c.setFather(father)

			# CUI.debug "removed ", @, our_idx, save_children

		if save_children
			for c in save_children
				c.filter(filter_func, filtered_nodes)

		filtered_nodes

	getPath: (include_self=false, path=[], call=0) ->
		assert(call < 100, "ListViewTreeNode.getPath", "Recursion detected.")

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
			assert(ci > -1, "#{getObjectClass(@)}.getChildIdx()", "Node not found in fathers children Array", node: @, father: @father, "father.children": @father.children)
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
		if (@isRoot() and @getTree()?.getGrid()) or @element
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
		assert(@father, "ListViewTreeNode.close()", "Cannot close root node", node: @)

		assert(not @isLoading(), "ListViewTreeNode.close", "Cannot close node, during opening...", node: @, tree: @getTree())
		@do_open = false
		if @father.is_open
			# CUI.debug "closing node", @node_element
			@removeFromDOM(false)
			@replaceSelf()
			# @getTree().layout()
			# @element.trigger("tree", type: "close")

		CUI.resolvedPromise()

	# remove_self == false only removs children
	removeFromDOM: (remove_self=true) ->
		@abortLoading()
		# CUI.debug "remove from DOM", @getNodeId(), @is_open, @children?.length, remove_self
		if @is_open
			@do_open = true
			for c in @children
				c.removeFromDOM()
		else
			@do_open = false

		if remove_self

			if @selected
				@getRoot()?.selectedNode = null
				@selected = false

			if @element
				if @getRowIdx() == null
					if not @isRoot()
						@getTree().removeDeferredRow(@)
				else
					@getTree().removeRow(@getRowIdx())

				@element = null

		@is_open = false
		@

	getElement: ->
		@element

	# replaces node_element with a new render of ourself
	replaceSelf: ->
		if @father
			if tree = @getTree()
				# layout_stopped = tree.stopLayout()
				tree.replaceRow(@getRowIdx(), @render())
				if @selected
					tree.rowAddClass(@getRowIdx(), ListViewRow.defaults.selected_class)
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

		@[action]()
		.done =>
			promises = []
			for child in @children
				promises.push(child["#{action}Recursively"]())
			CUI.when(promises)
			.done =>
				dfr.resolve()
			.fail =>
				dfr.reject()
		.fail =>
			dfr.reject()
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
		CUI.error("ListViewTreeNode.abortLoading: Aborting chunk loading.")
		@__loadingDeferred.reject()

	# resolves with the opened node
	open: ->
		dfr = new CUI.Deferred()
		tree = @getTree()
		# CUI.error "Node.open START", @getUniqueId(), @getNodeId(), @isLoading(), @is_open, dfr.getUniqueId()

		assert(not @isLoading(), "ListViewTreeNode.open", "Cannot open node #{@getUniqueId()}, during opening. This can happen if the same node exists multiple times in the same tree.", node: @, tree: tree)

		if @is_open
			# CUI.debug "node is already open"
			return dfr.resolve(@).promise()

		# keep this as long as the other deferred is not done
		@__loadingDeferred = new CUI.Deferred()

		# console.time "open:"+tree.getUniqueId()+@getNodeId()
		dfr.always =>
			# CUI.error @getUniqueId(), "running always...", @__loadingDeferred, @isLoading()
			@__loadingDeferred = null
			# console.timeEnd "open:"+tree.getUniqueId()+@getNodeId()
			# CUI.error "Node.open DONE", @getUniqueId(), @isLoading()
			return

		load_children = =>
			assert(CUI.isArray(@children), "ListViewTreeNode.open", "children to be loaded must be an Array", children: @children, listViewTreeNode: @)

			if @children.length == 0
				@is_open = true
				@do_open = false
				if not @isRoot()
					@replaceSelf()
				dfr.resolve(@)
				return

			@initChildren()

			# # CUI.debug "starting with children", @getUniqueId(), (c.getUniqueId() for c in @children)
			# for n in @children
			#       @__addNode(n, true, false, true)

			# if not @isRoot()
			# 	@is_open = true
			# 	@replaceSelf()
			# dfr.resolve()
			# return

			# CUI.debug "root: ", @isRoot(), @is_open, @children.length

			promises = []
			@__loadingDeferred = CUI.chunkWork(@children, 5, 1) # set ms to 1 so we track this
			.progress (node, idx) =>
				# CUI.debug "chunk adding node:", "this:", @getUniqueId(), "node:", node.getUniqueId()
				promises.push(@__appendNode(node, true)) # , false, true)) # don't add again to child array, assume open
				# CUI.debug "node appended", idx, tree.layoutIsStopped(), tree
			.done =>
				CUI.when(promises)
				.done =>
					# CUI.error @getUniqueId(), "resolving deferred...", @, @__loadingDeferred
					@is_open = true
					@do_open = false
					if not @isRoot()
						@replaceSelf()

					dfr.resolve(@)
				.fail =>
					dfr.reject(@)
			.fail =>
				# we need to remove our children
				for c in @children
					c.removeFromDOM()
				# CUI.error(@getUniqueId(), "rejecting deferred...", @__loadingDeferred)
				dfr.reject(@)
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
					assert(isPromise(ret), "#{getObjectClass(@)}.open", "returned children are not of type Promise or Array", children: ret)
					ret
					.done (@children) =>
						if @__loadingDeferred.state() == "rejected"
							CUI.warn("getChildren promise returned, but node opening was cancelled.")
							dfr.reject(@)
						else
							load_children()
					.fail =>
						dfr.reject(@)
			else
				if not @isRoot()
					@replaceSelf()
				dfr.resolve(@)

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
			node.setFather(@)
		return

	# add node adds the node to our children array and
	# actually visually appends it to the ListView
	# however, it does not visually appends it, if the root node
	# is not yet "open".

	addNode: (node, append=true) ->
		assert(not @isLoading(), "ListViewTreeNode.addNode", "Cannot add node, during loading.", node: @)

		if not @children
			@children = []

		assert(CUI.isArray(@children), "Tree.addNode","Cannot add node, children needs to be an Array in node", node: @, new_node: node)
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
		assert(node instanceof ListViewTreeNode, "ListViewTreeNode.__appendNode", "node must be instance of ListViewTreeNode", node: @, new_node: node)
		assert(node.getFather() == @, "ListViewTreeNode.__appendNode", "node added must be child of current node", node: @, new_node: node)

		# CUI.debug ".__appendNode: father: ", @getUniqueId()+"["+@getNodeId()+"]", "child:", node.getUniqueId()+"["+node.getNodeId()+"]"

		if append == false
			append = 0

		tree = @getTree()

		if tree?.isDestroyed()
			return CUI.rejectedPromise(node)

		if not @isRendered()
			return CUI.resolvedPromise(node)

		child_idx = node.getChildIdx()
		if @isRoot()
			if append == true or @children.length == 1 or append+1 == @children.length
				tree.appendRow(node.render())
			else
				assert(@children[append+1], @__cls+".__addNode", "Node not found", children: @children, node: @, append: append)
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
			# 	CUI.error "row index is not there", tree, @is_open, @getNodeId(), child_idx, @children
			# 	_last_node = @children[child_idx-1]
			# 	CUI.debug "last node", _last_node, _last_node.isRendered()
			# 	CUI.debug "child nodes", child_nodes, last_node.isRendered()

			tree.insertRowAfter(last_node.getRowIdx(), node.render())

		if node.selected
			tree.rowAddClass(node.getRowIdx(), ListViewRow.defaults.selected_class)

		if node.do_open
			node.open()
		else
			CUI.resolvedPromise(node)

	remove: (keep_children_array=false, select_after=true) ->
		dfr = new CUI.Deferred()
		select_after_node = null

		remove_node = =>
			# CUI.debug "remove", @getNodeId(), @father.getNodeId(), @element
			@removeFromDOM()
			@father?.removeChild(@, keep_children_array)

			if tree = @getTree()
				Events.trigger
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
		removeFromArray(child, @children)
		if @children.length == 0 and not @isRoot()
			@is_open = false
			if not keep_children_array
				# this hides the "open" icon
				@children = null

		# console.error "removeChild...", @children?.length, keep_children_array, @isRoot()
		@update()
		child.setFather(null)

	deselect: (ev) ->
		if not @getTree().isSelectable()
			return CUI.resolvedPromise()

		@check_deselect(ev)
		.done =>
			@getRoot().selectedNode = null
			t = @getTree()
			t.rowRemoveClass(@getRowIdx(), ListViewRow.defaults.selected_class)
			@selected = false
			@getTree().triggerNodeDeselect(ev, @)

	allowRowMove: ->
		true

	# this is used by hash change and internally
	# ev._confirm_hash_change needs to be set to a "confirmation text"
	# to ask the user if the deselect is ok
	allow_deselect: (ev, info) ->

	# checks if deselecting is possible
	# returns a Promise
	# done: possible
	# fail: not-possible
	check_deselect: (ev) ->
		if ev
			@allow_deselect(ev)
			if ev.getInfo()._confirm_hash_change
				m = new ModalConfirm(text: ev.getInfo()._confirm_hash_change)
				return m.open()

		return CUI.resolvedPromise()

	isSelected: ->
		!!@selected

	select: (ev) ->
		dfr = new CUI.Deferred()
		if ev and @getTree?().isSelectable()
			ev.stopPropagation()

		dfr.done =>
			@getTree().triggerNodeSelect(ev, @)

		if not @isSelectable()
			# CUI.debug "row is not selectable", "row:", @, "tree:", @getTree()
			return dfr.reject().promise()

		if @isSelected()
			return dfr.resolve().promise()

		# CUI.debug "selecting node", sel_node

		do_select = =>
			@getRoot().selectedNode = @
			# CUI.error "openUpwards", @getNodeId(), @is_open
			@openUpwards()
			.done =>
				@getTree().rowAddClass(@getRowIdx(), ListViewRow.defaults.selected_class)
				@selected = true
				dfr.resolve()
			.fail(dfr.reject)

		# the selected node is not us, so we ask the other
		# node
		sel_node = @getRoot().selectedNode

		if sel_node
			sel_node.check_deselect(ev)
			.done ->
				# don't pass event, so no check is performed
				#CUI.debug "selected node:", sel_node
				sel_node.deselect()
				.done ->
					do_select()
				.fail(dfr.reject)
			.fail(dfr.reject)
		else
			do_select()

		# CUI.debug "selecting node",
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
			new EmptyLabel(text: "<empty>").DOM

	update: (update_root=false) =>
		# CUI.debug "updating ", @element?[0], @children, @getFather(), update_root, @isRoot(), @getTree()
		if @isRoot() and not update_root
			# dont update root
			return

		tree = @getTree()
		layout_stopped = tree?.stopLayout()
		@replaceSelf()
		.done =>
			if layout_stopped
				tree.startLayout()
		@

	reload: ->
		# CUI.debug "ListViewTreeNode.reload:", @isRoot(), @is_open
		assert(not @isLoading(), "ListViewTreeNode.reload", "Cannot reload node, during opening...", node: @, tree: @getTree())

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
		if @element
			@__handleDiv.empty()
			@__handleDiv.append(new Icon(icon: "spinner").DOM)
		@

	hideSpinner: ->
		if @element
			@__handleDiv.empty()
			if @__handleIcon
				@__handleDiv.append(new Icon(icon: @__handleIcon).DOM)
			else
		@

	render: ->
		assert(not @isRoot(), "ListViewTreeNode.render", "Unable to render root node.")
		@removeColumns()

		@element = $div("cui-tree-node level-#{@level()}")

		# Space for the left side
		for i in [1...@level()] by 1
			@element.append($div("cui-tree-node-spacer"))

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

		if not @children?.length
			cls.push("cui-tree-node-no-children")

		@__handleDiv = $div(cls.join(" "))
		if @__handleIcon
			@__handleDiv.append(new Icon(icon: @__handleIcon).DOM)

		@element.append(@__handleDiv)

		# push the tree element as the first column
		@prependColumn new ListViewColumn
			element: @element
			class: "cui-tree-node-column cui-tree-node-level-#{@level()}"
			colspan: @opts.colspan

		# nodes can re-arrange the order of the columns
		# so we call them last

		# append Content
		contentDiv = $div("cui-tree-node-content")
		content = @renderContent()
		if CUI.isArray(content)
			for con in content
				contentDiv.append(con?.DOM or content)
		else
			contentDiv.append(content?.DOM or content)
		@element.append(contentDiv)
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



