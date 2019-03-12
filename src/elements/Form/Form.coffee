class CUI.Form extends CUI.SimpleForm

	constructor: (opts) ->
		super(opts)
		if @_padded
			@addClass("cui-form--padded")

		return

	initOpts: ->
		super()
		@addOpts
			top: {}
			bottom: {}
			padded:
				check: Boolean
				default: false

	initTemplate: ->
		@registerTemplate(@__verticalLayout.getLayout())

	initLayout: ->
		vl_opts = class: "cui-form cui-form-appearance-"+@_appearance

		for k in [
			"maximize"
			"maximize_horizontal"
			"maximize_vertical"
		]
			if @hasSetOpt(k)
				vl_opts[k] = @getSetOpt(k)

		if @hasSetOpt("top")
			vl_opts.top = content: @_top

		if @hasSetOpt("bottom")
			vl_opts.bottom = content: @_bottom

		@__verticalLayout = new CUI.VerticalLayout(vl_opts)

		if @_render_as_grid
			@__verticalLayout.addClass("cui-form--grid")

		@__verticalLayout

	getLayout: ->
		@__verticalLayout

	appendToContainer: (stuff) ->
		@__verticalLayout.append(stuff, "center")
