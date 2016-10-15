class ScrollIntoViewDemo extends Demo
	getGroup: ->
		"Demo"

	display: ->

		@__tmpl = new Template
			name: "scroll-demo"
			map:
				buttons: true

		bb = new Buttonbar()

		for el in DOM.matchSelector(@__tmpl.DOM, ".scroll-item")
			do (el) =>
				btn = new Button
					text: el.textContent
					onClick: (ev) =>
						if ev.hasModifierKey()
							el.scrollIntoView()
						else
							DOM.scrollIntoView(el)
						@saveScrollState()

				bb.addButton(btn)

		for el in DOM.matchSelector(@__tmpl.DOM, "*")

			Events.listen
				type: "scroll"
				node: el
				call: =>
					@saveScrollState()


		@__tmpl.append(bb, "buttons")
		@__tmpl.append(new EmptyLabel(text: "Use CTRL to use native .scrollIntoView().", "buttons"))

		bb.addButton new Button
			text: "Reset All"
			onClick: =>
				for el in DOM.matchSelector(@__tmpl.DOM, "*")
					el.scrollLeft = 0
					el.scrollTop = 0
				@saveScrollState()

		Events.listen
			type: "hashchange"
			node: window
			instance: @
			call: =>
				@loadScrollState()

		DOM.waitForDOMInsert
			node: @__tmpl
		.done =>
			@loadScrollState()

		@__tmpl.DOM

	loadScrollState: ->
		els = DOM.matchSelector(@__tmpl.DOM, "*")
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
		for el, idx in DOM.matchSelector(@__tmpl.DOM, "*")
			if el.scrollLeft > 0 or el.scrollTop > 0
				scrollinfo.push(idx+":"+el.scrollLeft+"x"+el.scrollTop)

		if scrollinfo.length > 0
			document.location.hash = "#ScrollIntoView#"+scrollinfo.join(" ")
		else
			document.location.hash = "#ScrollIntoView"


	undisplay: ->
		super()
		Events.ignore(instance: @)

Demo.register(new ScrollIntoViewDemo())