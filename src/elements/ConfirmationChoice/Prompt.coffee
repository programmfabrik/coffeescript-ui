class CUI.Prompt extends CUI.Confirm
	initOpts: ->
		super()
		@removeOpt("choices")
		@addOpts
			default:
				default: ""
				check: String

	readOpts: ->
		if isEmpty(@opts.title)
			@opts.title = CUI.defaults.class.ConfirmationChoice.defaults.prompt_title
		if not @opts.hasOwnProperty("cancel")
			@opts.cancel = true

		super()
		text = @_text

		delete(@_text) # delete so the ConfirmationDialog does not warn us

		@__data = input: @_default+""
		@_content = new Form
			fields: [
				type: Output
				multiline: true
				text: text
			,
				type: Input
				name: "input"
				data: @__data
				onKeyup: (inp, ev) =>
					if ev.keyCode() == 13
						@getButtons()[1].onClickAction(ev)

				onDataChanged: =>
					@__checkOkBtn()
			]
		.start()

		@_choices = [
			text: @_button_text_cancel
			cancel: true
			primary: @_button_primary == "cancel"
		,
			text: @_button_text_ok
			primary: @_button_primary == "ok"
		]

	open: ->
		@__checkOkBtn()
		dfr = new CUI.Deferred()
		super()
		.done (choice) =>
			dfr.resolve(@__data.input)
		.fail(dfr.reject)
		dfr.promise()


	__checkOkBtn: =>
		buttons = @getButtons()
		if @__data.input.trim().length > 0
			buttons[1].enable()
		else
			buttons[1].disable()


	getForm: ->


CUI.prompt = (opts) ->
	new CUI.Prompt(opts).open()


