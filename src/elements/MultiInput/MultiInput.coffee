###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.MultiInput extends CUI.DataFieldInput
	constructor: (opts) ->
		super(opts)
		@addClass("cui-multi-input")
		if @_textarea
			@addClass("cui-multi-input--textarea")

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
			user_selectable:
				default: false
				check: Boolean

	readOpts: ->
		super()
		@__inputs = null
		@__userSelectedData = {}
		@__user_selectable = @_user_selectable

	disable: ->
		super()
		if not @__inputs
			return
		for inp in @__inputs
			inp.disable()
		return

	enable: ->
		super()
		if not @__inputs
			return
		for inp in @__inputs
			inp.enable()
		return

	remove: ->
		if @__inputs
			for input in @__inputs
				input.destroy()
			delete @__inputs
		return super()

	initValue: ->
		if CUI.util.isNull(v = @__data[@_name])
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

		input_data = CUI.util.copyObject(@getValue(), true)
		for input in @__inputs
			input.setData(input_data)
			if @_undo_support
				v = @getInitValue()[input.getName()]
			else
				v = @getValue()[input.getName()]

			input.setCheckChangedValue(v)

			# All keys are selected when user_selectable option is false, otherwise the only ones with values are selected.
			@__userSelectedData[input.getName()] = not @__user_selectable or (@__user_selectable and not CUI.util.isEmpty(v))
		return

	setInputVisibility: ->
		# the "append" re-orders the input, if needed
		names = (key.name for key in @_control.getKeys())
		# sort input by key
		@__inputs.sort (a, b) =>
			CUI.util.compareIndex(
				names.indexOf(a.getOpt("name"))
				names.indexOf(b.getOpt("name"))
			)

		ok = false
		for inp in @__inputs
			CUI.dom.append(@__multiInputDiv, inp.DOM)
			if @_control.isEnabled(inp.getName()) or (@__userSelectedData[inp.getName()] and @__user_selectable)
				inp.show()
				ok = true
			else
				inp.hide()

		if not ok
			console.warn("MultiInput.setInputVisibility: No input visible.", input: @__inputs, control: @_control)

		CUI.Events.trigger
			type: "content-resize"
			node: @DOM

		return

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

		@__multiInputDiv = CUI.dom.div("cui-multi-input-container")

		CUI.Events.listen
			type: "multi-input-control-update"
			node: @__multiInputDiv
			call: (_, info) =>
				if not CUI.util.isUndef(info.user_selectable)
					@__user_selectable = info.user_selectable
				@setInputVisibility()

		@__inputs = []

		for key, idx in @_control.getKeys()
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
				onDataInit: (field, data) =>
					if @__user_selectable and CUI.util.isEmpty(data[field.getName()])
						field.hide()
					return

			input = new CUI.MultiInputInput(input_opts)
			input.render()

			do (input, key) =>
				button = new CUI.defaults.class.Button
					text: key.tag
					tabindex: null
					disabled: not @_control.hasUserControl() and not @__user_selectable
					role: "multi-input-tag"
					class: "cui-multi-input-tag-button"
					tooltip: key.tooltip
					onClick: (ev) =>
						if @__user_selectable
							form.reload()
							userSelectablePopover.show()
						else
							@_control.showUserControl(ev, button, @__multiInputDiv)

				form = new CUI.Form
					data: @__userSelectedData
					fields: =>
						fields = @_control.getKeys().map((key) =>
							type: CUI.Checkbox
							name: key.name
							text: key.tooltip.text
							onDataChanged: (data, field) =>
								if Object.values(@__userSelectedData).some((val) -> val)
									return
								data[field.getName()] = true
								field.reload()
						)
						return fields
					onDataChanged: =>
						@setInputVisibility()
				form.start()

				userSelectablePopover = new CUI.Popover
					pane:
						padded: true
						content: form
					element: button

				input.append(button, "right")

				CUI.Events.listen
					type: "data-changed"
					node: input
					call: (ev) =>
						values = CUI.util.copyObject(@getValue())
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



