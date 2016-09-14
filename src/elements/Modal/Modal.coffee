# Modal
#
class CUI.Modal extends CUI.LayerPane

	#Construct a new Modal.
	#
	constructor: (@opts={}) ->
		super(@opts)
		@__defer_auto_size = false

		@__addHeaderButton("fill_screen_button", Pane.getToggleFillScreenButton())

		Events.listen
			type: "end-fill-screen"
			node: @getPane().DOM
			call: (ev) =>
				if @__defer_auto_size
					@autoSize(false)
					@__defer_auto_size = false
				return

		@__addHeaderButton "cancel",
			class: "ez5-modal-close-button"
			icon:  "close"
			appearance: if CUI.__ng__ then "flat" else "normal"
			onClick: (ev) =>
				@doCancel(ev)


	readOpts: ->
		super()

		if not @opts.backdrop?.policy
			@_backdrop.policy = "modal"

		@

	initOpts: ->
		super()
		@addOpts
			cancel:
				check: Boolean
			cancel_action:
				default: "destroy"
				check: ["destroy", "hide"]
			onCancel:
				check: Function
			# show a fill screen button
			fill_screen_button:
				check: Boolean
			onToggleFillScreen:
				check: Function

		@mergeOpt "placement",
			default: "c"


	__addHeaderButton: (pname, _btn) ->
		if not @["_#{pname}"]
			return

		if CUI.isPlainObject(_btn)
			btn = new Button(_btn)
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

	doCancel: (ev) ->
		if not @_cancel
			super(ev)
		else
			ret = @_onCancel?(ev, @)
			if isPromise(ret)
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

	autoSize: (immediate = false) ->
		if @getPane().getFillScreenState()
			@__defer_auto_size = true
		else
			super(immediate)


Modal = CUI.Modal
