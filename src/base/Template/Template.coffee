###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# Template needs to be called like this:
#
# new CUI.Template
#    name: "name-of-template"  // a .cui-tmpl.cui-tmpl-name-of-template has to exist in the DOM tree
#    map:
#       key: selector    // selector can be "true", than key is used like ".key", "_" is replaced by "-"
#    layout:
#       key: opts        // key is the name of layout looked for, selector is assumed "true", opts are the
#                        // opts passed to the layout
#
# when inserted into the DOM, the template initializes all containing
# layouts
#
# Template.map
# Template.obj: the actual DOM element
#

class CUI.Template extends CUI.Element
	constructor: (opts) ->
		super(opts)

		#try find it inside cached list
		node = CUI.Template.nodeByName[@_name]
		CUI.util.assert(node, "CUI.Template", @_name+" not found. Make sure to call Template.loadFile(...).")

		@DOM = node.cloneNode(true)
		if @_class
			CUI.dom.addClass(@DOM, @_class)

		if @_attr
			CUI.dom.setAttributeMap(@DOM, @_attr)

		# map elements which require mapping
		@map = @getElMap(@_map)

		@__updateTemplateEmpty()

		if @_init_flex_handles
			@initFlexHandles()

		return

	initOpts: ->
		super()
		@addOpts
			name:
				mandatory: true
				check: String
			map_prefix:
				check: String
			init_flex_handles:
				mandatory: true
				default: false
				check: Boolean
			map:
				type: "PlainObject"
				default: {}
			class:
				check: String
			attr:
				check: "PlainObject"
		@


	initFlexHandles: (pane_opts={}) ->
		# init any flex handles find in the markup
		@__flexHandles = {}
		# txt = "Template.initFlexHandles[name=#{@_name}]"
		# console.time(txt)

		for fh_el in CUI.dom.matchSelector(@DOM, "[data-cui-flex-handle]")
			opts = @readOptsFromAttr(CUI.dom.getAttribute(fh_el, "data-cui-flex-handle"))
			if pane_opts[opts.name]
				# merge opts
				for k,v of pane_opts[opts.name]
					if not opts.hasOwnProperty(k)
						opts[k] = v
			else
				opts.manage_state = false

			opts.element = fh_el
			fh = new CUI.FlexHandle(opts)
			if not CUI.util.isEmpty(fh_name = fh.getName())
				# console.warn("Template.initFlexHandles", fh_name)
				@__flexHandles[fh_name] = fh
				fh.init()
		# console.timeEnd(txt)
		@

	getFlexHandle: (name) ->
		CUI.util.assert(@__flexHandles, "Template.getFlexHandle", "flexHandles are not initialized yet, call Template.initFlexHandles(opts) first.", name: name)
		fh = @__flexHandles[name]
		CUI.util.assert(fh instanceof CUI.FlexHandle, "#{@__cls}.getFlexHandle", "FlexHandle \"#{name}\" not found, make sure you have specified a name in the cui-flex-handle attribute.", opts: @opts, flexHandles: @__flexHandles)
		fh

	getFlexHandles: ->
		@__flexHandles

	getElMap: (map) ->
		el_map = {}
		report = []
		misses = 0
		for k, v of map
			if CUI.util.isNull(v)
				continue

			if v == true
				clean_k = k.replace(/_/g, "-")
				if @_map_prefix
					sel = "."+@_map_prefix+"-"+clean_k
				else
					prefix = CUI.util.toDash(@_name)
					sel = ".ez-"+prefix+"-"+clean_k+",.cui-"+prefix+"-"+clean_k
				sel = sel + ',[data-slot="'+CUI.escapeAttribute(k)+'"]'
			else
				sel = v

			map_obj = CUI.dom.matchSelector(@DOM, sel, true)

			if map_obj.length == 0
				report.push("* #{k}: not found (#{sel})")
				misses++
			else if map_obj.length > 1
				console.debug(k, v, "found more than once", map_obj, @DOM)
				report.push("* #{k}: found more than once (#{sel})")
				misses++
			else
				report.push("+ #{k}: found")
				el_map[k] = map_obj[0]
				# CUI.dom.addClass(el_map[k], "cui-template-empty")

				map_obj[0].removeAttribute("data-slot")

				do (k) =>
					el_map[k].empty = =>
						@empty(k)
						el_map[k]
					el_map[k].append = (value) =>
						@append(value, k)
						el_map[k]
					el_map[k].prepend = (value) =>
						@prepend(value, k)
						el_map[k]

		if misses
			CUI.util.assert(false, "Not all required elements were found for Template:\n\n\"#{@_name}\"\n\n"+report.join("\n"))

		el_map

	destroy: ->
		# console.error "destroying...", CUI.util.getObjectClass(DOM.data(@DOM, "element")), CUI.util.getObjectClass(@DOM[0])
		CUI.dom.remove(@DOM)
		delete(@map)
		super()

	addClass: (cls, key) ->
		if key
			CUI.util.assert(@map[key], "#{@__cls}.addClass", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
			CUI.dom.addClass(@map[key], cls)
		else
			CUI.dom.addClass(@DOM, cls)

	removeClass: (cls, key) ->
		if key
			CUI.util.assert(@map[key], "#{@__cls}.removeClass", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
			CUI.dom.removeClass(@map[key], cls)
		else
			CUI.dom.removeClass(@DOM, cls)

	hasClass: (cls, key) ->
		if key
			CUI.util.assert(@map[key], "#{@__cls}.hasClass", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
			CUI.dom.hasClass(@map[key], cls)
		else
			CUI.dom.hasClass(@DOM, cls)

	has: (key) ->
		!!@map[key]

	hide: (key) ->
		if not key
			CUI.dom.hideElement(@DOM)
		else
			CUI.dom.hideElement(@map[key])

	show: (key) ->
		if not key
			CUI.dom.showElement(@DOM)
		else
			CUI.dom.showElement(@map[key])

	__updateTemplateEmpty: ->

		if CUI.util.isEmptyObject(@map)
			is_empty = @isEmpty()
		else
			is_empty = true
			for key of @map
				if not @isEmpty(key)
					is_empty = false
					break

		if is_empty
			CUI.dom.addClass(@DOM, "cui-template-empty")
		else
			CUI.dom.removeClass(@DOM, "cui-template-empty")

		return

	replace: (value, key, element) ->
		CUI.util.assert(@map, "Template[#{@_name}].replace [#{@getUniqueId()}]", "Already destroyed")
		if key
			CUI.util.assert(@map[key], "#{@__cls}.replace", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
		@__empty(key)
		node = @__append(value, key, element)
		@__updateTemplateEmpty()
		return node

	text: (value, key, element) ->
		CUI.util.assert(CUI.util.isString(value), "#{@__cls}.text", "Value must be String", value: value, key: key, element: element)
		if key
			@map[key].textContent = value
		else
			@DOM.textContent = value

		@__updateTemplateEmpty()
		return

	prepend: (value, key, element) ->
		node = @__append(value, key, element, true)
		@__updateTemplateEmpty()
		return node

	append: (value, key, element) ->
		node = @__append(value, key, element, false)
		@__updateTemplateEmpty()
		return node

	empty: (key) ->
		node = @__empty(key)
		@__updateTemplateEmpty()
		return node

	__empty: (key) ->
		CUI.util.assert(@map, "Template[#{@_name}].empty [#{@getUniqueId()}]", "Already destroyed", template: @, name: @_name)
		if @isEmpty(key)
			if key
				return @map[key]
			else
				return @DOM

		if key
			CUI.util.assert(@map[key], "#{@__cls}.empty", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map)
			# console.debug "Template.destroyingChildren", key, @map[key]
			CUI.dom.empty(@map[key])
			return @map[key]

		if CUI.util.isEmptyObject(@map)
			# without map we empty the whole @DOM
			CUI.dom.empty(@DOM)
		else
			# with map we empty each individual map entry
			for key of @map
				CUI.dom.empty(@map[key])

		return @DOM

	__append: (value, key, element, prepend) ->
		if prepend
			fn = "prepend"
		else
			fn = "append"

		CUI.util.assert(@map, "Template[#{@_name}].#{fn} [#{@getUniqueId()}]", "Already destroyed")
		if key
			CUI.util.assert(@map[key], "#{@__cls}.#{fn}", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map)

		if CUI.util.isFunction(value)
			value = value(element)

		if not CUI.util.isArray(value)
			value = [value]

		appends = []
		for _value in value
			if _value?.DOM
				appends.push(_value.DOM)
			else
				CUI.util.assert(not CUI.util.isPromise(_value), "Template.append", "value cannot be Promise", value: value)
				if _value
					appends.push(_value)

		if key
			node = @map[key]
		else
			node = @DOM

		if appends.length > 0
			CUI.dom[fn](node, appends)

		node

	get: (key) ->
		CUI.util.assert(@map[key], "#{@__cls}.get", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
		return @map[key]

	isEmpty: (key) ->
		if not key
			return !@DOM.firstChild

		CUI.util.assert(@map[key], "#{@__cls}.isEmpty", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map)
		return !@map[key].firstChild

	removeEmptySlots: ->
		for key, node of @map
			if not node.firstChild
				CUI.dom.remove(node)
		@

	@nodeByName: {}

	@loadTemplateFile: (filename) ->
		@loadFile(filename, true)

	@loadTemplateText: (html) ->
		@__appendContent(html, true)

	@loadText: (text) ->
		@__appendContent(text, false)

	@loadFile: (filename, load_templates = false) ->
		if filename.match("^(https://|http://|/)")
			p = filename
		else
			p = CUI.getPathToScript()+filename

		new CUI.XHR
			url: p
			responseType: "text"
		.start()
		.done (data) =>
			@__appendContent(data, load_templates)
			return
		.fail (xhr) ->
			console.error("Template.loadFile: Unable to load filename: \"#{filename}\", see Console for more details. You can however, output easydbui.html manually before loading easydbui.js.", xhr)

	@load: (start_element = document.documentElement) ->
		count = 0
		for el in CUI.dom.matchSelector(start_element, ".cui-tmpl,[data-template]")
			name = null

			name = el.getAttribute("data-template")

			if CUI.util.isEmpty(name)
				for cls in el.classList
					if cls.startsWith("cui-tmpl-")
						name = cls.substr(9)
						if CUI.Template.nodeByName[name]
							console.error("Template.load:", name, "already found in DOM tree. Make sure all elements exists only once.", el)
							continue
						break

			if name
				# console.debug("Template: ", name)
				CUI.Template.nodeByName[name] = el
				CUI.dom.remove(el)
				el.classList.remove("cui-tmpl")
				el.removeAttribute("data-template")
				count = count + 1

		return count

	@__appendContent: (data, load_templates) ->
		div = CUI.dom.element("DIV", style: "display:none;")
		div.innerHTML = data
		if not load_templates
			document.body.appendChild(div)
		else
			count = CUI.Template.load(div)

			if div.children.length > 0
				document.body.appendChild(div)
				console.warn("Template.loadFile:", filename, "contains extra content.", div)

			if count == 0
				console.warn("Template.loadFile:", filename, "contains no Templates.")
			else
				; # console.info("Template.loadFile:", count, "Template loaded from", filename)
