class FileUploadButton extends Button
	constructor: (@opts={}) ->
		super(@opts)
		if @_drop
			@_fileUpload.initDropZone(dropZone: @DOM)

	initOpts: ->
		super()
		@addOpts
			fileUpload:
				mandatory: true
				check: FileUpload
			multiple:
				default: true
				check: Boolean
			directory:
				check: Boolean
			# whether to allow file drop on the button
			drop:
				check: Boolean

	readOpts: ->
		@__ownClick = @opts.onClick
		@opts.onClick = @__onClick
		super()

	__onClick: (ev, btn) =>
		# CUI.debug "click", @, ev, btn
		@__ownClick?.call(@, ev, btn)

		if ev.ctrlKey()
			return

		@_fileUpload.openFilePicker
			directory: ev.altKey() or ev.shiftKey() or btn._directory
			multiple: @_multiple
		return

