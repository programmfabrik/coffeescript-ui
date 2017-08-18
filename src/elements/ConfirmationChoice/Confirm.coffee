###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Confirm extends CUI.ConfirmationChoice
	initOpts: ->
		super()
		@removeOpt("choices")
		@mergeOpt("text", mandatory: true)
		@addOpts
			button_text_ok:
				mandatory: true
				default: CUI.defaults.class.ConfirmationChoice.defaults.ok
				check: String

			button_text_cancel:
				mandatory: true
				default: CUI.defaults.class.ConfirmationChoice.defaults.cancel
				check: String

			button_primary:
				mandatory: true
				default: "ok"
				check: ["ok", "cancel"]

	readOpts: ->
		super()

		@_choices = [
			text: @_button_text_cancel
			cancel: true
			choice: "cancel"
			primary: @_button_primary == "cancel"
		,
			text: @_button_text_ok
			choice: "ok"
			primary: @_button_primary == "ok"
		]

CUI.confirm = (opts) ->
	new CUI.Confirm(opts).open()


CUI.windowCompat.protect.push("confirm", "Confirm")
