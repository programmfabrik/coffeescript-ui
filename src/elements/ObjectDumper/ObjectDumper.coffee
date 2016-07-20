class ObjectDumper extends Element

	initOpts: ->
		super()
		@addOpts
			object:
				mandatory: true
				check: (v) ->
					not $.isFunction(v)
					try
						JSON.stringify(v)
					catch e
						CUI.error(e)
						return false
					return true

	render: ->
		 $div("cui-object-dumper-container").append(@__dumpToDiv(@_object))

	__dumpToDiv: (obj, depth = 0) ->

		label = (txt) =>
			new Label(text: txt).DOM

		if $.isPlainObject(obj)
			node = $table()
			for k, v of obj
				tr = $tr().appendTo(node)
				tr.append($td().append(new Label(text: k).DOM))
				tr.append($td().append(@__dumpToDiv(v, depth+1)))
		else if $.isArray(obj)
			node = $ul()
			for k in obj
				node.append($li().append(@__dumpToDiv(k, depth+1)))
		else if obj == true
			node = label("<true>")
		else if obj == false
			node = label("<false>")
		else if isNumber(obj)
			node = label(obj+"")
		else if isString(obj)
			node = label(obj)
		else if obj == null
			node = label("<null>")
		else if obj == undefined
			node = label("<undefined>")
		else
			CUI.error("Unable to dumpToDiv", obj)

		return node
