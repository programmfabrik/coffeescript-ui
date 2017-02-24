class CUI.ObjectDumperNode extends CUI.ListViewTreeNode
	initOpts: ->
		super()
		@addOpts
			key:
				default: "root"
				mandatory: true
			data:
				mandatory: true
		@removeOpt("colspan")
		@removeOpt("children")
		@removeOpt("getChildren")

	readOpts: ->
		super()
		@__info = @getInfoFromData(@_data)

		if @_key == "root"
			@children = @getNodesFromData(@_data)

	getChildren: ->
		@getNodesFromData(@_data)

	isLeaf: ->
		not @__info.has_children

	renderContent: ->
		@addColumn(new ListViewColumn(class: "cui-object-dumper-node-"+@__info.cls.toLowerCase(), text: @__info.text))
		new Label(class: "cui-object-dumper-node-key cls", text: @_key)

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
			nodes.push(new CUI.ObjectDumperNode(key: k, data: v))
		nodes

