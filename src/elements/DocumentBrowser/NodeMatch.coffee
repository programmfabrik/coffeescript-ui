###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DocumentBrowser.NodeMatch extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			title_match:
				check: CUI.DocumentBrowser.SearchMatch
			text_matches:
				check: (v) ->
					for item in v
						if item not instanceof CUI.DocumentBrowser.SearchMatch
							return false
					true
			searchQuery:
				check: CUI.DocumentBrowser.SearchQuery
			node:
				check: CUI.DocumentBrowser.Node

	marked: (markdown) ->
		@_node.getBrowser().marked(@_node, markdown)

	render: ->
		titlePath =[]
		for part in @_node.getTitlePath()
			titlePath.push(toHtml(part))

		if @_title_match
			# replace last item
			titlePath[titlePath.length-1] = @_title_match.getHighlighted()
		# console.debug titlePath

		lbl = new Label
			class: "cui-document-browser-search-match--title"
			multiline: true
			content: CUI.DOM.htmlToNodes(titlePath.join("<span class='cui-document-browser-node-match-hierarchy'>"+new Icon(icon: "right").DOM.outerHTML+"</span>"))

		CUI.DOM.setAttribute(lbl.DOM, "tabindex", 0)

		Events.listen
			type: "focus"
			node: lbl
			call: (ev) =>
				@_node.select(search: @_searchQuery.getSearch())
				return

		arr = [ lbl ]

		if @_text_matches
			ul = CUI.DOM.element("UL")
			arr.push(ul)
			for text_match in @_text_matches
				html = text_match.getHighlighted(true)
				li = CUI.DOM.element("LI", title: text_match.getString(), tabindex: 0)
				do (text_match) =>
					Events.listen
						type: "focus"
						node: li
						call: (ev) =>
							@_node.select(search: @_searchQuery.getSearch(), nodeIdx: text_match.nodeIdx)
							return
				CUI.DOM.append(li, CUI.DOM.htmlToNodes(html))
				ul.appendChild(li)
		arr
