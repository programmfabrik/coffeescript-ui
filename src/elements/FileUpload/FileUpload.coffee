###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FileUpload extends CUI.Element
	constructor: (opts) ->
		super(opts)
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
			add_filename_to_url:
				default: false
				mandatory: true
				check: Boolean
			parallel:
				default: 2
				check: (v) ->
					v >= 1
			onAdd:
				check: Function
			onBatchStart:
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
		# console.info("FileUpload.setUrl: #{@getUrl()}.")
		@__url

	getUrl: ->
		@__url

	# returns all uploaded files including completed
	getFiles: (filter) ->
		if CUI.util.isString(filter)
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
		CUI.FileUploadFile

	queueFiles: (files) ->
		batch = ++@__batch_id
		# console.debug "FileUpload.queueFiles", files

		locked = false

		done_queuing = =>
			@_onBatchQueued?()
			@uploadNextFiles()
			locked = false

		idx = -1
		next_file = =>
			locked = true

			idx++
			if idx == files.length
				done_queuing()
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
				console.debug("FileUpload.onAdd: Skipping file, function returned 'false'.")
				locked = false
				return

			queue_file = =>
				@__files.push(f)

				@_onUpdate?(f)
				f.queue()
				locked = false
				return

			@__isQueueing = true

			CUI.decide(@_onAdd?(f, idx, files.length))
			.done =>
				queue_file()
			.fail =>
				dont_queue_file()
			.always =>
				@__isQueueing = false

		@_onBatchStart?()

		@__queuing = new CUI.Deferred()

		interval = window.setInterval(=>
			if locked
				# wait
				return

			if @__stop or @__abort
				window.clearInterval(interval)
				dfr = @__queuing
				delete(@__queuing)
				if @__stop
					delete(@__stop)
					done_queuing()
					dfr.resolve()
				else
					delete(@__abort)
					dfr.reject()
				return

			if idx < files.length
				# console.debug "queue", idx, files.length
				next_file()
			else
				window.clearInterval(interval)
				@__queuing.resolve()
				delete(@__queuing)
		,
			1)

		@

	isQueuing: ->
		!!@__queuing

	stopQueuing: (abort = false) ->
		dfr = new CUI.Deferred()
		if @__queuing
			if not abort
				@__stop = true
			else
				@__abort = true
			@__queuing.always(dfr.resolve)
		else
			dfr.resolve()
		dfr.promise()

	clear: ->
		@stopQueuing(true)
		.done =>
			while file = @__files[0]
				file.remove()

	removeFile: (file) ->
		CUI.util.removeFromArray(file, @__files)

	isDone: ->
		if @__isQueueing
			return false

		for f in @__files
			if not f.isDone()
				return false
		return true

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
			# console.debug "uploading next file", file._file.name
			@uploadFile(file)
		@

	uploadFile: (file) ->
		if @_add_filename_to_url
			file.upload(@getUrl()+file.getName(), @_name)
		else
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


	initDropZone: (_opts={}) ->

		opts = CUI.Element.readOpts _opts, "FileUpload.initDropZone",
			dropZone:
				mandatory: true
				check: (v) ->
					CUI.util.isElement(v) or CUI.util.isElement(v.DOM)
			multiple:
				mandatory: true
				default: true
				check: (v) ->
					v == true or v == false or v instanceof Function
			selector:
				check: String
			allow_drop: (ev) =>
				check: Function

		dropZone = opts.dropZone.DOM or opts.dropZone

		selector = opts.selector
		multiple = opts.multiple

		CUI.Events.ignore
			node: dropZone
			instance: @

		dropZone.classList.add("cui-file-upload-drop-zone")

		CUI.Events.listen
			node: dropZone
			type: ["dragover"]
			instance: @
			selector: selector
			call: (ev) =>
				if opts.allow_drop and not opts.allow_drop(ev)
					return ev.stop()

				CUI.FileUpload.setDropClassByEvent(ev)
				ev.stopPropagation()
				ev.preventDefault()
				return false

		CUI.Events.listen
			node: dropZone
			type: "drop"
			instance: @
			selector: selector
			call: (ev) =>
				if opts.allow_drop and not opts.allow_drop(ev)
					return ev.stop()

				CUI.FileUpload.setDropClassByEvent(ev)
				dt = ev.getNativeEvent().dataTransfer

				if dt.files?.length > 0
					warn = []
					files = []

					for file in dt.files
						# if file.size == 0
						# 	warn.push(file)
						# else
						files.push(file)
						if multiple == false
							break
						if multiple instanceof Function and multiple() == false
							break

					if warn.length > 0
						console.warn("Files empty or directories, not uploaded...", warn)

					if files.length > 0
						@queueFiles(files)

				ev.stopPropagation()
				ev.preventDefault()
				return false

		for dz in @__dropZones
			if dz == dropZone
				return @

		@__dropZones.push(dropZone)
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


	openDialog: (_opts) ->

		opts = CUI.Element.readOpts _opts, "FileUpload.openDialog",
			directory:
				check: Boolean
				mandatory: true
				default: false
			multiple:
				check: Boolean
				mandatory: true
				default: false
			fileUpload:
				check: (v) ->
					if v?.nodeName == "INPUT" and v.type == "file"
						return true
					else
						return false

		fp = @initFilePicker(opts)
		opts.fileUpload.click()
		return fp

	initFilePicker: (opts) ->
		if not opts.fileUpload
			opts.fileUpload = document.getElementById("cui-file-upload-button")

		opts.fileUpload.form.reset()

		inp = opts.fileUpload
		for k in ["webkitdirectory", "mozdirectory", "directory"]
			if opts.directory
				CUI.dom.setAttribute(inp, k, true)
			else
				CUI.dom.removeAttribute(inp, k)

		if opts.accept
			CUI.dom.setAttribute(inp, "accept", opts.accept)
		else
			CUI.dom.removeAttribute(inp, "accept")

		if opts.multiple
			CUI.dom.setAttribute(inp, "multiple", true)
		else
			CUI.dom.removeAttribute(inp, "multiple")

		dfr = new CUI.Deferred()

		CUI.Events.ignore
			node: inp

		CUI.Events.listen
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
		CUI.Events.ignore
			instance: @

		for dz in @__dropZones
			CUI.dom.removeClass(dz, "cui-file-upload-drop-zone")
		@__dropZones = []
		@

	destroy: ->
		@resetDropZones()
		super()
		@
