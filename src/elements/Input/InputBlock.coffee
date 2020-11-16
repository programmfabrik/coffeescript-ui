###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.InputBlock extends CUI.Element
	constructor: (opts) ->
		super(opts)
		@__start = @_start
		@setString(@_string)

	initOpts: ->
		super()
		@addOpts
			start:
				mandatory: true
				check: (v) ->
					CUI.util.isInteger(v) and v >= 0
			string:
				mandatory: true
				check: (v) ->
					CUI.util.isString(v)
	setString: (s) ->
		CUI.util.assert(CUI.util.isString(s), "#{CUI.util.getObjectClass(@)}.setString", "Parameter needs to be String with a minimum length of 1.", string: s)
		@__string = s
		@calcSizes()
		@

	getString: ->
		@_string

	calcSizes: ->
		@__len = @__string.length
		@__end = @__start + @__len
		for k in ["len", "end", "start", "string"]
			@[k] = @["__#{k}"]
		@

	incrementBlock: (block, blocks) ->
		block

	decrementBlock: (block, blocks) ->
		block


	toString: ->
		CUI.util.dump(
			start: @__start
			end: @__end
			len: @__len
			string: @__string
		)