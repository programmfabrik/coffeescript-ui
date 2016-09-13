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

	readOpts: ->
		if isEmpty(@opts.title)
			@opts.title = CUI.defaults.class.ConfirmationChoice.defaults.alert_title

		super()
		@_choices = [
			text: @_button_text_ok
		]

CUI.alert = (opts=text: "CUI.alert") ->
	new CUI.Alert(opts).open()

CUI.problem = (opts=text: "CUI.problem") ->
	if not opts.class
		opts.class = ""
	opts.class += " cui-alert-problem"
	CUI.alert(opts)

