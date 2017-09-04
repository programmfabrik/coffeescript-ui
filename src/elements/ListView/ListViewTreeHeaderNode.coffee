class CUI.ListViewTreeHeaderNode extends CUI.ListViewTreeNode
	initOpts: ->
		super()
		@addOpts
			headers:
				check: (v) ->
					v.length > 0

	render: ->
		@__is_rendered = true
		for header, idx in @_headers
			@addColumn(new CUI.ListViewHeaderColumn(header))
		@
