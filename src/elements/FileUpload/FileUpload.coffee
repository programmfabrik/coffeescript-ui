class FileUpload extends Element
	constructor: (@opts = {}) ->
		super(@opts)
		@__files = []
		@__dropZones = []
		@__batch_id = 0
		@__batches_done = 0

	initOpts: ->
		super()
		@addOpts
			url:
				mandatory: true
				check: String
			name:
				default: CUI.defaults.FileUpload.name
				check: String
			parallel:
				default: 2
				check: (v) ->
					v >= 1
			onAdd:
				check: Function
			onBatchQueued:
				check: Function
			onBatchDone:
				check: Function
			onProgress:
				check: Function
			onDone:
				check: Function
			onUpdate:
				check: Function
			onDequeue:
				check: Function
			onRemove:
				check: Function
			onFail:
				check: Function
			onAlways:
				check: Function
			# callback which can be used
			# to let the file reject or resolve
			onBeforeDone:
				check: Function

	readOpts: ->
		super()
		@setUrl(@_url)

	setUrl: (@__url) ->
		# CUI.info("FileUpload.setUrl: #{@getUrl()}.")
		@__url

	getUrl: ->
		@__url

	# returns all uploaded files including completed
	getFiles: (filter) ->
		if isString(filter)
			filter = [ filter ]

		files = []
		for file in @__files
			if not filter or file.getStatus() in filter
				files.push(file)
		files

	getInfo: ->
		status = {}
		total = 0
		loaded = 0
		count = 0
		done = 0
		all_done = true
		for _fuf in @getFiles()
			_p = _fuf.getProgress()
			s = _p.status
			if not status[s]
				status[s] = 1
			else
				status[s]++

			if not _fuf.isDone()
				all_done = false
			else
				done += 1

			total += _p.total
			loaded += _p.loaded
			count += 1

		info =
			status: status
			total: total
			count: count
			done: done
			loaded: loaded
			percent: Math.floor(loaded / total * 100)
			all_done: all_done

	getUploadFileClass: ->
		FileUploadFile

	queueFiles: (files) ->
		batch = ++@__batch_id
		# CUI.debug "FileUpload.queueFiles", files

		idx = -1
		next_file = =>
			idx++
			if idx == files.length
				@_onBatchQueued?()
				@uploadNextFiles()
				return

			file = files[idx]
			cls = @getUploadFileClass()
			f = new cls
				file: file
				fileUpload: @
				batch: batch
				onBeforeDone: @_onBeforeDone
				onDequeue: (f) =>
					@_onDequeue?(f)
					@_onUpdate?(f)
				onRemove: (f) =>
					@_onRemove?(f)

			# we need to queue us here before the actually
			# queuing happens, so that "onAdd" can also queue events
			# which are called after onDone is called.

			f.getPromise()
			.progress =>
				@_onProgress?(f)
				@_onUpdate?(f)
			.done =>
				@_onDone?(f)
				@_onUpdate?(f)
				@uploadNextFiles()
			.fail =>
				@_onFail?(f)
				@_onUpdate?(f)
				@uploadNextFiles()
			.always =>
				@_onAlways?(f)
				@checkBatchDone(f)

			dont_queue_file = =>
				CUI.debug("FileUpload.onAdd: Skipping file, function returned 'false'.")
				next_file()

			queue_file = =>
				@__files.push(f)

				@_onUpdate?(f)
				f.queue()
				next_file()

			CUI.decide(@_onAdd?(f))
			.done =>
				queue_file()
			.fail =>
				dont_queue_file()

		next_file()
		@

	clear: ->
		while file = @__files[0]
			file.remove()
		@

	removeFile: (file) ->
		removeFromArray(file, @__files)


	isUploading: ->
		for f in @__files
			if f.isUploading()
				return true
		return false

	uploadNextFiles: ->
		files = []
		slots = @_parallel
		for f in @__files
			if f.getStatus() == "QUEUED"
				files.push(f)
				slots--
			if f.isUploading()
				slots--
			if slots == 0
				break

		for file in files
			# CUI.debug "uploading next file", file._file.name
			@uploadFile(file)
		@

	uploadFile: (file) ->
		file.upload(@getUrl(), @_name)

	checkBatchDone: (file) ->
		alarm = false
		for f in @__files
			if f.getBatch() != file.getBatch()
				continue
			if not f.isDone()
				return
			alarm = true

		if alarm
			@_onBatchDone?()
		return


	initDropZone: (opts={}) ->
		dropZone = opts.dropZone?.DOM
		if not dropZone
			dropZone = opts.dropZone

		selector = opts.selector
		if opts.multiple == false
			multiple = false
		else
			multiple = true

		assert(dropZone instanceof jQuery and dropZone.length == 1, "FileUpload.initDropZone", "Drop Zone needs to be jQuery object with one DOM element or contain such an element in its property \"DOM\".", dropZone: dropZone)

		Events.ignore
			instance: @

		dropZone.addClass("cui-file-upload-drop-zone")

		Events.listen
			node: dropZone
			type: ["dragover"]
			instance: @
			selector: selector
			call: (ev) =>
				FileUpload.setDropClassByEvent(ev)
				ev.stopPropagation()
				ev.preventDefault()
				return false

		Events.listen
			node: dropZone
			type: "drop"
			instance: @
			selector: selector
			call: (ev) =>
				FileUpload.setDropClassByEvent(ev)
				dt = ev.getNativeEvent().dataTransfer
				if dt.files?.length > 0
					files = (file for file in dt.files)
					if multiple == false
						# only take the first
						files.splice(1)
					# CUI.debug("queing ", files)
					@queueFiles(files)
				ev.stopPropagation()
				ev.preventDefault()
				return false

		for dz in @__dropZones
			if dz == dropZone[0]
				return @

		@__dropZones.push(dropZone[0])
		@

	@setDropClassByEvent: (ev) ->
		el = ev.getCurrentTarget()

		# console.debug "FileUpload.setDropClassbyEvent", ev.getType(), el.nodeName, DOM.getAttribute(el, "row")
		switch ev.getType()
			when "dragover"

				CUI.clearTimeout(@__dropElementTimeout)
				@__dropElement?.classList.remove("cui-file-upload-drag-over")

				el.classList.add("cui-file-upload-drag-over")
				@__dropElement = el

				@__dropElementTimeout = CUI.setTimeout
					# dragover fire's every 350ms in FF
					ms: 500
					call: =>
						el.classList.remove("cui-file-upload-drag-over")
						delete(@__dropElement)

				ev.getNativeEvent().dataTransfer.dropEffect = "copy"

			when "drop"
				el.classList.remove("cui-file-upload-drag-over")
		@

	initFilePicker: (opts) ->
		# opts.directory
		# opts.multiple
		# opts.fileUpload (input)
		inp = opts.fileUpload
		for k in ["webkitdirectory", "mozdirectory", "directory"]
			if opts.directory
				DOM.setAttribute(inp, k)
			else
				DOM.removeAttribute(inp, k)

		if opts.multiple
			DOM.setAttribute(inp, "multiple")
		else
			DOM.removeAttribute(inp, "multiple")

		dfr = new CUI.Deferred()

		Events.ignore
			node: inp

		Events.listen
			type: "change"
			node: inp
			call: =>
				files = (file for file in inp.files)
				@queueFiles(files)
				inp.form.reset()
				dfr.resolve()
				return

		dfr.promise()

	resetDropZones: ->
		Events.ignore
			instance: @

		for dz in @__dropZones
			$(dz).removeClass("cui-file-upload-drop-zone")
		@__dropZones = []
		@

	destroy: ->
		@resetDropZones()
		super()
		@
