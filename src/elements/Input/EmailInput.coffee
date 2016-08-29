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
