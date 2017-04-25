###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Checkbox extends DataFieldInput

	initOpts: ->

		super()
		@addOpts
			onClick:
				check: Function
			value:
				default: true
			value_unchecked:
				default: false
			text:
				check: String
			content:
				check: (v) ->
					isContent(v) or isString(v)
			active:
				default: false
				check: Boolean
			onActivate:
				check: Function
			onDeactivate:
				check: Function
			radio:
				check: String
			group:
				check: String
			radio_allow_null:
				check: Boolean
			tooltip:
				check: "PlainObject"
			icon_active:
				default: "check"
				mandatory: true
				check: (v) ->
					v instanceof Icon or isString(v)
			icon_inactive:
				check: (v) ->
					v instanceof Icon or isString(v)

	enable: ->
		super()
		@__checkbox?.enable()

	disable: ->
		super()
		@__checkbox?.disable()

	getButton: ->
		@__checkbox

	getOptValue: ->
		@_value

	getOptValueUnchecked: ->
		@_value_unchecked

	getCheckboxClass: ->
		"cui-button-checkbox"

	destroy: ->
		@__checkbox?.destroy()
		super()

	render: ->
		super()
		btn_opts = @getButtonOpts()

		btn_opts.onActivate = (btn, flags, event) =>
			if flags.initial_activate
				return
			@storeValue(@_value, flags)
			ret = @_onActivate?(@, flags, event)
			if isPromise(ret)
				ret.fail =>
					@storeValue(@_value_unchecked, flags)
			ret

		btn_opts.onDeactivate = (btn, flags, event) =>
			if flags.initial_activate
				return

			@storeValue(@_value_unchecked, flags)
			ret = @_onDeactivate?(@, flags, event)
			if isPromise(ret)
				ret.fail =>
					@storeValue(@_value, flags)
			ret

		if @_onClick
			btn_opts.onClick = (ev) =>
				@_onClick(ev, @)
				return

		# tooltip is managed by "DataField", so do not pass it
		# to the Button

		for k in [
			"text"
			"radio_allow_null"
			"active"
		]
			if not isUndef(btn_opts[k])
				continue
			btn_opts[k] = @["_#{k}"]

		if isEmpty(btn_opts.text)
			btn_opts.text = ""

		btn_opts.disabled = @isDisabled()
		btn_opts.center = @_content
		# btn_opts.class = @_class

		@__checkbox = new CUI.defaults.class.Button(btn_opts)

		@__checkbox.addClass(@getCheckboxClass())

		if @_icon_active != "check" or @_icon_inactive
			@addClass("cui-checkbox--icon")

		if CUI.__ng__
			@__checkbox.removeClass("cui-button-button")

		@proxy(@__checkbox, [
			"activate"
			"deactivate"
			"isActive"
			"getGroup"
			"setGroup"
			"setTextMaxChars"
			"setText"
			"getText"
		])

		# @append(@getChangedMarker())
		@replace(@__checkbox)


	checkValue: (v, flags) ->
		if not isBoolean(v)
			throw new Error("#{@__cls}.setValue(value): Value needs to be Boolean.")

	displayValue: ->
		super()
		if not @hasData()
			return

		# CUI.debug "Checkbox.displayValue", @DOM[0], @getName(), @opts, @getOptValue(), @getOptValueUnchecked(), @getValue()
		if @getOptValue() == @getValue()
			@__checkbox.activate(initial_activate: true)
		else
			@__checkbox.deactivate(initial_activate: true)
		@

	getButtonOpts: ->
		if @_radio
			role: "radio"
			radio: @_radio
			group: @_group
			icon_active: @_icon_active
			icon_inactive: @_icon_inactive
		else
			role: "checkbox"
			switch: true
			group: @_group
			icon_active: @_icon_active
			icon_inactive: @_icon_inactive

	getDefaultValue: ->
		if @_active
			@_value
		else
			@_value_unchecked

	isChanged: ->
		if not @hasData()
			return undefined

		if not @_radio
			return super()

		# this radio button is selected
		if @getValue() == @getOptValue()
			return super()

		# this radio button is not selected
		# is has changed if the checked value
		return @__checkChangedValue == JSON.stringify(@getOptValue())

