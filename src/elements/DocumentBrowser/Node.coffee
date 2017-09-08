###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

#
class CUI.DocumentBrowser.Node extends CUI.ListViewTreeNode
	readOpts: ->
		super()

		@__url = @_url

		if @__url.endsWith("/")
			@__url = @__url.substr(0, @__url.length-1)

		# console.debug @__url, @_path

	initOpts: ->
		super()
		@addOpts
			browser:
				mandatory: true
				check: CUI.DocumentBrowser
			url:
				check: (v) ->
					!!CUI.parseLocation(v)
			path:
				default: []
				check: Array
			title:
				check: String

	getChildren: ->
		if @opts.leaf
			return []

		if @children
			new CUI.resolvedPromise(@children)
		else
			@__loadChildren()

	__loadChildren: (dive = true) ->

		@loadContent()

		dive = true

		dfr = new CUI.Deferred()
		xhr = new CUI.XHR
			url: @__url + @getNodePath("menu.cms")
			responseType: "text"

		xhr.start()
		.done (data) =>
			if data.startsWith("<") # assume HTML, something isnt right
				@opts.leaf = true
				dfr.resolve([])
				return

			# console.debug @getNodePath()
			children = []
			items = []
			for row in data.split("\n")
				m = row.match(/^\s*(\S+?)(|=(\S+))\s*$/)
				if not m
					continue

				# console.debug "match:", CUI.util.dump(m)

				info = m[1].split(":")
				if m[3]
					title = m[3]
				else
					title = info[0]

				path = @_path.slice(0)
				path.push(info[0])

				items.push
					title: title
					path: path

			if items.length == 0
				@opts.leaf = true
				dfr.resolve([])
				return

			children_done = 0
			for item, idx in items
				child = new CUI.DocumentBrowser.Node
					browser: @_browser
					url: @__url
					title: item.title
					path: item.path

				children.push(child)
				if dive
					child.__loadChildren(false)
					.always =>
						children_done = children_done + 1
						if children_done == items.length
							@children = children
							dfr.resolve(children)
			if not dive
				dfr.resolve(children)
			return
		.fail =>
			@opts.leaf = true
			dfr.resolve([])
		dfr.promise()

	getMainArticleUrl: ->
		@__url + @getNodePath(@getLastPathElement()+".md")


	loadIncludes: (content, nodePath, includes=[]) ->

		dfr = new CUI.Deferred()

		new_includes = includes.slice(0)

		load_next_include = =>
			match = content.match(/@@include\(\s*(.*?)\s*\)/)
			# console.debug "loading next", content, match
			if not match
				dfr.resolve(content)
				return

			url = @absoluteUrl(nodePath, match[1])

			# console.info("Including:", url, "From:", nodePath)
			replace_in_content = (replace_content) =>
				arr = [
					content.substr(0, match.index)
					content.substr(match.index + match[0].length)
				]
				arr.splice(1, 0, replace_content)
				content = arr.join("")
				load_next_include()

			if url in includes
				replace_in_content("**(Recursion: "+match[1]+")**")
				# recursion protection, ignore this
			else
				new_includes.push(url)
				new CUI.XHR
					url: @__url + url
					responseType: "text"
				.start()
				.done (include_content) =>
					parts = url.split("/")
					parts.pop()
					@loadIncludes(include_content, parts.join("/"), new_includes)
					.done (_content) =>
						replace_in_content(_content)
				.fail =>
					replace_in_content("**(Error: "+match[1]+")**")
			return

		load_next_include()

		return dfr.promise()


	loadContent: ->
		if @__content
			new CUI.resolvedPromise(@__content, @__htmlNodes, @__texts)

		dfr = new CUI.Deferred()
		new CUI.XHR
			url: @getMainArticleUrl()
			responseType: "text"
		.start()
		.done (@__content) =>
			if @__content.startsWith("<")
				dfr.reject()
				return

			@loadIncludes(@__content, @getNodePath())
			.fail(dfr.reject)
			.done (content) =>
				@_browser.marked(@, content)
				.done (content) =>
					@__htmlNodes = CUI.dom.htmlToNodes(content)
					@__texts = CUI.dom.findTextInNodes(@__htmlNodes)
					@_browser.addWords(@__texts)
					# console.debug "loaded:", filename, markdown.length, @__texts.length
					dfr.resolve(@__content, @__htmlNodes, @__texts)
			.fail(dfr.reject)
		.fail(dfr.reject)
		dfr.promise()

	findContent: (searchQuery, matches = []) ->
		CUI.util.assert(searchQuery instanceof CUI.DocumentBrowser.SearchQuery, "DocumentBrowserNode.findContent", "searchQuery needs to be instance of CUI.DocumentBrowser.SearchQuery.", searchQuery: searchQuery)

		regExpe = searchQuery.getRegExps()

		idx_hits = [0..regExpe.length-1]

		remove_matched_part = (match) =>
			if idx_hits.length == 0
				return

			for _match in match.getMatches()
				CUI.util.removeFromArray(_match.regExp_idx, idx_hits)
				if idx_hits.length == 0
					return

		title_match = searchQuery.match(@_title)
		if title_match
			remove_matched_part(title_match)

		text_matches = []

		if @__texts
			for text, idx in @__texts
				text_match = searchQuery.match(text)
				if not text_match
					continue

				text_match.nodeIdx = idx
				text_matches.push(text_match)
				remove_matched_part(text_match)

		if idx_hits.length == 0
			# console.debug "findContent", title_match, text_matches
			matches.push(new CUI.DocumentBrowser.NodeMatch(
				node: @
				searchQuery: searchQuery
				title_match: title_match
				text_matches: text_matches
			))

			# console.debug "pusing:", matches.length, row_matches, title_match
			# console.debug @getNodePath()+" matches:", matches1, matches2

		if @children
			for c in @children
				c.findContent(searchQuery, matches)

		return matches

	getBrowser: ->
		@_browser

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

	getTitlePath: ->
		texts = []
		for node in @getPath(true)
			if node.isRoot()
				continue
			texts.push(node.getTitle())
		texts

	getTitle: ->
		@_title

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

	rendererLink: (href, title, text) ->
		title = href
		href = @_browser.renderHref(href, @getNodePath())
		"<a href='"+href+"' title='"+CUI.escapeAttribute(title)+"'>"+text+"</a>"

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
		"<img src='"+_href+"' alt='"+CUI.escapeAttribute(text)+"' title='"+CUI.escapeAttribute(title)+"'></img>"

	renderContent: ->
		new CUI.Label(text: @_title, multiline: true)


class CUI.DocumentBrowser.RootNode extends CUI.DocumentBrowser.Node
