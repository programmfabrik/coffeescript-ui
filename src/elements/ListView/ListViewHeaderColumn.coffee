class ListViewHeaderColumn extends ListViewColumn

	initOpts: ->
		super()

		@removeOpt("text")
		@removeOpt("element")

		@addOpts
			rotate_90:
				check: Boolean
			label:
				mandatory: true
				check: (v) ->
					if $.isPlainObject(v) or v instanceof Label
						true
					else
						false

		return

	readOpts: ->
		super()
		if @_label instanceof Label
			@__label = @_label
		else
			@_label.rotate_90 = @_rotate_90
			@__label = new CUI.defaults.class.Label(@_label)

	setElement: (@__element) ->
		super(@__element)
		if @_rotate_90
			@addClass("cui-lv-td-rotate-90")
		@__element

	render: ->
		@__label.DOM

