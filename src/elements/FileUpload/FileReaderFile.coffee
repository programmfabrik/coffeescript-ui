###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class FileReaderFile extends FileUploadFile
	initOpts: ->
		super()
		@addOpts
			format:
				mandatory: true
				default: "Text"
				check: ["ArrayBuffer", "Text"]

	upload: (file) ->
		# CUI.debug "upload file", file
		@__reader = new FileReader()

		for key in [
			"loadStart"
			"progress"
			"abort"
			"error"
			"load"
			"loadend"
		]
			do (key) =>
				@__reader.addEventListener key.toLowerCase(), (ev) =>
					# CUI.debug "caught event", key, @__reader
					@["__event_"+key](ev)

		switch @_format
			when "Text"
				@__reader.readAsText(@_file)
			when "ArrayBuffer"
				@__reader.readAsArrayBuffer(@_file)

		return

	getResult: ->
		@__reader.result

	__event_loadStart: ->
		@__progress.status = "STARTED"
		@__progress.percent = 0
		@__dfr.notify(@)
		return

	__event_progress: (ev) ->
		total = ev.total
		loaded = ev.loaded

		if ev.lengthComputable
			percent = Math.floor(ev.loaded / ev.total * 100)
		else
			percent = -1

		if loaded == total
			@__progress.status = "COMPLETED"
		else
			@__progress.status = "PROGRESS"

		@__progress.loaded = loaded
		@__progress.total = total
		@__progress.percent = percent

		# CUI.debug @, @getProgress()
		@__dfr.notify(@)
		return

	__event_abort: ->

	__event_error: ->

	__event_load: ->

	__event_loadend: ->
		# CUI.debug @_file.name, "result:", @__reader.result.length, @__reader.result.byteLength
		@__progress.data = @__reader.result
		@__progress.status = "DONE"
		@__upload = null
		@__dfr.resolve(@)

	abort: ->
		@__reader.abort()
