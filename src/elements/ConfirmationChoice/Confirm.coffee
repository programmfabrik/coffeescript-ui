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

	readOpts: ->
		if isEmpty(@opts.title)
			@opts.title = CUI.defaults.class.ConfirmationChoice.defaults.confirm_title
		if not @opts.hasOwnProperty("cancel")
			@opts.cancel = true

		super()

		@_choices = [
			text: @_button_text_cancel
			cancel: true
		,
			text: @_button_text_ok
		]

CUI.confirm = (opts) ->
	new CUI.Confirm(opts).open()


