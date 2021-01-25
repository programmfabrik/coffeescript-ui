###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Input extends CUI.DataFieldInput
	constructor: (opts) ->
		super(opts)
		@addClass("cui-input")

		if @_textarea
			@addClass("cui-data-field--textarea")

		if @_overwrite
			@__getCursorBlocks = @__overwriteBlocks
		else
			@__getCursorBlocks = @_getCursorBlocks

		if @_content_size
			@addClass("cui-input-content-size")

		if @isRequired()
			@addClass("cui-input-required")

		if @_checkInput
			@__checkInput = @_checkInput

		if @_prevent_invalid_input
			@addClass("cui-input-has-prevent-invalid-input")

		if @__checkInput
			@addClass("cui-input-has-check-input")

		if @_appearance
			@addClass("cui-input-appearance-"+@_appearance)

		@__inputHints = {}
		@__inputHintTexts = {}

		for k in ["empty", "invalid", "valid"]
			hint = @["_"+k+"Hint"]

			if not hint
				continue

			@__inputHints[k]
			if hint instanceof CUI.Label
				@__inputHints[k] = hint
			else
				@__inputHints[k] = new CUI.defaults.class.Label(hint)

			@__inputHints[k].addClass("cui-input-"+k+"-hint")
			@__inputHintTexts[k] = @__inputHints[k].getText()

			@addClass("cui-input-has-"+k+"-hint")

		@__doSetContentSize = =>
			@__setContentSize()

		return


	initOpts: ->
		super()
		@addOpts
			spellcheck:
				default: false
				check: Boolean
			autocomplete:
				default: false
				check: Boolean
			overwrite:
				check: Boolean
			checkInput:
				check: Function
			getValueForDisplay:
				check: Function
			getValueForInput:
				check: Function
			correctValueForInput:
				check: Function
			emptyHint:
				check: (v) ->
					CUI.util.isString(v) or v instanceof CUI.Label or CUI.util.isPlainObject(v)
			invalidHint:
				check: (v) ->
					CUI.util.isString(v) or v instanceof CUI.Label or CUI.util.isPlainObject(v)
			validHint:
				check: (v) ->
					CUI.util.isString(v) or v instanceof CUI.Label or CUI.util.isPlainObject(v)
			maxLength:
				check: (v) ->
					v >= 0
			onFocus:
				check: Function
			onClick:
				check: Function
			onKeyup:
				check: Function
			onSelectionchange:
				check: Function
			incNumbers:
				default: true
				check: Boolean
			onBlur:
				check: Function
			regexp:
				check: String
			regexp_flags:
				default: ""
				check: String
			getInputBlocks:
				check: Function
			# if cursor blocks are provived, no automatic incNumberBlocks
			# takes place
			getCursorBlocks:
				check: (v) ->
					CUI.util.isFunction(v) and not @_overwrite
			placeholder:
				check: (v) ->
					CUI.util.isFunction(v) or CUI.util.isString(v)
			readonly:
				check: Boolean
			readonly_select_all:
				default: true
				check: Boolean
			textarea:
				check: Boolean
			min_rows:
				check: (v) ->
					v >= 2
				default: 2
			# limit the amount of rows in textarea input
			rows:
				check: (v) ->
					v >= 1
			content_size:
				default: false
				check: Boolean
			prevent_invalid_input:
				default: false
				check: Boolean
			required:
				default: false
				check: Boolean
			appearance:
				check: ["code"]

	readOpts: ->

		if @opts.readonly
			CUI.util.assert(not (@opts.getCursorBlocks or @opts.getInputBlocks or @opts.checkInput), "new CUI.Input", "opts.readonly conflicts with opts.getCursorBlocks, opts.getInputBlocks, opts.checkInput.")

		if @opts.textarea
			CUI.util.assert(not @opts.autocomplete, "new CUI.Input", "opts.textarea does not work with opts.autocomplete", opts: @opts)
			CUI.util.assert(not @opts.incNumbers, "new CUI.Input", "opts.textarea does not work with opts.incNumbers", opts: @opts)

		super()

		if @_readonly and @_readonly_select_all
			@_getCursorBlocks = (v) =>
				[ new CUI.InputBlock(start: 0, string: v) ]

		if @_regexp
			@__regexp = new RegExp(@_regexp, @_regexp_flags)
			# @_prevent_invalid_input = false
			@__checkInput = (value) =>
				if not @__checkInputRegexp(value)
					false
				else if @_checkInput
					@_checkInput(value)
				else
					true

		if @_required
			@__checkInput = (value) =>
				if value.trim().length == 0
					false
				else if @_checkInput
					@_checkInput(value)
				else
					true

		if @_spellcheck == false
			@__spellcheck = "false"
		else
			@__spellcheck = "default"

		# if @_rows
		# 	CUI.util.assert(@_content_size, "new CUI.Input", "opts.rows can only be used with opts.content_size set.", opts: @opts)

		if @_autocomplete == true
			@__autocomplete = "on"
		else if @_autocomplete == false
			@__autocomplete = "off"

		@

	__checkInputRegexp: (value) ->
		if @__regexp.exec(value)
			true
		else
			false

	setSpellcheck: (spellcheck) ->
		if spellcheck
			CUI.dom.setAttribute(@__input, "spellcheck", "default")
		else
			CUI.dom.setAttribute(@__input, "spellcheck", "false")

	setPlaceholder: (placeholder) ->
		CUI.dom.setAttribute(@__input, "placeholder", placeholder)

	getPlaceholder: ->
		if not @_placeholder
			return undefined

		if CUI.util.isFunction(@_placeholder)
			@_placeholder(@, @getData())
		else
			@_placeholder

	# MISSING FEATURES:
	# - tab block advance
	# - up/down cursor number decrement/increment
	# - input masking
	__createElement: (input_type="text") ->
		if @_textarea ==  true
			@__input = CUI.dom.$element "textarea", "cui-textarea",
				placeholder: @getPlaceholder()
				tabindex: "0"
				maxLength: @_maxLength
				id: "cui-input-"+@getUniqueId()
				spellcheck: @__spellcheck
				rows: @_min_rows
			@__input.style.setProperty("--textarea-min-rows", @_min_rows)

			resize = =>
				@__input.rows = @_min_rows
				rows = Math.ceil((@__input.scrollHeight - @__baseScrollHeight) / @__lineHeight);
				@__input.rows = @_min_rows + rows;

			calculateBaseHeight = =>
				value = @__input.value
				@__input.value = ""
				@__baseScrollHeight = @__input.scrollHeight
				@__input.value = value
				@__lineHeight = parseInt(CUI.dom.getComputedStyle(@__input).lineHeight, 10)

			CUI.Events.listen
				node: @__input
				type: "input"
				call: resize

			CUI.dom.waitForDOMInsert(node: @__input).done(=>
				if @isDestroyed()
					return
				calculateBaseHeight()
				resize()
			)
		else
			@__input = CUI.dom.$element "input", "cui-input",
				type: input_type
				size: 1
				placeholder: @getPlaceholder()
				tabindex: "0"
				maxLength: @_maxLength
				id: "cui-input-"+@getUniqueId()
				spellcheck: @__spellcheck
				autocomplete: @__autocomplete

		CUI.Events.listen
			node: @__input
			type: "dragstart"
			call: (ev) ->
				ev.preventDefault()

		CUI.Events.listen
			node: @__input
			type: "keydown"
			call: (ev) =>
				# console.debug "keydown on input", ev.hasModifierKey(), ev.keyCode(), @_incNumbers

				# dont return here if CTRL-Z is pressed
				if (ev.ctrlKey() and not ev.keyCode() == 90) or ev.metaKey()
					# console.debug "leaving keydown"
					return

				@lastKeyDownEvent = ev

				if @_incNumbers and not @_textarea and not @_readonly
					@incNumberBounds(ev)

				if ev.keyCode() in [37, 39, 36, 35] # LEFT, RIGHT, POS1, END
					@moveCursor(ev)
					@showCursor(ev)
					return

				if ev.keyCode() in [9, 16, 17, 18, 27, 33, 34, 35, 36, 38, 40]
					return

				# Select all, copy, paste, cut.
				if (ev.ctrlKey() or ev.metaKey()) and ev.keyCode() in [65, 67, 86, 88] # 'A', 'C', 'V', 'X'
					return

				if not @_textarea and ev.keyCode() == 13
					return

				# backspace and the cursor is slim and at the beginning
				if ev.keyCode() == 8 and 0 == @__input.selectionStart == @__input.selectionEnd
					return

				# if @_content_size and @_textarea and not @preventInvalidInput()
				# 	# in this case we are not focussing the shadow input,
				# 	# so that spellchecking gets not confused when
				# 	# we set the value of our textarea when unfocusing the shadow
				# 	# input.
				# 	return

				@__focusShadowInput()
				return

		CUI.Events.listen
			type: "keyup"
			node: @__input
			call: (ev) =>
				if ev.keyCode() in [37, 39, 36, 35] # LEFT, RIGHT, POS1, END
					ev.preventDefault()

					# movement was already done by us
					if not @cursor
						# if we dont have a cursor, we still call showCursor
						# because after a cursor movement was done by the browser
						# a derived class might overwrite showCursor and do stuff
						# although we (this Input class) does not do anything
						@showCursor(ev)

					return

				@initCursor(ev)
				@showCursor(ev)

				# if @_content_size and @_textarea and not @preventInvalidInput()
				# 	@__setContentSize()

				if @_onKeyup
					@_onKeyup(@, ev)
				return

		CUI.Events.listen
			type: "focus"
			node: @__input
			call: (ev) =>
				# console.debug "input focus event", @DOM[0], "immediate:", @hasImmediateFocus(), "shadow:", @hasShadowFocus()
				if @hasShadowFocus()
					return

				@enterInput()
				@addClass("cui-has-focus")
				@__initShadowInput()
				@_onFocus?(@, ev)
				@__invalidTooltip?.show()
				@__setCursor(ev)
				return

		oldSizes = null

		CUI.Events.listen
			type: "mousedown"
			node: @__input
			call: (ev) =>
				oldSizes = [@__input.offsetWidth, @__input.offsetHeight]

				trigger = =>
					if oldSizes[0] != @__input.offsetWidth or
						oldSizes[1] != @__input.offsetHeight
							CUI.Events.trigger
								type: "content-resize"
								node: @__input

				mev = CUI.Events.listen
					type: "mousemove"
					call: =>
						trigger()
						return

				CUI.Events.listen
					type: "mouseup"
					only_once: true
					capture: true
					call: (ev) =>
						CUI.Events.ignore(mev)
						return


		CUI.Events.listen
			type: "mouseup"
			node: @__input
			call: (ev) =>
				@__setCursor(ev)
				return

		CUI.Events.listen
			type: "blur"
			node: @__input
			call: (ev) =>

				if @hasShadowFocus()
					return

				@removeClass("cui-has-focus")
				@leaveInput()
				@__removeShadowInput()
				@_onBlur?(@, ev)
				return

		CUI.Events.listen
			type: "input"
			node: @__input
			call: (ev, info) =>
				# console.debug "#{@__cls}", ev.type, ev.isDefaultPrevented()
				if not ev.isDefaultPrevented()
					# this can happen thru CTRL-X, so we need to check again
					@checkInput()
					@moveCursor(ev)
					@showCursor(ev)
					if @getValueForStore(@__input.value) != @getValue()
						@storeValue(@__input.value)
				return

		CUI.Events.listen
			type: "paste"
			node: @__input
			call: (ev) =>
				@__focusShadowInput()

		CUI.Events.listen
			type: "click"
			node: @__input
			call: (ev) =>
				ev.stopPropagation()
				@_onClick?(@, ev)
				return

		# console.debug "listening for dom insert on ", @__input
		#
		if @_content_size
			CUI.dom.waitForDOMInsert(node: @__input)
			.done =>
				if @isDestroyed()
					return

				@setContentSize()

		@__input

	__setCursor: (ev) ->
		# console.debug "setting timeout"
		CUI.setTimeout =>
			# console.debug "focus?", @hasClass("focus")
			@initCursor(ev)
			if @cursor == null and
				(s = @__input.selectionStart) == @__input.selectionEnd and
				@__input.selectionEnd != @__input.value.length
					blocks = @getInputBlocks()
					if blocks.length > 0
						for block in blocks
							if block.start <= s <= block.end
								@markBlock(ev, block)
								break

			@showCursor(ev)
		,
			0

	getValueForStore: (value) ->
		value

	storeValue: (value, flags={}) ->
		super(@getValueForStore(value), flags)

	handleSelectionChange: ->
		@_onSelectionchange?.apply(@, arguments)

	getElement: ->
		@__input

	getUniqueIdForLabel: ->
		"cui-input-"+@getUniqueId()

	markBlock: (ev, bl) ->
		@__input.setSelectionRange(bl.start, bl.end)
		@initCursor(ev)

	remove: ->
		@__removeShadowInput()
		super()

	__focusShadowInput: ->
		if not @__shadow
			return

		# console.debug "focus shadow input"
		@__shadow_focused = true
		@__shadow.value = @__input.value
		@__shadow.focus()
		@__shadow.setSelectionRange(@__input.selectionStart, @__input.selectionEnd)

	__unfocusShadowInput: ->
		if not @hasShadowFocus()
			return

		# console.debug "unfocus shadow input"
		@setContentSize()
		@__input.focus()
		@showCursor()
		@__shadow_focused = false

	hasShadowFocus: ->
		@__shadow_focused

	setContentSize: ->
		# console.error "setting content size", !!@__contentSize, @getUniqueId()

		if not @_content_size
			return @

		if @__contentSize
			CUI.scheduleCallback
				call: @__doSetContentSize
				ms: 100
		else
			@__initContentSize()
			@__setContentSize()
			@__removeContentSize()
		@

	__initContentSize: ->
		# console.debug "initContentSize", @getUniqueId(), @__contentSize

		if @__contentSize
			return

		@__contentSize = CUI.dom.$element("textarea", "cui-input-shadow", tabindex: "-1", autocomplete: "off")

		CUI.dom.append(document.body, @__contentSize)

		style = window.getComputedStyle(@__input)

		# console.debug style

		css = {}
		for k in [
			"fontFamily"
			"fontKerning"
			"fontSize"
			"wordBreak"
			"wordSpacing"
			"wordWrap"
			"fontStretch"
			"lineHeight"
			"fontStyle"
			"fontVariant"
			"fontVariantLigatures"
			"fontWeight"
		]
			# console.debug k, style[k]
			css[k] = style[k]

		if not @_textarea
			css.whiteSpace = "nowrap"

		CUI.dom.setStyle(@__contentSize, css)
		CUI.dom.height(@__contentSize, 1)

		if @_textarea
			CUI.dom.width(@__contentSize, CUI.dom.width(@__contentSize))
			@__max_height = parseFloat(CUI.dom.getComputedStyle(@__input)["max-height"])
			@__input.style.overflow = "hidden"

			if isNaN(@__max_height)
				@__max_height = null
			else
				correct_height = parseFloat(CUI.dom.getComputedStyle(@__input)["height"]) - CUI.dom.height(@__input)
				@__max_height -= correct_height
		else
			CUI.dom.width(@__contentSize, 1)
		@

	__setContentSize: ->

		if not @__contentSize
			return

		@__contentSize.value = @__input.value

		if @hasShadowFocus()
			# we can only do this when shadow is focused,
			# otherwise the "blur" event on @__input
			# will remove @__contentSize and we will run into errors
			@__contentSize.focus()

		changed = false

		if @_textarea
			if @__input.value.length == 0
				@__contentSize.value = "A" # help IE out, so we get a height

			if CUI.dom.width(@__input) != CUI.dom.width(@__contentSize)
				CUI.dom.width(@__contentSize, CUI.dom.width(@__input))

			h = @__contentSize.scrollHeight

			if @__max_height == null or h <= @__max_height
				@__input.style.overflow = "hidden"
			else
				@__input.style.overflow = ""

			previous_height = CUI.dom.height(@__input)
			CUI.dom.height(@__input, h)

			if CUI.dom.height(@__input) != previous_height
				changed = true

			# console.error "__setContentSize", @_textarea, @__input.value, @__contentSize.value, h
		else
			w = @__contentSize.scrollWidth
			if @__contentSize.value.length == 0
				# help IE out here, IE measures one " "
				w = 1
			else
				# for now, add 1 pixel to the measurement
				# Chrome measures a Textarea width different than an Input width
				w = w + 1

			if CUI.dom.width(@__input) != w
				changed = true

			CUI.dom.width(@__input, w)

		if changed
			CUI.Events.trigger
				type: "content-resize"
				node: @__input
		@

	checkBlocks: (blocks) ->
		if not CUI.util.isArray(blocks)
			return false
		for b, idx in blocks
			CUI.util.assert(b instanceof CUI.InputBlock, "Input.getInputBlocks", "Block[#{idx}] needs to be instance of CUI.InputBlock.", blocks: blocks, block: b)
			b.idx = idx
		blocks



	getInputBlocks: ->
		if @_getInputBlocks
			blocks = @_getInputBlocks(@__input.value)
		else if @_getCursorBlocks
			blocks = @_getCursorBlocks(@__input.value)
		else
			blocks = @__getInputBlocks(@__input.value)
		@checkBlocks(blocks)

	__getInputBlocks: (v) ->
		blocks = []
		v =  @__input.value
		re = /[0-9]+/g
		blocks = []
		while (match = re.exec(v)) != null
			match_str = match[0]
			match_start = match.index
			if match_start > 0
				char_1_before = v.substr(match_start-1, 1)
			else
				char_1_before = null

			if match_start > 1
				char_2_before = v.substr(match_start-2, 1)
			else
				char_2_before = null

			if char_1_before == "-" and not char_2_before?.match(/[0-9]/)
				match_str = "-"+match_str
				match_start -= 1

			blocks.push new CUI.NumberInputBlock
				start: match_start
				string: match_str
		# console.debug "blocks", blocks
		blocks

	__overwriteBlocks: (v) ->
		blocks = []
		for i in [0...v.length]
			blocks.push new CUI.InputBlock
				start: i
				string: v.substr(i, 1)
		blocks.push new CUI.InputBlock
			start: v.length
			string: ""
		blocks

	# returns the currently exactly marked block
	# if no block is found, returns null
	getMarkedBlock: ->
		blocks = @getInputBlocks()
		if blocks == false or blocks.length == 0
			return null

		s = @__input.selectionStart
		e = @__input.selectionEnd

		for block, idx in blocks
			# console.debug match_start, match_end, match_str
			if block.start == s and block.end == e
				return block
		return null

	getSelection: ->
		s = @__input.selectionStart
		e = @__input.selectionEnd

		start: s
		end: e
		value: @__input.value
		before: @__input.value.substring(0, s)
		selected: @__input.value.substring(s, e)
		after: @__input.value.substring(e)

	setSelection: (selection) ->
		@__input.selectionStart = selection.start
		@__input.selectionEnd = selection.end

	selectAll: ->
		@__input.selectionStart = 0
		@__input.selectionEnd = @__input.value.length
		@

	updateSelection: (txt="") ->
		sel = @getSelection()
		@setValue(sel.before + txt + sel.after)
		start = sel.before.length
		end = start + txt.length
		if sel.start == sel.end
			start = end
		@setSelection(start: start, end: end)

	setValue: (v, flags = {}) ->

		if not @hasData()
			@__input?.value = v
			@setContentSize()

		super(v, flags)

	incNumberBounds: (ev) ->
		if ev.keyCode() not in [38, 40, 33, 34] # not in TAB
			return

		s = @__input.selectionStart
		e = @__input.selectionEnd
		v =  @__input.value

		blocks = @getInputBlocks()
		if blocks == false or blocks.length == 0
			return

		parts_inbetween = [v.substring(0, blocks[0].start)]
		for block, idx in blocks
			if idx == blocks.length-1
				break
			# console.debug idx, block.end, blocks[idx+1].start
			parts_inbetween.push(v.substring(block.end, blocks[idx+1].start))

		last_block = blocks[blocks.length-1]
		parts_inbetween.push(v.substring(last_block.end))

		# console.debug "blocks:", blocks
		# console.debug "parts_inbetween:", parts_inbetween
		# console.debug "s", s, "e", e, "v", v
		block_move = 0
		if ev.keyCode() in [9, 33, 34]
			# TAB, PAGE UP/DOWN  # TAB removed (above)
			if ev.shiftKey() or
				ev.keyCode() == 33
					block_move = -1
			else
				block_move = 1

		for block, idx in blocks
			# console.debug match_start, match_end, match_str
			if block.start == s and block.end == e
				if block_move
					block_jump_to = idx+block_move
					break

				if ev.keyCode() == 38
					block.incrementBlock(block, blocks)
				else
					block.decrementBlock(block, blocks)

				block_jump_to = idx
				break

			if (s == e or (@cursor and @cursor.start == @cursor.end)) and block.start <= s <= block.end
				# mark block
				# console.debug "cursor in block", s, e
				block_jump_to = idx
				continue

		if block_move and s == 0 and e == v.length and blocks.length > 1
			if block_move == -1
				block_jump_to = blocks.length-1
			else
				block_jump_to = 0

		if bl = blocks[block_jump_to]
			new_str = [parts_inbetween[0]]
			for block, idx in blocks
				new_str.push(block.string)
				new_str.push(parts_inbetween[idx+1])

			new_value = new_str.join("")

			if not @checkInput(new_value)
				ev.preventDefault()
				return

			@__input.value = new_value
			@markBlock(ev, bl)
			@storeValue(@__input.value)
			ev.preventDefault()

		return

	__removeContentSize: ->
		CUI.dom.remove(@__contentSize)
		@__contentSize = null
		@

	__removeShadowInput: ->
		# console.error "removeShadowInput", @getUniqueId()
		@__removeContentSize()

		CUI.dom.remove(@__shadow)
		@__shadow = null
		@__shadow_focused = false
		@

	preventInvalidInput: ->
		if @__checkInput and @_prevent_invalid_input
			true
		else
			false

	__initShadowInput: ->
		if not (@preventInvalidInput() or @_content_size or @_correctValueForInput or @_readonly or @_rows)
			return

		if @__shadow
			return

		# console.debug "initShadowInput", @getUniqueId()
		#
		if @_textarea
			@__shadow = CUI.dom.$element("textarea", "cui-input-shadow")
		else
			@__shadow = CUI.dom.$element("input", "cui-input-shadow", type: "text")

		@__shadow.setAttribute("tabindex", "-1")
		@__shadow.setAttribute("autocomplete", "off")
		CUI.dom.append(document.body, @__shadow)

		if @_content_size
			@__initContentSize()

		CUI.Events.listen
			type: "input"
			node: @__shadow
			call: (ev) =>
				@__shadowInput(ev)
				# console.debug ev.type, "unfocus shadow input"
				@__unfocusShadowInput()
				new CUI.Event
					type: "input"
					node: @__input
				.dispatch()
				return

		CUI.Events.listen
			type: "keyup"
			node: @__shadow
			call: (ev) =>
				# console.debug ev.type, "unfocus shadow input"
				@__unfocusShadowInput()
				# console.debug "shadow", ev.type
				return

		@


	__shadowInput: (ev) ->
		shadow_v = @__shadow.value

		if @_rows and shadow_v.split("\n").length > @_rows
			return

		if @preventInvalidInput() and shadow_v.length > 0
			ret = @checkInput(@correctValueForInput(shadow_v))
			# console.debug "checking shadow input", ret, shadow_v
			if ret == false
				return

		if not @_readonly
			@__input.value = @correctValueForInput(shadow_v)
			@__input.setSelectionRange(@__shadow.selectionStart, @__shadow.selectionEnd)

		# console.debug "shadow before init cursor", @cursor?.start.idx, "-", @cursor?.end.idx
		@initCursor(ev)
		# console.debug "shadow after init cursor", @cursor?.start.idx, "-", @cursor?.end.idx
		return

	checkValue: (v) ->
		if not CUI.util.isString(v) or null
			throw new Error("#{@__cls}.checkValue(value): Value needs to be String or null.")
		@

	render: ->
		super()
		@replace(@__createElement(), @getTemplateKeyForRender())

		# @append(@getChangedMarker(), @getTemplateKeyForRender())

		for k in ["empty", "invalid", "valid"]
			@append(@__inputHints[k], @getTemplateKeyForRender())
		@

	getTemplateKeyForRender: ->
		null

	isRequired: ->
		@_required

	updateInputState: (@__inputState=@__inputState) ->

		if @hasUserInput()
			@addClass("cui-input-has-user-input")
			@removeClass("cui-input-has-no-user-input")
		else
			@removeClass("cui-input-has-user-input")
			@addClass("cui-input-has-no-user-input")

		state = @getInputState()

		switch state
			when "empty", "valid"
				@removeClass("cui-input-invalid")
			when "invalid"
				@addClass("cui-input-invalid")

		for k in ["empty", "invalid", "valid"]
			CUI.dom.hideElement(@__inputHints[k]?.DOM)

		if not @hasUserInput() and state == "invalid"
			CUI.dom.showElement(@__inputHints.empty?.DOM)
		else
			CUI.dom.showElement(@__inputHints[state]?.DOM)
		@

	getInputState: ->
		if @__inputState != false
			return "valid"

		if @hasUserInput() or @isRequired()
			return "invalid"

		return "empty"

	leaveInput: ->
		if @getInputState() != "invalid"
			@__input.value = @getValueForDisplay()
			@checkInput()
		@

	enterInput: ->
		if @getInputState() != "invalid"
			@__input.value = @getValueForInput()
			@checkInput()
		@

	hasUserInput: ->
		@__input.value.length > 0

	checkInput: (value) ->
		state = @__checkInputInternal(value)
		if not @hasShadowFocus()
			@updateInputState(state)
		state

	__checkInputInternal: (value = @__input.value) ->
		if @__checkInput
			@__checkInput(value)
		else
			true

	setInputHint: (txt) ->
		@__inputHints.input?.setText(txt)

	setInvalidHint: (txt) ->
		@__inputHints.invalid?.setText(txt)

	setValidHint: (txt) ->
		@__inputHints.valid?.setText(txt)

	displayValue: ->
		super()
		value = @getValueForDisplay() or ""

		if value != @__input.value
			# prevent focus loss if value is the same
			@__input.value = value
		@checkInput()
		@

	getValueForDisplay: ->
		if @_getValueForDisplay
			@_getValueForDisplay(@, @getValue())
		else
			@getValue()

	getValueForInput: ->
		if @_getValueForInput
			@_getValueForInput(@, @getValue())
		else
			@getValue()

	correctValueForInput: (value) ->
		if @_correctValueForInput
			@_correctValueForInput(@, value)
		else
			value

	getDefaultValue: ->
		""

	getValue: ->
		if @hasData()
			super()
		else
			@__input?.value

	enable: ->
		super()
		@__input?.removeAttribute("disabled")

	disable: ->
		super()
		@__input?.setAttribute("disabled", true)

	focus: ->
		@__input?.focus()
		@

	getCursorBlocks: ->
		blocks = @__getCursorBlocks?(@__input.value)
		@checkBlocks(blocks)

	findBlock: (blocks, idx, cut) ->
		for block in blocks
			if idx == block.start == block.end
				return block
			if cut == "full" and idx >= block.start and idx <= block.end
				return block
			if cut == "left" and idx >= block.start and idx < block.end
				return block
			if cut == "right" and idx > block.start and idx <= block.end
				return block
			if cut == "touch" and idx >= block.start and idx <= block.end
				return block
		return null

	initCursor: (ev) ->
		blocks = @getCursorBlocks()
		if blocks == false
			@cursor = null
			return

		if blocks.length == 0
			console.warn "initCursor: 0 cursor blocks"
			@cursor = null
			return

		# console.debug "initCursor", ev.type, ev.which, ev.shiftKey # , blocks

		# find block which fits the current selection
		# positions
		#
		s = @__input.selectionStart
		e = @__input.selectionEnd
		len = @__input.value.length

		# console.debug "requested: start: ",s, "end: ",e

		@cursor =
			shift: @cursor?.shift
			start: null
			end: null

		if ev.getType() == "keyup" and ev.keyCode() == 16
			@cursor.shift = null

		if ev.getType() == "keydown" and ev.keyCode() in [46, 8]
			@cursor.shift = null

		if CUI.util.isUndef(@cursor.shift)
			@cursor.shift = null

		@cursor.start = @findBlock(blocks, s, "left")
		@cursor.end = @findBlock(blocks, e, "right")

		# console.debug "found cursors", @cursor.start, @cursor.end

		if @cursor.end?.idx < @cursor.start?.idx
			@cursor.end = @cursor.start

		if s == e and not @cursor.start and not @cursor.end
			# find closest blocks to the left and right
			dist_left = null
			dist_right = null
			for i in [s..0] by -1
				block_left = @findBlock(blocks, i, "left")
				if block_left
					dist_left = (s-i)
					break
			for i in [s...len] by 1
				block_right = @findBlock(blocks, i, "left")
				if block_right
					dist_right = (i-s)
					break
			if block_right and not block_left
				@cursor.start = block_right
			else if block_left and not block_right
				@cursor.start = block_left
			else if block_left and block_right
				if dist_left > dist_right
					@cursor.start = block_right
				else
					@cursor.start = block_left
			# console.debug "found block in dist:", dist_left, dist_right

		range = @getRangeFromCursor()

		# console.debug "cursor", "start:", @cursor.start?.idx, "end:", @cursor.end?.idx, range
		if not @cursor.start and not @cursor.end
			@cursor.start = @cursor.end = blocks[blocks.length-1]
		else if not @cursor.start
			@cursor.start = @cursor.end
		else if not @cursor.end
			@cursor.end = @cursor.start

		# console.debug "cursor CLEANED", "start:", @cursor.start?.idx, "end:", @cursor.end?.idx, range
		# console.debug "range", range

		if range[0] == s and range[1] == e
			1
			# console.debug "cursor is good"
		return

	showCursor: (ev) ->

		if @cursor
			r = @getRangeFromCursor()
			@__input.setSelectionRange(r[0], r[1])
		@

	checkSelectionChange: ->
		sel = @getSelection()

		if @__currentSelection and (
			@__currentSelection.start != sel.start or
			@__currentSelection.end != sel.end )
				@handleSelectionChange()

		@__currentSelection = sel
		@

	getRangeFromCursor: ->
		[ @cursor.start?.start, @cursor.end?.end ]


	moveCursor: (ev) ->
		if not @cursor
			return

		ev.preventDefault()

		# console.debug "moveCursor", ev.type, ev.which
		blocks = @getCursorBlocks()
		if blocks == false or blocks.length == 0
			# console.debug "no block found"
			@cursor = null
			return

		if ev.keyCode() == 36 # POS1
			@cursor.start = blocks[0]
			@cursor.end = blocks[0]
			return

		if ev.keyCode() == 35 # END
			@cursor.start = blocks[blocks.length-1]
			@cursor.end = blocks[blocks.length-1]
			return

		if @lastKeyDownEvent?.keyCode() == 46 # DELETE
			# dont move cursor, positioning will be down
			# in keyup
			@initCursor(@lastKeyDownEvent)
			return

		if @lastKeyDownEvent?.keyCode() == 8 # BACKSPACE
			@initCursor(@lastKeyDownEvent)
			return

		left = ev.keyCode() == 37
		right = (ev.keyCode() == 39 or ev.getType() == "input")

		s_idx = @cursor.start.idx
		e_idx = @cursor.end.idx

		if not blocks[s_idx] or not blocks[e_idx]
			console.warn "repositioning cursor, not executing cursor move"
			@initCursor(ev)
			return

		if ev.keyCode() == 46 # DELETE
			return


		if ev.shiftKey() and @cursor.shift == null
			@cursor.shift = @cursor.end.idx

		if @cursor.shift == null
			if s_idx == e_idx # move only if we have a single cursor
				if left
					if s_idx > 0
						@cursor.start = blocks[s_idx-1]
				else if right
					if s_idx < blocks.length-1
						@cursor.start = blocks[s_idx+1]
				@cursor.end = @cursor.start
			else if left
				@cursor.end = @cursor.start
			else if right
				@cursor.start = @cursor.end
		else
			c_idx = @cursor.shift
			# console.debug "SHIFT ME! ", "start:", s_idx, "end:", e_idx, "shift:", c_idx
			if left
				if c_idx >= e_idx
					if s_idx > 0
						@cursor.start = blocks[s_idx-1]
				else
					@cursor.end = blocks[e_idx-1]
			else if right
				if c_idx > s_idx
					@cursor.start = blocks[s_idx+1]
				else
					if e_idx < blocks.length-1
						@cursor.end = blocks[e_idx+1]

		#console.debug "moveCursor new range", @getRangeFromCursor()
		@

	destroy: ->
		@__removeShadowInput()
		super()

	@uniqueId: 0
