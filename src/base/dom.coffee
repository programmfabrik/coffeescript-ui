###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.dom

	@data: (node, key, data) ->
		if not node
			return undefined

		CUI.util.assert(node instanceof HTMLElement, "dom.data","node needs to be instance of HTMLElement", node: node)

		if key == undefined
			return node.__dom_data or {}

		if CUI.util.isPlainObject(key)
			for k, v of key
				CUI.dom.data(node, k, v)
			return node

		if data == undefined
			return node.__dom_data?[key]

		if not node.__dom_data
			node.__dom_data = {}

		node.__dom_data[key] = data
		return node

	@removeData: (node, key) ->
		if not node
			return undefined

		if node.__dom_data
			delete(node.__dom_data[key])
			if CUI.util.isEmptyObject(node.__dom_data)
				delete(node.__dom_data)
		node

	# find an element starting from node, but never going
	# up
	@findElement: (node, selector, nodeFilter, forward=true, siblingOnly=false) ->
		els = @findElements(node, selector, nodeFilter, 1, forward, siblingOnly)
		if els.length == 0
			return null

		return els[0]

	# find an element starting from node, with going up
	@findNextElement: (node, selector, nodeFilter=false, forward=true, siblingOnly=true) ->
		el = @findElement(node, selector, nodeFilter, forward, siblingOnly)
		# console.debug "find next element", node, el
		if el
			return el

		# find next parent node which has a sibling
		while true
			node = node.parentNode
			# console.debug "checking next node", node

			if not node
				return null

			if forward
				sibling = node.nextElementSibling
			else
				sibling = node.previousElementSibling

			# console.debug "sibling", forward, sibling

			if sibling
				break

		@findNextElement(sibling, selector, nodeFilter, forward, false)

	@findPreviousElement: (node, selector, nodeFilter=false) ->
		@findNextElement(node, selector, nodeFilter, false)

	@findNextVisibleElement: (node, selector, forward=true) ->
		@findNextElement(node, selector, ((node) =>
			# console.debug "node visible?", DOM.isVisible(node), node
			CUI.dom.isVisible(node)), forward)

	@findPreviousVisibleElement: (node, selector) ->
		@findNextVisibleElement(node, selector, false)

	@findNextSiblings: (node, selector, nodeFilter=false) ->
		@findElements(node, selector, nodeFilter, null, true, true)

	@findPreviousSiblings: (node, selector, nodeFilter=false) ->
		@findElements(node, selector, nodeFilter, null, false, true)

	# find the next node starting from node start
	# which matches the selector
	@findElements: (node=document.documentElement, selector=null, nodeFilter=false, maxEls=null, forward=true, siblingOnly=false, elements) ->
		if not elements
			CUI.util.assert(node instanceof HTMLElement, "DOM.findElement", "node needs to be instanceof HTMLElement.", node: node, selector: selector)
			elements = []
			check_node = not siblingOnly
		else
			check_node = true

		accept_node = not nodeFilter or nodeFilter(node)
		# console.debug "findElement", maxEls, node, accept_node, nodeFilter

		if check_node and accept_node
			# console.debug "checking node", node
			if selector == null or CUI.dom.matches(node, selector)
				# console.debug "node ok..."
				elements.push(node)
				if elements.length == maxEls
					# console.debug "enough!", elements.length, maxEls
					return elements
			else
				; # console.debug "node not ok..."


		if forward
			child = node.firstElementChild
			sibling = node.nextElementSibling
		else
			child = node.lastElementChild
			sibling = node.previousElementSibling

		# console.debug "child/sibling", child, sibling, siblingOnly

		if child and not siblingOnly and accept_node
			# console.debug "dive to", node
			@findElements(child, selector, nodeFilter, maxEls, forward, siblingOnly, elements)
			if elements.length == maxEls
				return elements

		if sibling
			# console.debug "sibling to", sibling
			@findElements(sibling, selector, nodeFilter, maxEls, forward, siblingOnly, elements)
			if elements.length == maxEls
				return elements

		# console.debug "nothing found, returning with", elements.length
		return elements


	@children: (node, filter) ->
		children = []

		for child, idx in node.children
			if not filter or @is(child, filter)
				children.push(child)

		children

	# finds the first element child which is not
	# filtered by the optional node filter
	@firstElementChild: (node, nodeFilter) ->
		child = node.firstElementChild
		while true
			if not child
				return null

			if not nodeFilter or @is(child, nodeFilter)
				return child

			child = child.nextElementSibling

	@lastElementChild: (node, nodeFilter) ->
		child = node.lastElementChild
		while true
			if not child
				return null

			if not nodeFilter or @is(child, nodeFilter)
				return child

			child = child.previousElementSibling

	@nextElementSibling: (node, nodeFilter) ->
		sibling = node

		while true
			sibling = sibling.nextElementSibling
			if not sibling
				return null

			if not nodeFilter or @is(sibling, nodeFilter)
				return sibling


	@previousElementSibling: (node, nodeFilter) ->
		sibling = node

		while true
			sibling = sibling.previousElementSibling
			if not sibling
				return null

			if not nodeFilter or @is(sibling, nodeFilter)
				return sibling


	@removeAttribute: (node, key) ->
		if not node
			return null

		node.removeAttribute(key)
		node

	@setAttribute: (_node, key, value) ->
		if not _node
			return null

		node = _node.DOM or _node

		if CUI.util.isNull(value) or value == false
			return @removeAttribute(node, key)

		if value == true
			node.setAttribute(key, key)
		else
			node.setAttribute(key, value)

		node

	@hasAttribute: (node, key) ->
		if not node
			return false

		node.hasAttribute(key)

	@setAttributeMap: (_node, map) ->
		if not _node
			return null

		node = _node.DOM or _node

		if not map
			return node

		for key, value of map
			CUI.dom.setAttribute(node, key, value)

		node

	@width: (docElem, value) ->
		if docElem == document or docElem == window
			if value != undefined
				CUI.util.assert(false, "CUI.dom.width", "Unable to set width on a non HTMLElement", docElem: docElem)
			return window.innerWidth

		if value == undefined
			@getDimension(docElem, "contentBoxWidth")
		else
			@setDimension(docElem, "contentBoxWidth", value)

	@height: (docElem, value) ->
		if docElem == document or docElem == window
			if value != undefined
				CUI.util.assert(false, "CUI.dom.height", "Unable to set width on a non HTMLElement", docElem: docElem)
			return window.innerHeight

		if value == undefined
			@getDimension(docElem, "contentBoxHeight")
		else
			@setDimension(docElem, "contentBoxHeight", value)

	@__append: (node, content, append=true) ->
		if CUI.util.isNull(content)
			return node

		if CUI.util.isArray(content) or content instanceof HTMLCollection or content instanceof NodeList
			idx = 0
			len = content.length

			while idx < len
				@__append(node, content[idx], append)
				if len > content.length
					# leave idx == 0, list is live
				else
					idx++

				len = content.length

			return node

		switch typeof(content)
			when "number", "boolean"
				append_node = document.createTextNode(content + "")
			when "string"
				append_node = document.createTextNode(content)
			else
				if content.hasOwnProperty('DOM')
					append_node = content.DOM
					if CUI.util.isNull(append_node)
						return
				else
					append_node = content

		if append
			CUI.util.assert(append_node instanceof Node, "CUI.dom.append", "Content needs to be instanceof Node, string, boolean, or number.", node: append_node)
			node.appendChild(append_node)
		else
			CUI.util.assert(append_node instanceof Node, "CUI.dom.prepend", "Content needs to be instanceof Node, string, boolean, or number.", node: append_node)
			node.insertBefore(append_node, node.firstChild)

		return node

	@replace: (node, content) ->
		if node.hasOwnProperty('DOM')
			node = node.DOM
		@empty(node)
		@append(node, content)

	@prepend: (node, content) ->
		@__append(node, content, false)

	@append: (node, content) ->
		@__append(node, content)

	# @getById: (uniqueId) ->
	# 	dom_el = document.getElementById("cui-dom-element-"+uniqueId)
	# 	if not dom_el
	# 		return null
	# 	DOM.data(dom_el, "element")

	@getAttribute: (node, key) ->
		if node.hasOwnProperty('DOM')
			node = node.DOM

		node.getAttribute(key)

	@remove: (_node) ->
		node = (_node?.DOM or _node)

		if not node
			return null

		node.parentNode?.removeChild(node)
		node

	@empty: (node) ->
		if not node
			return null

		if node.hasOwnProperty('DOM')
			node = node.DOM

		CUI.util.assert(CUI.util.isElement(node), "CUI.dom.empty", "top needs to be Element", node: node)
		while last = node.lastChild
			node.removeChild(last)
		node

	# checks if any of the classes are set
	@hasClass: (element, cls) ->
		if not element or not cls
			return null

		for _cls in cls.trim().split(/\s+/)
			if _cls == ""
				continue
			if element.classList.contains(_cls)
				return true
		return false

	@toggleClass: (element, cls) ->
		@setClass(element, cls, not @hasClass(element, cls))

	@setClass: (element, cls, on_off) ->
		if on_off
			@addClass(element, cls)
		else
			@removeClass(element, cls)
		return on_off

	@setAria: (element, attr, value) ->
		if value == true
			@setAttribute(element, "aria-"+attr, "true")
		else if value == false
			@setAttribute(element, "aria-"+attr, "false")
		else
			@setAttribute(element, "aria-"+attr, value)

	@addClass: (element, cls) ->
		if not cls or not element
			return element

		for _cls in cls.trim().split(/\s+/)
			if _cls == ""
				continue
			(element.DOM or element).classList.add(_cls)
		element

	@removeClass: (element, cls) ->
		if not cls or not element
			return element

		for _cls in cls.trim().split(/\s+/)
			if _cls == ""
				continue
			(element.DOM or element).classList.remove(_cls)
		element


	# returns the relative position of either
	# the next scrollable parent or positioned parent
	@getRelativeOffset: (node, untilElem = null, ignore_margin = false) ->
		CUI.util.assert(CUI.util.isElement(node), "CUI.dom.getRelativePosition", "Node needs to HTMLElement.", node: node)
		dim_node = CUI.dom.getDimensions(node)
		parent = node.parentNode

		if ignore_margin
			margin_key_top = "viewportTop"
			margin_key_left = "viewportLeft"
		else
			margin_key_top = "viewportTopMargin"
			margin_key_left = "viewportLeftMargin"

		while true
			dim = CUI.dom.getDimensions(parent)

			if parent == document.body or
				parent == document.documentElement or
				parent == document
					offset =
						parent: parent
						top: dim_node[margin_key_top] + document.body.scrollTop
						left: dim_node[margin_key_left] + document.body.scrollLeft
					break

			if dim.canHaveScrollbar or
				parent == node.offsetParent or
				parent == untilElem
					offset =
						parent: parent
						top: dim_node[margin_key_top] - (dim.viewportTop + dim.borderTop) + dim.scrollTop
						left: dim_node[margin_key_left] - (dim.viewportLeft + dim.borderTop) + dim.scrollLeft

					break

			parent = parent.parentNode

			if not parent
				break

		# console.debug parent, node, offset.top, offset.left
		return offset

	@hasAnimatedClone: (node) ->
		!!node.__clone

	# if selector is set, watch matched nodes
	#
	@initAnimatedClone: (node, selector) ->

		@removeAnimatedClone(node)

		clone = node.cloneNode(true)

		node.__clone = clone

		if selector
			watched_nodes = CUI.dom.matchSelector(node, selector)
			clone.__watched_nodes = CUI.dom.matchSelector(clone, selector)
		else
			watched_nodes = CUI.dom.children(node)
			clone.__watched_nodes = CUI.dom.children(clone)

		offset = CUI.dom.getRelativeOffset(node)

		if not CUI.dom.isPositioned(offset.parent)
			node.__parent_saved_position = offset.parent.style.position
			offset.parent.style.position = "relative"

		CUI.dom.setStyle clone,
			position: "absolute"
			"pointer-events": "none"
			top: offset.top
			left: offset.left
			# left: "300px"

		node.style.opacity = "0"

		dim = CUI.dom.getDimensions(node)
		CUI.dom.addClass(clone, "cui-dom-animated-clone")

		# We need this micro DIV to push the scroll height / left
		div = CUI.dom.element("div", style: "position: absolute; opacity: 0; width: 1px; height: 1px;")
		clone.appendChild(div)

		CUI.dom.insertAfter(node, clone)

		CUI.dom.setDimension(clone, "marginBoxWidth", dim.marginBoxWidth)
		CUI.dom.setDimension(clone, "marginBoxHeight", dim.marginBoxHeight)

		for clone_child, idx in clone.__watched_nodes
			clone_child.__watched_node = watched_nodes[idx]

			CUI.dom.setStyle clone_child,
				position: "absolute"
				margin: 0

		@syncAnimatedClone(node)

		node.__clone.__syncScroll = =>
			div.style.top = (node.scrollHeight-1)+"px";
			div.style.left = (node.scrollWidth-1)+"px";
			clone.scrollTop = node.scrollTop
			clone.scrollLeft = node.scrollLeft

		CUI.Events.listen
			type: "scroll"
			instance: clone
			node: node
			call: =>
				node.__clone.__syncScroll()

		node.__clone.__syncScroll()
		node

	@syncAnimatedClone: (node) ->

		clone = node.__clone
		if not clone
			return

		for clone_child, idx in clone.__watched_nodes

			child = clone_child.__watched_node

			# We don't check if the child is still in DOM, for
			# now this case is being ignored.

			offset_new = @getRelativeOffset(child, node, true)

			CUI.dom.setStyle clone_child,
				top: offset_new.top
				left: offset_new.left
		node

	@removeAnimatedClone: (node) ->
		if node.hasOwnProperty("__parent_saved_position")
			node.style.position = node.__parent_saved_position or ""
			delete(node.__parent_saved_position)

		if not node.__clone
			return

		CUI.Events.ignore(instance: node.__clone)
		node.style.opacity = ""
		CUI.dom.remove(node.__clone)
		delete(node.__clone)
		node


	# sets the absolute position of an element
	@setAbsolutePosition: (element, offset) ->
		CUI.util.assert(CUI.util.isElement(element), "CUI.dom.setAbsolutePosition", "element needs to be an instance of HTMLElement", element: element, offset: offset)
		CUI.util.assert(CUI.util.isNumber(offset?.left) and CUI.util.isNumber(offset?.top), "CUI.dom.setAbsolutePosition", "offset.left and offset.top must be >= 0", element: element, offset: offset)
		# the offset needs to be corrected by the parent offset
		# of our DOM element
		offsetParent = element.offsetParent

		if offsetParent == document.documentElement
			layer_parent_offset =
				top: 0
				left: 0

			correct_offset =
				top: document.body.scrollTop
				left: document.body.scrollLeft
		else
			dim = CUI.dom.getDimensions(offsetParent)
			layer_parent_offset =
				top: dim.top
				left: dim.left

			# position: relative/absolute anchor
			# is the point between padding and border,
			# we need to adjust this to the border
			layer_parent_offset.top += dim.borderTopWidth
			layer_parent_offset.left += dim.borderLeftWidth

			correct_offset =
				top: dim.scrollTop
				left: dim.scrollLeft

		CUI.dom.setStyle(element,
			top: offset.top - layer_parent_offset.top + correct_offset.top
			left: offset.left - layer_parent_offset.left + correct_offset.left
		)

	@__failedDOMInserts = 0


	@waitForDOMRemove: (_opts) ->

		opts = CUI.Element.readOpts _opts, "CUI.dom.waitForDOMRemove",
			node:
				mandatory: true
				check: (v) ->
					CUI.dom.isNode(v)
			ms:
				default: 200
				check: (v) ->
					v > 0

		node = CUI.dom.getNode(opts.node)

		dfr = new CUI.Deferred()
		check_in_dom = =>
			if not CUI.dom.isInDOM(node)
				dfr.resolve()
				return

			CUI.setTimeout
				call: check_in_dom
				ms: opts.ms
				track: false

		check_in_dom()
		dfr.promise()


	@waitForDOMInsert: (_opts) ->

		opts = CUI.Element.readOpts _opts, "CUI.dom.waitForDOMInsert",
			node:
				mandatory: true
				check: (v) ->
					CUI.dom.isNode(v)

		node = CUI.dom.getNode(opts.node)

		if CUI.dom.isInDOM(node)
			return CUI.resolvedPromise(true)

		dfr = new CUI.Deferred()

		# If we use MutationObserver, and a not gets not inserted
		# we never free memory on these nodes we wait to be inserted.

		# mo = new MutationObserver =>
		# 	console.debug "waiting for dom insert", node
		# 	if DOM.isInDOM(node)
		# 		if dfr.state() == "pending"
		# 			# console.warn "inserted by mutation", node
		# 			dfr.resolve()

		# dfr.always =>
		# 	mo.disconnect()

		# mo.observe(document.documentElement, childList: true, subtree: true)

		# return dfr.promise()


		#add animation style
		for prefix in ["-webkit-", "-moz-", "-ms-", "-o-", ""]
			# nodeInserted needs to be defined in CSS!
			CUI.dom.setStyleOne(node, "#{prefix}animation-duration", "0.001s")
			CUI.dom.setStyleOne(node, "#{prefix}animation-name", "nodeInserted")

		timeout = null

		CUI.Events.wait
			node: node
			type: "animationstart"
			maxWait: -1
		.done =>

			if CUI.dom.isInDOM(node)
				dfr.resolve()
				return

			c = @__failedDOMInserts++

			console.warn("[##{c}] Element received animationstart event but is not in DOM yet. We poll with timeout 0.")

			tries = 0

			check_for_node = ->
				if CUI.dom.isInDOM(node)
					console.warn("[##{c}] Poll done, element is in DOM now.")
					dfr.resolve()
				else if tries < 10
					console.warn("[##{c}] Checking for node failed, try: ", tries)
					tries = tries + 1
					CUI.setTimeout(check_for_node, 0)
				else
					console.error("[##{c}] Checking for node failed. Giving up.", node)

			CUI.setTimeout(check_for_node, 0)

		.fail(dfr.reject)
		dfr.promise()


	@getNode: (node) ->
		if node.DOM and node != window
			node.DOM
		else
			node

	# small experiment, testing...
	@printElement: (_opts) ->
		opts = CUI.Element.readOpts _opts, "CUI.dom.printElement",
			docElem:
				check: (v) ->
					v instanceof HTMLElement
			title:
				default: "CUI-Print-Window"
				check: String
			windowName:
				default: "_blank"
				check: String
			windowFeatures:
				default: "width=400,height=800"
				check: String
			bodyClasses:
				default: []
				check: Array

		if opts.docElem == document.documentElement
			docElem = document.body
		else
			docElem = opts.docElem

		win = window.open("", opts.windowName, opts.windowFeatures)

		if not CUI.util.isEmpty(opts.title)
			win.document.title = opts.title

		for style_node in CUI.dom.matchSelector(document.head, "link[rel='stylesheet']")
			new_node = style_node.cloneNode(true)
			href = ez5.getAbsoluteURL(new_node.getAttribute("href"))
			new_node.setAttribute("href", href)
			console.debug "cloning css node for href", href
			win.document.head.appendChild(new_node)
		win.document.body.innerHTML = docElem.outerHTML
		win.document.body.classList.add("cui-dom-print-element")
		for cls in opts.bodyClasses
			win.document.body.classList.add(cls)
		win.print()

	@isNode: (node, level=0) ->
		if not node
			return false

		if node == document.documentElement or
			node == window or
			node == document or
			node.nodeType or
			(@isNode(node.DOM, level+1) and level == 0)
				true
		else
			false

	# Inserts the node like array "slice"
	@insertChildAtPosition: (node, node_insert, pos) ->
		CUI.util.assert(CUI.util.isInteger(pos) and pos >= 0 and pos <= node.children.length, "CUI.dom.insertAtPosition", "Unable to insert node at position ##{pos}.", node: node, node_insert: node_insert, pos: pos)
		if pos == node.children.length
			node.appendChild(node_insert)
		else if node.children[pos] != node_insert
			@insertBefore(node.children[pos], node_insert)

	@insertBefore: (_node, node_before) ->
		node = (_node?.DOM or _node)
		if not node
			return null

		if node_before
			node.parentNode.insertBefore(node_before, node)
		node

	@insertAfter: (_node, node_after) ->
		node = (_node?.DOM or _node)
		if not node
			return null

		if node_after
			node.parentNode.insertBefore(node_after, node.nextSibling)
		node

	@is: (node, selector) ->
		if not node
			return null

		if selector instanceof HTMLElement
			return node == selector

		if CUI.util.isFunction(selector)
			return !!selector(node)

		if node not instanceof HTMLElement
			return null

		@matches(node, selector)


	@matches: (node, selector) ->
		if not node
			return null

		node[CUI.dom.matchFunc](selector)

	@matchFunc: (->
		d = document.createElement("div")
		for k in ["matches", "webkitMatchesSelector", "mozMatchesSelector", "oMatchesSelector", "msMatchesSelector"]
			if d[k]
				return k
		CUI.util.assert(false, "Could not determine match function on docElem")
	)()

	@find: (sel) ->
		@matchSelector(document.documentElement, sel)

	@matchSelector: (docElem, sel, trySelf=false) ->
		if docElem.hasOwnProperty('DOM')
			docElem = docElem.DOM

		CUI.util.assert(docElem instanceof HTMLElement or docElem == document, "CUI.dom.matchSelector", "docElem needs to be instanceof HTMLElement or document.", docElem: docElem)

		# console.error "matchSelector", docElem, sel, trySelf
		list = docElem.querySelectorAll(sel)
		# console.debug "DONE"

		if trySelf and list.length == 0
			if docElem[CUI.dom.matchFunc](sel)
				list = [docElem]
			else
				list = []

		return list

	# returns the element matching first the selector
	# upwards, ends at untilDocElem
	# selector & untilDocElem: collect everything until selector matches, but
	#                          not further than untilDocElem
	# selector: collection eveverything until selector matches, null if no match
	# untilDocElem: stop collecting at docElem
	@elementsUntil: (docElem, selector, untilDocElem) ->
		CUI.util.assert(docElem instanceof Node or docElem == window, "CUI.dom.elementsUntil", "docElem needs to be instanceof Node or window.", docElem: docElem, selector: selector, untilDocElem: untilDocElem)
		testDocElem = docElem
		path = [testDocElem]
		while true
			if selector and @is(testDocElem, selector)
				return path

			if testDocElem == untilDocElem
				if selector
					# this means we have not found any
					# elements which match the selector, so we
					return []
				else
					return path

			testDocElem = CUI.dom.parent(testDocElem)

			if testDocElem == null
				if selector
					return []
				else
					return path

			path.push(testDocElem)

		# this should unreachable
		return []

	@parent: (docElem) ->
		if docElem == window
			null
		else if docElem == document
			window
		else
			if docElem.hasOwnProperty('DOM')
				docElem = docElem.DOM
			docElem.parentNode

	@closest: (docElem, selector) ->
		@closestUntil(docElem, selector)

	@closestUntil: (docElem, selector, untilDocElem) ->
		if not selector
			return null

		path = @elementsUntil(docElem, selector, untilDocElem)
		if path.length == 0
			return null

		path[path.length-1]

	# selector is a stopper (like untiDocElem)
	@parentsUntil: (docElem, selector, untilDocElem=document.documentElement) ->
		parentElem = CUI.dom.parent(docElem)
		if not parentElem
			return []

		@elementsUntil(parentElem, selector, untilDocElem)

	# selector is a filter
	@parents: (docElem, selector, untilDocElem=document.documentElement) ->
		CUI.util.assert(docElem instanceof Element or docElem == document or docElem == window, "CUI.dom.parents", "element needs to be instanceof HTMLElement, document, or window.", element: docElem)
		path = @parentsUntil(docElem, null, untilDocElem)

		if not selector
			return path

		# filter parents
		parents = []
		for parent in path
			if @is(parent, selector)
				parents.push(parent)

		parents

	@isInDOM: (docElem) ->
		if not docElem
			return null

		if docElem.hasOwnProperty('DOM')
			docElem = docElem.DOM

		CUI.util.assert(docElem instanceof Node, "CUI.dom.isInDOM", "docElem needs to be instanceof Node.", docElem: docElem)
		document.documentElement.contains(docElem)

	# new nodes can be node or Array of nodes
	@replaceWith: (node, new_node) ->
		CUI.util.assert(node instanceof Node and (new_node instanceof Node or new_node instanceof NodeList), "CUI.dom.replaceWidth", "nodes need to be instanceof Node.", node: node, newNode: new_node)
		CUI.util.assert(node.parentNode instanceof Node, "CUI.dom.replaceWith", "parentNode of node needs to be an instance of Node", node: node, parentNode: node.parentNode)

		if new_node instanceof NodeList
			first_node = new_node[0]
			node.parentNode.replaceChild(first_node, node)
			while (new_node.length > 0)
				@insertAfter(first_node, new_node[new_node.length-1])
			return first_node
		else
			return node.parentNode.replaceChild(new_node, node)

	@getRect: (docElem) ->
		docElem.getBoundingClientRect()

	@getComputedStyle: (docElem) ->
		window.getComputedStyle(docElem)

	@setStyle: (docElem, style, append="px") ->
		if docElem.hasOwnProperty('DOM')
			docElem = docElem.DOM

		CUI.util.assert(docElem instanceof HTMLElement, "CUI.dom.setStyle", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		for k, v of style
			if v == undefined
				continue
			switch v
				when "", null
					set = ""
				else
					if isNaN(Number(v))
						set = v
					else if v == 0 or v == "0"
						set = 0
					else
						set = v + append

			if k.startsWith("--")
				docElem.style.setProperty(k, set)
			else
				docElem.style[k] = set


		docElem

	@getStyle: (element) ->
		if element.hasOwnProperty('DOM')
			element = element.DOM

		styles = {}
		for styleKey, styleValue of element.style
			if not CUI.util.isNull(styleValue)
				styles[styleKey] = styleValue
		styles

	@setStyleOne: (docElem, key, value) ->
		map = {}
		map[key] = value

		@setStyle(docElem, map)

	@setStylePx: (docElem, style) ->
		console.error("CUI.dom.setStylePx is deprectaed, use CUI.dom.setStyle.")
		@setStyle(docElem, style)

	@getRelativePosition: (docElem) ->
		CUI.util.assert(docElem instanceof HTMLElement, "CUI.dom.getRelativePosition", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		dim = CUI.dom.getDimensions(docElem)
		top: dim.offsetTopScrolled
		left: dim.offsetLeftScrolled

	@getDimensions: (docElem) ->
		if CUI.util.isNull(docElem)
			return null

		if docElem == window or docElem == document
			return {
				width: window.innerWidth
				height: window.innerHeight
			}

		cs = @getComputedStyle(docElem)
		rect = @getRect(docElem)

		dim =
			computedStyle: cs
			clientBoundingRect: rect

		for k1 in ["margin", "padding", "border"]
			for k2 in ["Top", "Right", "Bottom", "Left"]

				dim_key = k1+k2
				switch k1
					when "border"
						dim[dim_key] = @getCSSFloatValue(cs["border#{k2}Width"])
					else
						dim[dim_key] = @getCSSFloatValue(cs[dim_key])

			dim[k1+"Vertical"] = dim[k1+"Top"] + dim[k1+"Bottom"]
			dim[k1+"Horizontal"] = dim[k1+"Left"] + dim[k1+"Right"]

		dim.contentBoxWidth = Math.max(0, rect.width - dim.borderHorizontal - dim.paddingHorizontal)
		dim.contentBoxHeight = Math.max(0, rect.height - dim.borderVertical - dim.paddingVertical)
		dim.innerBoxWidth = Math.max(0, rect.width - dim.borderHorizontal)
		dim.innerBoxHeight = Math.max(0, rect.height - dim.borderVertical)
		dim.borderBoxWidth = rect.width
		dim.borderBoxHeight = rect.height

		if cs.boxSizing == "content-box"
			dim.contentWidthAdjust = dim.borderBoxWidth - dim.contentBoxWidth
			dim.contentHeightAdjust = dim.borderBoxHeight - dim.contentBoxHeight
		else
			dim.contentWidthAdjust = 0
			dim.contentHeightAdjust = 0

		dim.marginBoxWidth = Math.max(0, rect.width + dim.marginHorizontal)
		dim.marginBoxHeight = Math.max(0, rect.height + dim.marginVertical)

		dim.viewportTop = rect.top
		dim.viewportTopMargin = rect.top - dim.marginTop
		dim.viewportLeft = rect.left
		dim.viewportLeftMargin = rect.left - dim.marginLeft
		dim.viewportBottom = rect.bottom
		dim.viewportBottomMargin = rect.bottom + dim.marginBottom
		dim.viewportRight = rect.right
		dim.viewportRightMargin = rect.right + dim.marginRight

		dim.viewportCenterTop = rect.top + ((rect.bottom - rect.top) / 2)
		dim.viewportCenterLeft = rect.left + ((rect.right - rect.left) / 2)

		# passthru keys
		for k in [
			"left"
			"top"
			"minWidth"
			"minHeight"
			"maxWidth"
			"maxHeight"
			"marginRight"
			"marginLeft"
			"marginTop"
			"marginBottom"
			"borderTopWidth"
			"borderLeftWidth"
			"borderBottomWidth"
			"borderRightWidth"
		]
			dim[k] = @getCSSFloatValue(cs[k])

		for k in [
			"offsetWidth"
			"offsetHeight"
			"offsetTop"
			"offsetLeft"
			"clientWidth"
			"clientHeight"
			"scrollWidth"
			"scrollHeight"
			"scrollLeft"
			"scrollTop"
		]
			dim[k] = docElem[k]

		dim.scaleX = dim.borderBoxWidth / dim.offsetWidth or 1
		dim.scaleY = dim.borderBoxHeight / dim.offsetHeight or 1

		if docElem.offsetParent
			dim.offsetTopScrolled = dim.offsetTop + docElem.offsetParent.scrollTop
			dim.offsetLeftScrolled = dim.offsetLeft + docElem.offsetParent.scrollLeft
		else
			dim.offsetTopScrolled = dim.offsetTop + document.body.scrollTop
			dim.offsetLeftScrolled = dim.offsetLeft + document.body.scrollLeft

		for k in [
			"offsetWidth"
			"offsetLeft"
			"clientWidth"
			"scrollWidth"
			"scrollLeft"
		]
			dim[k+"Scaled"] = dim[k] * dim.scaleX

		for k in [
			"offsetHeight"
			"offsetTop"
			"clientHeight"
			"scrollHeight"
			"scrollTop"
		]
			dim[k+"Scaled"] = dim[k] * dim.scaleY

		dim.verticalScrollbarWidth = dim.offsetWidth - dim.borderHorizontal - dim.clientWidth
		dim.horizontalScrollbarHeight = dim.offsetHeight - dim.borderVertical - dim.clientHeight

		dim.canHaveScrollbar = cs.overflowX in ["auto", "scroll"] or cs.overflowY in ["auto", "scroll"]
		dim.horizontalScrollbarAtStart = dim.scrollLeft == 0
		dim.horizontalScrollbarAtEnd = dim.scrollWidth - dim.scrollLeft - dim.clientWidth - dim.verticalScrollbarWidth < 1
		dim.verticalScrollbarAtStart = dim.scrollTop == 0
		dim.verticalScrollbarAtEnd = dim.scrollHeight - dim.scrollTop - dim.clientHeight - dim.horizontalScrollbarHeight < 1

		dim.viewportTopContent = rect.top + dim.borderTop + dim.paddingTop
		dim.viewportLeftContent = rect.left + dim.borderLeft + dim.paddingLeft
		dim.viewportBottomContent = rect.bottom - dim.borderBottom - Math.max(dim.paddingBottom, dim.horizontalScrollbarHeight)
		dim.viewportRightContent = rect.right - dim.borderRight- Math.max(dim.paddingRight, dim.verticalScrollbarWidth)

		dim.viewportTopInner = rect.top + dim.borderTop
		dim.viewportLeftInner = rect.left + dim.borderLeft
		dim.viewportBottomInner = rect.bottom - dim.borderBottom - dim.horizontalScrollbarHeight
		dim.viewportRightInner = rect.right - dim.borderRight- dim.verticalScrollbarWidth

		dim

	# returns the scrollable parents
	@parentsScrollable: (node) ->
		parents = []
		for parent, idx in CUI.dom.parents(node)
			dim = CUI.dom.getDimensions(parent)
			if dim.canHaveScrollbar
				parents.push(parent)
		parents

	@setDimension: (docElem, key, value) ->
		set = {}
		set[key] = value
		@setDimensions(docElem, set)

	@getDimension: (docElem, key) ->
		@getDimensions(docElem)[key]

	@prepareSetDimensions: (docElem) ->
		if docElem.__prep_dim
			return

		docElem.__prep_dim =
			borderBox: @isBorderBox(docElem)
			dim: @getDimensions(docElem)
		@

	@setDimensions: (docElem, _dim) ->
		@prepareSetDimensions(docElem)

		css = {}
		borderBox = docElem.__prep_dim.borderBox
		dim = docElem.__prep_dim.dim

		delete(docElem.__prep_dim)

		set_dim = CUI.util.copyObject(_dim)

		cssFloat = {}
		set = (key, value) =>
			if CUI.util.isNull(value) or isNaN(value)
				return

			if not cssFloat.hasOwnProperty(key)
				if key in ["width", "height"] and value < 0
					value = 0

				cssFloat[key] = value
				return
			CUI.util.assert(cssFloat[key] == value, "CUI.dom.setDimensions", "Unable to set contradicting values for #{key}.", docElem: docElem, dim: set_dim)
			return

		# passthru keys
		for k in ["width", "height", "left", "top"]
			if set_dim.hasOwnProperty(k)
				set(k, set_dim[k])
				delete(set_dim[k])

		if set_dim.hasOwnProperty("contentBoxWidth")
			if borderBox
				set("width", set_dim.contentBoxWidth + dim.paddingHorizontal + dim.borderHorizontal)
			else
				set("width", set_dim.contentBoxWidth)

			delete(set_dim.contentBoxWidth)

		if set_dim.hasOwnProperty("contentBoxHeight")
			if borderBox
				set("height",set_dim.contentBoxHeight + dim.paddingVertical + dim.borderVertical)
			else
				set("height",set_dim.contentBoxHeight)

			delete(set_dim.contentBoxHeight)

		if set_dim.hasOwnProperty("borderBoxWidth")
			if borderBox
				set("width", set_dim.borderBoxWidth)
			else
				set("width", set_dim.borderBoxWidth - dim.paddingHorizontal - dim.borderHorizontal)
			delete(set_dim.borderBoxWidth)

		if set_dim.hasOwnProperty("borderBoxHeight")
			if borderBox
				set("height",set_dim.borderBoxHeight)
			else
				set("height",set_dim.borderBoxHeight - dim.paddingVertical - dim.borderVertical)

			delete(set_dim.borderBoxHeight)

		if set_dim.hasOwnProperty("marginBoxWidth")
			if borderBox
				set("width", set_dim.marginBoxWidth - dim.marginHorizontal)
			else
				set("width", set_dim.marginBoxWidth - dim.marginHorizontal - dim.paddingHorizontal - dim.borderHorizontal)

			delete(set_dim.marginBoxWidth)

		if set_dim.hasOwnProperty("marginBoxHeight")
			if borderBox
				set("height", set_dim.marginBoxHeight - dim.marginVertical)
			else
				set("height", set_dim.marginBoxHeight - dim.marginVertical - dim.paddingVertical - dim.borderHorizontal)

			delete(set_dim.marginBoxHeight)

		left_over_keys = Object.keys(set_dim)

		CUI.util.assert(left_over_keys.length == 0, "CUI.dom.setDimensions", "Unknown keys in dimension: \""+left_over_keys.join("\", \"")+"\".", docElem: docElem, dim: _dim)

		@setStyle(docElem, cssFloat)
		cssFloat

	@htmlToNodes: (html) ->
		if CUI.util.isNull(html)
			return

		d = @element("DIV")
		d.innerHTML = html
		d.childNodes

	# runs callback on each textnode
	@findTextInNodes: (nodes, callback, texts = []) ->
		for node in nodes
			child_nodes = []
			for child in node.childNodes
				switch child.nodeType
					when 3 # Text
						textContent = child.textContent.trim()
						if textContent.length > 0
							callback?(child, textContent)
							texts.push(textContent)
					when 1 # Element
						child_nodes.push(child)
			@findTextInNodes(child_nodes, callback, texts)

		return texts

	# turns 14.813px into a Number
	@getCSSFloatValue: (v) ->
		if v.indexOf("px") == -1
			return 0

		fl = parseFloat(v.substr(0, v.length-2))
		fl

	@isPositioned: (docElem) ->
		CUI.util.assert(docElem instanceof HTMLElement, "CUI.dom.isPositioned", "docElem needs to be instance of HTMLElement.", docElem: docElem)
		@getComputedStyle(docElem).position in ["relative", "absolute", "fixed"]

	@isVisible: (docElem) ->
		style = @getComputedStyle(docElem)
		if style.visibility == "hidden" or style.display == "none"
			false
		else
			true

	# @hasOverflow: (docElem) ->
	# 	style = @getComputedStyle(docElem)
	# 	if style.overflowX == "visible" and style.overflowY == "visible"
	# 		true
	# 	else
	# 		false

	@getBoxSizing: (docElem) ->
		@getComputedStyle(docElem).boxSizing

	@isBorderBox: (docElem) ->
		@getBoxSizing(docElem) == "border-box"

	@isContentBox: (docElem) ->
		@getBoxSizing(docElem) == "content-box"

	@hideElement: (docElem) ->
		if not docElem
			return
		if docElem.style.display != "none"
			docElem.__saved_display = docElem.style.display
		docElem.style.display = "none"
		docElem

	@focus: (element) ->
		if not element
			return
		if element.DOM
			element = element.DOM
		element.focus()

	@blur: (element) ->
		if not element
			return
		if element.DOM
			element = element.DOM
		element.blur()

	# remove all children from a DOM node (detach)
	@removeChildren: (docElem, filter) ->
		CUI.util.assert(docElem instanceof HTMLElement, "CUI.dom.removeChildren", "element needs to be instance of HTMLElement", element: docElem)
		for child in @children(docElem, filter)
			docElem.removeChild(child)
		return docElem

	@showElement: (docElem) ->
		if not docElem
			return
		docElem.style.display = docElem.__saved_display or ""
		delete(docElem.__saved_display)
		docElem

	@space: (style = null) ->
		switch style
			when "small"
				@element("DIV", class: "cui-small-space")
			when "large"
				@element("DIV", class: "cui-large-space")
			when "flexible"
				@element("DIV", class: "cui-flexible-space")
			when null
				@element("DIV", class: "cui-space")
			else
				CUI.util.assert(false, "CUI.dom.space", "Unknown style: "+style)

	@element: (tagName, attrs) ->
		CUI.dom.setAttributeMap(document.createElement(tagName), attrs)

	@debugRect: ->
		@remove(@find("#cui-debug-rect")[0])
		if arguments.length == 0
			return

		if arguments.length == 2 or not CUI.util.isArray(arguments[0])
			dim = arguments[0]
			pattern = arguments[1]
			arr = []
			for k in ["Top", "Left", "Bottom", "Right"]
				if CUI.util.isEmpty(pattern) or pattern == "*"
					k = k.toLowerCase()
					value = dim[k]
				else
					value = dim[pattern.replace("*", k)]

				arr.push(value)
		else if CUI.util.isArray(arguments[0])
			arr = arguments[0]
		else
			console.error("CUI.dom.debugRect: Argument Error.")
			return

		[top, left, bottom, right] = arr

		width = right - left
		height = bottom - top

		d = @element("DIV", id: "cui-debug-rect")
		@setStyle d,
			position: "absolute"
			border: "2px solid red"
			boxSizing: "border-box"
			top: top
			left: left
			width: width
			height: height

		document.body.appendChild(d)
		console.debug "CUI.dom.debugRect:", [top, left, bottom, right]
		d

	@scrollIntoView: (docElem) ->
		if not docElem
			return null

		if docElem.nodeType == 3 # textnode
			docElem = docElem.parentNode

		if docElem.hasOwnProperty('DOM')
			docElem = docElem.DOM

		parents = CUI.dom.parentsUntil(docElem)
		dim = null

		measure = =>
			dim = @getDimensions(docElem)

		measure()

		for p, idx in parents

			dim_p = @getDimensions(p)
			if dim_p.computedStyle.overflowY != "visible"

				off_bottom = dim.viewportBottomMargin - dim_p.viewportBottomContent

				if off_bottom > 0
					p.scrollTop = p.scrollTop + off_bottom
					measure()

				off_top = dim.viewportTopMargin - dim_p.viewportTopContent

				if off_top < 0
					p.scrollTop = p.scrollTop + off_top
					measure()

			if dim_p.computedStyle.overflowX != "visible"

				off_right = dim.viewportRightMargin - dim_p.viewportRightContent

				if off_right > 0
					p.scrollLeft = p.scrollLeft + off_right
					measure()

				off_left = dim.viewportLeftMargin - dim_p.viewportLeftContent

				if off_left < 0
					p.scrollLeft = p.scrollLeft + off_left
					measure()

		return docElem

	@setClassOnMousemove: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "CUI.dom.setClassOnMousemove",
			delayRemove:
				check: Function
			class:
				mandatory: true
				check: String
			ms:
				default: 3000
				mandatory: true
				check: (v) ->
					v > 0
			element:
				mandatory: true
				check: (v) ->
					v instanceof HTMLElement
			instance: {}

		remove_mousemoved_class = =>
			if opts.delayRemove?() or CUI.globalDrag
				schedule_remove_mousemoved_class()
				return
			opts.element.classList.remove(opts.class)

		schedule_remove_mousemoved_class = =>
			CUI.scheduleCallback
				ms: opts.ms
				call: remove_mousemoved_class

		CUI.Events.listen
			node: opts.element
			type: "mousemove"
			instance: opts.instance
			call: (ev) =>
				if not opts.element.classList.contains(opts.class)
					opts.element.classList.add(opts.class)
				schedule_remove_mousemoved_class()
				return

		CUI.Events.listen
			node: opts.element
			type: "mouseleave"
			instance: opts.instance
			call: (ev) =>
				remove_mousemoved_class()

	@requestFullscreen: (elem) ->
		if elem.hasOwnProperty('DOM')
			elem = elem.DOM

		CUI.util.assert(elem instanceof HTMLElement, "startFullscreen", "element needs to be instance of HTMLElement", element: elem)
		if elem.requestFullscreen
			elem.requestFullscreen()
		else if elem.webkitRequestFullscreen
			elem.webkitRequestFullscreen()
		else if elem.mozRequestFullScreen
			elem.mozRequestFullScreen()
		else if elem.msRequestFullscreen
			elem.msRequestFullscreen()

		dfr = new CUI.Deferred()

		# send notifiy on open and done on exit

		fsc_ev = CUI.Events.listen
			type: "fullscreenchange"
			node: window
			call: (ev) =>
				if CUI.dom.isFullscreen()
					dfr.notify()
				else
					CUI.Events.ignore(fsc_ev)
					dfr.resolve()
				return

		dfr.promise()

	@exitFullscreen: ->
		if not CUI.dom.isFullscreen()
			return CUI.resolvedPromise()

		dfr = new CUI.Deferred()

		if document.exitFullscreen
			document.exitFullscreen()
		else if document.msExitFullscreen
			document.msExitFullscreen()
		else if (document.mozCancelFullScreen)
			document.mozCancelFullScreen()
		else if (document.webkitExitFullscreen)
			document.webkitExitFullscreen()

		CUI.Events.listen
			type: "fullscreenchange"
			node: window
			only_once: true
			call: =>
				dfr.resolve()
				return

		dfr.promise()

	@fullscreenElement: ->
		document.fullscreenElement or
			document.webkitFullscreenElement or
			document.mozFullScreenElement or
			document.msFullscreenElement or
			undefined

	@fullscreenEnabled: ->
		document.fullscreenEnabled or
			document.webkitFullscreenEnabled or
			document.mozFullScreenEnabled or
			document.msFullscreenEnabled or
			false

	@isFullscreen: ->
		document.fullscreen or
			document.webkitIsFullScreen or
			document.mozFullScreen or
			!!document.msFullscreenElement or
			false

	@$element: (tagName, cls, attrs={}, no_tables=false) ->
		if not CUI.util.isEmpty(cls)
			attrs.class = cls

		if no_tables
			if CUI.util.isEmpty(cls)
				attrs.class = "cui-"+tagName
			else
				attrs.class = "cui-"+tagName+" "+cls

			tagName = "div"

		node = CUI.dom.element(tagName, attrs)
		node

	@div: (cls, attrs) ->
		CUI.dom.$element("div", cls, attrs)

	@video: (cls, attrs) ->
		CUI.dom.$element("video", cls, attrs)

	@audio: (cls, attrs) ->
		CUI.dom.$element("audio", cls, attrs)

	@source: (cls, attrs) ->
		CUI.dom.$element("source", cls, attrs)

	@span: (cls, attrs) ->
		CUI.dom.$element("span", cls, attrs)

	@table: (cls, attrs) ->
		CUI.dom.$element("table", cls, attrs, true)

	@img: (cls, attrs) ->
		CUI.dom.$element("img", cls, attrs)

	@tr: (cls, attrs) ->
		CUI.dom.$element("tr", cls, attrs, true)

	@th: (cls, attrs) ->
		CUI.dom.$element("th", cls, attrs, true)

	@td: (cls, attrs) ->
		CUI.dom.$element("td", cls, attrs, true)

	@i: (cls, attrs) ->
		CUI.dom.$element("i", cls, attrs)

	@p: (cls, attrs) ->
		CUI.dom.$element("p", cls, attrs)

	@pre: (cls, attrs) ->
		CUI.dom.$element("pre", cls, attrs)

	@ul: (cls, attrs) ->
		CUI.dom.$element("ul", cls, attrs)

	@a: (cls, attrs) ->
		CUI.dom.$element("a", cls, attrs)

	@b: (cls, attrs) ->
		CUI.dom.$element("b", cls, attrs)

	@li: (cls, attrs) ->
		CUI.dom.$element("li", cls, attrs)

	@label: (cls, attrs) ->
		CUI.dom.$element("label", cls, attrs)

	@h1: (cls, attrs) ->
		CUI.dom.$element("h1", cls, attrs)

	@h2: (cls, attrs) ->
		CUI.dom.$element("h2", cls, attrs)

	@h3: (cls, attrs) ->
		CUI.dom.$element("h3", cls, attrs)

	@h4: (cls, attrs) ->
		CUI.dom.$element("h4", cls, attrs)

	@h5: (cls, attrs) ->
		CUI.dom.$element("h5", cls, attrs)

	@h6: (cls, attrs) ->
		CUI.dom.$element("h6", cls, attrs)

	@text: (text, cls, attrs) ->
		s = CUI.dom.span(cls, attrs)
		s.textContent = text
		s

	@textEmpty: (text) ->
		s = CUI.dom.span("italic")
		s.textContent = text
		s

	@table_one_row: ->
		CUI.dom.append(CUI.dom.table(), CUI.dom.tr_one_row.apply(@, arguments))

	@tr_one_row: ->
		tr = CUI.dom.tr()
		append = (__a) ->
			td = CUI.dom.td()
			CUI.dom.append(tr, td)

			add_content = (___a) =>
				if CUI.util.isArray(___a)
					for a in ___a
						add_content(a)
				else if ___a?.DOM
					CUI.dom.append(td, ___a.DOM)
				else if not CUI.util.isNull(___a)
					CUI.dom.append(td, ___a)
				return


			add_content(__a)
			return

		for a in arguments
			if CUI.util.isArray(a)
				for _a in a
					append(_a)
			else
				append(a)

		tr
