###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Input extends CUI.DataFieldInput
	constructor: (@opts={}) ->
		super(@opts)
		@addClass("cui-input")

		if @_overwrite
			@__getCursorBlocks = @__overwriteBlocks
		else
			@__getCursorBlocks = @_getCursorBlocks

		if @_content_size
			@addClass("cui-input-content-size")

		if @isRequired()
			@addClass("cui-input-required")

		if @_checkInput
			@addClass("cui-input-has-check-input")

		if @_prevent_invalid_input
			@addClass("cui-input-has-prevent-invalid-input")

		@__inputHints = {}
		@__inputHintTexts = {}

		for k in ["empty", "invalid", "valid"]
			hint = @["_"+k+"Hint"]

			if not hint
				continue

			@__inputHints[k]
			if hint instanceof Label
				@__inputHints[k] = hint
			else
				@__inputHints[k] = new CUI.defaults.class.Label(hint)

			@__inputHints[k].addClass("cui-input-"+k+"-hint")
			@__inputHintTexts[k] = @__inputHints[k].getText()

			@addClass("cui-input-has-"+k+"-hint")

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
					isString(v) or v instanceof Label or CUI.isPlainObject(v)
			invalidHint:
				check: (v) ->
					isString(v) or v instanceof Label or CUI.isPlainObject(v)
			validHint:
				check: (v) ->
					isString(v) or v instanceof Label or CUI.isPlainObject(v)
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
					CUI.isFunction(v) and not @_overwrite
			placeholder:
				check: (v) ->
					CUI.isFunction(v) or isString(v)
			readonly:
				check: Boolean
			readonly_select_all:
				default: true
				check: Boolean
			textarea:
				check: Boolean
			content_size:
				default: false
				check: Boolean
			prevent_invalid_input:
				default: false
				check: Boolean
			required:
				default: false
				check: Boolean

	readOpts: ->
		if not isEmpty(@opts.regexp)
			assert(not (@opts.checkInput), "new Input", "opts.regexp conflicts with opts.checkInput.")
			assert(not @opts.hasOwnProperty("prevent_invalid_input"), "new Input", "opts.prevent_invalid_input conflicts with opts.regexp.")

		if @opts.readonly
			assert(not (@opts.getCursorBlocks or @opts.getInputBlocks or @opts.checkInput), "new Input", "opts.readonly conflicts with opts.getCursorBlocks, opts.getInputBlocks, opts.checkInput.")

		if @opts.textarea
			assert(not @opts.autocomplete, "new Input", "opts.textarea does not work with opts.autocomplete", opts: @opts)
			assert(not @opts.incNumbers, "new Input", "opts.textarea does not work with opts.incNumbers", opts: @opts)

		super()

		if @_readonly and @_readonly_select_all
			@_getCursorBlocks = (v) =>
				[ new InputBlock(start: 0, string: v) ]

		if @_regexp
			@__regexp = new RegExp(@_regexp, @_regexp_flags)
			@_prevent_invalid_input = false
			@_checkInput = @__checkInputRegexp

		if @_required and not @_checkInput
			@_checkInput = (opts) =>
				opts.value.trim().lengt > 0

		if @_spellcheck == false
			@__spellcheck = "false"
		else
			@__spellcheck = "default"

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
			DOM.setAttribute(@__input0, "spellcheck", "default")
		else
			DOM.setAttribute(@__input0, "spellcheck", "false")

	setPlaceholder: (placeholder) ->
		DOM.setAttribute(@__input[0], "placeholder", placeholder)

	getPlaceholder: ->
		if not @_placeholder
			return undefined

		if CUI.isFunction(@_placeholder)
			@_placeholder(@, @getData())
		else
			@_placeholder

	# MISSING FEATURES:
	# - tab block advance
	# - up/down cursor number decrement/increment
	# - input masking

	__createElement: (input_type="text") ->
		if @_textarea ==  true
			@__input = $element "textarea", "cui-textarea",
				placeholder: @getPlaceholder()
				tabindex: "0"
				id: "cui-input-"+@getUniqueId()
				spellcheck: @__spellcheck
		else
			if CUI.__ng__
				# this is the way to make input not behave irratically
				size = 1
			else
				size = undefined

			@__input = $element "input", "cui-input",
				type: input_type
				size: size
				placeholder: @getPlaceholder()
				tabindex: "0"
				id: "cui-input-"+@getUniqueId()
				spellcheck: @__spellcheck
				autocomplete: @__autocomplete

		Events.listen
			node: @__input
			type: "dragstart"
			call: (ev) ->
				ev.preventDefault()

		Events.listen
			node: @__input
			type: "keydown"
			call: (ev) =>
				# CUI.debug "keydown on input", ev.shiftKey, ev.which, @_incNumbers
				@lastKeyDownEvent = ev

				if @_incNumbers and not @_textarea and not @_readonly
					@incNumberBounds(ev)

				if ev.keyCode() in [37, 39, 36, 35] # LEFT, RIGHT, POS1, END
					@moveCursor(ev)
					@showCursor(ev)
					return

				if ev.keyCode() in [9, 16, 17, 18, 27, 33, 34, 35, 36, 38, 40]
					return

				if not @_textarea and ev.keyCode() == 13
					return

				# backspace and the cursor is slim and at the beginning
				if ev.keyCode() == 8 and 0 == @__input0.selectionStart == @__input0.selectionEnd
					return

				# if @_content_size and @_textarea and not @preventInvalidInput()
				# 	# in this case we are not focussing the shadow input,
				# 	# so that spellchecking gets not confused when
				# 	# we set the value of our textarea when unfocusing the shadow
				# 	# input.
				# 	return

				@__focusShadowInput()
				return

		Events.listen
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

		Events.listen
			type: "focus"
			node: @__input
			call: (ev) =>
				# CUI.debug "input focus event", @DOM[0], "immediate:", @hasImmediateFocus(), "shadow:", @hasShadowFocus()
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

		Events.listen
			type: "mousedown"
			node: @__input
			call: (ev) =>
				oldSizes = [@__input0.offsetWidth, @__input0.offsetHeight]

				trigger = =>
					if oldSizes[0] != @__input0.offsetWidth or
						oldSizes[1] != @__input0.offsetHeight
							Events.trigger
								type: "content-resize"
								node: @__input

				mev = Events.listen
					type: "mousemove"
					call: =>
						trigger()
						return

				Events.listen
					type: "mouseup"
					only_once: true
					capture: true
					call: (ev) =>
						Events.ignore(mev)
						return


		Events.listen
			type: "mouseup"
			node: @__input
			call: (ev) =>
				@__setCursor(ev)
				return

		Events.listen
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

		Events.listen
			type: "input"
			node: @__input
			call: (ev, info) =>
				# CUI.debug "#{@__cls}", ev.type, ev.isDefaultPrevented()
				if not ev.isDefaultPrevented()
					# this can happen thru CTRL-X, so we need to check again
					@checkInput()
					@moveCursor(ev)
					@showCursor(ev)
					if @getValueForStore(@__input0.value) != @getValue()
						@storeValue(@__input0.value)
				return

		Events.listen
			type: "paste"
			node: @__input
			call: (ev) =>
				@__focusShadowInput()

		Events.listen
			type: "click"
			node: @__input
			call: (ev) =>
				ev.stopPropagation()
				@_onClick?(@, ev)
				return

		@__input0 = @__input[0]

		# CUI.debug "listening for dom insert on ", @__input
		#
		if @_content_size
			DOM.waitForDOMInsert(node: @__input)
			.done =>
				if @isDestroyed()
					return

				@setContentSize()

		@__input

	__setCursor: (ev) ->
		# CUI.debug "setting timeout"
		CUI.setTimeout =>
			# CUI.debug "focus?", @hasClass("focus")
			@initCursor(ev)
			if @cursor == null and
				(s = @__input0.selectionStart) == @__input0.selectionEnd and
				@__input0.selectionEnd != @__input0.value.length
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
		@__input0.setSelectionRange(bl.start, bl.end)
		@initCursor(ev)

	remove: ->
		@__removeShadowInput()
		super()

	__focusShadowInput: ->
		if not @__shadow
			return

		# CUI.debug "focus shadow input"
		@__shadow_focused = true
		@__shadow0.value = @__input0.value
		@__shadow0.focus()
		@__shadow0.setSelectionRange(@__input0.selectionStart, @__input0.selectionEnd)

	__unfocusShadowInput: ->
		if not @hasShadowFocus()
			return

		# CUI.debug "unfocus shadow input"
		@setContentSize()
		@__input0.focus()
		@showCursor()
		@__shadow_focused = false

	hasShadowFocus: ->
		@__shadow_focused

	setContentSize: ->
		# console.error "setting content size", !!@__contentSize, @getUniqueId()

		if not @_content_size
			return @

		if @__contentSize
			@__setContentSize()
		else
			@__initContentSize()
			@__setContentSize()
			@__removeContentSize()
		@

	__initContentSize: ->
		# CUI.debug "initContentSize", @getUniqueId(), @__contentSize

		if @__contentSize
			return

		@__contentSize = $element("textarea", "cui-input-shadow", tabindex: "-1", autocomplete: "off")

		@__contentSize.appendTo(document.body)
		@__contentSize0 = @__contentSize[0]

		style = window.getComputedStyle(@__input0)

		# CUI.debug style

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
			# CUI.debug k, style[k]
			css[k] = style[k]

		if not @_textarea
			css.whiteSpace = "nowrap"

		@__contentSize.css(css)
		DOM.height(@__contentSize, 1)

		if @_textarea
			DOM.width(@__contentSize, DOM.width(@__contentSize))
			@__max_height = parseInt(@__input.css("max-height"))
			@__input0.style.overflow = "hidden"

			if isNaN(@__max_height)
				@__max_height = null
			else
				correct_height = parseInt(@__input.css("height")) - DOM.height(@__input)
				@__max_height -= correct_height
		else
			DOM.width(@__contentSize, 1)
		@

	__setContentSize: ->

		@__contentSize0.value = @__input0.value

		if @hasShadowFocus()
			# we can only do this when shadow is focused,
			# otherwise the "blur" event on @__input0
			# will remove @__contentSize and we will run into errors
			@__contentSize0.focus()

		changed = false

		if @_textarea
			if @__input0.value.length == 0
				@__contentSize0.value = "A" # help IE out, so we get a height

			if DOM.width(@__input) != DOM.width(@__contentSize)
				DOM.width(@__contentSize, DOM.width(@__input))

			h = @__contentSize0.scrollHeight

			if @__max_height == null or h <= @__max_height
				@__input0.style.overflow = "hidden"
			else
				@__input0.style.overflow = ""

			previous_height = DOM.height(@__input)
			DOM.height(@__input, h)

			if DOM.height(@__input) != previous_height
				changed = true

			# CUI.error "__setContentSize", @_textarea, @__input0.value, @__contentSize0.value, h
		else
			w = @__contentSize0.scrollWidth
			if @__contentSize0.value.length == 0
				# help IE out here, IE measures one " "
				w = 1
			else
				# for now, add 1 pixel to the measurement
				# Chrome measures a Textarea width different than an Input width
				w = w + 1

			if DOM.width(@__input) != w
				changed = true

			DOM.width(@__input, w)

		if changed
			Events.trigger
				type: "content-resize"
				node: @__input
		@

	checkBlocks: (blocks) ->
		if not CUI.isArray(blocks)
			return false
		for b, idx in blocks
			assert(b instanceof InputBlock, "Input.getInputBlocks", "Block[#{idx}] needs to be instance of InputBlock.", blocks: blocks, block: b)
			b.idx = idx
		blocks



	getInputBlocks: ->
		if @_getInputBlocks
			blocks = @_getInputBlocks(@__input0.value)
		else if @_getCursorBlocks
			blocks = @_getCursorBlocks(@__input0.value)
		else
			blocks = @__getInputBlocks(@__input0.value)
		@checkBlocks(blocks)

	__getInputBlocks: (v) ->
		blocks = []
		v =  @__input0.value
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

			blocks.push new NumberInputBlock
				start: match_start
				string: match_str
		# CUI.debug "blocks", blocks
		blocks

	__overwriteBlocks: (v) ->
		blocks = []
		for i in [0...v.length]
			blocks.push new InputBlock
				start: i
				string: v.substr(i, 1)
		blocks.push new InputBlock
			start: v.length
			string: ""
		blocks

	# returns the currently exactly marked block
	# if no block is found, returns null
	getMarkedBlock: ->
		blocks = @getInputBlocks()
		if blocks == false or blocks.length == 0
			return null

		s = @__input0.selectionStart
		e = @__input0.selectionEnd

		for block, idx in blocks
			# CUI.debug match_start, match_end, match_str
			if block.start == s and block.end == e
				return block
		return null

	getSelection: ->
		s = @__input0.selectionStart
		e = @__input0.selectionEnd

		start: s
		end: e
		value: @__input0.value
		before: @__input0.value.substring(0, s)
		selected: @__input0.value.substring(s, e)
		after: @__input0.value.substring(e)

	setSelection: (selection) ->
		@__input0.selectionStart = selection.start
		@__input0.selectionEnd = selection.end

	selectAll: ->
		@__input0.selectionStart = 0
		@__input0.selectionEnd = @__input0.value.length
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
			@__input0?.value = v
			@setContentSize()

		super(v, flags)

	incNumberBounds: (ev) ->
		if ev.keyCode() not in [38, 40, 33, 34] # not in TAB
			return

		s = @__input0.selectionStart
		e = @__input0.selectionEnd
		v =  @__input0.value

		blocks = @getInputBlocks()
		if blocks == false or blocks.length == 0
			return

		parts_inbetween = [v.substring(0, blocks[0].start)]
		for block, idx in blocks
			if idx == blocks.length-1
				break
			# CUI.debug idx, block.end, blocks[idx+1].start
			parts_inbetween.push(v.substring(block.end, blocks[idx+1].start))

		last_block = blocks[blocks.length-1]
		parts_inbetween.push(v.substring(last_block.end))

		# CUI.debug "blocks:", blocks
		# CUI.debug "parts_inbetween:", parts_inbetween
		# CUI.debug "s", s, "e", e, "v", v
		block_move = 0
		if ev.keyCode() in [9, 33, 34]
			# TAB, PAGE UP/DOWN  # TAB removed (above)
			if ev.shiftKey() or
				ev.keyCode() == 33
					block_move = -1
			else
				block_move = 1

		for block, idx in blocks
			# CUI.debug match_start, match_end, match_str
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
				# CUI.debug "cursor in block", s, e
				block_jump_to = idx
				continue

		if block_move and s == 0 and e == v.length and blocks.length > 1
			if block_move == -1
				block_jump_to = blocks.length-1
			else
				block_jump_to = 0

		if bl = blocks[block_jump_to]
			new_str = [parts_inbetween[0]]
			# CUI.debug "new blocks"+blocks
			for block, idx in blocks
				new_str.push(block.string)
				new_str.push(parts_inbetween[idx+1])

			new_value = new_str.join("")

			if not @checkInput(new_value)
				ev.preventDefault()
				return

			@__input0.value = new_value
			@markBlock(ev, bl)
			@storeValue(@__input0.value)
			ev.preventDefault()

		return

	__removeContentSize: ->
		@__contentSize?.remove()
		@__contentSize = null
		@__contentSize0 = null
		@

	__removeShadowInput: ->
		# CUI.error "removeShadowInput", @getUniqueId()
		@__removeContentSize()

		@__shadow?.remove()
		@__shadow = null
		@__shadow_focused = false
		@

	preventInvalidInput: ->
		if @_checkInput and @_prevent_invalid_input
			true
		else
			false

	__initShadowInput: ->
		if not (@preventInvalidInput() or @_content_size or @_correctValueForInput or @_readonly)
			return

		if @__shadow
			return

		# CUI.debug "initShadowInput", @getUniqueId()
		#
		if @_textarea
			@__shadow = $element("textarea", "cui-input-shadow")
		else
			@__shadow = $element("input", "cui-input-shadow", type: "text")

		@__shadow.prop("tabindex", "-1")
		@__shadow.prop("autocomplete", "off")
		@__shadow.appendTo(document.body)
		@__shadow0 = @__shadow[0]

		if @_content_size
			@__initContentSize()


		Events.listen
			type: "input"
			node: @__shadow
			call: (ev) =>
				@__shadowInput(ev)
				# CUI.debug ev.type, "unfocus shadow input"
				@__unfocusShadowInput()
				new CUI.Event
					type: "input"
					node: @__input
				.dispatch()
				return

		Events.listen
			type: "keyup"
			node: @__shadow
			call: (ev) =>
				# CUI.debug ev.type, "unfocus shadow input"
				@__unfocusShadowInput()
				# CUI.debug "shadow", ev.type
				return

		@


	__shadowInput: (ev) ->
		shadow_v = @__shadow0.value

		if @preventInvalidInput() and shadow_v.length > 0
			ret = @checkInput(@correctValueForInput(shadow_v))
			# console.debug "checking shadow input", ret, shadow_v
			if ret == false
				return

		if not @_readonly
			@__input0.value = @correctValueForInput(shadow_v)
			@__input0.setSelectionRange(@__shadow0.selectionStart, @__shadow0.selectionEnd)

		# CUI.debug "shadow before init cursor", @cursor?.start.idx, "-", @cursor?.end.idx
		@initCursor(ev)
		# CUI.debug "shadow after init cursor", @cursor?.start.idx, "-", @cursor?.end.idx
		return

	checkValue: (v) ->
		if not isString(v) or null
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
			DOM.hideElement(@__inputHints[k]?.DOM[0])

		if not @hasUserInput() and state == "invalid"
			DOM.showElement(@__inputHints.empty?.DOM[0])
		else
			DOM.showElement(@__inputHints[state]?.DOM[0])
		@

	getInputState: ->
		if @__inputState != false
			return "valid"

		if @hasUserInput() or @isRequired()
			return "invalid"

		return "empty"

	leaveInput: ->
		if @getInputState() != "invalid"
			@__input0.value = @getValueForDisplay()
			@checkInput()
		@

	enterInput: ->
		if @getInputState() != "invalid"
			@__input0.value = @getValueForInput()
			@checkInput()
		@

	hasUserInput: ->
		@__input0.value.length > 0

	checkInput: (value) ->
		state = @__checkInputInternal(value)
		if not @hasShadowFocus()
			@updateInputState(state)
		state

	__checkInputInternal: (value = @__input0.value) ->
		if @_checkInput
			@_checkInput(value)
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
		value = @getValueForDisplay()
		if value != @__input0.value
			# prevent focus loss if value is the same
			@__input0.value = value
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
			@__input0?.value

	enable: ->
		super()
		@__input?.prop("disabled", false)

	disable: ->
		super()
		@__input?.prop("disabled", true)

	focus: ->
		@__input0?.focus()
		@

	getCursorBlocks: ->
		blocks = @__getCursorBlocks?(@__input0.value)
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
			CUI.warn "initCursor: 0 cursor blocks"
			@cursor = null
			return

		# CUI.debug "initCursor", ev.type, ev.which, ev.shiftKey # , blocks

		# find block which fits the current selection
		# positions
		#
		s = @__input0.selectionStart
		e = @__input0.selectionEnd
		len = @__input0.value.length

		# CUI.debug "requested: start: ",s, "end: ",e

		@cursor =
			shift: @cursor?.shift
			start: null
			end: null

		if ev.getType() == "keyup" and ev.keyCode() == 16
			@cursor.shift = null

		if ev.getType() == "keydown" and ev.keyCode() in [46, 8]
			@cursor.shift = null

		if isUndef(@cursor.shift)
			@cursor.shift = null

		@cursor.start = @findBlock(blocks, s, "left")
		@cursor.end = @findBlock(blocks, e, "right")

		# CUI.debug "found cursors", @cursor.start, @cursor.end

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
			# CUI.debug "found block in dist:", dist_left, dist_right

		range = @getRangeFromCursor()

		# CUI.debug "cursor", "start:", @cursor.start?.idx, "end:", @cursor.end?.idx, range
		if not @cursor.start and not @cursor.end
			@cursor.start = @cursor.end = blocks[blocks.length-1]
		else if not @cursor.start
			@cursor.start = @cursor.end
		else if not @cursor.end
			@cursor.end = @cursor.start

		# CUI.debug "cursor CLEANED", "start:", @cursor.start?.idx, "end:", @cursor.end?.idx, range
		# CUI.debug "range", range

		if range[0] == s and range[1] == e
			1
			# CUI.debug "cursor is good"
		return

	showCursor: (ev) ->

		if @cursor
			r = @getRangeFromCursor()
			@__input0.setSelectionRange(r[0], r[1])
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

		# CUI.debug "moveCursor", ev.type, ev.which
		blocks = @getCursorBlocks()
		if blocks == false or blocks.length == 0
			# CUI.debug "no block found"
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

		if @lastKeyDownEvent.keyCode() == 46 # DELETE
			# dont move cursor, positioning will be down
			# in keyup
			@initCursor(@lastKeyDownEvent)
			return

		if @lastKeyDownEvent.keyCode() == 8 # BACKSPACE
			@initCursor(@lastKeyDownEvent)
			return

		left = ev.keyCode() == 37
		right = (ev.keyCode() == 39 or ev.getType() == "input")

		s_idx = @cursor.start.idx
		e_idx = @cursor.end.idx

		if not blocks[s_idx] or not blocks[e_idx]
			CUI.warn "repositioning cursor, not executing cursor move"
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
			# CUI.debug "SHIFT ME! ", "start:", s_idx, "end:", e_idx, "shift:", c_idx
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

		#CUI.debug "moveCursor new range", @getRangeFromCursor()
		@

	destroy: ->
		@__removeShadowInput()
		super()

	@uniqueId: 0

Input = CUI.Input
