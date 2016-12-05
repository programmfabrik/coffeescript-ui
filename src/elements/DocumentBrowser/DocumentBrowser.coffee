###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DocumentBrowser extends CUI.Element

	initOpts: ->
		super()
		@addOpts
			gotoLocation:
				check: Function
				default: (nodePath, search, nodeIdx) =>
					@loadLocation(nodePath, search, nodeIdx)
			marked_opts:
				default: {}
				mandatory: true
				check: (v) ->
					if not CUI.isPlainObject(v)
						return false
					for _k, _v of v
						if _k in ["image", "link"]
							return false
					true
			getMarkdown:
				default: (v) -> v
				check: Function
			renderHref:
				check: Function
				default: (href, nodePath) =>
					href
			url:
				check: (v) ->
					!!CUI.parseLocation(v)

	readOpts: ->
		super(@opts)

		@__marked_opts = copyObject(@_marked_opts)

		if not @__marked_opts.renderer
			@__marked_opts.renderer = new marked.Renderer()
		renderer = @__marked_opts.renderer

		for k, v of {
			sanitize: false
		}
			if not @__marked_opts.hasOwnProperty(k)
				@__marked_opts[k] = v

		renderer.image = (href, title, text) =>
			@__node.rendererImage(href, title, text)

		renderer.link = (href, title, text) =>
			@__node.rendererLink(href, title, text)

		@__words = {}

	renderHref: (href, nodePath) ->
		@_renderHref(href, nodePath)

	marked: (@__node, markdown) ->
		dfr = new CUI.Deferred()
		mark = (markdown) =>
			dfr.resolve(marked(markdown, @__marked_opts))
		ret = @_getMarkdown(markdown)
		if isPromise(ret)
			ret
			.done (markdown) =>
				mark(markdown)
			.fail(dfr.reject)
		else
			mark(ret)
		dfr.promise()

	loadLocation: (nodePath, search, _nodeIdx) ->
		# console.error "loading:", _nodePath

		if not nodePath
			if not @__tree.root.children.length
				return

			return @loadLocation(@__tree.root.children[0].getNodePath())

		@__tree.root.selectLocation(nodePath)
		.done (node) =>
			nodeIdx = parseInt(_nodeIdx)
			if not node.isSelected()
				node.select(search: search, nodeIdx: nodeIdx)
			@loadContent(node, search, nodeIdx)
		.fail =>
			@loadEmpty()

	loadEmpty: ->
		@__layout.replace(new EmptyLabel(text: "No article available."), "center")

	loadContent: (node, search, nodeIdx) ->
		node.loadContent()
		.done (content, htmlNodes, texts) =>
			if not search
				@__layout.replace(htmlNodes, "center")
				return

			scroll_node = null
			searchQuery = new CUI.DocumentBrowser.SearchQuery(search: search)
			nodes = CUI.DOM.htmlToNodes(@marked(node, content))

			text_matches = []
			text_node_idx = 0

			CUI.DOM.findTextInNodes(nodes, (node, textContent) =>

				text_node_idx = text_node_idx + 1
				text_match = searchQuery.match(textContent)

				if not text_match
					return

				console.debug "matches", searchQuery, textContent

				text_match.__mark_all = (nodeIdx == text_node_idx - 1)
				text_match.__node = node
				text_matches.push(text_match)
			)

			console.debug "text matches", text_matches

			for tm in text_matches

				html = tm.getHighlighted()
				if tm.__mark_all
					html = "<span class='cui-document-browser-marked-node'>" + html + "</span>"

				_node = CUI.DOM.replaceWith(tm.__node, CUI.DOM.htmlToNodes(html))
				if tm.__mark_all
					scroll_node = _node

				# console.debug(child, child.textContent, child.textContent.length)

			@__layout.replace(nodes, "center")
			@__layout.prepend(node.getMainArticleUrl(), "center")

			if scroll_node
				CUI.DOM.scrollIntoView(scroll_node)
			else
				@__layout.center().scrollTop = 0

		.fail =>
			@loadEmpty()

	getRootNode: ->
		@__tree.root

	__doSearch: (search) ->
		@__searchResult.empty("center")

		if search.trim().length > 2
			matches = @__tree.root.findContent(new CUI.DocumentBrowser.SearchQuery(search: search))
			# console.debug "found:", matches
			for match in matches
				@__searchResult.append(match.render(), "center")

			if matches.length == 0
				@__searchResult.append(
					new Label(markdown: true, text: "Nothing found for **"+search+"**.", multiline: true),
				"center")
			@showSearch(true)
		else
			matches = []
			@showSearch(false)

	addWords: (texts) ->
		return

		for text in texts
			for _word in text.split(/(\s+)/)
				word = _word.replace(/[\^\$\"\.,\-\(\)\s\t]/g,"")
				if word.length == 0
					continue

				if not @__words.hasOwnProperty(word)
					@__words[word] = 1
				else
					@__words[word] += 1
		@

	showSearch: (on_off) ->

		# console.debug "showSearch", on_off
		if on_off
			@__resetBtn.show()
			@__searchBtn.hide()
			CUI.DOM.remove(@__tree.DOM)
			@__leftLayout.replace(@__searchResult, "content")
		else
			@__resetBtn.hide()
			@__searchBtn.show()
			CUI.DOM.remove(@__searchResult.DOM)
			@__leftLayout.replace(@__tree.DOM, "content")

	render: ->

		data = search: ""

		do_search = =>
			@__doSearch(data.search)

		search_input = new Input
			data: data
			name: "search"
			onDataChanged: =>
				CUI.scheduleCallback(ms: 200, call: do_search)

		@__searchResult = new VerticalList()

		@__tree = new ListViewTree
			cols: ["maximize"]
			selectable: true
			onSelect: (ev, info) =>
				if ev?.search
					@_gotoLocation(info.node.getNodePath(), ev.search, ev.nodeIdx)
				else
					@_gotoLocation(info.node.getNodePath())

			onDeselect: (ev, info) =>
				# console.error "deselect me!", info
			root: new CUI.DocumentBrowser.RootNode(browser: @, url: @_url)

		@__leftLayout = new SimplePane
			header_center: search_input.start()
			header_right: [
				@__searchBtn = new Button
					icon: "search"
					onClick: =>
						@showSearch(true)
			,
				@__resetBtn = new Button
					icon: "remove"
					hidden: true
					onClick: =>
						@showSearch(false)
			]
			content: @__tree.render(false)


		@__layout = new HorizontalLayout
			class: "cui-document-browser"
			maximize: true
			left:
				class: "cui-document-browser-list"
				content: @__leftLayout
				flexHandle:
					hidden: false
			center:
				class: "cui-document-browser-center"
				content: $text(@_url)

		@__layout


	load: ->
		@__tree.root.open()
		.done =>
			@__all_words = []
			for word, count of @__words
				@__all_words.push
					word: word
					count: count
					sorted: word.toLocaleLowerCase().split("").sort((a,b) -> compareIndex(a, b)).join("")
			@__all_words.sort (a, b) =>
				b.count - a.count
			console.debug "words", @__words, @__all_words

