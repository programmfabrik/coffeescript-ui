###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.MultiInput extends CUI.DataFieldInput
	constructor: (@opts={}) ->
		super(@opts)
		@addClass("cui-multi-input")

	initOpts: ->
		super()
		@addOpts
			textarea:
				default: false
				check: Boolean
			spellcheck:
				default: false
				check: Boolean
			placeholder:
				check: "PlainObject"
			onFocus:
				check: Function
			onClick:
				check: Function
			onKeyup:
				check: Function
			onBlur:
				check: Function
			control:
				mandatory: true
				check: (v) ->
					v instanceof CUI.MultiInputControl
			content_size:
				default: false
				check: Boolean

	readOpts: ->
		super()
		@__inputs = null

	disable: ->
		super()
		if not @__inputs
			return
		for inp in @__inputs
			inp.disable()

	enable: ->
		super()
		if not @__inputs
			return
		for inp in @__inputs
			inp.enable()

	initValue: ->
		if isNull(v = @__data[@_name])
			v = @__data[@_name] = {}

		for key in @_control.getKeys()
			if not v.hasOwnProperty(key.name)
				v[key.name] = ""
		@

	setData: (data) ->
		super(data)
		@setDataOnInputs()

	setDataOnInputs: ->
		if not @__inputs
			return

		input_data = copyObject(@getValue(), true)
		for input in @__inputs
			input.setData(input_data)
			if @_undo_support
				v = @getInitValue()[input.getName()]
			else
				v = @getValue()[input.getName()]

			input.setCheckChangedValue(v)

	setInputVisibility: ->
		# the "append" re-orders the input, if needed

		names = (key.name for key in @_control.getKeys())
		# sort input by key
		@__inputs.sort (a, b) =>
			compareIndex(
				names.indexOf(a.getOpt("name"))
				names.indexOf(b.getOpt("name"))
			)

		ok = false
		for inp in @__inputs
			@__multiInputDiv.append(inp.DOM)
			if @_control.isEnabled(inp.getName())
				inp.show()
				ok = true
			else
				inp.hide()

		if not ok
			CUI.warn("MulitInput.setInputVisibility: No input visible.", input: @__inputs, control: @_control)

		Events.trigger
			type: "content-resize"
			node: inp.DOM # last one

	getUniqueIdForLabel: ->
		@__initInputs()
		for inp in @__inputs
			if @_control.isEnabled(inp.getName())
				return inp.getUniqueIdForLabel()
		null

	focus: ->
		for inp in @__inputs
			if @_control.isEnabled(inp.getName())
				inp.focus()
				return
		return

	displayValue: ->
		super()
		for input in @__inputs
			input.displayValue()
		@

	__initInputs: ->
		if @__inputs
			return

		@__multiInputDiv = $div("cui-multi-input-container")

		Events.listen
			type: "multi-input-control-update"
			node: @__multiInputDiv
			call: (ev) =>
				# CUI.debug ev.getType(), @__multiInputDiv[0], @_control.getKeys()
				@setInputVisibility()

		# DOM.registerEvent(multiInputDiv, "easydbui-multi-input-control-update")
		# multiInputDiv.on "easydbui-multi-input-control-update", (ev)

		@__inputs = []

		for key, idx in @_control.getKeys()
			assert(CUI.isPlainObject(key), "new #{@__cls}", "opts.keys[#{idx}] needs to be PlainObject.", opts: @opts)
			assert(isString(key.name), "new #{@__cls}", "opts.keys[#{idx}].name needs to be String.", opts: @opts)
			assert(isString(key.tag), "new #{@__cls}", "opts.keys[#{idx}].tag needs to be String.", opts: @opts)

			input_opts =
				class: "cui-multi-input-input"
				textarea: @_textarea
				spellcheck: @_spellcheck
				onBlur: @_onBlur
				onClick: @_onClick
				onFocus: @_onFocus
				onKeyup: @_onKeyup
				name: key.name
				undo_support: false
				content_size: @_content_size
				placeholder: @_placeholder?[key.name]

			input = new MultiInputInput(input_opts)
			input.render()

			do (input, key) =>
				btn = new CUI.defaults.class.Button
					text: key.tag
					tabindex: null
					disabled: !@_control.hasUserControl()
					onClick: (ev, btn) =>
						@_control.showUserControl(ev, btn, @__multiInputDiv)
					role: "multi-input-tag"
					class: "cui-multi-input-tag-button"

				input.append(btn, "right")

				Events.listen
					type: "data-changed"
					node: input
					call: (ev) =>
						values = copyObject(@getValue())
						values[key.name] = input.getValue()
						ev.stopImmediatePropagation()
						@storeValue(values)

			@__inputs.push(input)
		return


	render: ->
		super()
		@__initInputs()

		if @hasData()
			@setDataOnInputs()

		@replace(@__multiInputDiv)
		@setInputVisibility()
		@



