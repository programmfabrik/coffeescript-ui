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

	@__ng__: true

	@start: ->

		trigger_viewport_resize = =>
			# console.info("CUI: trigger viewport resize.")
			CUI.Events.trigger
				type: "viewport-resize"

		CUI.Events.listen
			type: "resize"
			node: window
			call: (ev, info) =>
				# console.info("CUI: caught window resize event.")
				if !CUI.browser.ie
					trigger_viewport_resize()
				else
					CUI.scheduleCallback(ms: 500, call: trigger_viewport_resize)
				return

		CUI.Events.listen
			type: "drop"
			node: document.documentElement
			call: (ev) ->
				ev.preventDefault()

		CUI.Events.listen
			type: "keyup"
			node: window
			capture: true
			call: (ev) ->
				if ev.getKeyboard() == "C+U+I"
					CUI.toaster(text: "CUI!")

		CUI.Events.listen
			type: "keydown"
			node: window
			call: (ev) ->
				if ev.getKeyboard() == "c+"
					CUI.toaster(text: "CUI!")

				# backspace acts as "BACK" in some browser, like FF
				if ev.keyCode() == 8
					for node in CUI.dom.elementsUntil(ev.getTarget(), null, document.documentElement)
						if node.tagName in ["INPUT", "TEXTAREA"]
							return
						if node.getAttribute("contenteditable") == "true"
							return
					# console.info("swalloded BACKSPACE keydown event to prevent default")
					ev.preventDefault()
				return

		document.body.scrollTop=0

		icons = require('../scss/icons/icons.svg')
		CUI.Template.loadText(icons)
		CUI.Template.load()

		@chainedCall.apply(@, @__readyFuncs).always =>
			@__ready = true
		@

	@getPathToScript: ->
		if not @__pathToScript
			scripts = document.getElementsByTagName('script')
			cui_script = scripts[scripts.length - 1]
			if m = cui_script.src.match("(.*/).*?\.js$")
				@__pathToScript = m[1]
			else
				CUI.util.assert(@__pathToScript, "CUI", "Could not determine script path.")

		@__pathToScript


	@ready: (func) ->
		if @__ready
			return func.call(@)

		@__readyFuncs.push(func)

	@defaults:
		FileUpload:
			name:
				"files[]"

		debug: true
		asserts: true
		asserts_alert: 'js' # or 'cui' or 'off' or 'debugger'
		class: {}

	# Returns a resolved CUI.Promise.
	@resolvedPromise: ->
		dfr = new CUI.Deferred()
		dfr.resolve.apply(dfr, arguments)
		dfr.promise()

	# Returns a rejected CUI.Promise.
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


			if CUI.util.isFunction(args[idx])
				if __this != CUI
					ret = args[idx].call(__this)
				else
					ret = args[idx]()
			else
				ret = args[idx]

			# console.debug "idx", idx, "ret", ret, "state:", ret?.state?()

			idx++

			if CUI.util.isPromise(ret)
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

	# Executes 'call' function in batches of 'chunk_size' for all the 'items'.
	# It must be called with '.call(this, opts)'
	@chunkWork: (_opts = {}) ->
		opts = CUI.Element.readOpts _opts, "CUI.chunkWork",
			items:
				mandatory: true
				check: (v) ->
					CUI.util.isArray(v)
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

		CUI.util.assert(@ != CUI, "CUI.chunkWork", "Cannot call CUI.chunkWork with 'this' not set to the caller.")

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

			if CUI.util.isPromise(ret)
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

				# console.debug idx, chunk, chunkSize, dfr.state()
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
		# console.debug target, source, methods
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
		if CUI.util.removeFromArray(timeout, @__timeouts)
			if timeout.track
				@__callTimeoutChangeCallbacks()
		return

	@__getTimeoutById: (timeoutID, ignoreNotFound = false) ->
		for timeout in @__timeouts
			if timeout.id == timeoutID
				return timeout

		CUI.util.assert(ignoreNotFound, "CUI.__getTimeoutById", "Timeout ##{timeoutID} not found.")
		null

	@resetTimeout: (timeoutID) ->
		timeout = @__getTimeoutById(timeoutID)
		CUI.util.assert(not timeout.__isRunning, "CUI.resetTimeout", "Timeout #{timeoutID} cannot be resetted while running.", timeout: timeout)
		timeout.onReset?(timeout)
		window.clearTimeout(timeout.real_id)
		old_real_id = timeout.real_id
		tid = @__startTimeout(timeout)

		return tid

	@registerTimeoutChangeCallback: (cb) ->
		@__timeoutCallbacks.push(cb)


	@setTimeout: (_func, ms=0, track) ->
		if CUI.util.isPlainObject(_func)
			ms = _func.ms or 0
			track = _func.track
			func = _func.call
			onDone = _func.onDone
			onReset = _func.onReset
		else
			func = _func

		if CUI.util.isNull(track)
			if ms == 0
				track = false
			else
				track = true

		CUI.util.assert(CUI.util.isFunction(func), "CUI.setTimeout", "Function needs to be a Function (opts.call)", parameter: _func)
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
					CUI.util.isInteger(v) and v >= 0
			track:
				default: false
				check: Boolean

		idx = CUI.util.idxInArray(opts.call, @__scheduledCallbacks, (v) -> v.call == opts.call)

		if idx > -1 and CUI.isTimeoutRunning(@__scheduledCallbacks[idx].timeoutID)
			# don't schedule the same call while it is already running, schedule
			# a new one
			idx = -1

		if idx == -1
			idx = @__scheduledCallbacks.length
			# console.debug "...schedule", idx
		else
			# function already scheduled
			# console.info("scheduleCallback, already scheduled: ", @__scheduledCallbacks[idx].timeout, CUI.isTimeoutRunning(@__scheduledCallbacks[idx].timeout))
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
			CUI.util.removeFromArray(opts.call, @__scheduledCallbacks, (v) -> v.call == opts.call)

		cb.promise

	# call: function callback to cancel
	# return: true if found, false if not
	@scheduleCallbackCancel: (_opts) ->
		opts = CUI.Element.readOpts _opts, "CUI.scheduleCallbackCancel",
			call:
				mandatory: true
				check: Function

		idx = CUI.util.idxInArray(opts.call, @__scheduledCallbacks, (v) -> v.call == opts.call)

		if idx > -1 and not CUI.isTimeoutRunning(@__scheduledCallbacks[idx].timeoutID)
			# console.error "cancel timeout...", @__scheduledCallbacks[idx].timeoutID
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
		# console.error "new timeout:", timeoutID, "ms:", ms, "current timeouts:", @__timeouts.length
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
		a= "body"
		CUI.dom.addClass(a, "cui-webdriver-test")

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
			if CUI.util.isFunction(replacer)
				encode_func = replacer
			else
				encode_func = (v) -> CUI.util.stringMapReplace(v+"", replace_map)
		else
			encode_func = (v) -> encodeURIComponent(v)

		for k, v of params
			if CUI.util.isArray(v)
				for _v in v
					url.push(encode_func(k) + connect_pair + encode_func(_v))
			else if not CUI.util.isEmpty(v)
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
			if CUI.util.isFunction(replacer)
				decode_func = replacer
			else
				decode_func = (v) -> CUI.util.stringMapReplace(v+"", replacer)
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

	# Deprecated -> Use CUI.util
	@mergeMap: (targetMap, mergeMap) ->
		for k, v of mergeMap
			if not targetMap.hasOwnProperty(k)
				targetMap[k] = v
			else if CUI.util.isPlainObject(targetMap[k]) and CUI.util.isPlainObject(v)
				CUI.util.mergeMap(targetMap[k], v)
		targetMap

	# Deprecated -> Use CUI.util
	@revertMap: (map) ->
		map_reverted = {}
		for k, v of map
			map_reverted[v] = k
		map_reverted

	# Deprecated -> Use CUI.util
	@stringMapReplace: (s, map) ->
		regex = []
		for key of map
			if CUI.util.isEmpty(key)
				continue
			regex.push(key.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"))

		if regex.length > 0
			s.replace(new RegExp(regex.join('|'),"g"), (word) -> map[word])
		else
			s

	# Deprecated -> Use CUI.util
	@isFunction: (v) ->
		v and typeof(v) == "function"

	# Deprecated -> Use CUI.util
	@isPlainObject: (v) ->
		v and typeof(v) == "object" and v.constructor?.prototype.hasOwnProperty("isPrototypeOf")

	# Deprecated -> Use CUI.util
	@isEmptyObject: (v) ->
		for k of v
			return false
		return true

	# Deprecated -> Use CUI.util
	@isMap: (v) ->
		@isPlainObject(v)

	# Deprecated -> Use CUI.util
	@isArray: (v) ->
		Array.isArray(v)

	# Deprecated -> Use CUI.util
	@inArray: (value, array) ->
		array.indexOf(value)

	# Deprecated -> Use CUI.util
	@isString: (s) ->
		typeof(s) == "string"

	@downloadData: (data, fileName) ->
		blob = new Blob([data], type: "octet/stream")
		if window.navigator.msSaveOrOpenBlob
			window.navigator.msSaveOrOpenBlob(blob, fileName)
		else
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
		if not CUI.util.isFunction(url?.match) or url.length == 0
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

	@escapeAttribute: (data) ->
		if CUI.util.isNull(data) or !CUI.util.isString(data)
			return ""

		data = data.replace(/"/g, "&quot;").replace(/\'/g, "&#39;")
		data

	@loadScript: (src) ->
		deferred = new CUI.Deferred
		script = CUI.dom.element("script", src: src)

		CUI.Events.listen
			type: "load"
			node: script
			only_once: true
			call: (ev) =>
				document.head.removeChild(script)
				deferred.resolve(ev)
				return

		CUI.Events.listen
			type: "error"
			node: script
			only_once: true
			call: (ev) =>
				document.head.removeChild(script)
				deferred.reject(ev)
				return

		document.head.appendChild(script)
		return deferred.promise()

# http://stackoverflow.com/questions/9847580/how-to-detect-safari-chrome-ie-firefox-and-opera-browser
	@browser: (->
		map =
			opera: `(!!window.opr && !!opr.addons) || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0`
			firefox: `typeof InstallTrigger !== 'undefined'`
			safari: `Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0`
			ie: `/*@cc_on!@*/false || !!document.documentMode`
			chrome: !!window.chrome and !!window.chrome.webstore
		map.edge = not map.ie && !!window.StyleMedia
		map.blink = (map.chrome or map.opera) && !!window.CSS
		map
	)()

CUI.ready =>

	for k of CUI.browser
		if CUI.browser[k]
			document.body.classList.add("cui-browser-"+k)

	CUI.defaults.marked_opts =
		renderer: new marked.Renderer()
		gfm: true
		tables: true
		breaks: false
		pedantic: false
		sanitize: true
		smartLists: true
		smartypants: false

	# initialize a markdown renderer
	marked.setOptions(CUI.defaults.marked_opts)

	nodes = CUI.dom.htmlToNodes("<!-- CUI.CUI --><a style='display: none;'></a><!-- /CUI.CUI -->")
	CUI.__downloadDataElement = nodes[1]
	CUI.dom.append(document.body, nodes)


if not window.addEventListener
	alert("Your browser is not supported. Please update to a current version of Google Chrome, Mozilla Firefox or Internet Explorer.")
else
	window.addEventListener("load", =>
		CUI.start()
	)

module.exports = CUI