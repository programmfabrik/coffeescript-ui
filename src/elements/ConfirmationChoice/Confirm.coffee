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
		if isEmpty(@opts.title)
			@opts.title = CUI.defaults.class.ConfirmationChoice.defaults.confirm_title
		if not @opts.hasOwnProperty("cancel")
			@opts.cancel = true

		super()

		@_choices = [
			text: @_button_text_cancel
			cancel: true
			primary: @_button_primary == "cancel"
		,
			text: @_button_text_ok
			primary: @_button_primary == "ok"
		]

CUI.confirm = (opts) ->
	new CUI.Confirm(opts).open()


