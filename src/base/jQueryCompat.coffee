###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# CUI jQueryCompat Layer
#

CUI.defaults.jQueryCompat = 2 # 0: off, 1: on, 2: as warnings, 3: as error, 4: ... with args

class CUI.jQueryCompat

	constructor: (input) ->
		if not input
			return CUI.jQueryCompat.__noopNode()

		if input instanceof Array or input instanceof NodeList or input instanceof HTMLCollection

			nodes = []
			for item in input
				assert(item instanceof Node, "jQueryCompat", "Wenn called with Array, only Nodes are supported.", item: item, input: input)
				nodes.push(CUI.jQueryCompat(item))

			nodes.last = =>
				CUI.jQueryCompat.__warn("last", nodes)
				if nodes.length == 0
					return CUI.jQueryCompat.__noopNode()

				nodes[nodes.length-1]

			nodes.first = =>
				CUI.jQueryCompat.__warn("first", nodes)
				if nodes.length == 0
					return CUI.jQueryCompat.__noopNode()

				nodes[0]

			# wrap functions for some into array
			for key in CUI.jQueryCompat.__noopKeys
				if key in ["0", "last", "first"]
					continue

				do (key) =>
					if key in [
						"css"
						"hide"
						"show"
						"remove"
						"pf_hide"
						"pf_show"
						"scrollIntoView"
						"addClass"
						"removeClass"
						"removeAttr"
						"detach"
					]
						nodes[key] = =>
							for node in nodes
								node[key].apply(node, arguments)
							return nodes

						return

					if key in [
						"attr"
					]
						nodes[key] = (prop, value) =>
							# only allow "set" on bulk
							if value != undefined
								for node in nodes
									node[key].apply(node, arguments)
								return nodes
							else
								return nodes[0]?.attr.apply(nodes[0], arguments)

						return

					if key in [
						"hasClass"
					]
						nodes[key] = =>
							for node in nodes
								has_class =	node[key].apply(node, arguments)
								if has_class
									return true

							return false

						return


					if key in [
						"find"
					]
						nodes[key] = =>
							if nodes.length == 0
								return nodes

							found_nodes = []
							for node in nodes
								found_nodes.push.apply(found_nodes, node.find.apply(node, arguments))
							return found_nodes

						return

					nodes[key] = =>
						console.error "Unsupported Function on jQuery Compat Array:", key

			return nodes

		if isString(input)
			nodes = CUI.DOM.matchSelector(document.documentElement, input)
			if nodes.length == 0
				return CUI.jQueryCompat.__noopNode()
			else if nodes.length == 1
				return CUI.jQueryCompat(nodes[0])
			else
				return CUI.jQueryCompat(nodes)

		return CUI.jQueryCompat.__wrapNode(input)

	@__warn: (prop, args...) =>
		if not CUI.defaults.jQueryCompat or
			CUI.defaults.jQueryCompat == 1
				return

		error_args = ["jQueryCompat: "+prop]

		if CUI.defaults.jQueryCompat >= 4
			error_args.push.apply(error_args, args)

		if CUI.defaults.jQueryCompat == 2
			console.warn.apply(console.warn, error_args)
		else
			console.error.apply(console.error, error_args)

	@__funcWraps: {}

	@__noopKeys: [
		"css"
		"text"
		"textContent"
		"closest"
		"outerHeight"
		"outerWidth"
		"rect"
		"offset"
		"cssInt"
		"cssFloat"
		"cssEdgeSpace"
		"hide"
		"show"
		"html"
		"val"
		"replaceWidth"
		"scrollIntoView"
		"empty"
		"append"
		"prepend"
		"appendTo"
		"remove"
		"parents"
		"removeAttr"
		"removeClass"
		"addClass"
		"hasClass"
		"is"
		"find"
		"before"
		"after"
		"attr"
		"last"
		"first"
		"relativePosition"
		"prop"
		"detach"
	]

	@__noopNode: ->
		node = CUI.DOM.element("DIV")

		Object.defineProperty node, "0",
			enumerable: true
			get: =>
				CUI.jQueryCompat.__warn("[0]", node)
				node
			set: =>
				throw new TypeError("jQueryCompat[0] unable to set value.")

		node.length = 0

		for key in @__noopKeys
			if key == "find"
				node[key] = =>
					@__warn(key, "Noop node.")
					return []

			node[key] = =>
				@__warn(key, "Noop node.")
				return

		return node


	@__wrapNode: (node) ->
		assert(node instanceof Node, "jQueryCompat", "Node needs to be instance of Node.", node: node)

		if not CUI.defaults.jQueryCompat
			return

		if node.__jQueryCompatNode__
			return node

		# we cannot provide (these are Functions in jQuery but properties in HTMLElements)
		#
		# offsetParent()
		# children()
		# outerHTML()

		node.__jQueryCompatNode__ = true

		Object.defineProperty node, "length",
			enumerable: false
			get: =>
				CUI.jQueryCompat.__warn(".length", node)
				if CUI.defaults.jQueryCompat > 1
					console.error("jQueryCompat: .length accessed on node. Returning 1.", node)
				return 1

			set: =>
				throw new TypeError("jQueryCompat[length] unable to set value.")

		Object.defineProperty node, "0",
			enumerable: true
			get: =>
				CUI.jQueryCompat.__warn("[0]", node)
				node
			set: =>
				throw new TypeError("jQueryCompat[0] unable to set value.")

		node.css = (style, value) =>
			CUI.jQueryCompat.__warn("css", node, style)
			if CUI.isPlainObject(style)
				CUI.DOM.setStyle(node, style)
			else if value == undefined
				CUI.DOM.getComputedStyle(node)[style]
			else
				CUI.DOM.setStyleOne(node, style, value)

		if node.nodeName not in ["BODY", "A"]
			node.text = (value) =>
				CUI.jQueryCompat.__warn("text", node)
				if isEmpty(value)
					return node.textContent

				node.textContent = value
				node

		if not node.remove
			# IE does not implement "remove"
			node.remove = =>
				CUI.jQueryCompat.__warn("remove", node)
				CUI.DOM.remove(node)

		node.parent = =>
			CUI.jQueryCompat.__warn("parent", node)
			parent = node.parentNode
			if not parent
				return CUI.jQueryCompat.__noopNode()
			return CUI.jQueryCompat(parent)

		node.last = =>
			CUI.jQueryCompat.__warn("last", node)
			return node

		node.first = =>
			CUI.jQueryCompat.__warn("first", node)
			return node

		node.closest = (selector) =>
			CUI.jQueryCompat(CUI.DOM.closest(node, selector))

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
			CUI.jQueryCompat.__warn("rect", node)
			CUI.DOM.getRect(node)

		node.offset = =>
			CUI.jQueryCompat.__warn("offset", node)
			rect = CUI.DOM.getRect(node)
			top: rect.top
			left: rect.left

		node.cssInt = (prop, check=true) =>
			CUI.jQueryCompat.__warn("cssInt", node)
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
			CUI.jQueryCompat.__warn("cssFloat", node)
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
			CUI.jQueryCompat.__warn("cssEdgeSpace", node)
			dim = CUI.DOM.getDimensions(node)

			keys = ["border", "padding"]
			if includeMargin
				keys.push("margin")

			value = 0
			access = toCamel(dir, true)
			for key in keys
				value = value + dim[key+access]

			return value

		node.hide = ->
			CUI.DOM.hideElement(node)

		node.show = ->
			CUI.DOM.showElement(node)

		node.html = (value) ->
			CUI.jQueryCompat.__warn("html", node, value)
			if value == undefined
				node.innerHTML
			else
				node.innerHTML = value
			node

		if node.nodeName in ["INPUT"]
			node.val = (value) ->
				CUI.jQueryCompat.__warn("val", node)
				if value == undefined
					return node.value
				else
					node.value = value

		node.replaceWith = (new_node) ->
			CUI.jQueryCompat.__warn("replaceWith", node, new_node)
			CUI.DOM.replaceWith(node, new_node)

		node.empty = ->
			CUI.jQueryCompat.__warn("empty", node)
			CUI.DOM.empty(node)

		node.append = (content, more_content...) ->
			CUI.jQueryCompat.__warn("append", node, content)
			if isString(content) and content.trim().startsWith("<") and content.indexOf(">") > -1
				console.error("jQueryCompat.append: Unable to append HTML. Use CUI.DOM.htmlToNodes(...). Possible HTML: ", content)
			CUI.DOM.append(node, content)
			if more_content.length > 0
				console.warn("jQueryCompat.append: Multiple parameters are deprecated.", more_content: more_content)
				CUI.DOM.append(node, more_content)
			node

		node.prepend = (content) ->
			CUI.jQueryCompat.__warn("prepend", node, content)
			CUI.DOM.prepend(node, content)

		node.appendTo = (node_appendTo) ->
			CUI.jQueryCompat.__warn("appendTo", node, node_appendTo)
			CUI.DOM.append(node_appendTo, node)
			node

		node.prependTo = (node_prependTo) ->
			CUI.jQueryCompat.__warn("prependTo", node, node_prependTo)
			CUI.DOM.prepend(node_prependTo, node)
			node

		node.parents = (selector) ->
			CUI.jQueryCompat.__warn("parents", node, selector)
			CUI.jQueryCompat(CUI.DOM.parents(node, selector))

		node.removeAttr = (attr) ->
			CUI.DOM.removeAttribute(node, attr)

		if node.nodeName in ["DIV"]
			node.width = (value) ->
				CUI.jQueryCompat.__warn("width", node, value)
				DOM.width(node, value)

			node.height = (value) ->
				CUI.jQueryCompat.__warn("height", node, value)
				DOM.height(node, value)

		node.removeClass = (cls) ->
			CUI.jQueryCompat.__warn("removeClass", node)
			CUI.DOM.removeClass(node, cls)

		node.addClass = (cls) ->
			CUI.jQueryCompat.__warn("addClass", node, cls)
			CUI.DOM.addClass(node, cls)

		node.hasClass = (cls) ->
			CUI.jQueryCompat.__warn("hasClass", node, cls)
			CUI.DOM.hasClass(node, cls)

		node.is = (selector) ->
			CUI.jQueryCompat.__warn("is", node, selector)
			CUI.DOM.is(node, selector)

		node.find = (selector) ->
			CUI.jQueryCompat.__warn("find", node)
			CUI.jQueryCompat(CUI.DOM.matchSelector(node, selector))

		node.before = (node_before) ->
			CUI.DOM.insertBefore(node, node_before)

		node.after = (node_after) ->
			CUI.DOM.insertAfter(node, node_after)

		node.attr = (prop, value) ->
			CUI.jQueryCompat.__warn("attr|prop", node, prop, value)
			if CUI.isPlainObject(prop)
				CUI.DOM.setAttributeMap(node, prop)
			else if value == undefined
				CUI.DOM.getAttribute(node, prop)
			else
				CUI.DOM.setAttribute(node, prop, value)

		node.relativePosition = ->
			CUI.DOM.getRelativePosition(node)

		node.prop = node.attr

		node.pf_hide = ->
			CUI.jQueryCompat.__warn("pf_hide", node)
			CUI.DOM.hideElement(node)

		node.pf_show = ->
			CUI.jQueryCompat.__warn("pf_show", node)
			CUI.DOM.showElement(node)

		node.detach = ->
			CUI.jQueryCompat.__warn("detach", node)
			node.remove()

		node


	@isPlainObject: (obj) ->
		CUI.jQueryCompat.__warn("isPlainObject")
		CUI.isPlainObject(obj)

	@isEmptyObject: (obj) ->
		CUI.jQueryCompat.__warn("isEmptyObject")
		CUI.isEmptyObject(obj)

	@isFunction: (obj) ->
		CUI.jQueryCompat.__warn("isFunction")
		CUI.isFunction(obj)

	@isArray: (obj) ->
		CUI.jQueryCompat.__warn("isArray")
		CUI.isArray(obj)

	@inArray: (value, arr) ->
		arr.indexOf(value)

	@each: (obj, callback) ->
		if CUI.isArray(obj)
			for item, idx in obj
				callback(idx, item)
			return

		if CUI.isPlainObject(obj)
			for key, value of obj
				callback(key, value)
			return

		assert(false, "jQueryCompat.each: obj needs to be Array or Map.", obj: obj)


class CUI.jQuery extends CUI.jQueryCompat
	constructor: (input) ->
		CUI.jQueryCompat.__warn("jQuery|$", input)
		return super(input)

