###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Alert extends CUI.ConfirmationChoice
	initOpts: ->
		super()
		# @removeOpt("choices")
		# @mergeOpt("text", mandatory: true)
		@mergeOpt("choices", mandatory: false, default: undefined)

		@addOpts
			button_text_ok:
				mandatory: true
				default: CUI.defaults.class.ConfirmationChoice.defaults.ok
				check: String

	isKeyboardCancellable: (ev) ->
		true

	readOpts: ->
		super()
		if not @_choices
			@_choices = [
				text: @_button_text_ok
			]

CUI.alert = (opts=text: "CUI.alert") ->
	new CUI.Alert(opts).open()

class CUI.AlertProblem extends CUI.Alert

CUI.problem = (opts=text: "CUI.problem") ->
	new CUI.AlertProblem(opts).open()