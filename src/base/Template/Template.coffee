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

class Template extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)

		#try find it inside cached list
		node = Template.nodeByName[@_name]

		if not node
			name = "cui-tmpl-"+@_name

			selector = ".cui-tmpl.cui-tmpl.#{name}"

			# find the template in the DOM tree
			nodeList = CUI.DOM.matchSelector(document.body, selector)

			#expecting parent domNode of template
			if nodeList.length != 1
				if nodeList.length == 0
					err = "Not found"
				else
					err = "Too many (#{nodeList.length}) found"

				err_txt = "Template \"#{name}\": #{err} in DOM, make sure you have a node with Class \"cui-tmpl #{name}\". Should match this selector: #{selector}"
				alert(err_txt)
				CUI.error(err_txt)
				@DOM = $div().append($i().text("Template \"cui-tmpl #{name}\": #{err}."))
				return

			node = Template.nodeByName[@_name] = nodeList[0]


		@DOM = node.cloneNode(true)
		@DOM.classList.remove("cui-tmpl")
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


	initFlexHandles: ->
		# init any flex handles find in the markup
		@__flexHandles = {}
		# txt = "Template.initFlexHandles[name=#{@_name}]"
		# console.time(txt)
		for fh_el in CUI.DOM.matchSelector(@DOM, "[cui-flex-handle]")
			fh = new FlexHandle(element: fh_el)
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
					prefix = @_map_prefix
				else
					prefix = toDash(@_name)

				sel = ".#{Template.cssPrefix}#{prefix}-#{clean_k},.#{Template.css_ui_prefix}#{prefix}-#{clean_k}"
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
				DOM.addClass(@DOM, "cui-template-empty")

			return @map[key]

		if CUI.isEmptyObject(@map)
			# without map we empty the whole @DOM
			DOM.empty(@DOM)
		else
			# with map we empty each individual map entry
			for key of @map
				DOM.empty(@map[key])
			DOM.addClass(@DOM, "cui-template-empty")

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

#TODO this prefix should be configured by the user of the UI
Template.cssPrefix = "ez-"
Template.css_ui_prefix = "cui-"
Template.nodeByName = {}