###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./ScrollIntoViewDemo.html'));

class Demo.ScrollIntoViewDemo extends Demo
	getGroup: ->
		"Demo"

	display: ->

		@__tmpl = new CUI.Template
			name: "scroll-demo"
			map:
				buttons: true

		bb = new CUI.Buttonbar()

		for el in CUI.dom.matchSelector(@__tmpl.DOM, ".scroll-item")
			do (el) =>
				btn = new CUI.Button
					text: el.textContent
					onClick: (ev) =>
						if ev.hasModifierKey()
							el.scrollIntoView()
						else
							CUI.dom.scrollIntoView(el)
						@saveScrollState()

				bb.addButton(btn)

		for el in CUI.dom.matchSelector(@__tmpl.DOM, "*")

			CUI.Events.listen
				type: "scroll"
				node: el
				call: =>
					@saveScrollState()


		@__tmpl.append(bb, "buttons")
		@__tmpl.append(new CUI.EmptyLabel(text: "Use CTRL to use native .scrollIntoView().", "buttons"))

		bb.addButton new CUI.Button
			text: "Reset All"
			onClick: =>
				for el in CUI.dom.matchSelector(@__tmpl.DOM, "*")
					el.scrollLeft = 0
					el.scrollTop = 0
				@saveScrollState()

		CUI.Events.listen
			type: "hashchange"
			node: window
			instance: @
			call: =>
				@loadScrollState()

		CUI.dom.waitForDOMInsert
			node: @__tmpl
		.done =>
			@loadScrollState()

		@__tmpl.DOM

	loadScrollState: ->
		els = CUI.dom.matchSelector(@__tmpl.DOM, "*")
		positioned = []
		scrollinfos = document.location.hash.split("#")[2]?.split(" ")

		if scrollinfos
			for scrollinfo in scrollinfos
				match = scrollinfo.match(/^([0-9]+):([0-9]+)x([0-9]+)$/)
				if not match
					continue

				idx = parseInt(match[1])
				left = parseInt(match[2])
				top = parseInt(match[3])

				els[idx].scrollLeft = left
				els[idx].scrollTop = top

				positioned.push(idx)

		for el, idx in els
			if idx not in positioned
				el.scrollLeft = 0
				el.scrollTop = 0

		return

	saveScrollState: ->
		scrollinfo = []
		for el, idx in CUI.dom.matchSelector(@__tmpl.DOM, "*")
			if el.scrollLeft > 0 or el.scrollTop > 0
				scrollinfo.push(idx+":"+el.scrollLeft+"x"+el.scrollTop)

		if scrollinfo.length > 0
			document.location.hash = "#ScrollIntoView#"+scrollinfo.join(" ")
		else
			document.location.hash = "#ScrollIntoView"


	undisplay: ->
		super()
		CUI.Events.ignore(instance: @)

Demo.register(new Demo.ScrollIntoViewDemo())