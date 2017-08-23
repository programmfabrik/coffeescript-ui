###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FileUploadFile extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)

		@__progress =
			status: "CREATED"
			total: @_file.size
			loaded: 0
			percent: null

		@__dfr = new CUI.Deferred()
		# @__dfr.always =>
		#	CUI.debug @_file.name, @getStatus()
		@__promise = @__dfr.promise()

	initOpts: ->
		super()
		@addOpts
			file:
				mandatory: true
				check: (v) ->
					# avoid instanceof, so external initializers like TestCafé work
					typeof(v) == 'object'
			fileUpload:
				mandatory: true
				check: FileUpload
			batch:
				check: (v) ->
					v >= 0
			onRemove:
				check: Function
			onDequeue:
				check: Function
			# callback which can be used
			# to let the file reject or resolve
			onBeforeDone:
				check: Function

	queue: ->
		@__progress.status = "QUEUED"
		@__dfr.notify(@)
		@

	getImage: ->
		if @__imgDiv
			return @__imgDiv

		img = $img()[0]
		img.src = window.URL.createObjectURL(@_file)
		img.onload = (ev) =>
			if img.width < img.height
				@__imgDiv.removeClass("landscape")
				@__imgDiv.addClass("portrait")
			window.URL.revokeObjectURL(img.src)

		@__imgDiv = $div("cui-file-upload-file-img").addClass("landscape").append($div().append(img))

	getFile: ->
		@_file

	getFileUpload: ->
		@_fileUpload

	getPromise: ->
		@__promise

	getBatch: ->
		@_batch

	getName: ->
		@_file.webkitRelativePath or @_file.name

	getStatus: ->
		@__progress.status

	getError: ->
		@__progress.fail

	getErrorXHR: ->
		@__progress.fail_xhr

	getData: ->
		@__progress.data

	getProgress: ->
		@__progress

	getPercent: ->
		@__progress.percent

	getInfo: ->
		s = @getStatus()
		if s in ["PROGRESS", "COMPLETED"]
			return (@getPercent() or 0)+"%"
		return s

	abort: ->
		switch @getStatus()
			when "CREATED","QUEUED"
				@__progress.status = "ABORT"
				@__dfr.reject(@)
			when "STARTED","PROGRESS","COMPLETED"
				# console.debug("FileUploadFile.abort:", @__upload)
				@__upload?.abort()
			when "ABORT","DEQUEUED"
				;
				# do nothing
		@

	dequeue: ->
		@__progress.status = "DEQUEUED"
		@_onDequeue?(@)
		@

	remove: ->
		if @isDone()
			@dequeue()
		else
			@abort()
		@_fileUpload.removeFile(@)
		@_onRemove?(@)
		@

	isDone: ->
		@__progress.status not in ["CREATED","QUEUED","STARTED","PROGRESS","COMPLETED"]

	isUploading: ->
		!!@__upload

	upload: (url, name) ->
		# CUI.debug "starting upload for", @_file.name
		assert(not @__upload, "FileUploadFile.upload", "A file can only be uploaded once.", file: @)

		form = {}
		form[name] = @_file

		onDone = =>

		if @_file.size > 0

			@__upload = new CUI.XHR
				url: url
				form: form

			@__upload
			.start()
			.progress (type, loaded, total, percent) =>
				if type == "download"
					return

				# CUI.debug loaded, total, percent
				if @__progress.status == "ABORT"
					return

				if loaded == total
					@__progress.status = "COMPLETED"
				else
					@__progress.status = "PROGRESS"

				@__progress.loaded = loaded
				@__progress.total = total
				@__progress.percent = percent
				@__dfr.notify(@)
			.done (data) =>
				@__progress.data = data

				onDone = =>
					# CUI.debug @_file.name, "result:", @result
					@__progress.status = "DONE"
					@__upload = null
					@__dfr.resolve(@)

				if @_onBeforeDone
					CUI.decide(@_onBeforeDone(@))
					.done(onDone)
					.fail =>
						@__progress.status = "ABORT"
						@__upload = null
						@__dfr.reject(@)
				else
					onDone()

			.fail (data, status, statusText) =>
				# "abort" may be set by jQuery
				# console.warn("FileUploadFile.fail", status, statusText)
				if statusText == "abort"
					@__progress.status = "ABORT"

				if @__progress.status != "ABORT"
					@__progress.status = "FAILED"

				@__progress.fail = @__upload.response()
				@__progress.fail_xhr = @__upload.getXHR()
				@__upload = null
				@__dfr.reject(@)
		else
			CUI.setTimeout
				call: =>
					# console.warn("FileUploadFile.fail, Not uploading empty file.")
					@__progress.status = "FAILED"
					@__upload = null
					@__dfr.reject(@)

		@__progress.status = "STARTED"
		@__progress.percent = 0
		@__dfr.notify(@)
		@__promise
