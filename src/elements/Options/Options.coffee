###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./Options.html'));

class CUI.Options extends CUI.DataField
	constructor: (opts) ->
		super(opts)
		if @_sortable
			CUI.dom.addClass(@DOM, "cui-options--sortable")

	initOpts: ->
		super()
		@addOpts
			radio:
				check: (v) ->
					CUI.util.isString(v) or CUI.util.isBoolean(v)

			radio_unchecked_value:
				default: false

			min_checked:
				check: (v) ->
					if @_radio
						v == 0 or v == 1
					else
						CUI.util.isInteger(v) and v >= 0
			options:
				mandatory: true
				check: (v) ->
					CUI.util.isArray(v) or CUI.util.isFunction(v)

			# true: all fields horizontal
			# int: n fields horizontal
			horizontal:
				check: (v) ->
					if CUI.util.isBoolean(v) or (CUI.util.isInteger(v) and v > 0)
						return true

			title:
				check: String

			hint:
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

			columns:
				check: (v) ->
					if (CUI.util.isInteger(v) and v <= 12) # max 12 columns
						return true
				default: 1


	readOpts: ->
		super()
		CUI.util.assert(not @_sortable or not @_left, "new CUI.Options", "opts.sortable and opts.left cannot be used together.", opts: @opts)
		CUI.util.assert(not @_sortable or not @_radio, "new CUI.Options", "opts.sortable and opts.radio cannot be used together.", opts: @opts)
		CUI.util.assert(not @_sortable or not @opts.horizontal, "new CUI.Options", "opts.sortable and opts.horizontal cannot be used together.", opts: @opts)

		if @opts.horizontal == undefined
			@_horizontal = not @_sortable

		if @_sortable and @_activatable == undefined
			@_activatable = true

		CUI.util.assert(not (@_sortable and not @_activatable), "new CUI.Options", "opts.sortable needs opts.activatable to be set.", opts: @opts)


	getTemplate: ->

		if @_activatable
			@__tmpl = new CUI.Template
				name: "options-activatable"
				map_prefix: "cui-options"
				map:
					top: true
					bottom: true
					active: true
					inactive: true
		else
			@__tmpl = new CUI.Template
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
			if CUI.util.isArray(@getValue())
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
				if @getValue()?.indexOf(opt) > -1
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
		if @__getOptionByValue(value).indeterminate
			@removeIndeterminate(value)
		cb = @__getCheckboxByValue(value)
		cb.disable()
		return @

	enableOption: (value) ->
		if @__getOptionByValue(value).indeterminate
			@removeIndeterminate(value)
		cb = @__getCheckboxByValue(value)
		cb.enable()
		return @

	setIndeterminate : (value) ->
		cb = @__getCheckboxByValue(value)
		@__getOptionByValue(value).indeterminate = true
		cb.setIndeterminate()
		return @

	removeIndeterminate: (value) ->
		@__getOptionByValue(value).indeterminate = false
		cb = @__getCheckboxByValue(value)
		cb.removeIndeterminate()
		return @

	isOptionIndeterminateByValue: (value) ->
		cb = @__getCheckboxByValue(value)
		return cb.isIndeterminate()

	__getCheckboxByValue: (value) ->
		found = null
		for opt, idx in @__options
			if opt.value == value
				found = idx
				break
		CUI.util.assert(found != null, "CUI.Options.__getCheckboxByValue", "Value #{value} not found in CUI.Options.", options: @__options)
		@__checkboxes[found]

	__getOptionByValue: (value) ->
		found = null
		for opt, idx in @__options
			if opt.value == value
				found = idx
				break
		CUI.util.assert(found != null, "CUI.Options.__getCheckboxByValue", "Value #{value} not found in CUI.Options.", options: @__options)
		@__options[found]

	getOptions: ->
		@__options

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
			if not CUI.util.isArray(_value)
				throw new CUI.CheckValueError("Value must be Array.")
			check = _value
		else
			check = [_value]

		for value in check
			for opt in @__options
				if opt.value == value
					return
		throw new CUI.CheckValueError("Value is not in the options.")

	render: ->
		super()

		unsorted_options = @getArrayFromOpt("options")

		sort_options = =>
			@__options.sort (a, b) =>
				a_idx = CUI.util.idxInArray(CUI.util.idxInArray(a, unsorted_options), @__options_order)
				b_idx = CUI.util.idxInArray(CUI.util.idxInArray(b, unsorted_options), @__options_order)
				CUI.util.compareIndex(a_idx, b_idx)

		find_value_in_options = (value, options) ->
			for opt, idx in options
				if opt.value == value or (not opt.hasOwnProperty("value") and opt.text == value)
					return idx
			-1

		order_value_array = (arr) =>
			# store the current index, by doing that
			# we make sure that array value which are not among
			# our CUI.Options.options, keep their order (but are
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
				CUI.util.compareIndex(a_idx, b_idx)

			for a, idx in arr
				delete(a.___idx)

		order_options_by_value_array = =>
			if @hasData()
				arr = @getValue()
			else
				arr = []

			@__options_order = []

			# first put the active values
			for value in arr
				@__options_order.push(find_value_in_options(value, unsorted_options))

			missing_opts = []
			# second put the inactive values
			for opt, idx in unsorted_options
				if CUI.util.idxInArray(idx, @__options_order) == -1
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
			sort_options()

		@__checkboxes = []

		@__maxChars = -1

		for _opt, idx in @__options
			do (_opt) =>

				opt = {}
				for k, v of _opt
					opt[k] = v

				CUI.util.assert(not CUI.util.isEmpty(opt.text) or not CUI.util.isEmpty(opt.content), "new #{@__cls}", "opts.options[#{idx}].text|content must be set.", opts: @opts)
				if not opt.hasOwnProperty("value")
					CUI.util.assert(not CUI.util.isEmpty(opt.text), "new #{@__cls}", "opts.options[#{idx}].text must be set.", opts: @opts)
					opt.value = opt.text

				chars = opt.text?.length or -1
				if @__maxChars < chars
					@__maxChars = chars

				opt.radio = @__radio
				if @__radio and @_min_checked == 0
					if @__options.length == 1
						delete(opt.radio)
					else
						opt.radio_allow_null = true

				if not @__radio
					opt.group = "group-"+@getUniqueId()

				opt.onActivate = (_cb, flags) =>
					#With any interaction we remove indeterminate
					_opt.indeterminate = false;
					#If is a radio option then we remove indeterminate of all group
					if @_radio
						for checkbox in @__checkboxes
							checkbox.removeIndeterminate()
						for option in @__options
							option.indeterminate = false;
					if _cb.hasData()
						if @_radio and not @__radio_use_array
							@storeValue(_cb.getValue(), flags)
						else
							CUI.util.pushOntoArray(_cb.getOptValue(), arr = (@getValue() or []).slice(0))
							order_value_array(arr)
							@storeValue(arr, flags)
							if @_sortable
								order_options_by_value_array()
								@reload()

					_opt.onActivate?(_cb, flags)
					return

				opt.onDeactivate = (_cb, flags) =>
					#With any interaction we remove indeterminate
					_opt.indeterminate = false;
					#If is a radio option then we remove indeterminate of all group
					if @_radio
						for checkbox in @__checkboxes
							checkbox.removeIndeterminate()
						for option in @__options
							option.indeterminate = false;
					if not @_radio
						c = 0
						for checkbox in @__checkboxes
							if checkbox.isActive()
								c++

						if c < @_min_checked
							return _cb.activate()


					if _cb.hasData()
						if @_radio and not @__radio_use_array
							if not flags.prior_activate
								@storeValue(_cb.getValue(), flags)
						else
							CUI.util.removeFromArray(_cb.getOptValue(), arr = @getValue().slice(0))
							@storeValue(arr, flags)

							if @_sortable
								order_options_by_value_array()
								@reload()
					_opt.onDeactivate?(_cb, flags)
					return

				opt.undo_support = false
				opt.mark_changed = @_mark_changed
				opt.multiline = true
				if @getName()
					if @__radio and not @__radio_use_array
						opt.name = @__radio
						opt.group = @__radio
					else
						opt.group = "options-"+@getUniqueId()
						opt.name = opt.group+"--"+idx

					opt.data = @__options_data
					opt.data_not_for_others = true

				opt.indeterminate = _opt.indeterminate

				cb = new CUI.Checkbox(opt)
				CUI.Events.listen
					type: "data-changed"
					node: cb
					call: (ev, info) ->
						if info.element == cb
							ev.stopImmediatePropagation()
						return

				@__checkboxes.push(cb)

		if @hasData()
			@__setDataOnOptions()

		if @__checkboxes.length
			hint = ""
			if @_sortable and not CUI.util.isEmpty(@_sortable_hint)
				hint = @_sortable_hint
			else if not CUI.util.isEmpty(@_hint)
				hint = @_hint

			if hint
				bottom = new CUI.Label
					multiline: true
					class: "cui-options-hint"
					text: hint
			else
				bottom = undefined

			if not CUI.util.isEmpty(@_title)
				top = new CUI.Label
					class: "cui-options-title"
					text: @_title
			else
				top = undefined

			@replace(bottom, "bottom")
			@replace(top, "top")

			if @_horizontal
				@addClass("cui-options--horizontal")
			else
				@addClass("cui-options--vertical")

			if @_columns > 1
				@addClass("cui-options--columns-#{@_columns}")

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
					el = CUI.dom.element("DIV", class: "cui-options-sortable-option")
					drag_handle = CUI.dom.element("DIV", class: "cui-options-sortable-drag-handle")
					drag_handle_inner = CUI.dom.element("DIV", class: "cui-drag-handle-row")
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

			if @_sortable
				new CUI.Sortable
					axis: "y"
					element: sortable_element
					selector: sortable_selector
					sorted: (ev, from_idx, to_idx) =>
						CUI.util.moveInArray(from_idx, to_idx, @__options_order, from_idx < to_idx)
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

		else if not CUI.util.isEmpty(@_placeholder)
			@replace(new CUI.EmptyLabel(text: @_placeholder), "center")

		@

	getDefaultValue: ->
		if @_radio and not @__radio_use_array
			@_radio_unchecked_value
		else
			[]

