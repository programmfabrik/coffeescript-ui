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
					CUI.util.isString(v) and v.length > 0

			symbol_before:
				default: false
				check: Boolean

			store_as_integer:
				default: false
				check: Boolean

			json_number:
				default: false
				check: Boolean

			decimalpoint:
				mandatory: true
				default: "."
				check: [",","."]

			separator:
				check: (v) ->
					CUI.util.isString(v) and v.length > 0

			min:
				default: null
				check: (v) ->
					CUI.util.isNumber(v)

			max:
				default: null
				check: (v) ->
					CUI.util.isNumber(v)

		@removeOpt("checkInput")
		@removeOpt("getValueForDisplay")
		@removeOpt("getValueForInput")
		@removeOpt("correctValueForInput")
		@removeOpt("prevent_invalid_input")

	readOpts: ->
		super()
		if @_json_number
			@_decimals = 13
		@_checkInput = @__checkInput
		@_prevent_invalid_input = true
		@setMin(@_min)
		@setMax(@_max)

	setMin: (@__min) ->

	setMax: (@__max) ->

	formatValueForDisplay: (value=@getValue(), forInput = false) ->
		CUI.util.assert(typeof(value) == "number" or value == null, "NumberInput.formatValueForDisplay", "value needs to be Number or null", value: value, type: typeof(value))
		if CUI.util.isEmpty(value)
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

		if @_decimals > 0 and not @_json_number
			while decimals.length < @_decimals
				decimals = decimals + "0"

		if forInput
			if @_decimals > 0 or @_json_number
				return number + @_decimalpoint + decimals
			else
				return number

		if @_decimals > 0 or @_json_number
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
		if not CUI.util.isString(value)
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
		else if (@_decimals > 0 or @_json_number) and CUI.util.isFloat(v)
			true
		else if CUI.util.isInteger(v)
			true
		else
			throw new Error("#{@__cls}.setValue(value): Value needs to be Number or null.")

	__addSymbol: (str) ->
		if CUI.util.isEmpty(@_symbol)
			return str

		if @_symbol_before
			@_symbol+" "+str
		else
			str+" "+@_symbol

	__addSeparator: (str) ->
		if CUI.util.isEmpty(@_separator)
			return str

		isNegative = str.startsWith("-")
		if isNegative
			str = str.substr(1)
		nn = []
		for n,idx in str.split("").reverse()
			if idx%3 == 0 and idx > 0
				nn.push(@_separator)
			nn.push(n)

		if isNegative
			nn.push("-")

		nn.reverse()
		nn.join("")

	correctValueForInput: (value) ->
		return value.replace(/[,\.]/g, @_decimalpoint)

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
		if points.length > @_decimals and not @_json_number
			return false

		if number.length > 0 and not number.match(/^((0|[1-9]+[0-9]*)|(-|-[1-9]|-[1-9][0-9]*))$/) and not @_json_number
			# console.debug "number not matched", number
			return false

		if not CUI.util.isNull(@__min)
			if @__min >= 0 and number == "-"
				return false

			if number < @__min
				return false

		if not CUI.util.isNull(@__max)
			if number > @__max
				return false

		if not points.match(/^([0-9]*)$/) and not @_json_number
			# console.debug "points not matched", points
			return false

		if points.length > @_decimals and not @_json_number
			return false

		return true # v.replace(".", @_decimalpoint)

	@format: (v, opts={}) ->
		if CUI.util.isEmpty(v)
			v = null

		# automatically set decimals
		if CUI.util.isFloat(v) and not opts.hasOwnProperty("decimals") and not opts.hasOwnProperty("json_number")
			_v = v+""
			opts.decimals = _v.length - _v.indexOf(".") - 1

		ni = new CUI.NumberInput(opts)
		ni.start()

		if not ni.checkInput(v+"")
			null
		else
			ni.formatValueForDisplay(v)

	@parse: (string, decimals) ->
		if isNaN(string.replace(/[,\.]/g, "")) # Remove comma to check if the input is valid.
			return null

		if isNaN(decimals)
			decimals = 0

		commaIndex = string.indexOf(",")
		dotIndex = string.indexOf(".")
		# Comma or dot not found, nothing to do.
		if commaIndex == -1 and dotIndex == -1
			return parseInt(string)

		# In case both are found, we assume that the first one will be the thousand and the second one the decimal separator.
		if dotIndex > 0 and commaIndex > 0
			if dotIndex > commaIndex
				thousandSeparatorRegex = /,/g
			else
				thousandSeparatorRegex = /\./g

		# When decimal defined, we can guess the decimal separator if the input has the correct amount of decimals.
		if not thousandSeparatorRegex and decimals > 0
			decimal = string[string.length - 1 - decimals]
			if decimal == ","
				thousandSeparatorRegex = /\./g
			else if decimal == "."
				thousandSeparatorRegex = /,/g

		# When there is no decimals it is possible to check with a regexp whether the separator is a valid thousand separator.
		if not thousandSeparatorRegex and decimals == 0
			if string.match(/^\d{1,3}([\.,]\d{3})+/)?[0] == string
				if dotIndex > 0
					thousandSeparatorRegex = /\./g
				else
					thousandSeparatorRegex = /,/g

		if thousandSeparatorRegex
			string = string.replace(thousandSeparatorRegex, "")

		if decimals == 0
			return parseInt(string)
		else
			string = string.replace(/,/, ".")
			return parseFloat(string)
