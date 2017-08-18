###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

globalDrag = null

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
		@element.addClass("cui-lasso-area")
		# assert @element.css("position") in ["relative","absolute","fixed"], "Lasso.init", "Element needs to be positioned (relative, absolute, fixed)", element: @element
		@position = null

	start_drag: (ev, $target, diff) ->
		if not CUI.DOM.isInDOM(@element[0])
			throw("DragDropSelect: Creating lasso failed, element is not in DOM.")

		globalDrag.lasso = $div("cui-lasso")
		# CUI.debug "create lasso", @_lassoClass
		#
		globalDrag.lasso.appendTo(@element)
		globalDrag.elements = []

	getCursor: ->
		"default"

	do_drag: (ev, $target, diff) ->
		# CUI.debug "Lasso do drag", globalDrag.start, globalDrag.$source[0] == @element[0], diff, @scroll?.top, @element[0].scrollTop
		left = 0
		top = 0
		width = 0
		height = 0
		if diff.x <= 0
			left = globalDrag.start.left + diff.x
			width = -diff.x
			over = -left
			if over > 0
				width -= over
				left = 0
		else
			left = globalDrag.start.left
			width = diff.x
			over = left + width - @element[0].scrollWidth
			if over > 0
				width -= over

		if diff.y <= 0
			top = globalDrag.start.top + diff.y
			height = -diff.y
			over = -top
			if over > 0
				height -= over
				top = 0
		else
			top = globalDrag.start.top
			height = diff.y
			over = top + height - @element[0].scrollHeight
			if over > 0
				height -= over

		lassoed_elements = @get_lassoed_elements()

		for el in lassoed_elements
			if el not in globalDrag.elements
				globalDrag.elements.push(el)
				CUI.DOM.toggleClass(el, @_lassoed_element_class)

		for el in globalDrag.elements.slice(0)
			if el not in lassoed_elements
				removeFromArray(el, globalDrag.elements)
				CUI.DOM.toggleClass(el, @_lassoed_element_class)

		window.globalDrag.lasso.css
			left: left
			top: top
			width: width
			height: height
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

		globalDrag.lasso_dim = get_dim(globalDrag.lasso)
		lassoed = []
		if @_lasso_filter
			for el in CUI.DOM.matchSelector(globalDrag.$source, @_lasso_filter)
				if not do_overlap(globalDrag.lasso_dim, get_dim(el))
					continue
				# find lasso filtered
				if @_filter
					lassoed_el = CUI.DOM.closest(el, @_filter, globalDrag.$source)
				else
					parents = CUI.DOM.parentsUntil(el, globalDrag.$source)
					lassoed_el = parents[parents.length-2]

				if lassoed_el
					pushOntoArray(lassoed_el, lassoed)
		else if @_filter
			for el in CUI.DOM.matchSelector(globalDrag.$source, @_filter)
				if do_overlap(globalDrag.lasso_dim, get_dim(el))
					pushOntoArray(el, lassoed)
		else
			for el in globalDrag.$source.children
				if do_overlap(globalDrag.lasso_dim, get_dim(el))
					lassoed.push(el)
		lassoed

	stop_drag: (ev) ->
		for el in globalDrag.elements.slice(0)
			removeFromArray(el, globalDrag.elements)
			CUI.DOM.toggleClass(el, @_lassoed_element_class)
		super(ev)

	cleanup_drag: (ev) ->
		super(ev)
		globalDrag.lasso.remove()

	end_drag: (ev) ->
		@_selected(ev, globalDrag)
		super(ev)
