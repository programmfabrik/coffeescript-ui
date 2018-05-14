###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ListViewHeaderColumn extends CUI.ListViewColumn

	initOpts: ->
		super()

		@removeOpt("text")
		# @removeOpt("element")

		@addOpts
			spacer:
				check: Boolean
			rotate_90:
				check: Boolean
			label:
				check: (v) ->
					if CUI.util.isPlainObject(v) or v instanceof CUI.Label
						true
					else
						false

		return

	readOpts: ->
		super()
		if @_label instanceof CUI.Label
			@__label = @_label
		else if @_label
			@_label.rotate_90 = @_rotate_90
			@__label = new CUI.defaults.class.Label(@_label)

	setElement: (@__element) ->
		super(@__element)
		if @_rotate_90
			@addClass("cui-lv-td-rotate-90")

		@addClass("cui-lv-th")

		listView = @getRow().getListView()

		if not listView.hasResizableColumns()
			return @__element

		coldef = listView.getColdef(@getColumnIdx())
		if coldef == "fixed"
			return @__element

		move_handle = CUI.dom.element("DIV", class: "cui-lv-col-resize-handle")

		new CUI.ListViewColResize
			element: move_handle
			row: @getRow()
			column: @

		CUI.dom.append(@__element, move_handle)
		@__element

	render: ->
		if @_spacer
			arr = [ CUI.dom.div("cui-tree-node-spacer") ]
		else
			arr = []

		if @_element
			arr.push(@_element)
		else if @__label
			arr.push(@__label)

		arr

