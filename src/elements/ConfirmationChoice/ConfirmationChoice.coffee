class CUI.ConfirmationChoice extends CUI.ConfirmationDialog
	constructor: (@opts) ->
		super(@opts)
		@__layer_root.addClass("cui-confirmation-choice")

	@defaults:
		ok: "Ok"
		cancel: "Cancel"
		alert_title: "..."
		confirm_title: "Confirmation"
		prompt_title: "???"

	initOpts: ->
		super()
		@removeOpt("buttons")
		@removeOpt("header_right")
		@removeOpt("cancel_action")
		@addOpts
			onChoice:
				check: Function

			choices:
				mandatory: true
				default: []
				check: (v) ->
					if not CUI.isArray(v)
						return false

					for choice in v
						CUI.Element.readOpts(choice, "new ConfirmationChoice", @choiceOpts)
					return true

	choiceOpts:
		text:
			mandatory: true
			check: String
		onClick:
			check: Function
		icon:
			check: Icon
		cancel:
			default: false
			check: Boolean
		primary:
			mandatory: true
			default: false
			check: Boolean

	readOpts: ->
		super()
		@_cancel_action = "cancel"

	init: ->
		@_buttons = []
		for choice in @_choices
			btn_opts =
				left: true
				value: choice
				onClick: (ev, btn) =>
					@__choice = btn.getValue()
					CUI.chainedCall(
						=>
							ret = @__choice.onClick?.call(@, ev, btn)
					,
						=>
							if @__choice.cancel
								@doCancel(ev, true) # force this in case opts.cancel is not set
								# go out of the way
								false
							else
								@_onChoice?.call(@, ev, @__choice)
					).done (ret1, ret2) =>
						# CUI.debug "chained call done", ret1, ret2, ev, @__choice
						if ev.isImmediatePropagationStopped() or
							ret1 == false or
							ret2 == false
								return

						@destroy()
						@__deferred.resolve(@__getResolveValue(), btn, ev)
					return

			for key of @choiceOpts
				if key not in ["onClick", "cancel"]
					btn_opts[key] = choice[key]

			@_buttons.push(btn_opts)

		super()
		return

	__getResolveValue: =>
		@__choice

	show: ->
		assert(false, "ConfirmationChoice.show", "Use .open to open the ConfirmationChoice")

	cancel: (ev, ret) ->
		@hide(ev)
		@__deferred.reject(@__choice, ret)

	# opens the dialog and returns a promise
	# promise fails if the user cancels
	open: ->
		@__deferred = new CUI.Deferred()
		CUI.ConfirmationDialog::show.call(@)
		return @__deferred.promise()



CUI.defaults.class.ConfirmationChoice = CUI.ConfirmationChoice
