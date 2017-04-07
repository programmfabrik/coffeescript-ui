###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Select extends Checkbox

	initOpts: ->
		super()
		@addOpts
			empty_text:
				check: String
			not_found_text:
				default: "- not found -"
				check: String
			options:
				mandatory: true
				check: (v) ->
					CUI.isArray(v) or CUI.isFunction(v)
			#group can be used for buttonbars to specify a group css style
			group:
				check: String
			onShow:
				check: Function
			onHide:
				check: Function


	init: ->
		@__value = null
		if not CUI.isFunction(@_options)
			@__loadOptions()

		# @DOM.prop("title", @getName()+":"+@__uniqueId)

	disable: (@__wasAutomaticDisabled = false) ->
		super()

	isDisabled: ->
		if @__wasAutomaticDisabled
			false
		else
			super()

	enableOption: (value) ->
		opt = @__getOptionByValue(value)
		if not opt
			return
		opt.disabled = false
		@displayValue()

	disableOption: (value) ->
		opt = @__getOptionByValue(value)
		if not opt
			return
		opt.disabled = true
		@displayValue()

	__getOptionByValue: (value) ->
		for opt in @getOptions()
			if opt.value == value
				return opt
		return null

	enable: (automatic = false) ->
		if automatic
			if @__wasAutomaticDisabled
				super()
			else
				# the select was disabled automatically but
				# during the deferred, disabled manually
				# so we ignore the automatic enable
		else
			super()

	__loadOptions: (event) ->
		if @__optionsPromise?.state() == "pending"
			return @__optionsPromise

		ret = @getArrayFromOpt("options", event, true)

		if isPromise(ret)
			@__optionsPromise = ret
			btn = @getButton()

			if btn
				icon_right = btn.getIconRight()
				btn.setIconRight("spinner")

				@__optionsPromise.always =>
					btn.setIconRight(icon_right)
		else
			@__optionsPromise = CUI.resolvedPromise(ret)

		# if not @isDisabled()
		# 	@disable(true)
		# 	@__optionsPromise.always =>
		# 		@enable(true)

		@__optionsPromise.done (@__options) =>
			first_value_opt = undefined

			# adjust options, so we always have a text and value
			for opt, idx in @__options
				opt._idx = idx
				if isUndef(opt.text) and not isUndef(opt.value) and not opt.icon
					opt.text = ""+opt.value

				if isUndef(opt.value) and not isUndef(opt.text)
					opt.value = opt.text

				if not isUndef(opt.value) and first_value_opt == undefined
					first_value_opt = opt

			# auto - select first opt, if value unset
			# and no empty text allowed
			@_default_opt = undefined
			if first_value_opt
				@default_opt = first_value_opt
				@__value = @default_opt.value
			else
				CUI.warn("Select #{@getName()}: did not find a value opt and no empty text is defined.", opts: @opts)

			# CUI.debug "load options", @__uniqueId, @__options, @default_opt
		@__optionsPromise

	setData: (data) ->
		super(data, false)  # dont init data, only set
		if CUI.isFunction(@_options)
			@__loadOptions()
			.done =>
				@initData()
		else
			@initData()
		@

	getCheckboxClass: ->
		"cui-button-select"

	getButtonOpts: ->
		group: @_group
		role: "select"
		left: true # make sure we have a "left" container for the icon
		menu:
			active_item_idx: @default_opt?._idx or null
			allow_null: not isEmpty(@_empty_text)
			class: "ez-menu-select"
			# placements: ["c"]
			# onPosition: (menu, vp) =>
			# 	il = menu.getItemList()

			# 	active_item = il.getBody().DOM.children[il.getActiveIdx()]
			# 	if not active_item
			# 		return

			# 	item_top = vp.layer_pos.top - vp.dim_layer.marginTop + DOM.getDimensions(active_item).viewportTop
			# 	adjust = vp.dim_element.viewportTop - item_top
			# 	console.debug "adjust", adjust, item_top, vp.dim_element.viewportTop, vp.layer_pos.top, DOM.getDimensions(active_item).viewportTop
			# 	vp.layer_pos.top = vp.layer_pos.top + adjust
			# 	vp.layer_pos.left += 20

			onDeactivate: (btn, item, idx, flags) =>
				if flags.prior_activate
					return
				@storeValue(null, flags)
				if @isDestroyed()
					return
				@displayValue()
				@
			onClick: =>
				@_onClick?.apply(@, arguments)
			onShow: =>
				@_onShow?.apply(@, arguments)
			onHide: =>
				@_onHide?.apply(@, arguments)
			onActivate: (btn, item, idx, flags) =>
				@storeValue(@__options[idx].value, flags)
				if @isDestroyed()
					return
				@displayValue()
				# @DOM.trigger("list-view-resize")
				@
			items: (event) =>
				@__loadOptions(event)
				.done =>
					# in case we have updated options
					# we need to adjust the active idx
					@displayValue()
			has_items: true


	getDefaultValue: ->
		# CUI.debug "getDefaultValue", @__uniqueId, @default_opt
		if @default_opt
			@default_opt.value
		else
			undefined

	getValue: ->
		if @hasData()
			super()
		else
			@__value

	checkValue: (v, flags) ->
		true

	reload: ->
		if CUI.isFunction(@_options)
			@__loadOptions()
		super()

	storeValue: (value, flags) ->
		if @hasData()
			super(value, flags)
		else
			@__value = value
		@

	displayValue: ->
		DataFieldInput::displayValue.call(@)

		if not @__optionsPromise and CUI.isFunction(@_options)
			@__loadOptions()

		@__optionsPromise
		.done =>
			found_opt = null
			max_chars = null

			for opt, idx in @__options
				if found_opt == null and opt.value == @getValue()
					found_opt = opt

				if opt.text?.length > max_chars
					max_chars = opt.text?.length

			# console.warn "Select.displayValue", @getUniqueId(), @getData(), @getName(), @getValue()
			if found_opt
				if found_opt.icon
					@__checkbox.setIcon(found_opt.icon)
				else
					@__checkbox.setIcon(null)

				txt = found_opt.text_selected or found_opt.text

				@__checkbox.menuSetActiveIdx(found_opt._idx)
			else
				if @getValue() == null and not isEmpty(@_empty_text)
					txt = @_empty_text
				else
					# console.error("Select, option not found:", @getUniqueId(), @getValue(), @getData(), @getName(), "options:", @__options)
					txt = @_not_found_text+":"+@getValue()

				@__checkbox.menuSetActiveIdx(null)

			@__checkbox.setText(txt)

			if txt?.length > max_chars
				max_chars = txt.length

			@__checkbox.setTextMaxChars(max_chars)
		@


	getOptions: ->
		@__options

	@newSelectOrOutput: (opts) ->
		if opts.options.length == 1
			out_opts =
				form: opts.form
				text: opts.options[0].text
			new Output(out_opts)
		else
			new Select(opts)

