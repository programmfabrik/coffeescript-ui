###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ConfirmationDialog extends CUI.Modal
	constructor: (opts) ->
		super(opts)
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
					v instanceof CUI.Icon or CUI.util.isString(v)
			markdown:
				mandatory: true
				default: false
				check: Boolean
			padded:
				check: Boolean
				default: true
			markdown_opts:
				check: "PlainObject"
			html:
				check: String
			content:
				check: (v) ->
					CUI.util.isContent(v) or v?.DOM
			icon:
				check: (v) ->
					v instanceof CUI.Icon or CUI.util.isString(v)
			buttons:
				check: (v) ->
					(CUI.util.isArray(v) and v.length > 0) or CUI.util.isFunction(v)
			footer_left: {}
			header_right: {}
			show_inline:
				check: (v) ->
					CUI.dom.isNode(v)

		@removeOpt("pane")

	setPane: ->
		super(padded: @_padded, force_header: true, force_footer: true)

	readOpts: ->
		super()
		# this needs to be set here, so that Modal / LayerPane are happy
		@_pane = {}

	show: (ev) ->
		if @_show_inline
			CUI.dom.addClass(@__layer, "cui-confirmation-dialog--show-inline")
			CUI.dom.addClass(@__show_inline, "cui-confirmation-dialog--has-show-inline")
			CUI.dom.prepend(@_show_inline, @__layer)
			# trigger Layout.all (absolute layouts)
			CUI.Events.trigger(type: "viewport-resize")
		else
			super(ev)

	hide: (ev) ->
		if @_show_inline
			CUI.dom.removeClass(@__layer, "cui-confirmation-dialog--show-inline")
			CUI.dom.removeClass(@__show_inline, "cui-confirmation-dialog--has-show-inline")
			CUI.dom.remove(@__layer)
			# trigger Layout.all (absolute layouts)
			CUI.Events.trigger(type: "viewport-resize")
		else
			super(ev)

	init: ->

		if not CUI.util.xor(@_html, CUI.util.xor(@_content, @_text))
			console.warn("#{@__cls}.readOpts", "Exactly on opts.content, opts.text, or opts.html needs to be set", opts: @opts)
			@_text = ""

		if not @_title
			@addClass("cui-confirmation-dialog--no-title")

		if not CUI.util.isEmpty(@_text)
			@__label = c = new CUI.MultilineLabel(markdown: @_markdown, markdown_opts: @_markdown_opts, text: @_text, icon: @_text_icon)
		else if not CUI.util.isEmpty(@_html)
			@__label = c = new CUI.MultilineLabel(content: @_html)
		else
			c = @_content

		if not CUI.util.isEmpty(@_title) or not CUI.util.isNull(@_icon)
			l = new CUI.Label(text: @_title, icon: @_icon)

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
		@__label = new CUI.MultilineLabel(markdown: markdown, markdown_opts: markdown_opts, text: text, icon: @_text_icon)
		@setContent(@__label)

	getButtons: ->
		[pane, key] = @getPane().getPaneAndKey("footer_right")
		els = CUI.dom.findElements(pane[key](), ".cui-button")
		buttons = []
		for el in els
			buttons.push(CUI.dom.data(el, "element"))
		buttons
