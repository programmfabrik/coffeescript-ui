###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
moment = require('moment')

class CUI.DateTimeInputBlock extends CUI.InputBlock
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

		console.debug "change block", block, blocks, diff, @_datetime, @_input_format.format

		mom = moment(@_datetime, @_input_format.input)

		if CUI.util.isFunction(@_matcher.inc_func)
			@_matcher.inc_func(mom, diff)
		else
			if diff < 0
				mom.subtract(@_matcher.inc_func_amount or 1, @_matcher.inc_func)
			else
				mom.add(@_matcher.inc_func_amount or 1, @_matcher.inc_func)

		for bl in blocks
			bl.setString(mom.format(bl._matcher.match_str))

		# console.debug "inc block", @_datetime, diff, mom.toString()
		return block
