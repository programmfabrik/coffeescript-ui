class CUI.ListViewTreeHeaderNode extends CUI.ListViewTreeNode
	initOpts: ->
		super()
		@addOpts
			headers:
				check: (v) ->
					v.length > 0

	renderContent: ->
		for header, idx in @_headers
			if idx == 0
				if header.label instanceof CUI.Label
					ret = header.label
				else
					ret = new CUI.defaults.class.Label(header.label)
			else
				@addColumn(new ListViewHeaderColumn(header))
		ret
