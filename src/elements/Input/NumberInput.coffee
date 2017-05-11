###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.NumberInput extends CUI.Input
	initOpts: ->
		super()
		@addOpts
			decimals:
				default: 0
				check: "Integer"

			symbol:
				check: (v) ->
					isString(v) and v.length > 0

			symbol_before:
				default: false
				check: Boolean

			store_as_integer:
				default: false
				check: Boolean

			decimalpoint:
				mandatory: true
				default: "."
				check: [",","."]

			separator:
				check: (v) ->
					isString(v) and v.length > 0

			min:
				default: null
				check: (v) ->
					isNumber(v)

			max:
				default: null
				check: (v) ->
					isNumber(v)

		@removeOpt("checkInput")
		@removeOpt("getValueForDisplay")
		@removeOpt("getValueForInput")
		@removeOpt("correctValueForInput")
		@removeOpt("prevent_invalid_input")

	readOpts: ->
		super()
		@_checkInput = @__checkInput
		@_prevent_invalid_input = true
		@setMin(@_min)
		@setMax(@_max)

	setMin: (@__min) ->

	setMax: (@__max) ->

	formatValueForDisplay: (value=@getValue(), forInput = false) ->
		assert(typeof(value) == "number" or value == null, "NumberInput.formatValueForDisplay", "value needs to be Number or null", value: value, type: typeof(value))
		if isEmpty(value)
			return ""

		if @_store_as_integer
			v = (value / Math.pow(10, @_decimals)).toFixed(@_decimals)
		else
			v = value+""

		# decimal is a "."
		v0 = v.split(".")
		if v0.length > 1
			number = v0[0]
			decimals = v0[1]
		else
			number = v0[0]
			decimals = ""

		if @_decimals > 0
			while decimals.length < @_decimals
				decimals = decimals + "0"

		if forInput
			if @_decimals > 0
				return number + @_decimalpoint + decimals
			else
				return number

		if @_decimals > 0
			v1 = @__addSeparator(number)+@_decimalpoint+decimals
		else
			v1 = @__addSeparator(number)

		# console.debug "v: ", v, value, @__addSeparator(v), v1
		@__addSymbol(v1)

	getValue: ->
		v = super()
		if @hasData()
			return v

		# value is as string in our input
		@getValueForStore(v)

	getValueForDisplay: ->
		@formatValueForDisplay(@getValue())

	getValueForStore: (value) ->
		if not isString(value)
			value = value + ""
		number = parseFloat(value.replace(/,/,"."))
		if isNaN(number)
			return null

		if @_store_as_integer
			return parseInt((number * Math.pow(10, @_decimals)).toFixed(0))

		return number

	getDefaultValue: ->
		null

	setValue: (v, flags = {}) ->
		@checkValue(v)
		super(v, flags)

	checkValue: (v) ->
		if v == null
			true
		else if @_decimals > 0 and isFloat(v)
			true
		else if isInteger(v)
			true
		else
			throw new Error("#{@__cls}.setValue(value): Value needs to be Number or null.")

	__addSymbol: (str) ->
		if isEmpty(@_symbol)
			return str

		if @_symbol_before
			@_symbol+" "+str
		else
			str+" "+@_symbol

	__addSeparator: (str) ->
		if isEmpty(@_separator)
			return str

		nn = []
		for n,idx in str.split("").reverse()
			if idx%3 == 0 and idx > 0
				nn.push(@_separator)
			nn.push(n)
		nn.reverse()
		nn.join("")

	correctValueForInput: (value) ->
		value.replace(/[,\.]/, @_decimalpoint)

	getValueForInput: ->
		@formatValueForDisplay(null, true)

	checkInput: (value) ->
		if value == null
			return true
		else
			return super(value)

	__checkInput: (value) ->

		if not @hasShadowFocus()
			v = value.replace(@_symbol, "")
		else
			v = value

		v = v.trim()

		if v == ""
			return true

		if @_separator
			re = new RegExp(RegExp.escape(@_separator), "g")
			v = v.replace(re, "")

		point_idx = v.lastIndexOf(@_decimalpoint)
		if point_idx == -1
			number = v
			points = ""
		else
			if @_decimals == 0
				return false

			number = v.substring(0, point_idx)
			points = v.substring(point_idx+1)

		# console.debug "v:", v, "number:", number, "points:", points, "decimalpoint", @_decimalpoint, "separator", @_separator
		if points.length > @_decimals
			return false

		if number.length > 0 and not number.match(/^((0|[1-9]+[0-9]*)|(-|-[1-9]|-[1-9][0-9]*))$/)
			# CUI.debug "number not matched", number
			return false

		if not isNull(@__min)
			if @__min >= 0 and number == "-"
				return false

			if number < @__min
				return false

		if not isNull(@__max)
			if number > @__max
				return false

		if not points.match(/^([0-9]*)$/)
			# CUI.debug "points not matched", points
			return false

		if points.length > @_decimals
			return false

		return true # v.replace(".", @_decimalpoint)


	@format: (v, opts={}) ->
		if isEmpty(v)
			v = null

		# automatically set decimals
		if isFloat(v) and not opts.hasOwnProperty("decimals")
			_v = v+""
			opts.decimals = _v.length - _v.indexOf(".") - 1

		ni = new NumberInput(opts)
		ni.start()

		if not ni.checkInput(v+"")
			null
		else
			ni.formatValueForDisplay(v)

NumberInput = CUI.NumberInput