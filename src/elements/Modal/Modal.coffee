###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

# Modal
#
class CUI.Modal extends CUI.LayerPane

	@defaults:
		cancel_tooltip: text: "Close Dialog"

	#Construct a new Modal.
	#
	constructor: (@opts={}) ->
		super(@opts)

		@__addHeaderButton("fill_screen_button", Pane.getToggleFillScreenButton(tooltip: @_fill_screen_button_tooltip))

		@__addHeaderButton "cancel",
			class: "ez5-modal-close-button"
			icon:  "close"
			tooltip: @_cancel_tooltip or CUI.Modal.defaults.cancel_tooltip
			appearance: if CUI.__ng__ then "normal" else "flat"
			onClick: (ev, btn) =>
				@doCancel(ev, false, btn)

	initOpts: ->
		super()
		@mergeOpt "backdrop",
			default:
				policy: "modal"
				add_bounce_class: true
				content: null
		@addOpts
			cancel:
				check: Boolean
			cancel_action:
				default: "destroy"
				check: ["destroy", "hide"]
			cancel_tooltip:
				check: "PlainObject"
			onCancel:
				check: Function
			# show a fill screen button
			fill_screen_button:
				check: Boolean
			fill_screen_button_tooltip:
				check: "PlainObject"
			onToggleFillScreen:
				check: Function

		@mergeOpt "placement",
			default: "c"

	__addHeaderButton: (pname, _btn) ->
		if not @["_#{pname}"]
			return

		if CUI.isPlainObject(_btn)
			btn = new CUI.defaults.class.Button(_btn)
		else
			btn = _btn

		assert(btn instanceof Button, "Modal.__addHeaderButton", "Button needs to be instance of Button", btn: btn)

		assert(@__pane instanceof SimplePane, "new #{@__cls}", "opts.#{pname} can only be used if opts.pane is instance of SimplePane.", pane: @__pane, opts: @opts)

		@append(btn, "header_right")
		@

	__runOnAllButtons: (func) ->
		for el in @__layer.DOM.find(".cui-button")
			btn = DOM.data(el, "element")
			if btn instanceof Button
				btn[func]()
		return

	disableAllButtons: ->
		@__runOnAllButtons("disable")

	enableAllButtons: ->
		@__runOnAllButtons("enable")

	isKeyboardCancellable: (ev) ->
		if @_cancel
			true
		else
			super(ev)

	doCancel: (ev, force_callback = false, button = null) ->
		if not @_cancel and not force_callback
			super(ev)
		else
			ret = @_onCancel?(ev, @)
			if isPromise(ret)
				if button
					button.disable()
					button.startSpinner()
					ret.always =>
						button.stopSpinner()
						button.enable()
				ret.done (value) => @[@_cancel_action](ev, value)
			else if ret != false
				@[@_cancel_action](ev, ret)
		return

	# PROXY some functions
	empty: (key="center") ->
		@getPane().empty(key)
		@position()
		@

	append: (content, key="center") ->
		@getPane().append(content, key)
		@position()
		@

	replace: (content, key="center") ->
		@getPane().replace(content, key)
		@position()
		@

	hide: (ev) ->
		@getPane().endFillScreen(false) # no transition
		super(ev)


Modal = CUI.Modal
