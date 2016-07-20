class NumberInput extends Input
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

	readOpts: ->
		super()
		@_checkInput = @__checkInput

	formatValueForInput: (value) ->
		if @_store_as_integer
			if isEmpty(value)
				""
			else
				(value / Math.pow(10, @_decimals)).toFixed(@_decimals)
		else
			value+""

	displayValue: ->
		DataField::displayValue.call(@)
		if not @hasData()
			return

		opts =
			leave: true
			value: @formatValueForInput(@getValue())

		if @_checkInput(opts) != false
			@__input.val(opts.value)
		else
			@__input.val("")
		@

	storeValue: (value, flags={}) ->
		if not isString(value)
			value = value + ""
		number = parseFloat(value.replace(/,/,"."))
		if isNaN(number)
			super(null, flags)
		else
			if @_store_as_integer
				number = parseInt((number * Math.pow(10, @_decimals)).toFixed(0))
			super(number, flags)
		@

	getDefaultValue: ->
		null

	checkValue: (v) ->
		if v == null
			true
		else if @_decimals > 0 and isFloat(v)
			true
		else if isInteger(v)
			true
		else
			throw new Error("#{@__cls}.setValue(value): Value needs to be Number or null.")

	__checkInput: (opts) ->
		opts.value = opts.value.replace(@_symbol, "")
		opts.value = opts.value.trim()
		v = opts.value
		if @_separator and opts.enter
			v = v.split(@_separator).join("")
		if v == ""
			return
		# CUI.debug "v", v, @_decimalpoint
		if @_decimalpoint == "."
			v = v.replace(",",".")
		else if @_decimalpoint == ","
			v = v.replace(".",",")

		chars = v.split(@_decimalpoint)
		# CUI.debug "first", v, @_decimalpoint, dump(chars)
		if chars.length > 2
			# CUI.debug "more splits", chars.length
			return false
		if chars.length > 1 and @_decimals == 0
			# CUI.debug "more splits", chars.length, @_decimals
			return false

		number = chars[0]
		points = chars[1] or ""

		if not number.match(/^((0|[1-9]+[0-9]*)|(-|-[1-9]|-[1-9][0-9]*))$/)
			# CUI.debug "number not matched", number
			return false

		if not isNull(@_min)
			if @_min >= 0 and number == "-"
				return false

			if number < @_min
				return false

		if not isNull(@_max)
			if number > @_max
				return false

		if not points.match(/^([0-9]*)$/)
			# CUI.debug "points not matched", points
			return false


		if number.length == 0
			number = "0"
		# CUI.debug "second", number, points, dump(chars)

		if points.length < @_decimals
			if opts.leave
				p = points.split("")
				for i in [points.length...@_decimals]
					p.push("0")
				points = p.join("")
		else if points.length > @_decimals
			p = points.split("")
			p.splice(@_decimals)
			points = p.join("")

		if opts.leave and @_separator
			nn = []
			for n,idx in number.split("").reverse()
				if idx%3 == 0 and idx > 0
					nn.push(@_separator)
				nn.push(n)
			nn.reverse()
			number = nn.join("")

		if points.length > 0 or chars[1] == ""
			opts.value = number + @_decimalpoint + points
		else
			opts.value = number

		if opts.leave and @_symbol
			if @_symbol_before
				opts.value = @_symbol+" "+opts.value
			else
				opts.value = opts.value+" "+@_symbol

		# CUI.debug "new value", opts.value
		return true


	@format: (v, _opts={}) ->
		if isEmpty(v)
			v = ""

		if isNumber(v)
			v = ""+v

		ni = new NumberInput(_opts)
		opts = leave: true, value: ni.formatValueForInput(v)
		if not ni.__checkInput(opts)
			null
		else
			opts.value
