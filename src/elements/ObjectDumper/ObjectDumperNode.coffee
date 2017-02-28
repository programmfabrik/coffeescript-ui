class CUI.ObjectDumperNode extends CUI.ListViewTreeNode

	initOpts: ->
		super()
		@addOpts
			key:
				default: "root"
				mandatory: true
			data: {}
			do_open:
				mandatory: true
				default: false
				check: Boolean
			parse_json:
				mandatory: true
				default: false
				check: Boolean

		@removeOpt("colspan")
		@removeOpt("children")
		@removeOpt("getChildren")

	readOpts: ->
		super()
		@setData(@_data)
		@__info = @getInfoFromData(@getData())

		if @_key == "root"
			@children = @getNodesFromData(@getData())

		if not @isLeaf() and @_do_open
			@do_open = true

	setData: (data) ->

		if @_parse_json and isString(data)
			try
				@__data = JSON.parse(data)
			catch e
				@__data = data
		else
			@__data = data

		@

	getData: ->
		@__data

	getChildren: ->
		@getNodesFromData(@getData())

	isLeaf: ->
		not @__info.has_children

	renderContent: ->
		@addColumn(new ListViewColumn(
			class: "cui-object-dumper-node-value"
			element: new Label(
				text: @__info.text
				multiline: true
			)
		))
		new Label(
			class: "cui-object-dumper-node-key"
			text: @_key
			multiline: true
		)

	getClass: ->
		cls = super()
		cls + " cui-object-dumper-node-" + @__info.cls.toLowerCase()

	getInfoFromData: (data) ->

		info = {}
		if data == undefined
			info.cls = "undefined"
			info.text = "undefined"
		else if data == null
			info.cls = "null"
			info.text = "null"
		else if data == true
			info.cls = "boolean"
			info.text = "true"
		else if data == false
			info.cls = "boolean"
			info.text = "false"
		else if isNumber(data)
			info.cls = "number"
			info.text = ""+data
		else if isString(data)
			info.cls = "String"
			info.text = '"'+data+'"'
		else
			info.cls = getObjectClass(data)

			if CUI.isArray(data) or CUI.isPlainObject(data)
				info.has_children = not CUI.isEmptyObject(data)
				if CUI.isArray(data)
					info.text = info.cls + " [" + data.length + "]"
				if CUI.isPlainObject(data)
					info.text = info.cls + " {" + Object.keys(data).length + "}"
			else
				info.has_children = true
				info.text = info.cls

		info

	getNodesFromData: (data) ->
		nodes = []
		info = @getInfoFromData(data)
		for k, v of data
			nodes.push(new CUI.ObjectDumperNode(key: k, data: v, do_open: @_do_open, parse_json: @_parse_json))
		nodes

