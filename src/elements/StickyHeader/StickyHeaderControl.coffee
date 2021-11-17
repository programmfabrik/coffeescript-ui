###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.StickyHeaderControl extends CUI.Element
	constructor: (opts) ->
		super(opts)

		# destroy old instances, in case we are re-initialized
		# on an .empty()ied element
		CUI.dom.data(@_element, "stickyHeaderControl")?.destroy()

		CUI.dom.data(@_element, "stickyHeaderControl", @)

		@__control = CUI.dom.div("cui-sticky-header-control")

		CUI.Events.listen
			instance: @
			type: "viewport-resize"
			node: @_element
			call: =>
				@__positionControl()

		@__positionControl()

		CUI.dom.append(@_element, @__control)

		@headers = []
		@newStickyHeaders = []
		@__hiddenHeaders = []
		@__positioned = false

		CUI.Events.listen
			node: @_element
			type: "scroll"
			instance: @
			call: (ev) =>
				# console.time "scroll"
				@position()
				# console.timeEnd "scroll"
				return

	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					CUI.util.isElement(v)

	__positionControl: ->
		dim = CUI.dom.getDimensions(@_element)
		CUI.dom.setStyle @__control,
			left: dim.clientBoundingRect.left
			top: dim.clientBoundingRect.top

		CUI.dom.setDimension(@__control, "marginBoxWidth", dim.clientWidth)
		# console.error "__positionControl", @_element, @__control
		return

	isInDOM: ->
		@__control and CUI.dom.isInDOM(@__control)

	addStickyHeader: (stickyHeader) ->
		CUI.util.assert(not @__positioned or CUI.dom.isInDOM(@__control), "#{@__cls}.addStickyHeader", "StickyHeaderControl is not in DOM tree anymore. Cannot add a new CUI.StickyHeader.")

		CUI.util.assert(stickyHeader instanceof CUI.StickyHeader, "#{@__cls}.addStickyHeader", "Needs to be instance of StickyHeader but is #{CUI.util.getObjectClass(stickyHeader)}", stickyHeader: stickyHeader)
		@newStickyHeaders.push(stickyHeader)

	initNewStickyHeaders: ->
		measure_headers = []
		for newStickyHeader in @newStickyHeaders
			dom = newStickyHeader.DOM

			header =
				stickyHeader: newStickyHeader
				level: newStickyHeader.getLevel()
				nodeToMeasure: dom.cloneNode(true)
				node: dom

			@headers.push(header)

			measure_headers.push(header)
			header.nodeToMeasure.style.visiblity = "hidden"
			CUI.dom.prepend(@__control, header.nodeToMeasure)

		@newStickyHeaders.splice(0)

		for header in measure_headers
			header.dimInControl = CUI.dom.getDimensions(header.nodeToMeasure)
			@__control.removeChild(header.nodeToMeasure)
			header.nodeToMeasure.style.visiblity = ""
			delete header.nodeToMeasure
		@

	destroy: ->
		# console.warn "destroying sticky header control"
		CUI.dom.removeData(@_element, "stickyHeaderControl")
		CUI.Events.ignore
			instance: @

		CUI.dom.remove(@__control)
		@__headers = null
		@newStickyHeaders = null

	position: ->
		if not @isInDOM()
			return

		@__positioned = true
		@initNewStickyHeaders()

		scrollTop = @_element.scrollTop
		slots = []
		extraTop = 0
		for header, idx in @headers
			extraTop = 0
			for i in [0...header.level] by 1
				slot = slots[i]
				if slot == null
					break
				extraTop += slots[i].dimInControl.marginBoxHeight

			if header.stickyHeader.DOM.offsetTop < scrollTop + extraTop + header.dimInControl.marginTop
				slots[header.level] = header
				for i in [header.level+1...slots.length] by 1
					slots[i] = null
			else
				next_header = header
				top_space = 0
				for slot in slots
					if slot == null
						break
					top_space += slot.dimInControl.marginBoxHeight
				break

		if next_header
			cut = next_header.stickyHeader.DOM.offsetTop - scrollTop - top_space
			cut = cut - next_header.dimInControl.marginTop
			# console.debug cut, next_header.stickyHeader.DOM[0], next_header.stickyHeader.DOM[0].offsetTop, scrollTop, top_space
		else
			cut = 0

		for hiddenHeader in @__hiddenHeaders
			hiddenHeader.style.visibility = ""

		@__hiddenHeaders.splice(0)

		CUI.dom.empty(@__control)

		top = 0
		for slot, idx in slots
			if slot == null
				break

			nodeCloned = slot.node.cloneNode(true)
			CUI.dom.prepend(@__control, nodeCloned)

			if cut < 0 and slot.level == next_header.level
				top += cut

			hideHeader = slot.stickyHeader.DOM
			hideHeader.style.visibility = "hidden"

			@__hiddenHeaders.push(hideHeader)

			nodeCloned.style.top = "#{top}px"
			dimInControl = CUI.dom.getDimensions(nodeCloned)
			top += dimInControl.marginBoxHeight

		CUI.dom.setStyle(@__control,
			height: top
		)

		@
