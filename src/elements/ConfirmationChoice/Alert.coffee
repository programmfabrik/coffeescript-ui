class CUI.Alert extends CUI.ConfirmationChoice
	initOpts: ->
		super()
		@removeOpt("choices")
		@mergeOpt("text", mandatory: true)
		@addOpts
			button_text_ok:
				mandatory: true
				default: CUI.defaults.class.ConfirmationChoice.defaults.ok
				check: String

	isKeyboardCancellable: (ev) ->
		true

	readOpts: ->
		super()
		@_choices = [
			text: @_button_text_ok
		]

CUI.alert = (opts=text: "CUI.alert") ->
	new CUI.Alert(opts).open()

class CUI.AlertProblem extends CUI.Alert

CUI.problem = (opts=text: "CUI.problem") ->
	new CUI.AlertProblem(opts).open()
