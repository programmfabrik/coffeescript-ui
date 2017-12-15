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

	#Construct a new CUI.Modal.
	#
	constructor: (@opts={}) ->
		super(@opts)

		@__addHeaderButton("fill_screen_button", CUI.Pane.getToggleFillScreenButton(tooltip: @_fill_screen_button_tooltip))

		@__addHeaderButton "cancel",
			class: "ez5-modal-close-button"
			icon:  "close"
			tooltip: @_cancel_tooltip or CUI.Modal.defaults.cancel_tooltip
			appearance: if CUI.__ng__ then "normal" else "flat"
			onClick: (ev, btn) =>
				@doCancel(ev, false, btn)

		@getPane().addClass("cui-pane--window")

		if @_onToggleFillScreen
			Events.listen
				type: ["start-fill-screen", "end-fill-screen"]
				node: @getPane()
				call: (ev) =>
					@_onToggleFillScreen.call(@, ev, @)

		return

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

	readOpts: ->
		if @opts.cancel and CUI.isPlainObject(@opts.pane)
			@opts.pane.force_header = true

		super()

	__addHeaderButton: (pname, _btn) ->
		if not @["_#{pname}"]
			return

		if CUI.isPlainObject(_btn)
			btn = new CUI.defaults.class.Button(_btn)
		else
			btn = _btn

		CUI.util.assert(btn instanceof CUI.Button, "Modal.__addHeaderButton", "Button needs to be instance of Button", btn: btn)

		CUI.util.assert(@__pane instanceof CUI.SimplePane, "new #{@__cls}", "opts.#{pname} can only be used if opts.pane is instance of SimplePane.", pane: @__pane, opts: @opts)

		@append(btn, "header_right")
		@

	__runOnAllButtons: (func) ->
		for el in CUI.dom.matchSelector(@__layer.DOM, ".cui-button,.cui-data-field")
			btn = CUI.dom.data(el, "element")
			if btn instanceof CUI.Button or btn instanceof CUI.DataField
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
			if CUI.util.isPromise(ret)
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

	focusOnShow: (ev) ->
		if ev == CUI.KeyboardEvent
			# set focus back on hide
			@__focused_on_show = true
		else
			@__focused_on_show = false

		@DOM.focus()
		@

	forceFocusOnShow: ->
		true

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

	setContent: (content) ->
		@getPane().replace(content, 'center')
		@position()
		@

	hide: (ev) ->
		@getPane().endFillScreen(false) # no transition
		super(ev)
