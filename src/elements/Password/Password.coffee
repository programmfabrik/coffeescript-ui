###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Password extends Input
	__createElement: ->
		super("password")

	showPassword: ->
		@__input.prop("type", "text")

	hidePassword: ->
		@__input.prop("type", "password")