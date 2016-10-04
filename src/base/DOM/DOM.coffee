class CUI.DOM extends CUI.Element

	initOpts: ->
		super()
		@addOpts
			class:
				default: ""
				check: String

	registerTemplate: (template) ->
		assert(template instanceof Template, "#{getObjectClass(@)}.registerDOMElement", "template must be instance of Template but is #{getObjectClass(template)}.", template: template)
		if @__template
			CUI.warn("#{getObjectClass(@)}.registerDOMElement", "Already called before, destroying existing template", template: @__template)
			@__template.destroy()
		@__template = template
		@registerDOMElement(@__template.DOM)

	getDOMElementClasses: ->
		if CUI.__ng__
			return "cui-dom-element cui-#{toDash(@__cls)}"
		else
			return "cui-dom-element cui-#{toDash(@__cls)} ez-#{toDash(@__cls)}"

	registerDOMElement: (_dom) ->
		@DOM = _dom
		CUI.DOM.addClass(@DOM, @getDOMElementClasses())
		CUI.DOM.setAttribute(@DOM, "id", "cui-dom-element-"+@getUniqueId())
		if @_class
			# CUI.debug DOM, @DOM, @_class
			CUI.DOM.addClass(@DOM, @_class) # @DOM.addClass(@_class)
		CUI.DOM.setElement(@DOM, @)
		@

	unregisterDOMElement: (@DOM) ->
		CUI.removeClass(@DOM, @getDOMElementClasses())
		CUI.DOM.removeAttribute(@DOM, "id")
		if @_class
			CUI.DOM.removeClass(@DOM, @_class)
		DOM.removeData(@DOM, "element")
		@

	assertDOMElement: (func) ->
		assert(@DOM, "#{@__cls}.#{func}", "registerDOMElement needs to be called before \"#{func}\" is supported.")

	assertTemplateElement: (func) ->
		assert(@__template, "#{@__cls}.#{func}", "registerTemplateElement needs to be called before \"#{func}\" is supported.")

	addClass: (cls) ->
		assert(arguments.length == 1, "DOM.addClass", "Only one parameter allowed.")

		@assertDOMElement("addClass")
		CUI.DOM.addClass(@DOM, cls)

	removeClass: (cls) ->
		assert(arguments.length == 1, "DOM.removeClass", "Only one parameter allowed.")

		@assertDOMElement("removeClass")
		CUI.DOM.removeClass(@DOM, cls)

	hasClass: (cls) ->
		assert(arguments.length == 1, "DOM.hasClass", "Only one parameter allowed.")
		@assertDOMElement("hasClass")
		CUI.DOM.hasClass(@DOM, cls)

	isDestroyed: (key) ->
		@__template?.isDestroyed.call(@__template, key)

	empty: (key) ->
		@assertTemplateElement("empty")
		@__template.empty.call(@__template, key)

	replace: (value, key) ->
		@assertTemplateElement("replace")
		@__template.replace.call(@__template, value, key, @)

	append: (value, key) ->
		@assertTemplateElement("append")
		@__template.append.call(@__template, value, key, @)

	prepend: (value, key) ->
		@assertTemplateElement("prepend")
		@__template.prepend.call(@__template, value, key, @)

	text: (value, key) ->
		@assertTemplateElement("text")
		@__template.text.call(@__template, value, key, @)

	getFlexHandle: (key, do_assert) ->
		@assertTemplateElement("getFlexHandle")
		@__template.getFlexHandle.call(@__template, key, do_assert)

	destroy: ->
		# we need to set "isDestroyed" first, so
		super()
		if @__template
			@__template?.destroy()
		else if @DOM
			DOM.remove(@DOM)
		@
		# Events.ignore(node: @DOM)


	@setElement: (element, inst) ->
		CUI.jQueryCompat(element)
		DOM.data(element, "element", inst)

	@data: (node, key, data) ->
		if not node
			return undefined

		assert(node instanceof HTMLElement, "DOM.data","node needs to be instance of HTMLElement", node: node)

		if key == undefined
			return node.__dom_data

		if CUI.isPlainObject(key)
			for k, v of key
				DOM.data(node, k, v)
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
			if CUI.isEmptyObject(node.__dom_data)
				delete(node.__dom_data)
		DOM

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
		# CUI.debug "find next element", node, el
		if el
			return el

		# find next parent node which has a sibling
		while true
			node = node.parentNode
			# CUI.debug "checking next node", node

			if not node
				return null

			if forward
				sibling = node.nextElementSibling
			else
				sibling = node.previousElementSibling

			# CUI.debug "sibling", forward, sibling

			if sibling
				break

		@findNextElement(sibling, selector, nodeFilter, forward, false)

	@findPreviousElement: (node, selector, nodeFilter=false) ->
		@findNextElement(node, selector, nodeFilter, false)

	@findNextVisibleElement: (node, selector, forward=true) ->
		@findNextElement(node, selector, ((node) =>
			# CUI.debug "node visible?", DOM.isVisible(node), node
			DOM.isVisible(node)), forward)

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
			assert(node instanceof HTMLElement, "DOM.findElement", "node needs to be instanceof HTMLElement.", node: node, selector: selector)
			elements = []
			check_node = not siblingOnly
		else
			check_node = true

		accept_node = not nodeFilter or nodeFilter(node)
		# CUI.debug "findElement", maxEls, node, accept_node, nodeFilter

		if check_node and accept_node
			# CUI.debug "checking node", node
			if selector == null or DOM.matches(node, selector)
				# CUI.debug "node ok..."
				elements.push(node)
				if elements.length == maxEls
					# CUI.debug "enough!", elements.length, maxEls
					return elements
			else
				; # CUI.debug "node not ok..."


		if forward
			child = node.firstElementChild
			sibling = node.nextElementSibling
		else
			child = node.lastElementChild
			sibling = node.previousElementSibling

		# CUI.debug "child/sibling", child, sibling, siblingOnly

		if child and not siblingOnly and accept_node
			# CUI.debug "dive to", node
			@findElements(child, selector, nodeFilter, maxEls, forward, siblingOnly, elements)
			if elements.length == maxEls
				return elements

		if sibling
			# CUI.debug "sibling to", sibling
			@findElements(sibling, selector, nodeFilter, maxEls, forward, siblingOnly, elements)
			if elements.length == maxEls
				return elements

		# CUI.debug "nothing found, returning with", elements.length
		return elements

	# finds the first element child which is not
	# filtered by the optional node filter
	@firstElementChild: (node, nodeFilter) ->
		child = node.firstElementChild
		while true
			if not nodeFilter or nodeFilter(child)
				return child

			child = child.nextElementSibling
			if not child
				return null

	@children: (node, filter) ->
		children = []

		for child, idx in node.children
			if not filter or @is(child, filter)
				children.push(child)

		children


	@lastElementChild: (node, nodeFilter) ->
		child = node.lastElementChild
		while true
			if not nodeFilter or nodeFilter(child)
				return child

			child = child.previousElementSibling
			if not child
				return null

	@nextElementSibling: (node, nodeFilter) ->
		while true
			sibling = node.nextElementSibling
			if not nodeFilter or nodeFilter(child)
				return sibling

			if not sibling
				return null


	@previousElementSibling: (node, nodeFilter) ->
		while true
			sibling = node.previousElementSibling
			if not nodeFilter or nodeFilter(child)
				return sibling

			if not sibling
				return null


	@removeAttribute: (node, key) ->
		node.removeAttribute(key)
		node

	@setAttribute: (node, key, value) ->
		if isNull(value) or value == false
			return @removeAttribute(node, key)

		if value == true
			node.setAttribute(key, key)
		else
			node.setAttribute(key, value)

		node

	@hasAttribute: (node, key) ->
		node.hasAttribute(key)

	@setAttributeMap: (node, map) ->
		for key, value of map
			CUI.DOM.setAttribute(node, key, value)
		node

	@width: (docElem, value) ->
		if docElem == document or docElem == window
			if value != undefined
				assert(false, "DOM.width", "Unable to set width on a non HTMLElement", docElem: docElem)
			return window.innerWidth

		if value == undefined
			@getDimension(docElem, "contentBoxWidth")
		else
			@setDimension(docElem, "contentBoxWidth", value)

	@height: (docElem, value) ->
		if docElem == document or docElem == window
			if value != undefined
				assert(false, "DOM.height", "Unable to set width on a non HTMLElement", docElem: docElem)
			return window.innerHeight

		if value == undefined
			@getDimension(docElem, "contentBoxHeight")
		else
			@setDimension(docElem, "contentBoxHeight", value)

	@__append: (node, content, append=true) ->
		if isNull(content)
			return node

		if CUI.isArray(content) or content instanceof HTMLCollection or content instanceof NodeList
			idx = 0
			len = content.length

			while idx < len
				CUI.DOM.append(node, content[idx], append)
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
				append_node = content

		if append
			assert(append_node instanceof Node, "DOM.append", "Content needs to be instanceof Node, string, boolean, or number.", node: content)
			node.appendChild(append_node)
		else
			assert(append_node instanceof Node, "DOM.prepend", "Content needs to be instanceof Node, string, boolean, or number.", node: content)
			node.insertBefore(content, node.firstChild)

		return node

	@prepend: (node, content) ->
		@__append(node, content, false)

	@append: (node, content) ->
		@__append(node, content)

	@getById: (uniqueId) ->
		dom_el = document.getElementById("cui-dom-element-"+uniqueId)
		if not dom_el
			return null
		DOM.data(dom_el, "element")

	@getAttribute: (node, key) ->
		node.getAttribute(key)

	@remove: (element) ->
		element.parentNode?.removeChild(element)
		element

	@empty: (element) ->
		assert(isElement(element), "DOM.empty", "top needs to be Element", element: element)
		element.innerHTML = ""
		element

	# checks if any of the classes are set
	@hasClass: (element, cls) ->
		if not cls
			return null

		for _cls in cls.trim().split(/\s+/)
			if _cls == ""
				continue
			if element.classList.contains(_cls)
				return true
		return false

	@setClass: (element, cls, on_off) ->
		if on_off
			@addClass(element, cls)
		else
			@removeClass(element, cls)

	@addClass: (element, cls) ->
		if not cls or not element
			return element

		for _cls in cls.trim().split(/\s+/)
			if _cls == ""
				continue
			element.classList.add(_cls)
		element

	@removeClass: (element, cls) ->
		if not cls or not element
			return element

		for _cls in cls.trim().split(/\s+/)
			if _cls == ""
				continue
			element.classList.remove(_cls)
		element


	# returns the relative position of either
	# the next scrollable parent or positioned parent
	@getRelativeOffset: (node, untilElem = null, ignore_margin = false) ->
		assert(isElement(node), "CUI.DOM.getRelativePosition", "Node needs to HTMLElement.", node: node)
		dim_node = CUI.DOM.getDimensions(node)
		parent = node.parentNode

		if ignore_margin
			margin_key_top = "viewportTop"
			margin_key_left = "viewportLeft"
		else
			margin_key_top = "viewportTopMargin"
			margin_key_left = "viewportLeftMargin"

		while true
			dim = CUI.DOM.getDimensions(parent)

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
			watched_nodes = CUI.DOM.matchSelector(node, selector)
			clone.__watched_nodes = CUI.DOM.matchSelector(clone, selector)
		else
			watched_nodes = CUI.DOM.children(node)
			clone.__watched_nodes = CUI.DOM.children(clone)

		offset = CUI.DOM.getRelativeOffset(node)

		if not CUI.DOM.isPositioned(offset.parent)
			node.__parent_saved_position = offset.parent.style.position
			offset.parent.style.position = "relative"

		CUI.DOM.setStyle clone,
			position: "absolute"
			"pointer-events": "none"
			top: offset.top
			left: offset.left
			# left: "300px"

		node.style.opacity = "0"

		dim = DOM.getDimensions(node)
		CUI.DOM.addClass(clone, "cui-dom-animated-clone cui-debug-node-copyable")

		# We need this micro DIV to push the scroll height / left
		div = CUI.DOM.element("div", style: "position: absolute; opacity: 0; width: 1px; height: 1px;")
		clone.appendChild(div)

		CUI.DOM.insertAfter(node, clone)

		CUI.DOM.setDimension(clone, "marginBoxWidth", dim.marginBoxWidth)
		CUI.DOM.setDimension(clone, "marginBoxHeight", dim.marginBoxHeight)

		for clone_child, idx in clone.__watched_nodes
			clone_child.__watched_node = watched_nodes[idx]

			CUI.DOM.setStyle clone_child,
				position: "absolute"
				margin: 0

		@syncAnimatedClone(node)

		node.__clone.__syncScroll = =>
			div.style.top = (node.scrollHeight-1)+"px";
			div.style.left = (node.scrollWidth-1)+"px";
			clone.scrollTop = node.scrollTop
			clone.scrollLeft = node.scrollLeft

		Events.listen
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

			CUI.DOM.setStyle clone_child,
				top: offset_new.top
				left: offset_new.left
		node

	@removeAnimatedClone: (node) ->
		if node.hasOwnProperty("__parent_saved_position")
			node.style.position = node.__parent_saved_position or ""
			delete(node.__parent_saved_position)

		if not node.__clone
			return

		Events.ignore(instance: node.__clone)
		node.style.opacity = ""
		node.__clone.remove()
		delete(node.__clone)
		node


	# sets the absolute position of an element
	@setAbsolutePosition: (element, offset) ->
		assert(isElement(element), "DOM.setAbsolutePosition", "element needs to be a jQuery element", element: element, offset: offset)
		assert(isNumber(offset?.left) and isNumber(offset?.top), "DOM.setAbsolutePosition", "offset.left and offset.top must be >= 0", element: element, offset: offset)
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
			dim = DOM.getDimensions(offsetParent)
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

		element.css
			top: offset.top - layer_parent_offset.top + correct_offset.top
			left: offset.left - layer_parent_offset.left + correct_offset.left
		@

	@__failedDOMInserts = 0

	@waitForDOMInsert: (_opts) ->

		opts = CUI.Element.readOpts _opts, "DOM.waitForDOMInsert",
			node:
				mandatory: true
				check: (v) ->
					DOM.isNode(v)

		node = DOM.getNode(opts.node)

		if CUI.DOM.isInDOM(node)
			return CUI.resolvedPromise(true)

		#add animation style
		for prefix in ["-webkit-", "-moz-", "-ms-", "-o-", ""]
			# nodeInserted needs to be defined in CSS!
			DOM.setStyleOne(node, "#{prefix}animation-duration", "0.001s")
			DOM.setStyleOne(node, "#{prefix}animation-name", "nodeInserted")

		timeout = null

		dfr = new CUI.Deferred()
		Events.wait
			node: node
			type: "animationstart"
			maxWait: -1
		.done =>
			if DOM.isInDOM(node)
				dfr.resolve()
				return

			c = @__failedDOMInserts++

			CUI.warn("[##{c}] Element received animationstart event but is not in DOM yet. We poll with timeout 0.")

			check_for_node = ->
				if DOM.isInDOM(node)
					CUI.warn("[##{c}] Poll done, element is in DOM now.")
					dfr.resolve()
				else
					CUI.warn("[##{c}] Checking for node failed, waiting another 0 seconds...")
					CUI.setTimeout(check_for_node, 0)

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
		opts = CUI.Element.readOpts _opts, "DOM.printElement",
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

		if not isEmpty(opts.title)
			win.document.title = opts.title

		for style_node in DOM.matchSelector(document.head, "link[rel='stylesheet']")
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

	@isNode: (node) ->
		if node == document.documentElement or
			node == window or
			node == document or
			node.nodeType or
			node.DOM
				true
		else
			false

	# Inserts the node like array "slice"
	@insertChildAtPosition: (node, node_insert, pos) ->
		assert(isInteger(pos) and pos >= 0 and pos <= node.children.length, "CUI.DOM.insertAtPosition", "Unable to insert node at position ##{pos}.", node: node, node_insert: node_insert, pos: pos)
		if pos == node.children.length
			node.appendChild(node_insert)
		else if node.children[pos] != node_insert
			@insertBefore(node.children[pos], node_insert)

	@insertBefore: (node, node_before) ->
		if node_before
			node.parentNode.insertBefore(node_before, node)
		node

	@insertAfter: (node, node_after) ->
		if node_after
			node.parentNode.insertBefore(node_after, node.nextElementSibling)
		node

	@is: (node, selector) ->
		if not node
			return null

		if selector instanceof HTMLElement
			return node == selector

		if CUI.isFunction(selector)
			return !!selector(node)

		if node not instanceof HTMLElement
			return null

		@matches(node, selector)


	@matches: (node, selector) ->
		if not node
			return null

		node[CUI.DOM.matchFunc](selector)

	@matchFunc: (->
		d = document.createElement("div")
		for k in ["matches", "webkitMatchesSelector", "mozMatchesSelector", "oMatchesSelector", "msMatchesSelector"]
			if d[k]
				return k
		assert(false, "Could not determine match function on docElem")
	)()

	@matchSelector: (docElem, sel, trySelf=false) ->
		assert(docElem instanceof HTMLElement or docElem == document, "CUI.DOM.matchSelector", "docElem needs to be instanceof HTMLElement or document.", docElem: docElem)

		# CUI.error "matchSelector", docElem, sel, trySelf
		list = docElem.querySelectorAll(sel)
		# CUI.debug "DONE"

		if trySelf and list.length == 0
			if docElem[CUI.DOM.matchFunc](sel)
				list = [docElem]
			else
				list = []

		return list

	# returns the element matching first the selector
	# upwards, ends at untilDocElem
	@elementsUntil: (docElem, selector, untilDocElem) ->

		assert(docElem instanceof HTMLElement or docElem == document or docElem == window, "CUI.DOM.elementsUntil", "docElem needs to be instanceof HTMLElement.", docElem: docElem, selector: selector, untilDocElem: untilDocElem)
		testDocElem = docElem
		path = [testDocElem]
		while true
			if selector and @is(testDocElem, selector)
				return path

			if testDocElem == untilDocElem or
				testDocElem == window
					if selector
						# this means we have not found any
						# elements which match the selector, so we
						# return null
						return null
					else
						return path

			testDocElem = CUI.DOM.parent(testDocElem)
			if testDocElem == null
				return null

			path.push(testDocElem)

		# this is unreachable
		return null

	@parent: (docElem) ->
		if docElem == window
			null
		else if docElem == document
			window
		else
			docElem.parentNode

	@closest: (docElem, selector) ->
		if selector instanceof HTMLElement
			@closestUntil(docElem, null, selector)
		else
			@closestUntil(docElem, selector, document.documentElement)

	@closestUntil: (docElem, selector, untilDocElem) ->
		path = @elementsUntil(docElem, selector, untilDocElem)
		if not path or path.length == 0
			return null

		last_element = path[path.length-1]

		# we return last_element "window", if untilDocElem
		# was set to window
		if last_element == window and untilDocElem != window
			return null

		last_element

	# selector is a stopper (like untiDocElem)
	@parentsUntil: (docElem, selector, untilDocElem) ->
		parentElem = CUI.DOM.parent(docElem)
		if not parentElem
			return []

		path = @elementsUntil(parentElem, null, untilDocElem)
		if not path?.length
			return []
		path

	# selector is a filter
	@parents: (docElem, selector, untilDocElem=document.documentElement) ->
		assert(docElem instanceof HTMLElement or docElem == document or docElem == window, "CUI.DOM.parents", "element needs to be instanceof HTMLElement, document, or window.", element: docElem)
		path = @parentsUntil(docElem, selector, untilDocElem)
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

		assert(docElem instanceof HTMLElement, "CUI.DOM.isInDOM", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		if @closestUntil(docElem, null, document.documentElement)
			true
		else
			false

	@replaceWith: (node, new_node) ->
		assert(node instanceof HTMLElement and new_node instanceof HTMLElement, "CUI.DOM.replaceWidth", "nodes need to be instanceof HTMLElement.", node: node, newNode: node)
		node.parentNode.replaceChild(new_node, node)

	@getRect: (docElem) ->
		docElem.getBoundingClientRect()

	@getComputedStyle: (docElem) ->
		window.getComputedStyle(docElem)

	@setStyle: (docElem, style, append="px") ->
		assert(docElem instanceof HTMLElement, "CUI.DOM.setStyle", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		for k, v of style
			switch v
				when "", null
					docElem.style[k] = ""
				else
					if isNaN(Number(v))
						docElem.style[k] = v
					else if v == 0 or v == "0"
						docElem.style[k] = 0
					else
						docElem.style[k] = v + append
		docElem

	@setStyleOne: (docElem, key, value) ->
		map = {}
		map[key] = value

		@setStyle(docElem, map)

	@setStylePx: (docElem, style) ->
		console.error("DOM.setStylePx is deprectaed, use DOM.setStyle.")
		@setStyle(docElem, style)

	@getRelativePosition: (docElem) ->
		assert(docElem instanceof HTMLElement, "CUI.DOM.getRelativePosition", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		dim = CUI.DOM.getDimensions(docElem)
		top: dim.offsetTopScrolled
		left: dim.offsetLeftScrolled

	@getDimensions: (docElem) ->
		if isNull(docElem)
			return null

		if docElem == window or docElem == document.documentElement
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

		dim.contentBoxWidth = rect.width - dim.borderHorizontal - dim.paddingHorizontal
		dim.contentBoxHeight = rect.height - dim.borderVertical - dim.paddingVertical
		dim.innerBoxWidth = rect.width - dim.borderHorizontal
		dim.innerBoxHeight = rect.height - dim.borderVertical
		dim.borderBoxWidth = rect.width
		dim.borderBoxHeight = rect.height
		dim.marginBoxWidth = rect.width + dim.marginHorizontal
		dim.marginBoxHeight = rect.height + dim.marginVertical

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


		if dim.scrollHeight > dim.clientHeight
			dim.hasVerticalScrollbar = true
			dim.verticalScrollbarWidth = dim.contentBoxWidth - dim.clientWidth
		else
			dim.verticalScrollbarWidth = 0

		if dim.scrollWidth > dim.clientWidth
			dim.hasHorizontalScrollbar = true
			dim.horizontalScrollbarHeight = dim.contentBoxHeight - dim.clientHeight
		else
			dim.horizontalScrollbarHeight = 0

		dim.hasScrollbar = dim.hasVerticalScrollbar or dim.hasHorizontalScrollbar
		dim.canHaveScrollbar = cs.overflowX in ["auto", "scroll"] or cs.overflowY in ["auto", "scroll"]
		dim.horizontalScrollbarAtStart = dim.scrollLeft == 0
		dim.horizontalScrollbarAtEnd = dim.scrollWidth - dim.scrollLeft - dim.clientWidth - dim.verticalScrollbarWidth < 1
		dim.verticalScrollbarAtStart = dim.scrollTop == 0
		dim.verticalScrollbarAtEnd = dim.scrollHeight - dim.scrollTop - dim.clientHeight - dim.horizontalScrollbarHeight < 1
		dim

	# returns the scrollable parent
	@parentsScrollable: (node) ->
		parents = []
		for parent, idx in DOM.parents(node)
			dim = DOM.getDimensions(parent)
			if dim.canHaveScrollbar
				parents.push(parent)
		parents

	@setDimension: (docElem, key, value) ->
		set = {}
		set[key] = value
		@setDimensions(docElem, set)

	@getDimension: (docElem, key) ->
		@getDimensions(docElem)[key]

	@setDimensions: (docElem, _dim) ->
		borderBox = @isBorderBox(docElem)
		css = {}
		dim = @getDimensions(docElem)
		set_dim = copyObject(_dim)

		cssFloat = {}
		set = (key, value) =>
			if isNull(value) or isNaN(value)
				return

			if not cssFloat.hasOwnProperty(key)
				if key in ["width", "height"] and value < 0
					value = 0

				cssFloat[key] = value
				return
			assert(cssFloat[key] == value, "DOM.setDimensions", "Unable to set contradicting values for #{key}.", docElem: docElem, dim: set_dim)
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

		assert(left_over_keys.length == 0, "DOM.setDimensions", "Unknown keys in dimension: \""+left_over_keys.join("\", \"")+"\".", docElem: docElem, dim: _dim)

		@setStyle(docElem, cssFloat)
		cssFloat

	@htmlToNodes: (html) ->
		d = @element("DIV")
		d.innerHTML = html
		d.childNodes


	# turns 14.813px into a float
	@getCSSFloatValue: (v) ->
		if v.indexOf("px") == -1
			return 0

		fl = parseFloat(v.substr(0, v.length-2))
		fl

	@isPositioned: (docElem) ->
		assert(docElem instanceof HTMLElement, "DOM.isPositioned", "docElem needs to be instance of HTMLElement.", docElem: docElem)
		if docElem == document.body or docElem == document.documentElement
			return true

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
		CUI.DOM.getBoxSizing() == "content-box"

	@hideElement: (docElem) ->
		if not docElem
			return
		if docElem.style.display != "none"
			docElem.__saved_display = docElem.style.display
		docElem.style.display = "none"
		docElem

	# remove all children from a DOM node (detach)
	@removeChildren: (docElem, filter) ->
		assert(docElem instanceof HTMLElement, "CUI.DOM.removeChildren", "element needs to be instance of HTMLElement", element: docElem)
		for child in @children(docElem, filter)
			docElem.removeChild(child)
		return docElem

	@showElement: (docElem) ->
		if not docElem
			return
		docElem.style.display = docElem.__saved_display or ""
		delete(docElem.__saved_display)
		docElem

	@element: (tagName, attrs={}) ->
		DOM.setAttributeMap(document.createElement(tagName), attrs)

	@scrollIntoView: (docElem) ->
		docElem.scrollIntoView()

	@setClassOnMousemove: (_opts={}) ->
		opts = CUI.Element.readOpts _opts, "DOM.setClassOnMousemove",
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
			if opts.delayRemove?() or window.globalDrag
				schedule_remove_mousemoved_class()
				return
			opts.element.classList.remove(opts.class)

		schedule_remove_mousemoved_class = =>
			CUI.scheduleCallback
				ms: opts.ms
				call: remove_mousemoved_class

		Events.listen
			node: opts.element
			type: "mousemove"
			instance: opts.instance
			call: (ev) =>
				if not opts.element.classList.contains(opts.class)
					opts.element.classList.add(opts.class)
				schedule_remove_mousemoved_class()
				return

	@requestFullscreen: (elem) ->
		assert(elem instanceof HTMLElement, "startFullscreen", "element needs to be instance of HTMLElement", element: elem)
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

		fsc_ev = Events.listen
			type: "fullscreenchange"
			node: window
			call: (ev) =>
				# console.debug "fullscreenchange caught...", ev, DOM.isFullscreen()
				if DOM.isFullscreen()
					dfr.notify()
				else
					Events.ignore(fsc_ev)
					dfr.resolve()
				return

		dfr.promise()

	@exitFullscreen: ->

		if document.exitFullscreen
			document.exitFullscreen()
		else if document.msExitFullscreen
			document.msExitFullscreen()
		else if (document.mozCancelFullScreen)
			document.mozCancelFullScreen()
		else if (document.webkitExitFullscreen)
			document.webkitExitFullscreen()
		return

	@fullscreenElement: ->
		document.fullscreenElement or
			document.webkitFullscreenElement or
			document.mozFullScreenElement or
			undefined

	@fullscreenEnabled: ->
		document.fullscreenEnabled or
			document.webkitFullscreenEnabled or
			document.mozFullScreenEnabled or
			false

	@isFullscreen: ->
		document.fullscreen or
			document.webkitIsFullScreen or
			document.mozFullScreen or
			false


DOM = CUI.DOM

