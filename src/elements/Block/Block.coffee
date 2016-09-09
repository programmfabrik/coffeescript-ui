class Block extends CUI.DOM
	constructor: (@opts={}) ->
		super(@opts)

		@__block = new Template
			name: @getTemplateName()
			map:
				header: true
				content: true

		@registerTemplate(@__block)

		if @_header
			@setHeader(@_header)
		else
			@__label = new Label
				text: @_text
				icon: @_icon
				multiline: true
			@setHeader(@__label)

		if @_content
			@setContent(@_content)

		@addClass("appearance-"+@_appearance)
		@addClass("cui-block-level-"+@_level)

	initOpts: ->
		super()
		@addOpts
			text:
				check: String
			header:
				check: (v) ->
					!!(isContent(v) or isString(v) or v?.DOM)
			icon:
				check: Icon
			content:
				check: (v) ->
					!!(isContent(v) or isString(v) or v?.DOM)
			level:
				mandatory: true
				default: 1
				check: [1, 2, 3]

			appearance:
				deprectated: true
				default: "normal"
				mandatory: true
				check: ["title","subtitle","normal"]

	readOpts: ->
		super()
		assert(not ((@_text or @_icon) and @_header), "new Block", "opts.text and opts.header are mutually exclusive.", opts: @opts)
		@

	getTemplateName: ->
		"block"

	setText: (txt) ->
		assert(@__label, "Block.setText", "Block must not be called with opts.header.", opts: @opts)
		@__label.setText(txt)

	setIcon: (icon) ->
		assert(@__label, "Block.setText", "Block must not be called with opts.header.", opts: @opts)
		@__label.setIcon(icon)

	setHeader: (header) ->
		@__block.replace(header, "header")

	setContent: (content) ->
		@__block.replace(content, "content")

	appendContent: (content) ->
		@__block.append(content, "content")



