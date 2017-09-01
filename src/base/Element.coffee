###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Element

	constructor: (@opts={}) ->
		@__uniqueId = CUI.Element.uniqueId++
		@__cls = CUI.util.getObjectClass(@)
		@__destroyed = false
		@__check_map = {}
		@__mapped_keys = []

		@initOpts()

		if CUI.Element.__dont_read_opts
			return

		@readOpts()
		if not @__initOptsCalled
			CUI.warn("new "+@__cls+": CUI.Element::initOpts not called.", opts: @opts)

		@_onConstruct?(@)

		# DEBUG:
		# console.error(CUI.util.getObjectClass(@)+"."+@__uniqueId+" created.")
		return

	getElementClass: ->
		@__cls

	getUniqueId: ->
		@__uniqueId

	getOpts: ->
		@opts

	getOpt: (key) ->
		@opts[key]

	hasOpt: (key) ->
		@opts.hasOwnProperty(key)

	getSetOpt: (key) ->
		@["_"+key]

	hasSetOpt: (key) ->
		@hasOwnProperty("_"+key)

	initOpts: ->
		@__initOptsCalled = true
		@addOpts
			debug: {}
			onConstruct:
				check: Function
			onDestroy:
				check: Function

	# create a new instance from the same opts
	copy: ->
		new window[@__cls](@opts)

	# returns the merged opt
	mergeOpt: (key, check_map={}) ->
		opt = @__check_map[key] or {}
		for k, v of check_map
			opt[k] = v
		@addOpt(key, opt, "mergeOpt")

	removeOpt: (key) ->
		delete(@__check_map[key])

	addOpt: (key, check_map, fn="addOpt") ->
		CUI.util.assert(CUI.util.isString(key), "#{@__cls}.#{fn}", "key needs to be String", key: key, check_map: check_map)
		if CUI.util.isNull(check_map)
			return
		CUI.util.assert(CUI.isPlainObject(check_map), "#{@__cls}.#{fn}", "check_map needs to be Map", key: key, check_map: check_map)
		@__check_map[key] = check_map
		@

	addOpts: (map) ->
		CUI.util.assert(CUI.isPlainObject(map), "#{@__cls}.addOpts", "Parameter needs to be Map", map: map)
		for k, v of map
			@addOpt(k, v)
		@

	mergeOpts: (map) ->
		CUI.util.assert(CUI.isPlainObject(map), "#{@__cls}.mergeOpts", "Parameter needs to be Map", map: map)
		for k, v of map
			@mergeOpt(k, v)
		@

	__getCheckMap: ->
		@__check_map

	readOpts: (opts = @opts, cls = @__cls, check_map = @__check_map) ->
		CUI.Element.readOpts.call(@, opts, cls, check_map, true)

	# read "style" like opts for layout
	readOptsFromAttr: (str) ->
		opts = {}
		if not str?.split
			return opts
		for key_value in str.split(";")
			if CUI.util.isEmpty(key_value.trim())
				continue
			[key, value] = key_value.split(":")
			key = key.trim()
			value = value?.trim()
			CUI.util.assert(not CUI.util.isEmpty(key) and not CUI.util.isEmpty(value), "#{@__cls}.readOptsFromAttr", "Parsing error in \"#{str}\".")
			if value == "true"
				value = true
			else if value == "false"
				value = false
			else if not isNaN(parseInt(value))
				value = parseInt(value)
			opts[key] = value
		opts

	# proxy given methods to given element
	proxy: (element, methods) ->
		CUI.util.assert(element instanceof CUI.Element, "CUI.Element.proxy", "element given must be instance of CUI.Element.", element: element, methods: methods)
		CUI.util.assert(CUI.isArray(methods), "Element.proxy", "methods given must be Array.", element: element, methods: methods)
		for method in methods
			do (method) =>
				@[method] = =>
					element[method].apply(element, arguments)
		@

	destroy: ->
		# clean mapped values
		CUI.util.assert(@__mapped_keys, CUI.util.getObjectClass(@)+".destroy", "__mapped_keys not found, that means the top level constructor was not called.", element: @)

		for k in @__mapped_keys
			delete("@_#{k}")
		@__mapped_keys = []
		@_onDestroy?(@)
		@__destroyed = true

	isDestroyed: ->
		@__destroyed

	@uniqueId: 0

	# this is a hackery function to return just
	# the opts keys for a given class
	@getOptKeys: ->
		CUI.Element.__dont_read_opt = true
		element = new(@)
		delete(CUI.Element.__dont_read_opts)
		Object.keys(element.__getCheckMap())

	@readOpts: (opts, cls, check_map, map_values) ->
		if map_values != true and map_values != false
			if @ != Element
				CUI.util.assert(@ != window, "CUI.Element.readOpts", "this cannot be window.")
				map_values = true

		if not CUI.defaults.asserts
			# fast path
			set_opts = {}
			for k, v of check_map
				if opts.hasOwnProperty(k) and opts[k] != undefined
					set_opts[k] = @["_#{k}"] = opts[k]
					if map_values
						@__mapped_keys.push(k)
				else if v.hasOwnProperty("default")
					set_opts[k] = @["_#{k}"] = v.default
					if map_values
						@__mapped_keys.push(k)

			return set_opts

		# @__time("readOpts")
		CUI.util.assert(CUI.isPlainObject(opts), cls, "opts needs to be PlainObject.", opts: opts, check_map: check_map)
		CUI.util.assert(CUI.isPlainObject(check_map), cls, "check_map needs to be PlainObject.", opts: opts, check_map: check_map)
		set_opts = {}
		for k, v of check_map
			# CUI.debug "check map", cls, k, v.check, v.check?.name
			if opts.hasOwnProperty(k) and opts[k] != undefined
				value = opts[k]
				exists = true
			else if v.hasOwnProperty("default")
				value = v.default
				exists = true
			else
				exists = false

			if CUI.isFunction(v.mandatory)
				mandatory = v.mandatory.call(@, value)
			else
				mandatory = v.mandatory

			if not exists
				if mandatory
					CUI.util.assert(false, cls, "opts.#{k} needs to be set.", opts: opts, check_map: check_map)
				else
					continue
			else if v.deprecated
				if v.deprecated.length > 0
					post = v.deprecated
				else
					post = ""

				# CUI.error("%c #{cls}: opts.#{k} is deprecated.", "font-weight: bold; color: red; font-size: 1.2em;", post)
				console.warn("#{cls}: opts.#{k} is deprecated.", value)

			if v.check and (not CUI.util.isNull(value) or mandatory)
				if CUI.isArray(v.check)
					CUI.util.assert(v.check.indexOf(value) > -1, cls, "opts.#{k} needs to be one of [\"#{v.check.join('\",\"')}\"].", opts: opts)
				else if v.check == Boolean or v.check == String or v.check == Function or v.check == Array
					CUI.util.assertInstanceOf.call(@, k, v.check, undefined, value)
				else if CUI.isFunction(v.check) and not v.check.__super__ # super is from coffeescript and shows us that we have a "class" here
					CUI.util.assert(CUI.util.isEmpty(v.check.name) or v.check.name == "check", cls, "#{k}.check is \"#{v.check.name}\" but has no \"__super__\" method. Use \"extends CUI.Element\" or \"extends CUI.Dummy\" to fix that.", opts: opts, key: k, value: v)
					check = v.check.call(@, value)
					if not(CUI.util.isNull(check) or CUI.util.isBoolean(check) or CUI.util.isString(check))
						_check = check
						console.error("CUI.Element.readOpts: check needs to return Boolean, null, undefined or String.", "opts:", opts, "opt:", v, "return:", _check)
						if _check
							check = true
						else
							check = false
					if check != true
						if CUI.util.isString(check)
							err = check
						else
							err = "needs to match\n\n"+v.check.toString()
						CUI.util.assert(false, cls, "opts.#{k}: #{err}.", opts: opts)
				else if CUI.isPlainObject(v.check)
					value = CUI.Element.readOpts(value, cls+" [opts."+k+"]", v.check)
				else if CUI.util.isNull(value) and mandatory
					CUI.util.assert(false, cls, "opts.#{k} is mandatory, but is #{value}.", opts: opts)
				else
					CUI.util.assertInstanceOf.call(@, k, v.check, undefined, value)

			# convenient mapping this to our space
			if map_values
				@["_#{k}"] = value
				if @ instanceof CUI.Element
					@__mapped_keys.push(k)

			set_opts[k] = value

		for k, v of opts
			# options starting with a "_" are considered private
			if v != undefined and not set_opts.hasOwnProperty(k) and not k.startsWith("_")
				console.warn("#{cls}: opts.#{k}, not supported. check_map: ", check_map, "opts:", opts)
				# delete(opts[k])

		# CUI.warn "#{@__cls}.opts = ", dump(set_opts)
		# @__timeEnd("readOpts")
		set_opts
