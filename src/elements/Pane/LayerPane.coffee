class LayerPane extends Layer

	constructor: (@opts={}) ->
		super(@opts)
		@setPane(@_pane)

	initOpts: ->
		super()
		@addOpts
			pane:
				mandatory: true
				default:
					new SimplePane()
				check: (v) ->
					v instanceof Pane or $.isPlainObject(v)

	getPane: ->
		@__pane


	setPane: (pane) ->
		if $.isPlainObject(pane)
			@__pane = new SimplePane(pane)
		else
			@__pane = pane
		@__pane.addClass("cui-layer-pane");
		# add pane to layer, using the layers append
		# method, so subclasses (like Modal does!) cannot interfer
		Layer::replace.call(@, @__pane)

	destroy: ->
		# CUI.debug "destroying pane", @__pane
		@__pane.destroy()
		super()
