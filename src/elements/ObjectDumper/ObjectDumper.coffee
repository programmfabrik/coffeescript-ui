###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ObjectDumper extends CUI.ListViewTree

	constructor: (@opts = {}) ->
		super(@opts)

		if @_headers
			headerRow = new CUI.ListViewTreeHeaderNode(headers: @_headers)
			@root.children.splice(0,0, headerRow)

		@render(false)
		@root.open()

	initOpts: ->
		super()
		@addOpts
			object:
				mandatory: true
				check: (v) ->
					if CUI.isArray(v) or CUI.isPlainObject(v)
						true
					else
						false
			headers:
				default: [
					label: text: "key"
				,
					label: text: "value"
				]
				check: (v) ->
					v.length == 2

		@removeOpt("root")
		@removeOpt("cols")
		@removeOpt("colResize")
		@removeOpt("fixedRows")

	readOpts: ->
		super()
		@_cols = ["auto", "auto"]
		@_colClasses = ["cui-object-dumper-key", "cui-object-dumper-value"]
		if @_headers
			@_colResize = true
			@_fixedRows = 1

	initListView: ->
		super()
		@root = new CUI.ObjectDumperNode(data: @_object)
