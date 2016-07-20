class StickyHeaderControl extends Element
	constructor: (@opts={}) ->
		super(@opts)

		# destroy old instances, in case we are re-initialized
		# on an .empty()ied element
		DOM.data(@_element[0], "stickyHeaderControl")?.destroy()

		DOM.data(@_element[0], "stickyHeaderControl", @)

		if @_element.css("position") not in ["absolute", "fixed", "relative"]
			@_element.css("position", "relative")

		@__control = $div("ez-sticky-header-control")
		@_element.append(@__control)

		@headers = []
		@newStickyHeaders = []

		Events.listen
			node: @_element
			type: "scroll"
			instance: @
			call: (ev) =>
				# console.time "scroll"
				@__scrolled = true
				@initNewStickyHeaders()
				@position()
				# console.timeEnd "scroll"
				return


	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					v instanceof jQuery and v.length == 1

	isInDOM: ->
		@__control and $elementIsInDOM(@__control)

	addStickyHeader: (stickyHeader) ->
		assert(not @__scrolled or $elementIsInDOM(@__control), "#{@__cls}.addStickyHeader", "StickyHeaderControl is not in DOM tree anymore. Cannot add a new StickyHeader.")


		assert(stickyHeader instanceof StickyHeader, "#{@__cls}.addStickyHeader", "Needs to be instance of StickyHeader but is #{getObjectClass(stickyHeader)}", stickyHeader: stickyHeader)
		@newStickyHeaders.push(stickyHeader)

	initNewStickyHeaders: ->
		for nsh in @newStickyHeaders
			dom = nsh.DOM
			assert dom[0].offsetParent == @_element[0], "StickyHeaderControl.addStickyHeader", "StickyHeader has a different node as offsetParent than expected.", stickyHeader: dom[0], control: @_element[0], offsetParent: dom[0].offsetParent
			rect = dom.rect()

			header =
				stickyHeader: nsh
				height: rect.height # + dom.cssFloat("marginTop") + dom.cssFloat("marginBottom")
				level: nsh.getLevel()
				offsetTop: dom[0].offsetTop
				node: dom[0].cloneNode(true)

			@headers.push(header)
		@newStickyHeaders.splice(0)
		@

	destroy: ->
		# CUI.warn "destroying sticky header control"
		DOM.removeData(@_element[0], "stickyHeaderControl")
		Events.ignore
			instance: @

		@__control.remove()
		@__headers = null
		@newStickyHeaders = null


	position: ->
		scrollTop = @_element[0].scrollTop
		slots = []
		extraTop = 0
		for header, idx in @headers
			extraTop = 0
			for i in [0...header.level] by 1
				slot = slots[i]
				if slot == null
					break
				extraTop += slots[i].height
			if header.offsetTop < scrollTop+extraTop
				slots[header.level] = header
				for i in [header.level+1...slots.length] by 1
					slots[i] = null
			else
				next_header = header
				top_space = 0
				for slot in slots
					if slot == null
						break
					top_space += slot.height
				break

		if next_header
			cut = next_header.offsetTop - scrollTop - top_space
		else
			cut = 0

		@__control.empty()
		top = 0
		for slot in slots
			if slot == null
				break
			if cut < 0 and slot.level == next_header.level
				top += cut
			@__control.append(slot.node)
			slot.node.style.top = top+"px"
			top += slot.height

		@__control.css
			top: scrollTop
			height: top

