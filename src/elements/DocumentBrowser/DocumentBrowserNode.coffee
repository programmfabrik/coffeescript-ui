#
class CUI.DocumentBrowserNode extends CUI.ListViewTreeNode
	readOpts: ->
		super()

		@__url = @_url

		if @__url.endsWith("/")
			@__url = @__url.substr(0, @__url.length-1)

		# console.debug @__url, @_path

	initOpts: ->
		super()
		@addOpts
			url:
				check: (v) ->
					!!CUI.parseLocation(v)
			path:
				default: []
				check: Array
			text:
				check: String

	getChildren: ->
		if @opts.leaf
			return []

		@__loadChildren()

	__loadChildren: (dive = true) ->
		# console.debug @__url, @getNodePath()
		dfr = new CUI.Deferred()
		new CUI.XHR
			url: @__url + @getNodePath("menu.cms")
			responseType: "text"
		.start()
		.done (data, xhr) =>
			children = []
			items = []
			for row in data.split("\n")
				m = row.match(/^\s*(\S+?)(|=(\S+))\s*$/)
				if not m
					continue

				# console.debug "match:", dump(m)

				info = m[1].split(":")
				if m[3]
					text = m[3]
				else
					text = info[0]

				path = @_path.slice(0)
				path.push(info[0])

				items.push
					text: text
					path: path

			if items.length == 0
				@opts.leaf = true
				dfr.resolve([])
				return

			children_done = 0
			for item, idx in items
				child = new CUI.DocumentBrowserNode
					url: @__url
					text: item.text
					path: item.path

				children.push(child)
				if dive
					child.__loadChildren(false)
					.always =>
						children_done = children_done + 1
						if children_done == items.length
							dfr.resolve(children)
			if not dive
				dfr.resolve(children)
			return
		.fail =>
			@opts.leaf = true
			dfr.resolve([])
		dfr.promise()

	loadContent: ->
		filename = @getLastPathElement()+".md"
		new CUI.XHR
			url: @__url + @getNodePath(filename)
			responseType: "text"
		.start()

	selectLocation: (nodePath, dfr = new CUI.Deferred()) ->
		# console.debug "selectLocation", nodePath, "us:", @getNodePath()

		if nodePath == @getNodePath()
			dfr.resolve(@)
			return

		select_child = =>
			if @opts.leaf
				dfr.fail(@)

			for c in @children
				# console.debug c.getNodePath()
				if nodePath.startsWith(c.getNodePath()+"/") or nodePath == c.getNodePath()
					c.selectLocation(nodePath, dfr)
					return

			console.error("Unable to find:", nodePath, "in", @getNodePath())
			dfr.fail()

		if @children
			select_child()
		else
			@open()
			.always =>
				select_child()
		dfr

	getLastPathElement: ->
		@_path[@_path.length-1]

	getNodePath: (filename) ->
		nodePath = "/"+@_path.join("/")
		if not filename
			nodePath
		else if nodePath == "/"
			nodePath + filename
		else
			nodePath + "/" + filename

	absoluteUrl: (base, relative) ->
		stack = base.split("/")
		parts = relative.split("/")

		for part in parts
			if part == "."
				continue
			if part == ".."
				stack.pop()
			else
				stack.push(part)

		stack.join("/")


	rendererImage: (href, title, text) ->
		if href.startsWith("http:") or href.startsWith("//")
			url = null
		else if href.startsWith("/")
			url = @__url
		else
			url = @__url + @getNodePath()

		if url != null
			_href = @absoluteUrl(url, href)
		else
			_href = href

		# console.debug @, @__url, @_path, _href, href, title, text
		"<img src='"+_href+"' alt='"+escapeAttribute(text)+"' title='"+escapeAttribute(title)+"'></img>"

	renderContent: ->
		new Label(text: @_text, multiline: true)


class CUI.DocumentBrowserRootNode extends CUI.DocumentBrowserNode
