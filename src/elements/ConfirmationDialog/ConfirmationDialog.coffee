###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ConfirmationDialog extends CUI.Modal
	constructor: (@opts) ->
		super(@opts)
		@__layer_root.addClass("cui-confirmation-dialog")
		@init()

	initOpts: ->
		super()
		@addOpts
			title:
				check: String
			text:
				check: String
			text_icon:
				check: (v) ->
					v instanceof Icon or CUI.util.isString(v)
			markdown:
				mandatory: true
				default: false
				check: Boolean
			markdown_opts:
				check: "PlainObject"
			html:
				check: String
			content:
				check: (v) ->
					CUI.util.isContent(v) or v?.DOM
			icon:
				check: (v) ->
					v instanceof Icon or CUI.util.isString(v)
			buttons:
				check: (v) ->
					(CUI.isArray(v) and v.length > 0) or CUI.isFunction(v)
			footer_left: {}
			header_right: {}

		@removeOpt("pane")

	setPane: ->
		super(padded: true, force_header: true, force_footer: true)

	readOpts: ->
		super()
		# this needs to be set here, so that Modal / LayerPane are happy
		@_pane = {}

	init: ->

		if not CUI.util.xor(@_html, CUI.util.xor(@_content, @_text))
			console.warn("#{@__cls}.readOpts", "Exactly on opts.content, opts.text, or opts.html needs to be set", opts: @opts)
			@_text = ""

		if not @_title
			@addClass("cui-confirmation-dialog--no-title")

		if not CUI.util.isEmpty(@_text)
			@__label = c = new MultilineLabel(markdown: @_markdown, markdown_opts: @_markdown_opts, text: @_text, icon: @_text_icon)
		else if not CUI.util.isEmpty(@_html)
			@__label = c = new MultilineLabel(content: @_html)
		else
			c = @_content

		if not CUI.util.isEmpty(@_title) or not CUI.util.isNull(@_icon)
			l = new Label(text: @_title, icon: @_icon)

		pane = @getPane()
		for key, content of {
			header_left: l
			header_right: @_header_right
			content: c
			footer_right: @_buttons
			footer_left: @_footer_left
		}
			if content
				pane.append(content, key)
		return

	updateText: (txt) ->
		@__label?.setText(txt)
		@

	setText: (text, markdown = @_markdown, markdown_opts = @_markdown_opts) ->
		@__label = new MultilineLabel(markdown: markdown, markdown_opts: markdown_opts, text: text, icon: @_text_icon)
		@setContent(@__label)

	getButtons: ->
		[pane, key] = @getPane().getPaneAndKey("footer_right")
		els = DOM.findElements(pane[key](), ".cui-button")
		buttons = []
		for el in els
			buttons.push(DOM.data(el, "element"))
		buttons
