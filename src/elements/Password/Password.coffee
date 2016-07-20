class Password extends Input
	__createElement: ->
		super("password")

	showPassword: ->
		@__input.prop("type", "text")

	hidePassword: ->
		@__input.prop("type", "password")