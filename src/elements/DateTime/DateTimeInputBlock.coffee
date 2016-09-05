class DateTimeInputBlock extends InputBlock
	initOpts: ->
		super()
		@addOpts
			matcher:
				mandatory: true
				check: "PlainObject"
			datetime:
				mandatory: true
				check: String
			input_format:
				mandatory: true
				check: (v) ->
					!!v.input


	incrementBlock: (block, blocks) ->
		@__changeBlock(block, blocks, 1)

	decrementBlock: (block, blocks) ->
		@__changeBlock(block, blocks, -1)

	__changeBlock: (block, blocks, diff) ->

		CUI.debug "change block", block, blocks, diff, @_datetime, @_input_format.format

		mom = moment(@_datetime, @_input_format.input)

		if CUI.isFunction(@_matcher.inc_func)
			@_matcher.inc_func(mom, diff)
		else
			if diff < 0
				mom.subtract(@_matcher.inc_func_amount or 1, @_matcher.inc_func)
			else
				mom.add(@_matcher.inc_func_amount or 1, @_matcher.inc_func)

		for bl in blocks
			bl.setString(mom.format(bl._matcher.match_str))

		# CUI.debug "inc block", @_datetime, diff, mom.toString()
		return block
