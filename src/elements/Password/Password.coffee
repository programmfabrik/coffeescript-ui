###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Password extends CUI.Input
	__createElement: ->
		super("password")

	showPassword: ->
		CUI.dom.setAttribute(@__input, "type", "text")

	hidePassword: ->
		CUI.dom.setAttribute(@__input, "type", "password")
