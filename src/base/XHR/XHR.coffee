###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.XHR extends CUI.Element
	getGroup: ->
		"Core"

	initOpts: ->
		super()
		@addOpts
			method:
				mandatory: true
				default: "GET"
				check: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
			url:
				mandatory: true
				check: String
				check: (v) ->
					v.trim().length > 0
			user:
				check: String
			password:
				check: String
			responseType:
				mandatory: true
				default: "json"
				check: ["", "text", "json", "blob", "arraybuffer"]
			timeout:
				check: (v) ->
					v >= 0
			form:
				check: "PlainObject"
			url_data:
				check: "PlainObject"
			body: {}
			json_data: {} # can be anything
			json_pretty:
				default: false
				check: (v) ->
					v == false or v == true or CUI.util.isString(v)
			headers:
				mandatory: true
				default: {}
				check: "PlainObject"
			withCredentials:
				mandatory: true
				default: false
				check: Boolean
		@


	@readyStates:
		0: "UNSENT"
		1: "OPENED"
		2: "HEADERS_RECEIVED"
		3: "LOADING"
		4: "DONE"

	@statusText:
		"-1": "abort"
		"-2": "timeout"
		"-3": "network_failure"

	readOpts: ->
		super()
		@__xhr = new XMLHttpRequest()
		@__xhr.withCredentials = @_withCredentials

		# console.debug "XHR.readOpts", @
		@__readyStatesSeen = [@readyState()]
		@__registerEvents("download")
		@__registerEvents("upload")

		@__headers = {}
		for k, v of @_headers
			@__headers[k.toLowerCase()] = v

		if @_form
			if not @opts.method
				@_method = "POST"

		if @_url_data
			@__url = CUI.appendToUrl(@_url, @_url_data)
		else
			@__url = @_url

		set = 0
		if @_form
			set = set + 1
		if @_json_data
			set = set + 1
			if @__headers['content-type'] == undefined
				@__headers['content-type'] = 'application/json; charset=utf-8'

		if @_body
			set = set + 1

		CUI.util.assert(set <= 1, "new CUI.XHR", "opts.form, opts.json_data, opts.body are mutually exclusive.")
		@

	# type: xhr / upload
	__registerEvents: (type) ->
		keys = [
			"loadStart"
			"progress"
			"abort"
			"error"
			"load"
			"loadend"
			"timeout"
		]
		if type == "upload"
			xhr = @__xhr.upload
		else
			keys.push("readyStateChange")
			xhr = @__xhr

		for k in keys
			fn = "__"+type+"_"+k
			if not @[fn]
				continue

			do (fn, k) =>
				# console.debug "register", type, k, fn
				xhr.addEventListener k.toLowerCase(), (ev) =>
					# console.debug ev.type, type # , ev
					@[fn](ev)
		@

	__setStatus: (@__status) ->
		@__xhr.CUI_status = @__status
		@__xhr.CUI_statusText = @statusText()

	__download_abort: ->
		@__setStatus(-1)
		# console.warn("Aborted:", @__readyStatesSeen, @)

	__download_timeout: ->
		@__setStatus(-2)
		# console.warn("Timeout:", @__readyStatesSeen, @)

	__download_loadend: ->
		# console.info("Loadend:", @__readyStatesSeen, @__status, @status())
		if @isSuccess()
			@__dfr.resolve(@response(), @status(), @statusText())
		else
			if not @status() and not @__status
				# check ready states if we can determine a pseudo status
				@__setStatus(-3)
				console.debug("XHR.__download_loadend", @getXHR())

			@__dfr.reject(@response(), @status(), @statusText())
		@

	__download_readyStateChange: ->
		CUI.util.pushOntoArray(@readyState(), @__readyStatesSeen)

	__progress: (ev, type) ->
		if @readyState() == "DONE"
			return
		loaded = ev.loaded
		total = ev.total
		if ev.lengthComputable
			percent = Math.floor(loaded / total * 100)
		else
			percent = -1
		@__dfr.notify(type, loaded, total, percent)
		@

	__upload_progress: (ev) ->
		@__progress(ev, "upload")

	__download_progress: (ev) ->
		@__progress(ev, "download")

	abort: ->
		@__xhr.abort()

	isSuccess: ->
		if @__url.startsWith("file:///") and @__readyStatesSeen.join(",") == "UNSENT,OPENED,HEADERS_RECEIVED,LOADING,DONE"
			true
		else
			@__xhr.status >= 200 and @__xhr.status < 300 or @__xhr.status == 304

	status: ->
		if @__status < 0
			@__status
		else
			@__xhr.status

	statusText: ->
		if @__status < 0
			CUI.XHR.statusText[@__status+""]
		else
			@__xhr.statusText

	response: ->
		if @_responseType == "json" and @__xhr.responseType == ""
			# Internet Explorer needs some help here
			try
				res = JSON.parse(@__xhr.response)
			catch e
				res = @__xhr.response
		else
			res = @__xhr.response

		if @_responseType == "json"
			# be more compatible with jQuery
			@__xhr.responseJSON = res
		res

	start: ->
		@__xhr.open(@_method, @__url, true, @_user, @_password)

		for k, v of @__headers
			@__xhr.setRequestHeader(k, v)

		@__xhr.responseType = @_responseType
		@__xhr.timeout = @_timeout

		# console.debug "URL:", @__xhr.responseType, @__url, @_form, @_json_data
		if @_form
			data = new FormData()
			for k, v of @_form
				data.append(k, v)
			send_data = data
			# let the browser set the content-type
		else if @_json_data
			if @_json_pretty
				if @_json_pretty == true
					send_data = JSON.stringify(@_json_data, null, "\t")
				else
					send_data = JSON.stringify(@_json_data, null, @_json_pretty)
			else
				send_data = JSON.stringify(@_json_data)
		else if @_body
			send_data = @_body
		else
			send_data = undefined

		@__dfr = new CUI.Deferred()
		@__xhr.send(send_data)
		# console.debug @__xhr, @getAllResponseHeaders()
		@__dfr.promise()

	getXHR: ->
		@__xhr

	getAllResponseHeaders: ->
		headers = []
		for header in @__xhr.getAllResponseHeaders().split("\r\n")
			if header.trim().length == 0
				continue
			headers.push(header)
		headers

	getResponseHeaders: ->
		map = {}
		for header in @getAllResponseHeaders()
			match = header.match(/^(.*?): (.*)$/)
			key = match[1].toLowerCase()
			if not map[key]
				map[key] = []
			map[key].push(match[2])
		map

	getResponseHeader: (key) ->
		@getResponseHeaders()[key.toLowerCase()]?[0]

	readyState: ->
		CUI.XHR.readyStates[@__xhr.readyState]
