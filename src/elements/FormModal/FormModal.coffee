###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.FormModal extends CUI.FormPopover
	constructor: (@opts={}) ->
		super(@opts)
		# console.debug "FormPopover", @opts
		@__old_text = null
		@__old_display = null

	initOpts: ->
		super()
		@removeOpt("popover")
		@addOpts
			modal:
				default: {}
				check: "PlainObject"
				apply_button:
					mandatory: true
					default:
						text: "Ok"
					check: (v) =>
						CUI.util.isPlainObject(v)

	initPopover: (opts) ->

		btn_opts = CUI.util.copyObject(@_modal.apply_button, true)

		onClick = btn_opts.onClick

		btn_opts.onClick = (ev, btn) =>
			CUI.decide(onClick?(ev, btn, @))
			.done =>
				@__popover.hide()

		btn = new CUI.defaults.class.Button(btn_opts)

		if @hasChanges()
			btn.enable()
		else
			btn.disable()

		opts.pane.footer_right = btn

		mod = new CUI.Modal(opts)

		if @__orig_set_data
			CUI.Events.listen
				type: "data-changed"
				node: mod
				call: =>
					if @hasChanges()
						btn.enable()
					else
						btn.disable()

		mod

	revertData: ->
		CUI.util.assert(@__orig_set_data, "Form.revertData", "Only supported with opts.name set and opts.data PlainObject.", opts: @opts)
		delete(@__data)
		if @__orig_data
			@__orig_set_data[@_name] = @__orig_data
		else
			delete(@__orig_set_data[@_name])

		@setData(@__orig_set_data)

		@resetTableAndFields()

		CUI.Events.trigger
			type: "data-changed"
			node: @getPopover()
		@

	setData: (data) ->
		if @_name and not CUI.util.isFunction(data)
			if data[@_name]
				@__orig_data = CUI.util.copyObject(data[@_name], true)
			else
				@__orig_data = undefined
			@__orig_set_data = data
		super(data)

	__closePopover: ->
		if @__orig_set_data
			@__orig_data = CUI.util.copyObject(@__orig_set_data[@_name], true)
		super()

	hasChanges: ->
		if @__orig_set_data
			JSON.stringify(@__orig_data) != JSON.stringify(@__orig_set_data[@_name])
		else
			null

	getPopoverOpts: ->
		pop_opts = CUI.util.copyObject(@_modal, true)

		if pop_opts.cancel and @__orig_set_data
			onCancel = pop_opts.onCancel
			pop_opts.onCancel = (ev, modal) =>
				dfr = new CUI.Deferred()

				CUI.decide(onCancel?(ev, modal, @hasChanges()))
				.done(dfr.resolve)
				.fail(dfr.reject)

				dfr.done =>
					@revertData()

				dfr.promise()

		delete(pop_opts.apply_button)
		if CUI.util.isEmpty(pop_opts.class)
			pop_opts.class = ""

		# don't center this to an element
		pop_opts.element = null
		if not pop_opts.pane
			pop_opts.pane = {}
		CUI.util.assert(CUI.util.isPlainObject(pop_opts.pane), "new CUI.FormModal", "opts.pane must be PlainObject", opts: pop_opts)
		pop_opts.class += " cui-form-modal-modal"
		pop_opts

	disable: ->
		super()
		@__button?.disable()

	enable: ->
		super()
		@__button?.enable()

	destroy: ->
		super()
		@__popover?.destroy()
