###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.EmailInput extends CUI.Input
	initOpts: ->
		super()
		@removeOpt("checkInput")

	readOpts: ->
		super()
		@_checkInput = @__checkInput

	__checkInput: (value) ->
		if CUI.util.isEmpty(value) or CUI.EmailInput.regexp.exec(value)
			return true
		else
			return false

	@regexp: /^[\S]+@(?:[\S]+\.[A-Z]{2,}|localhost)$/i
