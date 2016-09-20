# Base class for the Coffeescript UI system. It is used for
# Theme-Management as well as for basic event management tasks.
#
# @example Startup
#
class CUI

	@__readyFuncs = []
	@__themes = []

	@start: ->
		@getPathToScript()

		trigger_viewport_resize = =>
			CUI.info("CUI: trigger viewport resize.")
			Events.trigger
				type: "viewport-resize"

		Events.listen
			type: "resize"
			node: window
			call: (ev, info) =>
				CUI.info("CUI: caught window resize event.")
				CUI.scheduleCallback(ms: 500, call: trigger_viewport_resize)
				return

		Events.listen
			type: "drop"
			node: document.documentElement
			call: (ev) ->
				ev.preventDefault()

		Events.listen
			type: "keydown"
			node: window
			call: (ev) ->
				# backspace
				if ev.keyCode() == 8
					if ev.getTarget().tagName in ["INPUT", "TEXTAREA"]
						return
					else
						# CUI.info("swalloded BACKSPACE keydown event to prevent default")
						ev.preventDefault()
				return

		document.body.scrollTop=0

		if not DOM.matchSelector(document.documentElement, ".cui-tmpl-dummy").length
			@loadHTMLFile("easydbui.html")
			.done =>
				@ready()
		else
			@ready()
		@

	# @return [Array<Theme>] themes Array of Theme instances
	@getThemes: ->
		@__themes

	@getTheme: (name) ->
		for t in @__themes
			if t.getName() == name
				return t
		undefined

	# Get a list of theme names
	#
	# @return [Array<String>] themes Array of theme names
	@getThemeNames: ->
		t.getName() for t in @__themes

	# Register a theme
	#
	# @return [Array<Theme>]
	@registerTheme: (name, url) ->
		theme = new CSS(group: "cui-theme", name: name, url: url)

		# overwrite existing theme
		if removeFromArray(null, @__themes, (v) -> v.getName() == name)
			update = "[overwrite]"
		else
			update = ""

		CUI.info("CUI.registerTheme:", name+update, url)

		@__themes.push(theme)
		@__themes

	@resetThemes: ->
		@__themes = []

	# Make a theme the active theme
	#

	@loadTheme: (name) ->
		new_theme = @getTheme(name)
		assert(new_theme, "CUI.loadThemeByName", "Theme #{name} not found", themes: @getThemeNames())

		old_theme = @getActiveTheme()

		set_active_theme = (theme) =>
			DOM.setAttribute(document.body, "cui-theme", theme?.getName())
			@__activeTheme = theme
			if theme.getName().startsWith("ng")
				CUI.__ng__ = true
			else
				CUI.__ng__ = false

		# we set this before the load, so users can access the
		# active theme right from the start
		set_active_theme(new_theme)

		new_theme.load().fail =>
			if old_theme
				set_active_theme(old_theme)


	@getActiveTheme: ->
		@__activeTheme

	@getPathToScript: ->
		if not @pathToScript
			for s, idx in DOM.matchSelector(document.documentElement, "script")
				if m = s.src.match("(.*)/easydbui.js")
					@pathToScript = m[1]
					@script = s
					break
			assert(@pathToScript, "easydbui", "Could not determine script path.")
		@pathToScript

	@loadHTMLFile: (filename) ->
		if filename.match("^(https://|http://|/)")
			p = filename
		else
			p = @pathToScript+"/"+filename
		div = $div("", style: "display:none;")

		new CUI.XHR
			url: p
			responseType: "text"
		.start()
		.done (data) ->
			div.innerHTML = data
			document.body.appendChild(div)
		.fail (xhr) ->
			CUI.error("CUI.loadHTMLFile: Unable to load filename: \"#{filename}\", see Console for more details. You can however, output easydbui.html manually before loading easydbui.js.", xhr)

	@getViewport: ->
		width: window.innerWidth
		height: window.innerHeight

	@ready: (func) ->
		if func instanceof Function
			if @__ready
				func.call(@)
			else
				@__readyFuncs.push(func)
		else
			@__ready = true
			for func in @__readyFuncs
				func.call(@)

	@reachValue: (key, reach, ms) ->
		if not @length
			return null

		if isNull(reach)
			# return current scroll
			return @[0][key]

		timeout_key = "_reach_timeout_"+key
		promises = []

		for el in @
			dfr = new CUI.Deferred()
			promises.push(dfr.promise())

			if el[timeout_key]
				CUI.clearTimeout(el[timeout_key])
				el[timeout_key] = null

			if ms == 0
				el[key] = reach
				dfr.resolve()
				continue

			scroll = ->
				current = el[key]
				inc = Math.max(2, Math.ceil(Math.abs(el[key]-reach) / 10))
				# CUI.debug key, reach, current, inc, ms
				if el[key] < reach
					el[key] = Math.min(reach, el[key] + inc)
				else if el[key] > reach
					el[key] = Math.max(reach, el[key] - inc)
				else
					dfr.notify(current)
					dfr.resolve(current)
					return

				dfr.notify(el[key])
				if el[key] == current
					# our setting did not change anything
					# so we leave the value alone
					dfr.resolve(current)
					return

				if el[timeout_key]
					CUI.clearTimeout(el[timeout_key])
				el[timeout_key] = CUI.setTimeout(scroll, ms)

			scroll()

		CUI.when(promises)

	@defaults:
		FileUpload:
			name:
				"files[]"

		debug: true
		asserts: true
		class: {}

	@resolvedPromise: ->
		dfr = new CUI.Deferred()
		dfr.resolve.apply(dfr, arguments)
		dfr.promise()

	@rejectedPromise: ->
		dfr = new CUI.Deferred()
		dfr.reject.apply(dfr, arguments)
		dfr.promise()


	# calls the as argument passed functions in order
	# of appearance. if a function returns
	# a deferred or promise, the next function waits
	# for that function to complete the promise
	# if the argument is a value or a promise
	# it is used the same way
	# returns a promise which resolve when all
	# functions resolve or the first doesnt
	@chainedCall: ->
		idx = 0

		__this = @

		# return a real array from arguments
		get_args = (_arguments) ->
			_args = []
			for arg in _arguments
				_args.push(arg)
			_args

		# mimic the behaviour of jQuery "when"
		get_return_value = (_arguments) ->
			_args = get_args(_arguments)
			if _args.length == 0
				return undefined
			else if _args.length == 1
				return _args[0]
			else
				return _args

		args = get_args(arguments)
		return_values = []

		init_next = =>
			if idx == args.length
				dfr.resolve.apply(dfr, return_values)
				return


			if CUI.isFunction(args[idx])
				if __this != CUI
					ret = args[idx].call(__this)
				else
					ret = args[idx]()
			else
				ret = args[idx]

			# CUI.debug "idx", idx, "ret", ret, "state:", ret?.state?()

			idx++

			if isPromise(ret)
				ret
				.done =>
					return_values.push(get_return_value(arguments))
					init_next()
				.fail =>
					return_values.push(get_return_value(arguments))
					dfr.reject.apply(dfr, return_values)
			else
				return_values.push(ret)
				init_next()
			return

		dfr = new CUI.Deferred()
		init_next()
		dfr.promise()


	# returns a Deferred, the Deferred
	# notifies the worker for each
	# object
	@chunkWork: (objects, chunkSize = 10, timeout = 0) ->
		dfr = new CUI.Deferred()

		idx = 0
		do_next_chunk = =>
			chunk = 0
			while idx < objects.length and (chunk < chunkSize or chunkSize == 0)
				if dfr.state() == "rejected"
					return

				# CUI.debug idx, chunk, chunkSize, dfr.state()
				dfr.notify(objects[idx], idx)
				if idx == objects.length-1
					dfr.resolve()
					return

				idx++
				chunk++

			if idx < objects.length
				CUI.setTimeout(do_next_chunk, timeout)


		if objects.length == 0
			CUI.setTimeout =>
				if dfr.state() == "rejected"
					return
				dfr.resolve()
		else
			CUI.setTimeout(do_next_chunk)
		dfr

	# proxy methods
	@proxyMethods: (target, source, methods) ->
		# CUI.debug target, source, methods
		for k in methods
			target.prototype[k] = source.prototype[k]

	@__timeouts = []

	# list of function which we need to call if
	# the timeouts counter changes
	@__timeoutCallbacks = []

	@__callTimeoutChangeCallbacks: ->
		tracked = @countTimeouts()
		for cb in @__timeoutCallbacks
			cb(tracked)
		return

	@__removeTimeout: (timeout) ->
		if removeFromArray(timeout, @__timeouts)
			if timeout.track
				@__callTimeoutChangeCallbacks()
		return

	@__getTimeoutById: (timeoutID, ignoreNotFound = false) ->
		for timeout in @__timeouts
			if timeout.id == timeoutID
				return timeout

		assert(ignoreNotFound, "CUI.__getTimeoutById", "Timeout ##{timeoutID} not found.")
		null

	@resetTimeout: (timeoutID) ->
		timeout = @__getTimeoutById(timeoutID)
		assert(not timeout.__isRunning, "CUI.resetTimeout", "Timeout #{timeoutID} cannot be resetted while running.", timeout: timeout)
		timeout.onReset?(timeout)
		window.clearTimeout(timeout.real_id)
		old_real_id = timeout.real_id
		tid = @__startTimeout(timeout)

		return tid

	@registerTimeoutChangeCallback: (cb) ->
		@__timeoutCallbacks.push(cb)


	@setTimeout: (_func, ms=0, track) ->
		if CUI.isPlainObject(_func)
			ms = _func.ms or 0
			track = _func.track
			func = _func.call
			onDone = _func.onDone
			onReset = _func.onReset
		else
			func = _func

		if isNull(track)
			if ms == 0
				track = false
			else
				track = true

		assert(CUI.isFunction(func), "CUI.setTimeout", "Function needs to be a Function (opts.call)", parameter: _func)
		timeout =
			call: =>
				timeout.__isRunning = true
				func()
				@__removeTimeout(timeout)
				timeout.onDone?(timeout)
			ms: ms
			func: func # for debug purposes
			track: track
			onDone: onDone
			onReset: onReset

		@__timeouts.push(timeout)
		if track and ms > 0
			@__callTimeoutChangeCallbacks()

		@__startTimeout(timeout)


	@__scheduledCallbacks = []

	# schedules to run a function after
	# a timeout has occurred. does not schedule
	# the same function a second time
	# returns a deferred, which resolves when
	# the callback is done
	@scheduleCallback: (_opts) ->
		opts = CUI.Element.readOpts _opts, "CUI.scheduleCallback",
			call:
				mandatory: true
				check: Function
			ms:
				default: 0
				check: (v) ->
					isInteger(v) and v >= 0
			track:
				default: false
				check: Boolean

		idx = idxInArray(opts.call, @__scheduledCallbacks, (v) -> v.call == opts.call)

		if idx > -1 and CUI.isTimeoutRunning(@__scheduledCallbacks[idx].timeoutID)
			# don't schedule the same call while it is already running, schedule
			# a new one
			idx = -1

		if idx == -1
			idx = @__scheduledCallbacks.length
			# CUI.debug "...schedule", idx
		else
			# function already scheduled
			# CUI.info("scheduleCallback, already scheduled: ", @__scheduledCallbacks[idx].timeout, CUI.isTimeoutRunning(@__scheduledCallbacks[idx].timeout))
			CUI.resetTimeout(@__scheduledCallbacks[idx].timeoutID)
			return @__scheduledCallbacks[idx].promise

		dfr = new CUI.Deferred()

		timeoutID = CUI.setTimeout
			ms: opts.ms
			track: opts.track
			call: =>
				opts.call()
				dfr.resolve()

		cb = @__scheduledCallbacks[idx] =
			call: opts.call
			timeoutID: timeoutID
			promise: dfr.promise()

		# console.error "scheduleCallback", cb.timeoutID, opts.call

		dfr.done =>
			# remove this callback after we are done
			removeFromArray(opts.call, @__scheduledCallbacks, (v) -> v.call == opts.call)

		cb.promise

	# call: function callback to cancel
	# return: true if found, false if not
	@scheduleCallbackCancel: (_opts) ->
		opts = CUI.Element.readOpts _opts, "CUI.scheduleCallbackCancel",
			call:
				mandatory: true
				check: Function

		idx = idxInArray(opts.call, @__scheduledCallbacks, (v) -> v.call == opts.call)

		if idx > -1 and not CUI.isTimeoutRunning(@__scheduledCallbacks[idx].timeoutID)
			console.error "cancel timeout...", @__scheduledCallbacks[idx].timeoutID
			CUI.clearTimeout(@__scheduledCallbacks[idx].timeoutID)
			@__scheduledCallbacks.splice(idx, 1)
			return true
		else
			return false

	@utf8ArrayBufferToString: (arrayBuffer) ->
		out = []
		array = new Uint8Array(arrayBuffer)
		len = array.length
		i = 0
		while (i < len)
			c = array[i++]
			switch(c >> 4)
				when 0, 1, 2, 3, 4, 5, 6, 7
			        # 0xxxxxxx
			        out.push(String.fromCharCode(c))
				when 12, 13
			        # 110x xxxx   10xx xxxx
			        char2 = array[i++]
			        out.push(String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F)))
				when 14
			        # 1110 xxxx  10xx xxxx  10xx xxxx
			        char2 = array[i++]
			        char3 = array[i++]
			        out.push(String.fromCharCode(((c & 0x0F) << 12) |
                       ((char2 & 0x3F) << 6) |
                       ((char3 & 0x3F) << 0)))
		out.join("")

	@__startTimeout: (timeout) ->
		real_id = window.setTimeout(timeout.call, timeout.ms)
		if not timeout.id
			# first time we put the real id
			timeout.id = real_id
		timeout.real_id = real_id
		# CUI.error "new timeout:", timeoutID, "ms:", ms, "current timeouts:", @__timeouts.length
		timeout.id

	@countTimeouts: ->
		tracked = 0
		for timeout in @__timeouts
			if timeout.track
				tracked++
		tracked

	@clearTimeout: (timeoutID) ->
		timeout = @__getTimeoutById(timeoutID, true) # ignore not found
		if not timeout
			return

		window.clearTimeout(timeout.real_id)
		@__removeTimeout(timeout)
		timeout.id

	@isTimeoutRunning: (timeoutID) ->
		timeout = @__getTimeoutById(timeoutID, true) # ignore not found
		if not timeout?.__isRunning
			false
		else
			true

	@setInterval: (func, ms) ->
		window.setInterval(func, ms)

	@clearInterval: (interval) ->
		window.clearInterval(interval)

	# used to set a css-class while testing with webdriver. this way
	# we can hide things on the screen that should not irritate our screenshot comparison

	@startWebdriverTest: ->
		a= $("body")
		a.addClass("cui-webdriver-test")

	@mergeMap: (targetMap, mergeMap) ->
		for k, v of mergeMap
			if not targetMap.hasOwnProperty(k)
				targetMap[k] = v
			else if CUI.isPlainObject(targetMap[k]) and CUI.isPlainObject(v)
				CUI.mergeMap(targetMap[k], v)
		targetMap

	@getParameterByName: (name, search=document.location.search) ->
		name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
		regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
		results = regex.exec(search)
		if results == null
			""
		else
			decodeURIComponent(results[1].replace(/\+/g, " "))

	@encodeUrlData: (params, replacer = null, connect = "&", connect_pair = "=") ->
		url = []
		if replacer
			if CUI.isFunction(replacer)
				encode_func = replacer
			else
				encode_func = (v) -> CUI.stringMapReplace(v+"", replace_map)
		else
			encode_func = (v) -> encodeURIComponent(v)

		for k, v of params
			if CUI.isArray(v)
				for _v in v
					url.push(encode_func(k) + connect_pair + encode_func(_v))
			else
				url.push(encode_func(k) + connect_pair + encode_func(v))

		url.join(connect)

	@encodeURIComponentNicely: (str="") ->
		s = []
		for v in (str+"").split("")
			if v in [",",":"]
				s.push(v)
			else
				s.push(encodeURIComponent(v))
		s.join("")

	@decodeURIComponentNicely: (v) ->
		decodeURIComponent(v)

	@decodeUrlData: (url, replacer = null, connect = "&", connect_pair = "=", use_array=false) ->
		params = {}
		if replacer
			if CUI.isFunction(replacer)
				decode_func = replacer
			else
				decode_func = (v) -> CUI.stringMapReplace(v+"", replacer)
		else
			decode_func = (v) -> decodeURIComponent(v)

		for part in url.split(connect)
			pair = part.split(connect_pair)
			key = decode_func(pair[0])
			value = decode_func(pair[1])

			if use_array
				if not params[key]
					params[key] = []
				params[key].push(value)
			else
				params[key] = value

		params

	@decodeUrlDataArray: (url, replace_map = null, connect = "&", connect_pair = "=") ->
		@decodeUrlData(url, replace_map, connect, connect_pair, true)


	@revertMap: (map) ->
		map_reverted = {}
		for k, v of map
			map_reverted[v] = k
		map_reverted

	@stringMapReplace: (s, map) ->
		regex = []
		for key of map
			if isEmpty(key)
				continue
			regex.push(key.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"))
		return s.replace(new RegExp(regex.join('|'),"g"), (word) -> map[word])

	@isFunction: (v) ->
		v and typeof(v) == "function"

	@isPlainObject: (v) ->
		v and typeof(v) == "object" and v.constructor?.prototype.hasOwnProperty("isPrototypeOf")

	@isEmptyObject: (v) ->
		for k of v
			return false
		return true

	@isMap: (v) ->
		@isPlainObject(v)

	@isArray: (v) ->
		Array.isArray(v)

	@isString: (s) ->
		typeof(s) == "string"

	@downloadData: (data, fileName) ->
		json = JSON.stringify(data)
		blob = new Blob([json], type: "octet/stream")
		url = window.URL.createObjectURL(blob)
		@__downloadDataElement.href = url
		@__downloadDataElement.download = fileName
		@__downloadDataElement.click()
		window.URL.revokeObjectURL(url)


	# https://gist.github.com/dperini/729294
	@urlRegex: new RegExp(
		"^" +
		# protocol identifier
		"(?:(?:(https?))://|)" +
		# user:pass authentication
		"(?:(\\S+?)(?::(\\S*))?@)?" +
		"((?:(?:" +
		# IP address dotted notation octets
		# excludes loopback network 0.0.0.0
		# excludes reserved space >= 224.0.0.0
		# excludes network & broacast addresses
		# (first & last IP address of each class)
		"(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])" +
		"(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}" +
		"(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))" +
		"|" +
		# host & domain name
		"(?:[a-z\\u00a1-\\uffff0-9-*][a-z\\u00a1-\\uffff0-9-]*\\.)*" +
		# last identifier
		"(?:[a-z\\u00a1-\\uffff]{2,})" +
		"))|)" +
	    # port number
	    "(?::(\\d{2,5}))?" +
	    # resource path
	    "(?:([/?#]\\S*))?" +
		"$", "i"
	)

	@evalCode: (code) ->
		script = document.createElement("script")
		script.text = code
		document.head.appendChild(script).parentNode.removeChild(script)

	@appendToUrl: (url, data) ->
		for key, value of data
			if value == undefined
				continue
			# add token to the url
			if url.match(/\?/)
				url += "&"
			else
				url += "?"
			url += encodeURIComponent(key)+"="+encodeURIComponent(value)
		url

	@parseLocation: (url) ->
		if not CUI.isFunction(url?.match) or url.length == 0
			return null

		match = url.match(@urlRegex)
		if not match
			return null

		# console.debug "CUI.parseLocation:", url, match

		p =
			protocol: match[1] or ""
			user: match[2] or ""
			password: match[3] or ""
			hostname: match[4] or ""
			port: match[5] or ""
			path: match[6] or ""
			origin: ""

		if p.hostname
			if not p.protocol
				p.protocol = "http"
			p.origin = p.protocol+"://"+p.hostname
			if p.port
				p.origin += ":"+p.port

			p.url = p.protocol+"://"
			if p.user
				p.url = p.url + p.user + ":" + p.password + "@"
			p.url = p.url + p.hostname
			if p.port
				p.url = p.url + ":" + p.port
		else
			p.url = ""

		if p.path.length > 0
			_match = p.path.match(/(.*?)(|\?.*?)(|\#.*)$/)
			p.pathname = _match[1]
			p.search = _match[2]
			if p.search == "?"
				p.search = ""
			p.fragment = _match[3]
		else
			p.search = ""
			p.pathname = ""
			p.fragment = ""

		p.href = p.origin+p.path
		p.hash = p.fragment
		if p.login
			p.auth = btoa(p.user+":"+p.password)

		# url includes user+password
		p.url = p.url + p.path
		p


	@initNodeDebugCopy: ->
		Events.listen
			type: "keyup"
			capture: true
			call: (ev) =>
				if not (ev.altKey() and ev.keyCode() == 67) # ALT-C
					return

				if ev.shiftKey()
					# remove all nodes
					i = 0
					for el in DOM.matchSelector(document.documentElement, ".cui-debug-node-copy")
						el.remove()
						i++

					CUI.toaster(text: i+" Node(s) removed.")
					return

				i = 0
				for node in CUI.DOM.matchSelector(document.documentElement, ".cui-debug-node-copyable")
					node_copy = node.cloneNode(true)
					node.parentNode.appendChild(node_copy)
					CUI.DOM.insertAfter(node, node_copy)
					node_copy.classList.add("cui-demo-node-copy")
					console.debug "Node copied. Original:", node.parentNode, node, "Copy:", node_copy
					i++

				CUI.toaster(text: i+" Node(s) copied.")
				return



	# use for CSS markings of wrongly build markup
	@setDebug: ->
		document.body.classList.add("cui-debug")

	@error: ->
		console.error.apply(console, arguments)

	@debug: ->
		console.debug.apply(console, arguments)

	@info: ->
		console.info.apply(console, arguments)

	@warn: ->
		console.warn.apply(console, arguments)


CUI.ready =>

	# initialize a markdown renderer
	marked?.setOptions
		renderer: new marked.Renderer()
		gfm: true
		tables: true
		breaks: false
		pedantic: false
		sanitize: true
		smartLists: true
		smartypants: false

	for k in ["light", "dark"]
		CUI.registerTheme(k, CUI.pathToScript+"/css/cui_#{k}.css")

	CUI.__downloadDataElement = document.createElement("a")
	CUI.__downloadDataElement.style.display = "none"
	document.body.appendChild(CUI.__downloadDataElement)

window.addEventListener "load", =>
	CUI.start()


