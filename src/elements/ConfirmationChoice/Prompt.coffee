###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Prompt extends CUI.Confirm
	initOpts: ->
		super()
		@removeOpt("choices")
		@addOpts
			default:
				default: ""
				check: String

	readOpts: ->
		if not @opts.hasOwnProperty("cancel")
			@opts.cancel = true

		super()
		text = @_text

		delete(@_text) # delete so the ConfirmationDialog does not warn us

		@__input = null

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
				onConstruct: (@__input) =>
				onKeyup: (inp, ev) =>
					if ev.keyCode() == 13
						@getButtons()[1].onClickAction(ev)

				onDataChanged: =>
					@__checkOkBtn()
			]
		.start()

	getValue: ->
		@__input.getValue()

	open: ->
		@__checkOkBtn()
		dfr = new CUI.Deferred()
		super()
		.done (choice) =>
			dfr.resolve(@__data.input)
		.fail(dfr.reject)
		CUI.setTimeout
			call: =>
				@__input.focus().selectAll()
		dfr.promise()


	__checkOkBtn: =>
		buttons = @getButtons()
		if @__data.input.trim().length > 0
			buttons[1].enable()
		else
			buttons[1].disable()



CUI.prompt = (opts) ->
	new CUI.Prompt(opts).open()


