class CUI.DocumentBrowser.SearchMatch extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			title_match:
				check: "PlainObject"
			text_matches:
				check: "Array"
			search:
				check: String
			node:
				check: CUI.DocumentBrowser.Node

	marked: (markdown) ->
		@_node.getBrowser().marked(@_node, markdown)

	render: ->
		titlePath = @_node.getTitlePath()

		if @_title_match
			console.debug dump(@_title_match)
			# replace last item
			titlePath[titlePath.length-1] = @markMatch(@_title_match.str, @_title_match.matches)

		lbl = new Label
			class: "cui-document-browser-search-match--title"
			multiline: true
			markdown: true
			text: titlePath.join(" > ")

		Events.listen
			type: "click"
			node: lbl
			call: (ev) =>
				@_node.select(search: @_search)
				return

		arr = [ lbl ]

		if @_text_matches
			ul = CUI.DOM.element("UL")
			arr.push(ul)
			for text_match in @_text_matches
				txt = @markMatch(text_match.match.str, text_match.match.matches)
				li = CUI.DOM.element("LI", title: txt)
				CUI.DOM.append(li, CUI.DOM.htmlToNodes(@marked(txt)))
				ul.appendChild(li)
		arr

	markMatch: (str, matches) ->
		shrink = (text) =>
			parts = text.split(/\s+/)
			if parts.length > 6
				parts.splice(3, parts.length-6, "...")
			parts.join(" ")

		console.debug "markMatch", str, matches

		mark_begin = "Qq"
		mark_end = "qQ"

		splits = []
		idx = 0
		for match in matches
			if idx < match.index
				splits.push(shrink(str.slice(idx, match.index)))
			splits.push(mark_begin)
			splits.push(str.slice(match.index, match.index+match[0].length))
			splits.push(mark_end)
			idx = match.index + match[0].length
		if idx < str.length
			splits.push(shrink(str.slice(idx)))

		# console.debug str, matches, splits
		splits.join("")


