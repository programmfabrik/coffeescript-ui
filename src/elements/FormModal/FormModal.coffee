class FormModal extends FormPopover
	constructor: (@opts={}) ->
		super(@opts)
		# CUI.debug "FormPopover", @opts
		@__old_text = null
		@__old_display = null

	initOpts: ->
		super()
		@removeOpt("popover")
		@addOpts
			modal:
				default: {}
				check: "PlainObject"
			ok_button_opts:
				mandatory: true
				default:
					text: "Ok"
				check: "PlainObject"

	getPopover: (opts) ->
		opts.pane.footer_right = =>
			opts = copyObject(@_ok_button_opts, true)
			opts.onClick = =>
				@__popover.hide()
			new Buttonbar(buttons: [ new Button(opts) ])

		new Modal(opts)

	getPopoverOpts: ->
		pop_opts = copyObject(@_modal, true)
		if isEmpty(pop_opts.class)
			pop_opts.class = ""
		if not pop_opts.pane
			pop_opts.pane = {}
		assert($.isPlainObject(pop_opts.pane), "new FormModal", "opts.pane must be PlainObject", opts: pop_opts)
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