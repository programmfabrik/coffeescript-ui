###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Lasso extends CUI.Draggable
	@cls = "lasso"

	initOpts: ->
		super()
		@addOpts
			filter:
				check: String

			selected:
				default: (ev, info) ->
					alert("You lassoed #{info.elements.length} elements.")
				check: Function

			# only lasso rectangle cuts with this
			lasso_filter:
				check: String

			lassoed_element_class:
				default: "cui-selected"
				check: String

		@removeOpt("helper")

	readOpts: ->
		super()
		@_helper = null

	init: ->
		super()
		# @makeElementRelative @element
		CUI.dom.addClass(@element, "cui-lasso-area")
		# assert @element.css("position") in ["relative","absolute","fixed"], "Lasso.init", "Element needs to be positioned (relative, absolute, fixed)", element: @element
		@position = null

	start_drag: (ev, $target, diff) ->
		if not CUI.dom.isInDOM(@element)
			throw("DragDropSelect: Creating lasso failed, element is not in DOM.")

		CUI.globalDrag.lasso = CUI.dom.div("cui-lasso")
		# console.debug "create lasso", @_lassoClass
		#
		CUI.dom.append(@element, CUI.globalDrag.lasso)
		CUI.globalDrag.elements = []

	getCursor: ->
		"default"

	do_drag: (ev, $target, diff) ->
		# console.debug "Lasso do drag", CUI.globalDrag.start, CUI.globalDrag.$source[0] == @element[0], diff, @scroll?.top, @element[0].scrollTop
		left = 0
		top = 0
		width = 0
		height = 0
		if diff.x <= 0
			left = CUI.globalDrag.start.left + diff.x
			width = -diff.x
			over = -left
			if over > 0
				width -= over
				left = 0
		else
			left = CUI.globalDrag.start.left
			width = diff.x
			over = left + width - @element.scrollWidth
			if over > 0
				width -= over

		if diff.y <= 0
			top = CUI.globalDrag.start.top + diff.y
			height = -diff.y
			over = -top
			if over > 0
				height -= over
				top = 0
		else
			top = CUI.globalDrag.start.top
			height = diff.y
			over = top + height - @element.scrollHeight
			if over > 0
				height -= over

		lassoed_elements = @get_lassoed_elements()

		for el in lassoed_elements
			if el not in CUI.globalDrag.elements
				CUI.globalDrag.elements.push(el)
				CUI.dom.toggleClass(el, @_lassoed_element_class)

		for el in CUI.globalDrag.elements.slice(0)
			if el not in lassoed_elements
				CUI.util.removeFromArray(el, CUI.globalDrag.elements)
				CUI.dom.toggleClass(el, @_lassoed_element_class)

		CUI.dom.setStyle(CUI.globalDrag.lasso,
			left: left
			top: top
			width: width
			height: height
		)
		# this has problems when browser is set to zoom != 100%
		# ("transform", "translate3d(#{left}px,#{top}px,0) scale(#{width},#{height})")

	get_lassoed_elements: ->
		get_dim = (el) ->
			dim = el.getBoundingClientRect()
			dim

		do_overlap = (dims1, dims2) ->
			x1 = dims1.left
			y1 = dims1.top
			w1 = dims1.width
			h1 = dims1.height
			x2 = dims2.left
			y2 = dims2.top
			w2 = dims2.width
			h2 = dims2.height
			!(y2 + h2 <= y1 || y1 + h1 <= y2 || x2 + w2 <= x1 || x1 + w1 <= x2)

		CUI.globalDrag.lasso_dim = get_dim(CUI.globalDrag.lasso)
		lassoed = []
		if @_lasso_filter
			for el in CUI.dom.matchSelector(CUI.globalDrag.$source, @_lasso_filter)
				if not do_overlap(CUI.globalDrag.lasso_dim, get_dim(el))
					continue
				# find lasso filtered
				if @_filter
					lassoed_el = CUI.dom.closest(el, @_filter, CUI.globalDrag.$source)
				else
					parents = CUI.dom.parentsUntil(el, CUI.globalDrag.$source)
					lassoed_el = parents[parents.length-2]

				if lassoed_el
					CUI.util.pushOntoArray(lassoed_el, lassoed)
		else if @_filter
			for el in CUI.dom.matchSelector(CUI.globalDrag.$source, @_filter)
				if do_overlap(CUI.globalDrag.lasso_dim, get_dim(el))
					CUI.util.pushOntoArray(el, lassoed)
		else
			for el in CUI.globalDrag.$source.children
				if do_overlap(CUI.globalDrag.lasso_dim, get_dim(el))
					lassoed.push(el)
		lassoed

	stop_drag: (ev) ->
		for el in CUI.globalDrag.elements.slice(0)
			CUI.util.removeFromArray(el, CUI.globalDrag.elements)
			CUI.dom.toggleClass(el, @_lassoed_element_class)
		super(ev)

	cleanup_drag: (ev) ->
		super(ev)
		CUI.dom.remove(CUI.globalDrag.lasso)

	end_drag: (ev) ->
		@_selected(ev, CUI.globalDrag)
		super(ev)
