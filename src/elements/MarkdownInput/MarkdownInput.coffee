###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

marked = require('marked')

class CUI.MarkdownInput extends CUI.Input
	initOpts: ->
		super()

		@removeOpt("textarea")
		@addOpts
			preview:
				check: Boolean

			preview_ms:
				default: 500
				check: (v) =>
					v >= 0

			renderFunction:
				mandatory: true
				default: (md) =>
					marked(md, CUI.defaults.marked_opts)
				check: Function


	readOpts: ->
		super()
		@_textarea = true
		@__preview = null

		@__updatePreview = =>
			@updatePreview()

		vl_opts =
			top: {}

		for k in [
			"maximize"
			"maximize_horizontal"
			"maximize_vertical"
		]
			if @hasSetOpt(k)
				vl_opts[k] = @getSetOpt(k)

		@__verticalLayout = new Pane(vl_opts)


	initTemplate: ->
		@registerTemplate(@__verticalLayout.getLayout())

	getTemplateKeyForRender: ->
		"center"

	# add char before and after the current
	# selection
	encloseSelection: (char) ->
		sel = @getSelection()
		len = char.length

		rows = sel.selected.split("\n")
		if rows.length > 1
			return

		if sel.selected.startsWith(char) and
			sel.selected.endsWith(char)
				@setValue(sel.before + sel.selected.substr(len, sel.selected.length-len*2) + sel.after)
				@setSelection(start: sel.start, end: sel.end-len*2)

		else
			@setValue(sel.before + char + sel.selected + char + sel.after)
			@setSelection(start: sel.start, end: sel.end+len*2)

	makeOrderedList: ->
		@__makeList(false)

	makeUnorderedList: ->
		@__makeList(true)

	# for the current list status, returns
	# "unordered", "ordered", "nolist" or null, if no
	# list is selected
	checkList:  ->
		type = @__makeList(null, true)
		console.debug "selection is type", type

	__makeList: (ul=true, check_only=false) ->
		sel = @getSelection()
		rows = sel.selected.split("\n")

		if sel.before != "" and not sel.before.endsWith("\n")
			return null

		space = null

		if check_only
			is_ul = undefined
		else if ul
			prefix = "- "
		else
			prefix = "1. "

		new_rows = []
		for row in rows
			console.debug "row:", row
			if row.trim().length == 0
				new_rows.push(row)
				continue

			match = row.match(/^(\s*)([0-9]+\.|\*|\-|)(\s*)(.*)$/)
			console.debug "match", row, match

			if not match
				console.warn("No match, not making list.", row)
				return null

			if space == null
				space = match[1]
				item = match[2]

				if item != ""
					is_ul = isNaN(parseInt(item))
				else
					is_ul = null

				if is_ul != null and not CUI.util.xor(is_ul, ul) # unsorted list
					prefix = ""

				console.debug "rowcriteria.", space.length, item

			else if match[1] != space
				new_rows.push(row.substring(match[1].length-space.length))
				console.debug "row not matching space criteria."
				continue

			if not check_only
				new_rows.push(space+prefix+match[4])

		if check_only
			if is_ul == null
				return "nolist"
			else if is_ul == true
				return "ul"
			else if is_ul == false
				return "ol"
			else
				# happens if we have only empty lines
				return null

		@updateSelection(new_rows.join("\n"))


	handleSelectionChange: (ev) ->
		super(ev)
		sel = @getSelection()
		console.debug "md selection change", ev, CUI.util.dump(sel)
		@checkList()


	render: ->
		super()
		bb = new Toolbar
			left:
				content: [
					group: "lists"
					icon: "fa-list-ul"
					onClick: =>
						@makeUnorderedList()
				,
					group: "lists"
					icon: "fa-list-ol"
					onClick: =>
						@makeOrderedList()
				,
					text: "*"
					onClick: =>
						@encloseSelection("*")
				,
					text: "**"
					onClick: =>
						@encloseSelection("**")
				,
					text: "SC"
					onClick: =>
						@handleSelectionChange()
				]

		@__verticalLayout.append(bb, "top")
		@

	storeValue: (value, flags={}) ->
		ret = super(value, flags)
		if not @__preview
			return ret

		if @_preview_ms == 0
			@updatePreview()
		else
			CUI.scheduleCallback
				ms: @_preview_ms
				call: @__updatePreview
		ret

	getPreview: ->
		if not @__preview
			@__preview = DOM.element("div", class: "cui-markdown-input-preview")
			@updatePreview()
		@__preview

	updatePreview: ->
		@__preview.innerHTML = @renderHTML()

	renderHTML: ->
		@_renderFunction(@getElement().value)

	@__escape_regexp: new RegExp('[\\'+('*-_\\![]()'.split("").join("\\"))+']','g')

	@escape: (obj) ->
		CUI.util.assert(typeof(obj) in ["string", "object"], "MarkdownInput.escape", "Object needs to be typof 'string' or 'object'.", obj: obj)
		if typeof(obj) == "string"
			return obj.replace(@__escape_regexp, "\\$&")

		new_obj = {}
		for k, v of obj
			new_obj[k] = @escape(v)
		return new_obj
