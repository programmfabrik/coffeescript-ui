class Options extends DataField
	constructor: (@opts={}) ->
		super(@opts)
		@DOM.addClass("cui-padding-reset")
		if @_sortable
			@DOM.addClass("cui-options-sortable")

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
					$.isArray(v) or $.isFunction(v)

			# true: all fields horizontal
			# int: n fields horizontal
			horizontal:
				check: (v) ->
					v == true or (isInteger(v) and v > 0)

			title:
				check: String

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

	init: ->
		switch @_radio
			when false
				@__radio = undefined
			when true
				@__radio = "options--#{@__uniqueId}"
			else
				@__radio = @_radio
		@__options_data = {}

	disable: ->
		# proxy

	enable: ->
		# proxy

	setData: (data) ->
		super(data)
		if @_radio
			if $.isArray(@getValue())
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
		assert(found != null, "Options.__getCheckboxByValue", "Value #{value} not found in Options.", options: @__options)
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
			if not $.isArray(_value)
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

		order_options_by_value_array = (arr) =>
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
			order_options_by_value_array(@getValue())

		@__options = unsorted_options.slice(0)

		if @__options_order
			# CUI.debug "rendering with order", @__options_order.join(", ")
			sort_options()

		@__checkboxes = []

		for _opt, idx in @__options
			do (_opt) =>

				opt = {}
				for k, v of _opt
					opt[k] = v

				assert(not isEmpty(opt.text) or not isEmpty(opt.content), "new #{@__cls}", "opts.options[#{idx}].text|content must be set.", opts: @opts)
				if not opt.hasOwnProperty("value")
					assert(not isEmpty(opt.text), "new #{@__cls}", "opts.options[#{idx}].text must be set.", opts: @opts)
					opt.value = opt.text

				if @_sortable
					if not opt.form
						opt.form = {}
					opt.form.label = $div("cui-options-sortable-drag-handle")

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
								order_options_by_value_array(arr)
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
							@storeValue(_cb.getValue(), flags)
						else
							removeFromArray(_cb.getOptValue(), arr = @getValue().slice(0))
							@storeValue(arr, flags)
							if @_sortable
								order_options_by_value_array(arr)
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
						opt.name = "#{@__uniqueId}--#{idx}"
						opt.group = @__uniqueId

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

			@__optionsForm = new Form
				class: "cui-options-form cui-form-options" # form-options needed by old design
				horizontal: @_horizontal
				top: top
				bottom: bottom
				fields: @__checkboxes

			# CUI.debug "Options", @__checkboxes.length, @__options.length, @__options

			@replace(@__optionsForm)
			@proxy(@__optionsForm, ["disable", "enable"])
			@__optionsForm.render()
			if @_sortable
				new Sortable
					element: @__optionsForm.getTable() # this is the tbody
					sorted: (ev, from_idx, to_idx) =>
						# CUI.debug "options order before sort", @__options_order.join(", ")
						moveInArray(from_idx, to_idx, @__options_order)
						# CUI.debug "sort", from_idx, " > ", to_idx
						# CUI.debug "options order after sort", @__options_order.join(", ")
						# re order options
						sort_options()
						# set value to new order
						arr = @getValue().slice(0)

						order_value_array(arr)
						@storeValue(arr)
						# re order again by value in case we have sorted
						# an inactive
						order_options_by_value_array(arr)
						@reload()

		else
			@replace(new EmptyLabel(text: @_placeholder))

		@

	getDefaultValue: ->
		if @_radio and not @__radio_use_array
			@_radio_unchecked_value
		else
			[]

