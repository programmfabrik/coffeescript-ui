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

		if @_parse_json and CUI.util.isString(data)
			try
				@__data = JSON.parse(data)
				if CUI.util.isString(@__data)
					@__data = data
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
		if @isLeaf() or not @isOpen()
			@addColumn(new CUI.ListViewColumn(
				class: "cui-object-dumper-node-value"
				element: new CUI.Label(
					text: @__info.text
					multiline: true
				)
			))
		new CUI.Label(
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
		else if typeof(data) == "number" and isNaN(data)
			info.cls = "NaN"
			info.text = "NaN"
		else if CUI.util.isNumber(data)
			info.cls = "number"
			info.text = ""+data
		else if CUI.util.isString(data)
			info.cls = "String"
			info.text = '"'+data+'"'
		else
			info.cls = CUI.util.getObjectClass(data)

			if CUI.util.isArray(data) or CUI.util.isPlainObject(data)
				info.has_children = not CUI.util.isEmptyObject(data)
				if CUI.util.isArray(data)
					info.text = info.cls + " [" + data.length + "]"
				if CUI.util.isPlainObject(data)
					info.text = info.cls + " {" + Object.keys(data).length + "}"
			else
				info.has_children = true
				info.text = info.cls

		info

	getNodesFromData: (data) ->
		nodes = []
		info = @getInfoFromData(data)
		if info.cls == "Array"
			for idx in [0...data.length]
				nodes.push(new CUI.ObjectDumperNode(key: idx, data: data[idx], do_open: @_do_open, parse_json: @_parse_json))
		else
			keys = []
			for k of data
				keys.push(k)

			keys.sort (a, b) ->
				a.localeCompare(b)

			for k in keys
				v = data[k]
				nodes.push(new CUI.ObjectDumperNode(key: k, data: v, do_open: @_do_open, parse_json: @_parse_json))

		nodes
