###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DocumentBrowser.SearchQuery extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			search:
				mandatory: true
				check: String

	readOpts: ->
		super()
		@__regExpe = []
		for str in @_search.trim().split(/\s+/)
			if str.trim() == ""
				continue
			@__regExpe.push(new RegExp(RegExp.escape(str), "ig"))
		return

	getRegExps: ->
		@__regExpe

	getSearch: ->
		@_search

	match: (str, strip) ->
		search_match = null
		if CUI.util.isEmpty(str)
			return search_match

		for regExp, idx in @__regExpe
			matches = []
			while ((match = regExp.exec(str)) != null)
				matches.push(match)

			if matches.length > 0
				if not search_match
					search_match = new CUI.DocumentBrowser.SearchMatch
						searchQuery: @
						string: str

				for match in matches
					match.regExp_idx = idx
					search_match.addMatch(match)

		search_match

