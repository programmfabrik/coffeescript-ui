###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Options extends CUI.DataField
	constructor: (@opts={}) ->
		super(@opts)
		@DOM.addClass("cui-padding-reset")
		if @_sortable
			@DOM.addClass("cui-options--sortable")

	initOpts: ->
		super()
		@addOpts
			hash_store:
				check: Boolean
			radio:
				check: (v) ->
					isString(v) or isBoolean(v)

			radio_unchecked_value:
				default: false

			min_checked:
				check: (v) ->
					if @_radio
						v == 0 or v == 1
					else
						isInteger(v) and v >= 0
			options:
				mandatory: true
				check: (v) ->
					CUI.isArray(v) or CUI.isFunction(v)

			# true: all fields horizontal
			# int: n fields horizontal
			horizontal:
				check: (v) ->
					v == true or (isInteger(v) and v > 0)

			title:
				check: String

			activatable:
				check: Boolean

			sortable:
				check: Boolean

			sortable_hint:
				check: String

			placeholder:
				default: "No options available."
				check: String


	readOpts: ->
		super()
		assert(not @_sortable or not @_left, "new Options", "opts.sortable and opts.left cannot be used together.", opts: @opts)
		assert(not @_sortable or not @_radio, "new Options", "opts.sortable and opts.radio cannot be used together.", opts: @opts)
		assert(not @_sortable or not @_horizontal, "new Options", "opts.sortable and opts.horizontal cannot be used together.", opts: @opts)

		if @_sortable and @_activatable == undefined
			@_activatable = true

		assert(not (@_sortable and not @_activatable), "new Options", "opts.sortable needs opts.activatable to be set.", opts: @opts)


	getTemplate: ->
		if not CUI.__ng__
			return super()

		if @_activatable
			@__tmpl = new Template
				name: "options-activatable"
				map_prefix: "cui-options"
				map:
					top: true
					bottom: true
					active: true
					inactive: true
		else
			@__tmpl = new Template
				name: "options"
				map:
					top: true
					bottom: true
					center: true

	init: ->
		switch @_radio
			when false
				@__radio = undefined
			when true
				@__radio = "options--"+@getUniqueId()
			else
				@__radio = @_radio
		@__options_data = {}

	setData: (data) ->
		super(data)
		if @_radio
			if CUI.isArray(@getValue())
				@__radio_use_array = true
			else
				@__radio_use_array = false

		@__setDataOnOptions()
		@

	__setDataOnOptions: (init_data=true) ->
		if not @__checkboxes
			return

		if init_data
			for cb in @__checkboxes
				cb.callOnOthers("setData", @__data)

		if @_radio and not @__radio_use_array
			for cb in @__checkboxes
				@__options_data[cb.getName()] = @getValue()
				if not init_data
					continue

				if @_check_changed and JSON.parse(@getCheckChangedValue()) == cb.getOptValue()
					cb.setCheckChangedValue(cb.getOptValue())
				else
					cb.setCheckChangedValue(cb.getOptValueUnchecked())
		else
			for cb in @__checkboxes
				opt = cb.getOptValue()
				opt_unchecked = cb.getOptValueUnchecked()
				if @getValue().indexOf(opt) > -1
					@__options_data[cb.getName()] = opt
				else
					@__options_data[cb.getName()] = opt_unchecked

				if not init_data
					continue

				if @_check_changed and JSON.parse(@getCheckChangedValue()).indexOf(opt) > -1
					cb.setCheckChangedValue(opt)
				else
					cb.setCheckChangedValue(opt_unchecked)

		@

	disableOption: (value) ->
		cb = @__getCheckboxByValue(value)
		cb.disable()
		@

	enableOption: (value) ->
		cb = @__getCheckboxByValue(value)
		cb.enable()
		@

	__getCheckboxByValue: (value) ->
		found = null
		for opt, idx in @__options
			if opt.value == value
				found = idx
		assert(found != null, "CUI.Options.__getCheckboxByValue", "Value #{value} not found in Options.", options: @__options)
		@__checkboxes[found]


	setValue: (v, flags={}) ->
		flags.__set_on_data = true
		super(v, flags)

	storeValue: (value, flags={}) ->
		super(value, flags)
		if flags.__set_on_data
			@__setDataOnOptions()
		@

	displayValue: ->
		super()
		for cb in @__checkboxes
			cb.displayValue()
		@

	checkValue: (_value) ->
		if @__radio_use_array or not @_radio
			if not CUI.isArray(_value)
				throw new CheckValueError("Value must be Array.")
			check = _value
		else
			check = [_value]

		for value in check
			for opt in @__options
				if opt.value == value
					CUI.debug "value is ok.", @hasData(), @getData()[@_name]
					return
		throw new CheckValueError("Value is not in the options.")

	disable: ->
		if not CUI.__ng__
			return
		super()

	enable: ->
		if not CUI.__ng__
			return
		super()

	render: ->
		super()
		# CUI.debug "Options.render", @getUniqueId()

		unsorted_options = @getArrayFromOpt("options")

		sort_options = =>
			@__options.sort (a, b) =>
				a_idx = idxInArray(idxInArray(a, unsorted_options), @__options_order)
				b_idx = idxInArray(idxInArray(b, unsorted_options), @__options_order)
				compareIndex(a_idx, b_idx)

		find_value_in_options = (value, options) ->
			for opt, idx in options
				if opt.value == value or (not opt.hasOwnProperty("value") and opt.text == value)
					return idx
			-1

		order_value_array = (arr) =>
			# store the current index, by doing that
			# we make sure that array value which are not among
			# our Options.options, keep their order (but are
			# send to the end of the array)
			for a, idx in arr
				a.___idx = idx

			arr.sort (a, b) =>
				a_idx = find_value_in_options(a, @__options)
				if a_idx == -1
					a_idx = arr.length+a.__idx
				b_idx = find_value_in_options(b, @__options)
				if b_idx == -1
					b_idx = arr.length+b.__idx
				compareIndex(a_idx, b_idx)

			for a, idx in arr
				delete(a.___idx)

			# CUI.debug "order_value_array:", arr.join(", ")

		order_options_by_value_array = =>
			if @hasData()
				arr = @getValue()
			else
				arr = []

			@__options_order = []

			# first put the active values
			for value in arr
				@__options_order.push(find_value_in_options(value, unsorted_options))

			# CUI.debug "order in unsorted:", @__options_order.join(", ")

			missing_opts = []
			# second put the inactive values
			for opt, idx in unsorted_options
				if idxInArray(idx, @__options_order) == -1
					missing_opts.push(opt: opt, idx: idx)

			missing_opts.sort (a, b) ->
				a_txt = a.opt.text.toLocaleUpperCase()
				b_txt = b.opt.text.toLocaleUpperCase()
				if a_txt < b_txt
					-1
				else if a_txt > b_txt
					1
				else
					0

			for mopt in missing_opts
				@__options_order.push(mopt.idx)


		if @_sortable and not @__options_order
			order_options_by_value_array()

		@__options = unsorted_options.slice(0)

		if @__options_order
			# CUI.debug "rendering with order", @__options_order.join(", ")
			sort_options()

		@__checkboxes = []

		@__maxChars = -1

		for _opt, idx in @__options
			do (_opt) =>

				opt = {}
				for k, v of _opt
					opt[k] = v

				assert(not isEmpty(opt.text) or not isEmpty(opt.content), "new #{@__cls}", "opts.options[#{idx}].text|content must be set.", opts: @opts)
				if not opt.hasOwnProperty("value")
					assert(not isEmpty(opt.text), "new #{@__cls}", "opts.options[#{idx}].text must be set.", opts: @opts)
					opt.value = opt.text

				chars = opt.text?.length or -1
				if @__maxChars < chars
					@__maxChars = chars

				if @_sortable
					if not opt.form
						opt.form = {}
					opt.form.label = $div("cui-options-sortable-drag-handle cui-drag-handle-row")

				opt.radio = @__radio
				if @_radio and @_min_checked == 0
					if @__options.length == 1
						delete(opt.radio)
					else
						opt.radio_allow_null = true

				opt.onActivate = (_cb, flags) =>
					if _cb.hasData()
						if @_radio and not @__radio_use_array
							@storeValue(_cb.getValue(), flags)
						else
							addToArray(_cb.getOptValue(), arr = @getValue().slice(0))
							order_value_array(arr)
							@storeValue(arr, flags)
							if @_sortable
								order_options_by_value_array()
								@reload()

					_opt.onActivate?(_cb, flags)
					return

				opt.onDeactivate = (_cb, flags) =>
					if not @_radio
						c = 0
						for f in @__checkboxes
							if f.isActive()
								c++

						if c < @_min_checked
							return _cb.activate()

					if _cb.hasData()
						if @_radio and not @__radio_use_array
							if not flags.prior_activate
								@storeValue(_cb.getValue(), flags)
						else
							removeFromArray(_cb.getOptValue(), arr = @getValue().slice(0))
							@storeValue(arr, flags)

							if @_sortable
								order_options_by_value_array()
								@reload()
					_opt.onDeactivate?(_cb, flags)
					return

				opt.undo_support = false
				opt.mark_changed = @_mark_changed
				if @getName()
					if @__radio and not @__radio_use_array
						opt.name = @__radio
						opt.group = @__radio
					else
						opt.group = "options-"+@getUniqueId()
						opt.name = opt.group+"--"+idx

					opt.data = @__options_data
					opt.data_not_for_others = true


				cb = new Checkbox(opt)
				Events.listen
					type: "data-changed"
					node: cb
					call: (ev, info) ->
						if info.element == cb
							ev.stopImmediatePropagation()
						return

				@__checkboxes.push(cb)

		if @hasData()
			@__setDataOnOptions()
			# CUI.debug "setting data on options", @__radio, @getName(), @getData(), dump(@__options_data)

		if @__checkboxes.length
			if @_sortable and not isEmpty(@_sortable_hint)
				bottom = new Label
					multiline: true
					class: "cui-options-order-hint"
					text: @_sortable_hint
			else
				bottom = undefined

			if not isEmpty(@_title)
				top = new Label
					class: "cui-options-title"
					text: @_title
			else
				top = undefined

			if CUI.__ng__

				@replace(bottom, "bottom")
				@replace(top, "top")

				if @_horizontal
					@addClass("cui-options--horizontal")

				if @_activatable
					@empty("active")
					@empty("inactive")
				else
					@empty("center")

				for cb in @__checkboxes
					cb.start()
					if @__maxChars > 0
						cb.setTextMaxChars(@__maxChars)

					if @_sortable and cb.isActive()
						# we need extra markup around our checkbox
						el = CUI.DOM.element("DIV", class: "cui-options-sortable-option")
						drag_handle = CUI.DOM.element("DIV", class: "cui-options-sortable-drag-handle")
						drag_handle_inner = CUI.DOM.element("DIV", class: "cui-drag-handle-row")
						drag_handle.appendChild(drag_handle_inner)
						el.appendChild(drag_handle)
						el.appendChild(cb.DOM)
					else
						el = cb.DOM

					if @_activatable
						if cb.isActive()
							@append(el, "active")
						else
							@append(el, "inactive")
					else
						@append(el, "center")

				sortable_element = @__tmpl.map.active
				sortable_selector = ".cui-options-sortable-drag-handle"
			else
				@__optionsForm = new Form
					class: "cui-options-form cui-form-options" # form-options needed by old design
					horizontal: @_horizontal
					top: top
					bottom: bottom
					fields: @__checkboxes

				@replace(@__optionsForm)
				@proxy(@__optionsForm, ["disable", "enable"])
				@__optionsForm.render()

				sortable_element = @__optionsForm.getTable()
				sortable_selector = undefined

			if @_sortable
				new Sortable
					axis: "y"
					element: sortable_element
					selector: sortable_selector
					sorted: (ev, from_idx, to_idx) =>
						console.debug "from:", from_idx, "to:", to_idx
						# CUI.debug "options order before sort", @__options_order.join(", ")
						moveInArray(from_idx, to_idx, @__options_order)
						# CUI.debug "sort", from_idx, " > ", to_idx
						# CUI.debug "options order after sort", @__options_order.join(", ")
						# re order options
						sort_options()

						# set value to new order
						if @hasData()
							arr = @getValue().slice(0)
							order_value_array(arr)
							@storeValue(arr)

						# re order again by value in case we have sorted
						# an inactive
						order_options_by_value_array()
						@reload()

		else
			@replace(new EmptyLabel(text: @_placeholder))

		@

	getDefaultValue: ->
		if @_radio and not @__radio_use_array
			@_radio_unchecked_value
		else
			[]

Options = CUI.Options