jQueryWarn = (prop, args...) =>
	if not CUI.defaults.jQueryCompatWarningLevel
		return

	error_args = ["jQueryCompat: "+prop]

	if CUI.defaults.jQueryCompatWarningLevel > 1
		error_args.push.apply(error_args, args)

	if CUI.defaults.jQueryCompatWarningLevel == 1
		console.warn.apply(console.warn, error_args)
	else
		console.error.apply(console.error, error_args)

jQuery = (input) ->
	jQueryWarn("jQuery|$", input)
	if isString(input)
		nodes = []
		for node in CUI.DOM.matchSelector(document.documentElement, input)
			nodes.push(jQueryNode(node))
		nodes
	else
		jQueryNode(input)

jQuery.isPlainObject = (obj) ->
	jQueryWarn("$.isPlainObject")
	CUI.isPlainObject(obj)

jQuery.isEmptyObject = (obj) ->
	jQueryWarn("$.isEmptyObject")
	CUI.isEmptyObject(obj)

jQuery.isFunction = (obj) ->
	jQueryWarn("$.isFunction")
	CUI.isFunction(obj)

jQuery.isArray = (obj) ->
	jQueryWarn("$.isArray")
	CUI.isArray(obj)

$ = jQuery


# turns a DOM node in something a little jQuery compatible
jQueryNode = (node) =>
	assert(node instanceof HTMLElement, "jQueryCompat", "Node needs to be instance of HTMLElement.", node: node)

	if node.__jQueryCompatNode__
		return node

	node.__jQueryCompatNode__ = true

	Object.defineProperty node, "0",
		enumerable: true
		get: =>
			jQueryWarn("[0]", node)
			node
		set: =>
			throw new TypeError("jQueryCompat[0] unable to set value.")

	node.css = (style, value) =>
		jQueryWarn("css", node, style)
		if CUI.isPlainObject(style)
			CUI.DOM.setStyle(node, style)
		else if value == undefined
			CUI.DOM.getComputedStyle(node)[style]
		else
			CUI.DOM.setStyleOne(node, style, value)

	if node.nodeName not in ["BODY", "A"]

		node.text = (value) =>
			jQueryWarn("text", node)
			node.textContent = value
			node

	node.outerHeight = (includeMargin = false) =>
		if includeMargin
			CUI.DOM.getDimensions(node).marginBoxHeight
		else
			CUI.DOM.getDimensions(node).borderBoxHeight

	node.outerWidth = (includeMargin = false) =>
		if includeMargin
			CUI.DOM.getDimensions(node).marginBoxWidth
		else
			CUI.DOM.getDimensions(node).borderBoxWidth

	node.rect = =>
		jQueryWarn("rect", node)
		CUI.DOM.getRect(node)

	node.offset = =>
		jQueryWarn("offset", node)
		rect = CUI.DOM.getRect(node)
		top: rect.top
		left: rect.left

	node.cssInt = (prop, check=true) =>
		jQueryWarn("cssInt", node)
		s = CUI.DOM.getComputedStyle(node)[prop]
		if s == undefined or s == ""
			return 0
		assert(not check or s.match(/px$/), "cssInt", "css(\"#{prop}\") did not return \"px\" but \"#{s}\".")
		i = parseInt(s)
		if isNaN(i)
			return 0
		else
			return i


	node.cssFloat = (prop, check=true) =>
		jQueryWarn("cssFloat", node)
		s = CUI.DOM.getComputedStyle(node)[prop]
		if s == undefined or s == ""
			return 0
		assert(not check or s.match(/px$/), "cssFloat", "css(\"#{prop}\") did not return \"px\" but \"#{s}\".")
		i = parseFloat(s)
		if isNaN(i)
			return 0
		else
			return i

	node.cssEdgeSpace = (dir, includeMargin=false) ->
		jQueryWarn("cssEdgeSpace", node)
		dim = CUI.DOM.getDimensions(node)

		keys = ["border", "padding"]
		if includeMargin
			keys.push("margin")

		value = 0
		access = toCamel(dir, true)
		for key in keys
			value = value + dim[key+access]

		return value

	# we cannot provide (these are Functions in jQuery but properties in HTMLElements)
	#
	# offsetParent()
	# children()
	# closest()

	node.html = (value) ->
		jQueryWarn("html", node, value)
		if value == undefined
			node.innerHTML
		else
			node.innerHTML = value
		node

	node.empty = ->
		jQueryWarn("append", node)
		CUI.DOM.empty(node)

	node.append = (args...) ->
		args.splice(0, 0, node)
		jQueryWarn("append", node, args)
		CUI.DOM.append.apply(CUI.DOM, args)

	node.prepend = (args...) ->
		args.splice(0, 0, node)
		jQueryWarn("prepend", node, args)
		CUI.DOM.prepend.apply(CUI.DOM, args)

	node.appendTo = (node_appendTo) ->
		jQueryWarn("appendTo", node, node_appendTo)
		node_appendTo.appendChild(node)

	node.parents = (selector) ->
		jQueryWarn("parents", node, selector)
		CUI.DOM.parents(node, selector)

	if node.nodeName in ["DIV"]

		node.width = (value) ->
			jQueryWarn("width", node, value)
			DOM.width(node, value)

		node.height = (value) ->
			jQueryWarn("height", node, value)
			DOM.height(node, value)

	node.removeClass = (cls) ->
		jQueryWarn("removeClass", node)
		CUI.DOM.removeClass(node, cls)

	node.addClass = (cls) ->
		jQueryWarn("addClass", node, cls)
		CUI.DOM.addClass(node, cls)

	node.hasClass = (cls) ->
		jQueryWarn("hasClass", node, cls)
		CUI.DOM.hasClass(node, cls)

	node.is = (selector) ->
		jQueryWarn("is", node, selector)
		CUI.DOM.is(node, selector)

	node.find = (selector) ->
		jQueryWarn("find", node)
		CUI.DOM.matchSelector(node, selector)

	node.before = (node_before) ->
		node.parentNode.insertBefore(node_before, node)

	node.after = (node_after) ->
		node.parentNode.insertBefore(node_after, node.nextElementSibling)

	node.attr = (prop, value) ->
		jQueryWarn("attr|prop", node, prop, value)
		if CUI.isPlainObject(prop)
			CUI.DOM.setAttributeMap(node, prop)
		else if value == undefined
			CUI.DOM.getAttribute(node, prop)
		else
			CUI.DOM.setAttribute(node, prop, value)

	node.relativePosition = ->
		CUI.DOM.getRelativePosition(node)

	node.prop = node.attr

	node.detach = ->
		jQueryWarn("detach", node)
		node.remove()

	node

