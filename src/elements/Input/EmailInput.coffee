###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class EmailInput extends Input
	initOpts: ->
		super()
		@removeOpt("checkInput")

	readOpts: ->
		super()
		@_checkInput = @__checkInput

	__checkInput: (value) ->
		if isEmpty(value) or EmailInput.regexp.exec(value)
			return true
		else
			return false

	@regexp: new RegExp("^[a-z0-9!\#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!\#$%&'*+/=?^_`{|}~-]+)*@(([a-z0-9][a-z0-9-]*[a-z0-9]\.)+[a-z0-9][a-z0-9-]*[a-z0-9]|localhost)$", "i")
