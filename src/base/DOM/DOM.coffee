class CUI.DOM extends Element
	constructor: (@opts={}) ->
		super(@opts)
		@DOM = null

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
		return "cui-dom-element ez-#{toDash(@__cls)} cui-#{toDash(@__cls)}"

	registerDOMElement: (_dom) ->
		@DOM = _dom
		DOM.addClass(@DOM[0], @getDOMElementClasses())
		@DOM.attr("cui-unique-id", @getUniqueId())
		if @_class
			# CUI.debug DOM, @DOM, @_class
			DOM.addClass(@DOM[0], @_class) # @DOM.addClass(@_class)
		DOM.setElement(@DOM, @, @_dummy)
		@

	unregisterDOMElement: (@DOM) ->
		@DOM.removeClass(@getDOMElementClasses())
		@DOM.removeAttr("cui-unique-id")
		if @_class
			@DOM.removeClass(@_class)
		DOM.removeData(@DOM[0], "element")
		@

	assertDOMElement: (func) ->
		assert(@DOM, "#{@__cls}.#{func}", "registerDOMElement needs to be called before \"#{func}\" is supported.")

	assertTemplateElement: (func) ->
		assert(@__template, "#{@__cls}.#{func}", "registerTemplateElement needs to be called before \"#{func}\" is supported.")

	addClass: ->
		@assertDOMElement("addClass")
		@DOM.addClass.apply(@DOM, arguments)

	removeClass: ->
		@assertDOMElement("removeClass")
		@DOM.removeClass.apply(@DOM, arguments)

	hasClass:  ->
		@assertDOMElement("hasClass")
		@DOM.hasClass.apply(@DOM, arguments)

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
			DOM.empty(@DOM)
			@DOM.remove()
		@
		# Events.ignore(node: @DOM)


	@setElement: (element, inst, dummy) ->
		DOM.data(element[0], "element", inst)


	@data: (node, key, data) ->
		if not node
			return undefined

		assert(node instanceof HTMLElement, "DOM.data","node needs to be instance of HTMLElement", node: node)

		if key == undefined
			return node.__dom_data

		if $.isPlainObject(key)
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
			if $.isEmptyObject(node.__dom_data)
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

			child = node.nextElementSibling
			if not child
				return null


	@lastElementChild: (node, nodeFilter) ->
		child = node.lastElementChild
		while true
			if not nodeFilter or nodeFilter(child)
				return child

			child = node.previousElementSibling
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

	@setAttribute: (node, key, value=key) ->
		node.setAttribute(key, value)
		node

	@hasAttribute: (node, key) ->
		node.hasAttribute(key)

	@setAttributeMap: (node, map) ->
		for key, value of map
			DOM.setAttribute(node, key, value)
		node

	@getCUIElementById: (uniqueId) ->
		dom_el = DOM.matchSelector(document.documentElement, "[cui-unique-id=\"cui-element-"+uniqueId+"\"]")[0]
		if not dom_el
			return null
		DOM.data(dom_el, "element")

	@getAttribute: (node, key) ->
		node.getAttribute(key)

	@empty: (element) ->
		assert(isElement(element), "DOM.empty", "top needs to be jQuery Element", element: element)
		DOM.destroy(element[0], true)
		element.empty()


	@remove: (element) ->
		# assert(isElement(element), "DOM.empty", "top needs to be jQuery Element", element: element)
		@destroy(element[0])
		element.remove()
		@

	@destroy: (element, childrenOnly=false) ->
		return
		assert(element instanceof HTMLElement, "DOM.destroy", "top needs to be HTMLElement", element: element)

		$element = $(element)
		if $element.closest("[destroy-in-progress]").length > 0
			# CUI.error("DOM.destroyChildren: loop call, avoid loop")
			return
		$element.attr("destroy-in-progress", 1)
		DOM.destroyElements(CUI.DOM.matchSelector(element, ".cui-dom-element,.cui-events-listener-element"))
		if not childrenOnly
			DOM.destroyElements([element])
		$element.removeAttr("destroy-in-progress")
		@

	@destroyElements: (dom_els) ->
		destroy_els = []
		for dom_el in dom_els
			listeners = DOM.data(dom_el, "listeners")
			if listeners?.length > 0
				while listeners.length > 0
					listener = listeners.shift()
					listener.destroy()

			_el = DOM.data(dom_el, "element")
			if not _el
				continue

			assert(_el instanceof Element, "DOM.destroyChildren", "Element found is not instance of DOM.", element: _el)
			destroy_els.push(_el)

		for _el in destroy_els
			if not _el.isDestroyed()
				# CUI.debug "destroy", getObjectClass(_el), _el
				_el.destroy()
		@

	# checks if any of the classes are set
	@hasClass: (element, cls) ->
		for _cls in cls.trim().split(/\s+/)
			if element.classList.contains(_cls)
				return true
		return false

	@addClass: (element, cls) ->
		for _cls in cls.trim().split(/\s+/)
			element.classList.add(_cls)
		element

	@removeClass: (element, cls) ->
		for _cls in cls.trim().split(/\s+/)
			element.classList.remove(_cls)
		element

	# sets the absolute position of an element
	@setAbsolutePosition: (element, offset) ->
		assert(isElement(element), "DOM.setAbsolutePosition", "element needs to be a jQuery element", element: element, offset: offset)
		assert(isNumber(offset?.left) and isNumber(offset?.top), "DOM.setAbsolutePosition", "offset.left and offset.top must be >= 0", element: element, offset: offset)
		# the offset needs to be corrected by the parent offset
		# of our DOM element
		offsetParent = element.offsetParent()

		if offsetParent.is("html")
			layer_parent_offset =
				top: 0
				left: 0

			correct_offset =
				top: document.body.scrollTop
				left: document.body.scrollLeft
		else
			rect = offsetParent.rect()
			layer_parent_offset =
				top: rect.top
				left: rect.left

			# position: relative/absolute anchor
			# is the point between padding and border,
			# we need to adjust this to the border
			layer_parent_offset.top += offsetParent.cssInt("border-top-width")
			layer_parent_offset.left += offsetParent.cssInt("border-left-width")

			correct_offset =
				top: offsetParent[0].scrollTop
				left: offsetParent[0].scrollLeft

		element.css
			top: offset.top - layer_parent_offset.top + correct_offset.top
			left: offset.left - layer_parent_offset.left + correct_offset.left
		@

	@__failedDOMInserts = 0

	@waitForDOMInsert: (_opts) ->

		opts = Element.readOpts _opts, "DOM.waitForDOMInsert",
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


	@isJQueryElement: (el) ->
		el instanceof jQuery and el.length == 1


	@getNode: (node) ->
		if DOM.isJQueryElement(node)
			node[0]
		else if node.DOM and node != window
			node.DOM[0]
		else
			node

	# small experiment, testing...
	@printElement: (_opts) ->
		opts = Element.readOpts _opts, "DOM.printElement",
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
			DOM.isJQueryElement(node) or
			node.DOM
				true
		else
			false

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
		sel_func = CUI.isFunction(selector)

		assert(docElem instanceof HTMLElement or docElem == document or docElem == window, "CUI.DOM.elementsUntil", "docElem needs to be instanceof HTMLElement.", docElem: docElem, selector: selector, untilDocElem: untilDocElem)
		testDocElem = docElem
		path = [testDocElem]
		while true
			if selector
				if sel_func
					if selector(testDocElem)
						return path
				else if testDocElem != document and testDocElem != window
					# CUI.error testDocElem, selector
					if testDocElem[@matchFunc](selector)
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
		@closestUntil(docElem, selector)

	@closestUntil: (docElem, selector, untilDocElem) ->
		path = @elementsUntil(docElem, selector, untilDocElem)
		if not path or path.length == 0
			return null

		last_element = path[path.length-1]
		if last_element == window and untilDocElem != last_element
			return null

		last_element


	@parentsUntil: (docElem, selector, untilDocElem) ->
		parentElem = DOM.parent(docElem)
		if not parentElem
			return []
		path = @elementsUntil(parentElem, selector, untilDocElem)
		if not path
			[]
		else
			path

	@parents: (docElem, selector) ->
		@parentsUntil(docElem, selector)

	@preventEvent: (docElem, type) ->
		# CUI.debug "DOM.preventEvent on element:", docElem, type
		if not docElem.__cui_prevent_event
			docElem.__cui_prevent_event = {}

		docElem.__cui_prevent_event[type] = true
		@

	@unpreventEvent: (event) ->
		docElem = event.getCurrentTarget()
		type = event.getType()
		# CUI.debug "unprevent event...", event, docElem, docElem.__cui_prevent_event, type
		if not docElem.__cui_prevent_event
			return
		delete(docElem.__cui_prevent_event[type])
		if $.isEmptyObject(docElem.__cui_prevent_event)
			delete(docElem.__cui_prevent_event)
		@

	@isEventPrevented: (event) ->
		docElem = event.getCurrentTarget()
		# if event.getType() == "click"
		# 	CUI.debug "is event prevented?", event, docElem, docElem.__cui_prevent_event
		if not docElem
			return false
		else if not docElem.__cui_prevent_event
			false
		else if docElem.__cui_prevent_event[event.getType()]
			true
		else
			false

	@isInDOM: (docElem) ->
		assert(docElem instanceof HTMLElement, "CUI.DOM.isInDOM", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		if @closestUntil(docElem, null, document.documentElement)
			true
		else
			false

	@getRect: (docElem) ->
		docElem.getBoundingClientRect()

	@getComputedStyle: (docElem) ->
		window.getComputedStyle(docElem)

	@setStyle: (docElem, style, append="") ->
		assert(docElem instanceof HTMLElement, "CUI.DOM.setStyle", "docElem needs to be instanceof HTMLElement.", docElem: docElem)
		for k, v of style
			switch v
				when "", null
					docElem.style[k] = ""
				else
					if isNaN(parseFloat(v))
						docElem.style[k] = v
					else
						docElem.style[k] = v + append
		@

	@setStyleOne: (docElem, key, value) ->
		map = {}
		map[key] = value

		@setStyle(docElem, map)

	@setStylePx: (docElem, style) ->
		@setStyle(docElem, style, "px")

	@getDimensions: (docElem) ->
		if isNull(docElem)
			return null

		cs = @getComputedStyle(docElem)
		rect = @getRect(docElem)

		dim = {}
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
		dim.borderBoxWidth = rect.width
		dim.borderBoxHeight = rect.height
		dim.marginBoxWidth = rect.width + dim.marginHorizontal
		dim.marginBoxHeight = rect.height + dim.marginVertical

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
			dim.verticalScrollbarWidth = dim.contentBoxWidth - dim.clientWidth
		else
			dim.verticalScrollbarWidth = 0

		if dim.scrollWidth > dim.clientWidth
			dim.horizontalScrollbarHeight = dim.contentBoxHeight - dim.clientHeight
		else
			dim.horizontalScrollbarHeight = 0

		dim

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
				set("height", set_dim.marginBoxHeight - dim.marginVertical - dim.paddingHorizontal - dim.borderHorizontal)

			delete(set_dim.marginBoxHeight)

		left_over_keys = Object.keys(set_dim)

		assert(left_over_keys.length == 0, "DOM.setDimensions", "Unknown keys in dimension: \""+left_over_keys.join("\", \"")+"\".", docElem: docElem, dim: _dim)

		@setStylePx(docElem, cssFloat)
		cssFloat




	# turns 14.813px into a float
	@getCSSFloatValue: (v) ->
		if v.indexOf("px") == -1
			return 0

		fl = parseFloat(v.substr(0, v.length-2))
		fl

	@isPositioned: (docElem) ->
		if docElem == document.body
			return true

		if docElem == document.documentElement or docElem == document or docElem == window
			assert(false, "DOM.isPositioned", "docElem needs to be at least document.body.", docElem: docElem)

		@getComputedStyle(docElem).position in ["relative", "absolute", "fixed"]

	@isVisible: (docElem) ->
		style = @getComputedStyle(docElem)
		if style.visibility == "hidden" or style.display == "none"
			false
		else
			true

	@getBoxSizing: (docElem) ->
		@getComputedStyle(docElem).boxSizing

	@isBorderBox: (docElem) ->
		@getBoxSizing(docElem) == "border-box"

	@isContentBox: (docElem) ->
		CUI.DOM.getBoxSizing() == "content-box"

	@hideElement: (docElem) ->
		if docElem.style.display != "none"
			docElem.__saved_display = docElem.style.display
		docElem.style.display = "none"

	@showElement: (docElem) ->
		docElem.style.display = docElem.__saved_display or ""
		delete(docElem.__saved_display)

	@element: (tagName, attrs={}) ->
		DOM.setAttributeMap(document.createElement(tagName), attrs)

	@scrollIntoView: (docElem) ->
		docElem.scrollIntoView()

	@setClassOnMousemove: (_opts={}) ->
		opts = Element.readOpts _opts, "DOM.setClassOnMousemove",
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

