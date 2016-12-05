###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DocumentBrowser.SearchMatch extends CUI.Element
	initOpts: ->
		super()
		@addOpts
			searchQuery:
				mandatory: true
				check: CUI.DocumentBrowser.SearchQuery
			string:
				mandator: true
				check: String

	readOpts: ->
		super()
		@__matches = []

	addMatch: (match) ->
		@__matches.push(match)

	getMatches: ->
		@__matches

	getString: ->
		@_string

	getHighlighted: (shrink_long = false) ->
		# marks n matches with spans in
		# str

		str = @_string

		char_id = (char) =>
			if char == undefined
				null
			else
				char.join(".")

		shrink = (text) =>
			parts = text.split(/\s+/)
			if parts.length > 6
				parts.splice(3, parts.length-6, "...")
			parts.join(" ")


		chars = []
		chars.length = str.length
		for m, m_idx in @__matches
			# console.debug "index", m.index, "len", m.length
			for idx in [m.index...m.index+m[0].length]
				if not chars[idx]
					chars[idx] = []
				chars[idx].push(m.regExp_idx)

		# console.debug "mark arr", dump(mark_arr)
		splits = []

		idx = 0
		while (idx < chars.length)
			char_id_prev = char_id(chars[idx-1])
			char_id_curr = char_id(chars[idx])

			if char_id_prev and char_id_curr != char_id_prev
				splits.push("</span>")
			if char_id_curr and char_id_curr != char_id_prev
				splits.push("<span class=\"cui-document-browser-search-match-mark cui-search-match--"+chars[idx].join(" cui-search-match--")+"\">")
			# eat all texts without marker
			txt_chars = []
			while true
				txt_chars.push(str[idx])
				idx = idx + 1
				if idx == chars.length or
					chars[idx] or
					char_id_curr
						break
			splits.push(toHtml(shrink(txt_chars.join(""))))

		if char_id_curr
			splits.push("</span>")

		# console.debug "markMatch", str, splits.join(""), matches
		splits.join("")



