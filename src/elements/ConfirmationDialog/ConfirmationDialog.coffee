class CUI.ConfirmationDialog extends CUI.Modal
	constructor: (@opts) ->
		super(@opts)
		@__layer_root.addClass("cui-confirmation-dialog")
		@init()

	initOpts: ->
		super()
		@addOpts
			title:
				default: ""
				check: String
			text:
				check: String
			markdown:
				mandatory: true
				default: false
				check: Boolean
			html:
				check: String
			content:
				check: (v) ->
					isContent(v) or v?.DOM
			icon:
				check: (v) ->
					v instanceof Icon or isString(v)
			buttons:
				check: (v) ->
					(CUI.isArray(v) and v.length > 0) or CUI.isFunction(v)
			footer_left: {}
			header_right: {}

		@removeOpt("pane")

	readOpts: ->
		super()
		# this needs to be set here, so that Modal / LayerPane are happy
		@_pane = {}

	init: ->
		assert(xor(@_html, xor(@_content, @_text)), "#{@__cls}.readOpts", "only opts.content, opts.text, or opts.html can be set", opts: @opts)

		if not isEmpty(@_text)
			c = new MultilineLabel(markdown: @_markdown, text: @_text)
		else if not isEmpty(@_html)
			c = new MultilineLabel(content: @_html)
		else
			c = @_content

		if not isEmpty(@_title) or not isNull(@_icon)
			l = new Label(text: @_title, icon: @_icon)

		pane = @getPane()
		for key, content of {
			header_left: l
			header_right: @_header_right
			content: c
			footer_right: @_buttons
			footer_left: @_footer_left
		}
			pane.append(content, key)
		return

	setText: (text, markdown = @_markdown) ->
		c = new MultilineLabel(markdown: markdown, text: text)
		@getPane().replace(c, "content")

	getButtons: ->
		[pane, key] = @getPane().getPaneAndKey("footer_right")
		els = DOM.findElements(pane[key]()[0], ".cui-button")
		buttons = []
		for el in els
			buttons.push(DOM.data(el, "element"))
		buttons
