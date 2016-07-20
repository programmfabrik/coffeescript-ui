class ListViewHeaderColumn extends ListViewColumn

	initOpts: ->
		super()

		@removeOpt("text")
		@removeOpt("element")

		@addOpts
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
			@__label = new Label(@_label)

	render: ->
		@__label.DOM

