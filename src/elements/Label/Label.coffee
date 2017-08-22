###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

marked = require('marked')
CUI.Template.loadHtml(require('./Label.html'));

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

		if @_rotate_90
			tname = "label-rotate-90"
		else if @_icon or not CUI.__ng__
			tname = "label"
		else
			tname = "label-no-icon"

		@__label = new Template
			name: tname
			map_prefix: "cui-label"
			map:
				icon: if tname == "label-no-icon" then undefined else true
				content: true

		@registerTemplate(@__label)

		if @_icon and @_icon != true
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

		if @_padded
			@addClass("cui-label--padded")

		if @_size
			@addClass("cui-label-size-"+@_size)
		else if not CUI.__ng__
			@addClass("cui-label-size-normal") #need to set normal as default for mediathek! and light

		if @_appearance
			@addClass("cui-label-appearance-"+@_appearance)
		else if not CUI.__ng__
			@addClass("cui-label-appearance-auto cui-label-appearance-normal")

		if @_manage_overflow

			if @_manage_overflow == true
				btn_opts = copyObject(CUI.defaults.class.Label.defaults.manage_overflow, true)
			else
				btn_opts = @_manage_overflow

			for k, v of {
				class: "cui-label-manage-overflow-button"
				appearance: "flat"
				switch: true
				hidden: true
				onActivate: =>
					@__label.addClass("cui-label--show-overflow")
				onDeactivate: =>
					@__label.removeClass("cui-label--show-overflow")
			}
				if not btn_opts.hasOwnProperty(k) or
					k not in ["class"]
						btn_opts[k] = v
						continue

				btn_opts[k] += " "+v

			@__overflow_button = new CUI.defaults.class.Button(btn_opts)

			# push in global markup
			@append(@__overflow_button)

			Events.listen
				node: @DOM
				type: "viewport-resize"
				call: =>
					@checkOverflowSize()
		return

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
					v instanceof Icon or isString(v) or v == true
			size:
				check: ["mini","normal","big","bigger"]
			appearance:
				check: ["normal","important","title","secondary"]
			# set to true if text is markdown
			markdown:
				mandatory: true
				default: false
				check: Boolean
			markdown_opts:
				check: "PlainObject"
			tooltip:
				check: "PlainObject"
			group:
				check: String
			rotate_90:
				default: false
				check: Boolean
			centered:
				default: false
				check: Boolean
			multiline:
				default: false
				check: Boolean
			padded:
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

		if @_markdown_opts
			@__markdown_opts = copyObject(CUI.defaults.marked_opts, false)
			for k, v of @_markdown_opts
				@__markdown_opts[k] = v
		else
			@__markdown_opts = CUI.defaults.marked_opts

		if @_manage_overflow
			assert(@_multiline, "new Label", "opts.multiline needs to be set for opts.manage_overflow", opts: @opts)
		@

	setText: (@__currentText, markdown = @__markdown) ->
		if isEmpty(@__currentText)
			@empty("content")
		else if markdown
			@setContent(CUI.DOM.htmlToNodes(marked(@__currentText, @__markdown_opts)))
			@addClass("cui-label-markdown")
		else
			@setContent($text(@__currentText))
			@removeClass("cui-label-markdown")
		@

	setTextMaxChars: (max_chars) ->
		CUI.DOM.setAttribute(@__label.map.content[0], "data-max-chars", max_chars)

	getText: ->
		@__currentText

	setContent: (content) ->
		if isString(content)
			@replace(CUI.DOM.htmlToNodes(content), 'content')
		else
			@replace(content, "content")

		if not @_manage_overflow
			return

		# append overflow button to the whole thing
		@append(@__overflow_button)

		CUI.DOM.waitForDOMInsert(node: @DOM)
		.done =>
			@checkOverflowSize()

		return


	checkOverflowSize: ->
		if not @__overflow_button
			return

		# show full content and see if it fits
		@__label.removeClass("cui-label--show-overflow")
		@__label.addClass("cui-label--measure-overflow")

		@__overflow_button.hide()

		dim_div = DOM.getDimensions(@__label.map.content)

		max_height = CUI.DOM.getCSSFloatValue(dim_div.computedStyle.maxHeight)
		if not (max_height > 0)
			max_height = dim_div.clientHeight

		# console.info("Label.checkOverflowSize: Scroll Height:", dim_div.scrollHeight, " Using Height: ", max_height, "Element:", @__label.map.content)

		if dim_div.scrollHeight > max_height
			# really to big, show button
			@__overflow_button.show()
			if @__overflow_button.isActive()
				@__label.addClass("cui-label--show-overflow")
		else
			@__label.addClass("cui-label--show-overflow")

		@__label.removeClass("cui-label--measure-overflow")
		@

	getGroup: ->
		@_group

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
