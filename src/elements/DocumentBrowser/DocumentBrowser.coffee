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
			@__node.rendererImage(href, title, text)
		@__marked_opts = renderer: @__markedRenderer
		@__words = {}

	marked: (@__node, markdown) ->
		marked(markdown, @__marked_opts)

	loadLocation: (_nodePath) ->
		# console.error "loading:", _nodePath

		if not _nodePath
			if not @__tree.root.children.length
				return

			return @loadLocation(@__tree.root.children[0].getNodePath())

		# might contain ; as select word
		if _nodePath.indexOf(";") > -1
			parts = _nodePath.split(";")
			nodePath = parts[0]
			search = parts[1]
		else
			nodePath = _nodePath
			search = null

		@__tree.root.selectLocation(nodePath)
		.done (node) =>
			if not node.isSelected()
				node.select(search: search)
			@loadContent(node, search)
		.fail =>
			@loadEmpty()

	loadEmpty: ->
		@__layout.replace(new EmptyLabel(text: "No article available."), "center")

	getMatches: (regExpe, str) ->
		matches = null
		if isEmpty(str)
			return matches

		for regExp, idx in regExpe
			_matches = []
			while ((match = regExp.exec(str)) != null)
				_matches.push(match)

			if _matches.length > 0
				if not matches
					matches =
						str: str
						regExpe: regExpe
						matches: []

				for _match in _matches
					_match.regExp_idx = idx
					matches.matches.push(_match)

		matches

	loadContent: (node, search) ->
		node.loadContent()
		.done (content, htmlNodes) =>
			# console.debug "loadContent", content, htmlNodes, node, search
			if not search
				@__layout.replace(htmlNodes, "center")
			else
				@__layout.replace(CUI.DOM.htmlToNodes(@marked(node, "# "+search+"\n\n"+content)), "center")

		.fail =>
			@loadEmpty()

	getRootNode: ->
		@__tree.root

	__doSearch: (search) ->
		@__searchResult.empty("center")

		if search.trim().length > 2
			# charRegExp = search.trim().split("").join(".*?")
			# chary = new RegExp(charRegExp)
			# matching_words = []
			# for word in @__all_words
			# 	if chary.exec(word.word)
			# 		matching_words.push(word)

			# matching_words.sort (a, b) =>
			# 	b.count - a.count

			# words = []
			# for word in matching_words
			# 	words.push(RegExp.escape(word.word))

			# _search = "(?:"+words.join("|")+")"
			# console.debug "matching words:", charRegExp,  _search

			regExpe = []
			for str in search.trim().split(/\s+/)
				if str.trim() == ""
					continue
				regExpe.push(new RegExp(RegExp.escape(str), "ig"))

			matches = @__tree.root.findContent(regExpe, search.trim())
			console.debug "found:", matches
			for match in matches
				@__searchResult.append(match.render(), "center")
		else
			matches = []

		@showSearch(matches.length > 0)

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

		search_input = new Input
			data: data
			name: "search"
			onDataChanged: =>
				@__doSearch(data.search)

		@__searchResult = new VerticalList()

		@__tree = new ListViewTree
			cols: ["maximize"]
			selectable: true
			onSelect: (ev, info) =>
				if ev?.search
					@_gotoLocation(info.node.getNodePath()+";"+ev.search)
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

