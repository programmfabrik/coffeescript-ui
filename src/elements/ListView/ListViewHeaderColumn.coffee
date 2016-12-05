###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class ListViewHeaderColumn extends ListViewColumn

	initOpts: ->
		super()

		@removeOpt("text")
		@removeOpt("element")

		@addOpts
			spacer:
				check: Boolean
			rotate_90:
				check: Boolean
			label:
				mandatory: true
				check: (v) ->
					if CUI.isPlainObject(v) or v instanceof Label
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

		@addClass("cui-lv-th")
		@__element

	render: ->
		if @_spacer
			arr = [ $div("cui-tree-node-spacer") ]
		else
			arr = []

		arr.push(@__label.DOM)
		arr

