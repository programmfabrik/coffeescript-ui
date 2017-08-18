###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# Base class for the Coffeescript UI system. It is used for
# Theme-Management as well as for basic event management tasks.
#
# @example Startup
#

marked = require('marked')

class CUI

	@__readyFuncs = []
	@__themes = []

	@start: ->

		@CSS = new CUI.CSSLoader()

		@getPathToScript()
		trigger_viewport_resize = =>
			console.info("CUI: trigger viewport resize.")
			Events.trigger
				type: "viewport-resize"

		Events.listen
			type: "resize"
			node: window
			call: (ev, info) =>
				console.info("CUI: caught window resize event.")
				if CUI.__ng__ && !CUI.browser.ie
					trigger_viewport_resize()
				else
					CUI.scheduleCallback(ms: 500, call: trigger_viewport_resize)
				return

		Events.listen
			type: "drop"
			node: document.documentElement
			call: (ev) ->
				ev.preventDefault()

		Events.listen
			type: "keyup"
			node: window
			capture: true
			call: (ev) ->
				if ev.getKeyboard() == "C+U+I"
					CUI.toaster(text: "CUI!")

		Events.listen
			type: "keydown"
			node: window
			call: (ev) ->
				if ev.getKeyboard() == "c+"
					CUI.toaster(text: "CUI!")

				# backspace acts as "BACK" in some browser, like FF
				if ev.keyCode() == 8
					for node in CUI.DOM.elementsUntil(ev.getTarget(), null, document.documentElement)
						if node.tagName in ["INPUT", "TEXTAREA"]
							return
						if node.getAttribute("contenteditable") == "true"
							return
					# CUI.info("swalloded BACKSPACE keydown event to prevent default")
					ev.preventDefault()
				return

		document.body.scrollTop=0

		Template.load()
		if not Template.nodeByName["cui-base"] # loaded in easydbui.html
			CUI.Template.loadTemplateFile("cui.html")
			.done =>
				@ready()
		else
			@ready()
		@

	@getPathToScript: ->
		if not @pathToScript
			for s, idx in DOM.matchSelector(document.documentElement, "script")
				if m = s.src.match("(.*/)cui\.js$")
					@pathToScript = m[1]
					@script = s
					break
			assert(@pathToScript, "CUI", "Could not determine script path.")

		@pathToScript


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

	@defaults:
		FileUpload:
			name:
				"files[]"

		debug: true
		asserts: true
		asserts_alert: 'js' # or 'cui' or 'off' or 'debugger'
		class: {}

	@resolvedPromise: ->
		dfr = new CUI.Deferred()
		dfr.resolve.apply(dfr, arguments)
		dfr.promise()

	@rejectedPromise: ->
		dfr = new CUI.Deferred()
		dfr.reject.apply(dfr, arguments)
		dfr.promise()

	# calls the as arguments passed functions in order
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


	@chunkWork: (_opts = {}) ->
		opts = CUI.Element.readOpts _opts, "CUI.chunkWork",
			items:
				mandatory: true
				check: (v) ->
					CUI.isArray(v)
			chunk_size:
				mandatory: true
				default: 10
				check: (v) ->
					v >= 1
			timeout:
				mandatory: true
				default: 0
				check: (v) ->
					v >= -1
			call:
				mandatory: true
				check: (v) ->
					v instanceof Function

		chunk_size = opts.chunk_size
		timeout = opts.timeout

		assert(@ != CUI, "CUI.chunkWork", "Cannot call CUI.chunkWork with 'this' not set to the caller.")

		idx = 0
		len = opts.items.length

		next_chunk = =>
			progress = (idx+1) + " - " + Math.min(len, idx+chunk_size) + " / " +len
			# console.error "progress:", progress

			dfr.notify
				progress: progress
				idx: idx
				len: len
				chunk_size: chunk_size

			go_on = =>
				if idx + chunk_size >= len
					dfr.resolve()
				else
					idx = idx + chunk_size
					if timeout == -1
						next_chunk()
					else
						CUI.setTimeout
							ms: timeout
							call: next_chunk
				return

			ret = opts.call.call(@, opts.items.slice(idx, idx+opts.chunk_size), idx, len)
			if ret == false
				# interrupt this
				dfr.reject()
				return

			if isPromise(ret)
				ret.fail(dfr.reject).done(go_on)
			else
				go_on()

			return

		dfr = new CUI.Deferred()
		CUI.setTimeout
			ms: Math.min(0, timeout)
			call: =>
				if len > 0
					next_chunk()
				else
					dfr.resolve()

		return dfr.promise()

	# returns a Deferred, the Deferred
	# notifies the worker for each
	# object
	@chunkWorkOLD: (objects, chunkSize = 10, timeout = 0) ->
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

	@setSessionStorage: (key, value) ->
		@__setStorage("sessionStorage", key, value)

	@getSessionStorage: (key = null) ->
		@__getStorage("sessionStorage", key)

	@clearSessionStorage: ->
		@__clearStorage("sessionStorage")

	@setLocalStorage: (key, value) ->
		@__setStorage("localStorage", key, value)

	@getLocalStorage: (key = null) ->
		@__getStorage("localStorage", key)

	@clearLocalStorage: ->
		@__clearStorage("localStorage")

	@__storage: localStorage: null, sessionStorage: null

	@__setStorage: (skey, key, value) ->
		data = @__getStorage(skey)
		if value == undefined
			delete(data[key])
		else
			data[key] = value
		try
			window[skey].setItem("CUI", JSON.stringify(data))
		catch e
			console.warn("CUI.__setStorage: Storage not available.", e)
			@__storage[skey] = JSON.stringify(data)
		data


	@__getStorage: (skey, key = null) ->
		try
			data_json = window[skey].getItem("CUI")
		catch e
			console.warn("CUI.__getStorage: Storage not available.", e)
			data_json = @__storage[skey]

		if data_json
			data = JSON.parse(data_json)
		else
			data = {}

		if key != null
			data[key]
		else
			data

	@__clearStorage: (skey) ->
		try
			window[skey].removeItem("CUI")
		catch e
			console.warn("CUI.__clearStorage: Storage not available.", e)
			@__storage[skey] = null

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
			else if not isEmpty(v)
				url.push(encode_func(k) + connect_pair + encode_func(v))
			else if v != undefined
				url.push(encode_func(k))

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
			if part.length == 0
				continue

			if part.indexOf(connect_pair) > -1
				pair = part.split(connect_pair)
				key = decode_func(pair[0])
				value = decode_func(pair[1])
			else
				key = decode_func(part)
				value = ""

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

		if regex.length > 0
			s.replace(new RegExp(regex.join('|'),"g"), (word) -> map[word])
		else
			s

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
		blob = new Blob([data], type: "octet/stream")
		url = window.URL.createObjectURL(blob)
		@__downloadDataElement.href = url
		@__downloadDataElement.download = fileName
		@__downloadDataElement.click()
		window.URL.revokeObjectURL(url)


	# https://gist.github.com/dperini/729294
	@urlRegex: new RegExp(
		"^" +
		# protocol identifier
		"(?:(?:(ftp|ftps|https|http))://|)" +
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

	@error: ->
		console.warn("CUI.error is deprecated, use console.error.")
		console.error.apply(console, arguments)

	@debug: ->
		console.warn("CUI.debug is deprecated, use console.debug.")
		console.debug.apply(console, arguments)

	@info: ->
		console.warn("CUI.info is deprecated, use console.info.")
		console.info.apply(console, arguments)

	@warn: ->
		console.warn("CUI.warn is deprecated, use console.warn.")
		console.warn.apply(console, arguments)


	@escapeAttribute: (data) ->
		if isNull(data) or !isString(data)
			return ""

		data = data.replace(/"/g, "&quot;").replace(/\'/g, "&#39;")
		data


# http://stackoverflow.com/questions/9847580/how-to-detect-safari-chrome-ie-firefox-and-opera-browser
CUI.browser =
	opera: `(!!window.opr && !!opr.addons) || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0`
	firefox: `typeof InstallTrigger !== 'undefined'`
	safari: `Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0`
	ie: `/*@cc_on!@*/false || !!document.documentMode`
	chrome: `!!window.chrome && !!window.chrome.webstore`

CUI.browser.edge = `!CUI.browser.ie && !!window.StyleMedia`
CUI.browser.blink = `(CUI.browser.chrome || CUI.browser.opera) && !!window.CSS`

CUI.ready =>
	for k of CUI.browser
		if CUI.browser[k]
			document.body.classList.add("cui-browser-"+k)

	if window.marked
		CUI.defaults.marked_opts =
			renderer: new marked.Renderer()
			gfm: true
			tables: true
			breaks: false
			pedantic: false
			sanitize: true
			smartLists: true
			smartypants: false

	for i in [1..9]
		do (i) ->
			CUI["$"+i] = ->
				if arguments.length == 1
					window["$"+i] = arguments[0]
					console.debug "$"+i+" = ", arguments[0]
					return

				for arg, idx in arguments
					window["$"+i+idx] = arg
					console.debug "$"+i+idx+" = ", arg
			return

	# initialize a markdown renderer
	marked?.setOptions(CUI.defaults.marked_opts)

	nodes = CUI.DOM.htmlToNodes("<!-- CUI.CUI --><a style='display: none;'></a><!-- /CUI.CUI -->")
	CUI.__downloadDataElement = nodes[1]
	CUI.DOM.append(document.body, nodes)


if not window.addEventListener
	alert("Your browser is not supported. Please update to a current version of Google Chrome, Mozilla Firefox or Internet Explorer.")
else
	window.addEventListener("ready", =>
		CUI.start()
	)


window.CUI = CUI