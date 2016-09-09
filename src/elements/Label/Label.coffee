

# @param [Object] options for {Label} creation
# @option options [boolean] centered , label will be centered with css style 'position: absolute'.
class CUI.Label extends CUI.DOM

	@defaults:
		manage_overflow:
			icon_inactive: "down"
			icon_active: "up"
			active_css_class: ""

	constructor: (@opts={}) ->
		super(@opts)

		@__label = new Template
			name: if @_rotate_90 then "label-rotate-90" else "label"
			map_prefix: "label"
			map:
				icon: true
				content: true

		@registerTemplate(@__label)

		if @_icon
			@setIcon(@_icon)

		if not isEmpty(@_text)
			@setText(@_text)
		else
			@setContent(@_content)

		if @_tooltip
			tt_opts = copyObject(@_tooltip)
			tt_opts.element ?= @DOM
			@__tooltip = new Tooltip(tt_opts)

		if @_multiline
			@addClass("cui-label-multiline")

		if @_centered
			@addClass("cui-label-centered")

		if @_markdown
			@addClass("cui-label-markdown")

		if @_manage_overflow
			@addClass("cui-label-manage-overflow")

		if @_size == "auto"
			@addClass("cui-label-size-normal") #additionally used as a fallback

		@addClass("cui-label-size-"+@_size)

		if @_appearance == "auto"
			@addClass("cui-label-appearance-normal") #additionally used as a fallback
		@addClass("cui-label-appearance-"+@_appearance)


	initOpts: ->
		super()
		@addOpts
			text:
				check: (v) ->
					isString(v) or isNumber(v)
			content:
				check: (v) ->
					isContent(v) or isString(v)
			icon:
				check: (v) ->
					v instanceof Icon or isString(v)
			size:
				default: "auto"
				mandatory: true
				check: ["auto","mini","normal","big","bigger"]
			# set to true if text is markdown
			markdown:
				mandatory: true
				default: false
				check: Boolean
			appearance:
				default: "auto"
				mandatory: true
				check: ["auto","normal","important","title"]
			tooltip:
				check: "PlainObject"
			rotate_90:
				default: false
				check: Boolean
			centered:
				default: false
				check: Boolean
			multiline:
				default: false
				check: Boolean
			manage_overflow:
				check: (v) ->
					CUI.isPlainObject(v) or v == true or v == false


	readOpts: ->
		super()
		if isNull(@_text) and isNull(@_content)
			@_text = ""

		if @_markdown
			assert(not @_content, "new "+@__cls, "opts.markdown cannot be combined with opts.content, use opts.text instead.", opts: @opts)
			if not marked
				CUI.error("new Label: Could not find markdown renderer 'marked'. Disabling markedown option.", opts: @opts)
				@__markdown = false
			else
				@__markdown = true

		@__currentText = null
		assert(xor(isNull(@_text), isNull(@_content)), "new Label", "opts.text and opts.content cannot both be set.", opts: @opts)

		if @_manage_overflow
			assert(@_multiline, "new Label", "opts.multiline needs to be set for opts.manage_overflow", opts: @opts)
		@

	setText: (@__currentText, markdown = @__markdown) ->
		if isEmpty(@__currentText)
			@empty("content")
		else if markdown
			@setContent(CUI.DOM.htmlToNodes(marked(@__currentText)))
		else
			@setContent($text(@__currentText))
		@

	getText: ->
		@__currentText

	setContent: (content) ->
		if @_manage_overflow
			@__overflow_content_div = $div("cui-label-manage-overflow-content-container").append(content)
			@replace(@__overflow_content_div, "content")

			@__overflow_button_div = $div("cui-label-manage-overflow-button-container")

			if @_manage_overflow == true
				btn_opts = CUI.defaults.class.Label.defaults.manage_overflow
			else
				btn_opts = @_manage_overflow

			for k, v of {
				class: "cui-label-manage-overflow-button"
				appearance: "flat"
				switch: true
				activate_initial: false
				onActivate: =>
					@setOverflowSize(true)
				onDeactivate: =>
					@setOverflowSize(false)
			}
				if not btn_opts.hasOwnProperty(k) or
					k not in ["class"]
						btn_opts[k] = v
						continue

				btn_opts[k] += " "+v

			overflow_button = new CUI.defaults.class.Button(btn_opts)
			@__overflow_button_div.append(overflow_button.DOM[0])
			@append(@__overflow_button_div, "content")

			CUI.DOM.waitForDOMInsert(node: @DOM[0])
			.done =>
				@initOverflowSize()

			Events.listen
				node: @DOM[0]
				type: "viewport-resize"
				call: =>
					@initOverflowSize()

		else
			@replace(content, "content")


	initOverflowSize: ->
		# reset style
		CUI.DOM.setStyle(@__overflow_content_div[0],
			height: ""
		)
		CUI.DOM.setStyle(@__label.map.content[0],
			height: ""
			maxHeight: ""
		)
		DOM.hideElement(@__overflow_button_div[0])
		dim_div = DOM.getDimensions(@__label.map.content[0])

		if not (dim_div.scrollHeight > dim_div.clientHeight)
			return

		DOM.showElement(@__overflow_button_div[0])

		dim_content = DOM.getDimensions(@__overflow_content_div[0])
		dim_btn = DOM.getDimensions(@__overflow_button_div[0])

		@__overflow_heights =
			content_hide: dim_div.clientHeight - dim_btn.marginBoxHeight
			content_show: dim_content.scrollHeight
			button: dim_btn.marginBoxHeight

		@setOverflowSize()
		@

	setOverflowSize: (showOverflow = false) ->

		if showOverflow
			content_height = @__overflow_heights.content_show
		else
			content_height = @__overflow_heights.content_hide

		# we need to show the button by making the content smaller
		CUI.DOM.setDimensions(@__overflow_content_div[0],
			marginBoxHeight: content_height
		)
		CUI.DOM.setDimensions(@__label.map.content[0],
			height: content_height + @__overflow_heights.button
		)
		CUI.DOM.setStyle(@__label.map.content[0],
			maxHeight: content_height + @__overflow_heights.button
		)
		Events.wait
			type: "transitionend"
			node: @__label.map.content
		.always =>
			Events.trigger
				type: "content-resize"
				node: @__label.map.content
		@

	setIcon: (icon) ->
		if icon instanceof Icon
			__icon = icon
		else if not isEmpty(icon)
			__icon = new Icon(icon: icon)
		else
			__icon = null

		@replace(__icon, "icon")
		@

	destroy: ->
		@__tooltip?.destroy()
		super()


CUI.defaults.class.Label = CUI.Label

Label = CUI.Label
