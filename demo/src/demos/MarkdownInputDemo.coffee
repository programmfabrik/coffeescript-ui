###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.MarkdownInputDemo extends Demo
	getGroup: ->
		"Extra"

	display: ->
		data = {}

		md_input = new CUI.MarkdownInput
			data: data
			class: "cui-markdown-input-demo-md-input"
			name: "md"

		md_input.start()
		md_output = md_input.getPreview()


		hl = new CUI.HorizontalLayout
			maximize: true
			class: "cui-markdown-input-demo"
			left:
				flexHandle:
					closed: false
				content: md_input
			center:
				content: md_output

		load_from_hash = ->
			_val = document.location.hash.split("#")[2]?.trim() or ""
			val = decodeURIComponent(_val)
			console.debug "load from hash", _val, val, data.md
			if val != data.md
				md_input.setValue(val)

		update_hash = =>
			document.location.hash = "#MarkdownInput#"+encodeURIComponent(data.md)

		@__interval = window.setInterval(update_hash, 1000)

		CUI.Events.listen
			type: "hashchange"
			node: window
			instance: @
			call: (ev) =>
				load_from_hash()

		load_from_hash()
		hl


	undisplay: ->
		window.clearInterval(@__interval)
		CUI.Events.ignore(instance: @)




Demo.register(new Demo.MarkdownInputDemo())