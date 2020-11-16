###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ConfirmationChoice extends CUI.ConfirmationDialog
	constructor: (opts) ->
		super(opts)
		@__layer_root.addClass("cui-confirmation-choice")

	@defaults:
		ok: "Ok"
		cancel: "Cancel"

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
					if not CUI.util.isArray(v)
						return false

					for choice, idx in v
						if not choice
							continue
						CUI.Element.readOpts(choice, "new CUI.ConfirmationChoice[choice#"+idx+"]",
							CUI.ConfirmationChoice.choiceOpts)
					return true

	@choiceOpts:
		text:
			mandatory: true
			check: String
		onClick:
			check: Function
		icon:
			check: CUI.Icon
		choice:
			check: String
		tooltip:
			check: "PlainObject"
		cancel:
			default: false
			check: Boolean
		primary:
			mandatory: true
			default: false
			check: Boolean
		disabled:
			mandatory: true
			default: false
			check: Boolean

	readOpts: ->
		super()
		@_cancel_action = "cancel"

	init: ->
		@_buttons = []
		for choice in @_choices
			if not choice
				continue

			btn_opts =
				left: true
				value: choice
				disabled: choice.disabled
				tooltip: choice.tooltip
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
								return false

							@_onChoice?.call(@, ev, @__choice, @, btn)
					).done (ret1, ret2) =>
						# console.debug "chained call done", ret1, ret2, ev, @__choice
						if ev.isImmediatePropagationStopped() or
							ret1 == false or
							ret2 == false
								return

						# its possible that a previous click caused an error
						# so @__deferred would already be unset
						@__deferred?.resolve(@__getResolveValue(), btn, ev)
						@destroy()
					return

			for key of CUI.ConfirmationChoice.choiceOpts
				if key not in ["onClick", "cancel", "choice"]
					btn_opts[key] = choice[key]

			@_buttons.push(btn_opts)

		super()
		return

	__getResolveValue: =>
		@__choice

	show: ->
		CUI.util.assert(false, "ConfirmationChoice.show", "Use .open to open the ConfirmationChoice")

	cancel: (ev, ret) ->
		@hide(ev)
		@__deferred.reject(@__choice, ret)

	destroy: ->
		@__deferred = null
		super()

	# opens the dialog and returns a promise
	# promise fails if the user cancels
	open: ->
		if @__deferred
			return @__deferred.promise()

		@__deferred = new CUI.Deferred()

		CUI.ConfirmationDialog::show.call(@)

		@__deferred.always =>
			@__deferred = null

		return @__deferred.promise()

CUI.choice = (opts=text: "CUI.ConfirmationChoice") ->
	new CUI.ConfirmationChoice(opts).open()


CUI.defaults.class.ConfirmationChoice = CUI.ConfirmationChoice
