class CUI.ListViewTreeHeaderNode extends CUI.ListViewTreeNode
	initOpts: ->
		super()
		@addOpts
			headers:
				check: (v) ->
					v.length > 0

	setElement: (@element) ->

	render: ->
		for header, idx in @_headers
			@addColumn(new ListViewHeaderColumn(header))
		@
