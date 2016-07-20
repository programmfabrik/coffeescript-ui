class EmailInput extends Input
	initOpts: ->
		super()
		@removeOpt("checkInput")

	readOpts: ->
		super()
		@_checkInput = @__checkInput

	__checkInput: (opts) ->
		if isEmpty(opts.value) or EmailInput.regexp.exec(opts.value)
			return true
		else if opts.leave
			return false
		else
			return "invalid"

	@regexp: ///
		^[a-z0-9!\#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!\#$%&'*+/=?^_`{|}~-]+)*
		@(([a-z0-9][a-z0-9-]*[a-z0-9]\.)+[a-z0-9][a-z0-9-]*[a-z0-9]|localhost)$
		///
