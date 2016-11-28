# Template needs to be called like this:
#
# new Template
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
	constructor: (@opts={}) ->
		super(@opts)

		#try find it inside cached list
		node = Template.nodeByName[@_name]
		assert(node, "CUI.Template", @_name+" not found. Make sure to call Template.loadFile(...).")

		@DOM = node.cloneNode(true)
		if @_class
			DOM.addClass(@DOM, @_class)
		CUI.DOM.setElement(@DOM, @)

		# map elements which require mapping
		@map = @getElMap(@_map)
		if not CUI.isEmptyObject(@map)
			CUI.DOM.addClass(@DOM, "cui-template-empty")

		return

	initOpts: ->
		super()
		@addOpts
			name:
				mandatory: true
				check: String
			map_prefix:
				check: String
			map:
				type: "PlainObject"
				default: {}
			class:
				check: String
		@


	initFlexHandles: (pane_opts={}) ->
		# init any flex handles find in the markup
		@__flexHandles = {}
		# txt = "Template.initFlexHandles[name=#{@_name}]"
		# console.time(txt)

		for fh_el in CUI.DOM.matchSelector(@DOM, "[cui-flex-handle]")
			opts = @readOptsFromAttr(CUI.DOM.getAttribute(fh_el, "cui-flex-handle"))
			if pane_opts[opts.name]
				# merge opts
				for k,v of pane_opts[opts.name]
					if not opts.hasOwnProperty(k)
						opts[k] = v
			else
				opts.manage_state = false

			opts.element = fh_el
			fh = new FlexHandle(opts)
			if not isEmpty(fh_name = fh.getName())
				# CUI.warn("Template.initFlexHandles", fh_name)
				@__flexHandles[fh_name] = fh
				fh.init()
		# console.timeEnd(txt)
		@

	getFlexHandle: (name) ->
		assert(@__flexHandles, "Template.getFlexHandle", "flexHandles are not initialized yet, call Template.initFlexHandles(opts) first.", name: name)
		fh = @__flexHandles[name]
		assert(fh instanceof FlexHandle, "#{@__cls}.getFlexHandle", "FlexHandle \"#{name}\" not found, make sure you have specified a name in the cui-flex-handle attribute.", opts: @opts, flexHandles: @__flexHandles)
		fh

	getFlexHandles: ->
		@__flexHandles

	getElMap: (map) ->
		el_map = {}
		report = []
		misses = 0
		for k, v of map
			if isNull(v)
				continue

			if v == true
				clean_k = k.replace(/_/g, "-")
				if @_map_prefix
					sel = "."+@_map_prefix+"-"+clean_k
				else
					prefix = toDash(@_name)
					sel = ".ez-"+prefix+"-"+clean_k+",.cui-"+prefix+"-"+clean_k
				sel = sel + ',[data-slot="'+CUI.escapeAttribute(k)+'"]'
			else
				sel = v

			map_obj = CUI.DOM.matchSelector(@DOM, sel, true)

			if map_obj.length == 0
				report.push("* #{k}: not found (#{sel})")
				misses++
			else if map_obj.length > 1
				CUI.debug(k, v, "found more than once", map_obj, @DOM)
				report.push("* #{k}: found more than once (#{sel})")
				misses++
			else
				report.push("+ #{k}: found")
				el_map[k] = CUI.jQueryCompat(map_obj[0])

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
			alert("Not all required elements were found for Template:\n\n\"#{@_name}\"\n\n"+report.join("\n"))
		el_map

	destroy: ->
		# CUI.error "destroying...", getObjectClass(DOM.data(@DOM, "element")), getObjectClass(@DOM[0])
		DOM.remove(@DOM)
		delete(@map)
		super()

	addClass: (cls, key) ->
		if key
			assert(@map[key], "#{@__cls}.addClass", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
			DOM.addClass(@map[key], cls)
		else
			DOM.addClass(@DOM, cls)
		# @DOM.addClass.apply(@DOM, arguments)

	removeClass: (cls, key) ->
		if key
			assert(@map[key], "#{@__cls}.removeClass", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
			DOM.removeClass(@map[key], cls)
		else
			DOM.removeClass(@DOM, cls)

	hasClass: (cls, key) ->
		if key
			assert(@map[key], "#{@__cls}.hasClass", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
			DOM.hasClass(@map[key], cls)
		else
			DOM.hasClass(@DOM, cls)

	has: (key) ->
		!!@map[key]


	empty: (key) ->
		assert(@map, "Template[#{@_name}].empty [#{@getUniqueId()}]", "Already destroyed", template: @, name: @_name)
		if @isEmpty(key)
			if key
				return @map[key]
			else
				return @DOM

		if key
			assert(@map[key], "#{@__cls}.empty", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map)
			# CUI.debug "Template.destroyingChildren", key, @map[key]
			DOM.empty(@map[key])

			is_empty = true
			for key of @map
				if not @isEmpty(key)
					is_empty = false
					break

			if is_empty
				CUI.DOM.addClass(@DOM, "cui-template-empty")

			return @map[key]

		if CUI.isEmptyObject(@map)
			# without map we empty the whole @DOM
			DOM.empty(@DOM)
		else
			# with map we empty each individual map entry
			for key of @map
				DOM.empty(@map[key])
			CUI.DOM.addClass(@DOM, "cui-template-empty")

		return @DOM

	replace: (value, key, element) ->
		assert(@map, "Template[#{@_name}].replace [#{@getUniqueId()}]", "Already destroyed")
		if key
			assert(@map[key], "#{@__cls}.replace", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map, DOM: @DOM)
		@empty(key)
		@append(value, key, element)

	text: (value, key, element) ->
		assert(isString(value), "#{@__cls}.text", "Value must be String", value: value, key: key, element: element)
		if key
			@map[key].text(value)
		else
			@DOM.text(value)

	prepend: (value, key, element) ->
		@append(value, key, element, true)

	append: (value, key, element, prepend = false) ->
		if prepend
			fn = "prepend"
		else
			fn = "append"
		assert(@map, "Template[#{@_name}].#{fn} [#{@getUniqueId()}]", "Already destroyed")
		if key
			assert(@map[key], "#{@__cls}.#{fn}", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map)

		if CUI.isFunction(value)
			value = value(element)

		if not CUI.isArray(value)
			value = [value]

		appends = []
		for _value in value
			if _value?.DOM
				appends.push(_value.DOM)
			else
				assert(not isPromise(_value), "Template.append", "value cannot be Promise", value: value)
				if _value
					appends.push(_value)

		if key
			node = @map[key]
		else
			node = @DOM

		if appends.length > 0
			CUI.DOM[fn](node, appends)
			CUI.DOM.removeClass(@DOM, "cui-template-empty")

		node

	isEmpty: (key) ->
		if not key
			!@DOM.firstChild
		else
			assert(@map[key], "#{@__cls}.isEmpty", "Key \"#{key}\" not found in map. Template: \"#{@_name}\".", map: @map)
			!@map[key].firstChild
			# if fc
			# 	CUI.debug "isEmpty: false", key, fc
			# !fc

	@nodeByName: {}

	@start: ->
		dfr = new CUI.Deferred()
		@load()
		if not @nodeByName["cui-base"]
			CUI.Template.loadFile("easydbui.html")
			.done =>
				dfr.resolve()
		else
			dfr.resolve()
		dfr.promise()


	@loadFile: (filename) ->
		if filename.match("^(https://|http://|/)")
			p = filename
		else
			p = CUI.pathToScript+"/"+filename

		div = CUI.DOM.element("DIV", style: "display:none;")

		new CUI.XHR
			url: p
			responseType: "text"
		.start()
		.done (data) ->
			div.innerHTML = data
			count = Template.load(div)

			if div.children.length > 0
				document.body.appendChild(div)
				console.error("Template.loadFile:", filename, "contains extra content.", div)

			if count == 0
				console.warn("Template.loadFile:", filename, "contains no Templates.")
			else
				console.info("Template.loadFile:", count, "Template loaded from", filename)
			return

		.fail (xhr) ->
			CUI.error("Template.loadFile: Unable to load filename: \"#{filename}\", see Console for more details. You can however, output easydbui.html manually before loading easydbui.js.", xhr)

	@load: (start_element = document.documentElement) ->
		count = 0
		for el in CUI.DOM.matchSelector(start_element, ".cui-tmpl,[data-template]")
			name = null

			name = el.getAttribute("data-template")

			if isEmpty(name)
				for cls in el.classList
					if cls.startsWith("cui-tmpl-")
						name = cls.substr(9)
						if Template.nodeByName[name]
							console.error("Template.load:", name, "already found in DOM tree. Make sure all elements exists only once.", el)
							continue
						break

			if name
				# console.debug("Template: ", name)
				Template.nodeByName[name] = el
				CUI.DOM.remove(el)
				el.classList.remove("cui-tmpl")
				count = count + 1

		return count


Template = CUI.Template
