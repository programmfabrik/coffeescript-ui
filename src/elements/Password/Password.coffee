###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Password extends CUI.Input

	initOpts: ->
		super()
		@addOpts
			toggleButton:
				default: false
				check: Boolean

	readOpts: ->
		super()
		if @_toggleButton
			@_controlElement = new CUI.Button
				icon: "fa-eye"
				onClick: (ev, btn) =>
					if CUI.dom.getAttribute(@__input, "type") == "password"
						btn.setIcon("fa-eye-slash")
						@showPassword()
					else
						btn.setIcon("fa-eye")
						@hidePassword()

	__createElement: ->
		super("password")

	showPassword: ->
		CUI.dom.setAttribute(@__input, "type", "text")

	hidePassword: ->
		CUI.dom.setAttribute(@__input, "type", "password")
