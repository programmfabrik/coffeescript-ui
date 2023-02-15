###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.ObjectDumper extends CUI.ListViewTree

	constructor: (opts) ->
		super(opts)

		if @_headers
			headerRow = new CUI.ListViewTreeHeaderNode(headers: @_headers)
			@root.children.splice(0,0, headerRow)

		@render()
		@root.open()
		.always =>
			@_onAfterRender?(@)
		return

	initOpts: ->
		super()
		@addOpts
			object:
				mandatory: true
				check: (v) ->
					if CUI.util.isArray(v) or CUI.util.isPlainObject(v)
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
					v.length == 2 or CUI.util.isFalse(v)
			do_open:
				mandatory: true
				default: false
				check: Boolean
			parse_json:
				mandatory: true
				default: false
				check: Boolean
			onAfterRender:
				check: Function

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

		@_no_hierarchy = @__hasOnlyPlainValues(@_object)

	initListView: ->
		super()
		@root = new CUI.ObjectDumperNode(data: @_object, do_open: @_do_open, parse_json: @_parse_json)

	__hasOnlyPlainValues: (object) ->
		for key, value of object
			if CUI.util.isPlainObject(value) or CUI.util.isArray(value)
				return false
			if @_parse_json and CUI.util.isJSON(value)
				return false
		return true
