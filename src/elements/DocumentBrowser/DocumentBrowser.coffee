class CUI.DocumentBrowser extends CUI.Element

	initOpts: ->
		super()
		@addOpts
			gotoLocation:
				check: Function
				default: (nodePath) =>
					@loadLocation(nodePath)
			url:
				check: (v) ->
					!!CUI.parseLocation(v)

	readOpts: ->
		super(@opts)
		@__markedRenderer = new marked.Renderer()
		@__markedRenderer.image = (href, title, text) =>
			@__renderNode.rendererImage(href, title, text)
		@__marked_opts = renderer: @__markedRenderer


	loadLocation: (nodePath) ->
		if not nodePath
			if not @__tree.root.children.length
				return

			return @loadLocation(@__tree.root.children[0].getNodePath())

		@__tree.root.selectLocation(nodePath)
		.done (node) =>
			node.select()
			@loadContent(node)
		.fail =>
			@loadEmpty()

	loadEmpty: ->
		@__layout.replace(new EmptyLabel(text: "No article available."), "center")


	loadContent: (node) ->
		node.loadContent()
		.done (content) =>
			@__renderNode = node
			@__layout.replace(CUI.DOM.htmlToNodes(marked(content, @__marked_opts)), "center")
		.fail =>
			@loadEmpty()

	getRootNode: ->
		@__tree.root

	render: ->
		@__tree = new ListViewTree
			cols: ["maximize"]
			selectable: true
			onSelect: (ev, info) =>
				@_gotoLocation(info.node.getNodePath())
			onDeselect: (ev, info) =>
				# console.error "deselect me!", info
			root: new CUI.DocumentBrowserRootNode(url: @_url)

		@__layout = new HorizontalLayout
			maximize: true
			left:
				content: @__tree.render(false)
				flexHandle:
					hidden: false
			center:
				content: $text(@_url)

		@__layout


	load: ->
		@__tree.root.open()


