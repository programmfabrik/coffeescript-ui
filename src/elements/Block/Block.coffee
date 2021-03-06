###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Block.html'));

class CUI.Block extends CUI.DOMElement
	constructor: (opts) ->
		super(opts)

		@__block = new CUI.Template
			name: @getTemplateName()
			map:
				header: true
				content: true

		@registerTemplate(@__block)

		if @_header
			@setHeader(@_header)
		else
			arr = []
			if @_text or @_icon
				@__label = new CUI.Label
					class: "cui-block-title"
					text: @_text
					icon: @_icon
					multiline: true
				arr.push(@__label)

			if @_description
				arr.push new CUI.Label
					class: "cui-block-description"
					text: @_description
					markdown: true
					multiline: true

			if arr.length > 0
				@setHeader(arr)

		if @_content
			@setContent(@_content)

		@addClass("appearance-"+@_appearance)
		@addClass("cui-block-level-"+@_level)
		@maximizeAddClasses()

		if @_padded
			@addClass("cui-block--padded")

	initOpts: ->
		super()
		@addOpts
			text:
				check: String
			description:
				check: String
			header:
				check: (v) ->
					!!(CUI.util.isContent(v) or CUI.util.isString(v) or v?.DOM)
			icon:
				check: CUI.Icon
			content:
				check: (v) ->
					!!(CUI.util.isContent(v) or CUI.util.isString(v) or v?.DOM)
			level:
				mandatory: true
				default: 1
				check: [1, 2, 3]
			appearance:
				default: "normal"
				mandatory: true
				check: ["normal","wide","muted"]
			padded:
				check: Boolean
				default: true
			maximize:
				check: Boolean
			maximize_horizontal:
				check: Boolean
				default: false
			maximize_vertical:
				check: Boolean
				default: false

	readOpts: ->
		super()
		CUI.util.assert(not ((@_text or @_icon) and @_header), "new CUI.Block", "opts.text and opts.header are mutually exclusive.", opts: @opts)
		CUI.Layout::maximizeReadOpts.call(@)
		@

	maximizeAddClasses: ->
		CUI.Layout::maximizeAddClasses.call(@)

	getTemplateName: ->
		"block"

	setText: (txt) ->
		CUI.util.assert(@__label, "Block.setText", "Block must not be called with opts.header and with opts.text or opts.icon.", opts: @opts)
		@__label.setText(txt)

	setIcon: (icon) ->
		CUI.util.assert(@__label, "Block.setText", "Block must not be called with opts.header and with opts.text or opts.icon.", opts: @opts)
		@__label.setIcon(icon)

	setHeader: (header) ->
		@__block.replace(header, "header")

	setContent: (content) ->
		@__block.replace(content, "content")

	getContent: ->
		@__block.map.content

	getHeader: ->
		@__block.map.header

	appendContent: (content) ->
		@__block.append(content, "content")
