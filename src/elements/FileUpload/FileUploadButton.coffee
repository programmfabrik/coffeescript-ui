class FileUploadButton extends Button
	constructor: (@opts={}) ->
		super(@opts)
		@addClass("cui-button")
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

	getTemplateName: ->
		@__has_left = true
		@__has_right = true
		if CUI.__ng__
			return "file-upload-button-ng"
		else
			return "file-upload-button"

	readOpts: ->
		@__ownClick = @opts.onClick
		@opts.onClick = @__onClick
		super()

	__onClick: (ev, btn) =>

		@__ownClick?.call(@, ev, btn)

		if ev.isDefaultPrevented() or ev.isImmediatePropagationStopped()
			return

		uploadBtn = document.getElementById("cui-file-upload-button")
		uploadBtn.form.reset()

		@_fileUpload.initFilePicker
			directory: (ev.altKey() or ev.shiftKey() and @_multiple) or @_directory
			multiple: @_multiple
			fileUpload: uploadBtn

		return

CUI.ready =>
	CUI.DOM.append(document.body, CUI.DOM.htmlToNodes("""<!-- CUI.FileUploadButton --><form style="display:none;"><input type="file" id="cui-file-upload-button"></input></form><!-- /CUI.FileUploadButton -->"""))
