###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
CUI.Template.loadTemplateText(require('./FileUploadButton.html'));

class CUI.FileUploadButton extends CUI.Button
	constructor: (opts) ->
		super(opts)
		@addClass("cui-button")
		if @_drop
			@_fileUpload.initDropZone(dropZone: @DOM)

	initOpts: ->
		super()
		@addOpts
			fileUpload:
				mandatory: true
				check: CUI.FileUpload
			multiple:
				default: true
				check: (v) =>
					v == true or v == false or v instanceof Function
			directory:
				check: Boolean
			# whether to allow file drop on the button
			drop:
				check: Boolean
			accept:
				check: String

	getTemplateName: ->
		@__has_left = true
		@__has_right = true
		return "file-upload-button-ng"

	readOpts: ->
		@__ownClick = @opts.onClick
		@opts.onClick = @__onClick
		super()
		return

	run: (ev, btn) ->
		@__onClick(ev)

	__onClick: (ev, btn) =>

		@__ownClick?.call(@, ev, btn)

		if ev.isDefaultPrevented() or ev.isImmediatePropagationStopped()
			return

		if @_multiple instanceof Function
			multiple = @_multiple.call(@, ev, btn) == true
		else
			multiple = @_multiple

		@_fileUpload.initFilePicker
			directory: ((ev.altKey() or ev.shiftKey()) and @_multiple) or @_directory
			multiple: multiple
			accept: @_accept

		return

CUI.ready =>
	CUI.dom.append(document.body, CUI.dom.htmlToNodes("""<!-- CUI.FileUploadButton --><form style="display:none;"><input type="file" id="cui-file-upload-button"></input></form><!-- /CUI.FileUploadButton -->"""))
