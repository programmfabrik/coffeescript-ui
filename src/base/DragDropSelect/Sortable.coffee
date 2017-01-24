###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

globalDrag = null

class CUI.Sortable extends CUI.Draggable
	@cls = "sortable"

	initOpts: ->
		super()
		@addOpts
			sorted:
				mandatory: true
				default: (ev, from_idx, to_idx) ->
					alert("You sorted item #{from_idx} to #{to_idx}.")
				check: Function

		@removeOpt("helper_contain_element")
		@mergeOpt "selector", default:
			(target, node) ->
				els = CUI.DOM.elementsUntil(target, null, node)
				if not els
					return null
				if els.length > 1
					els[els.length-2]
				else
					return null
	readOpts: ->
		super()
		@_helper_contain_element = @_element

	get_child_number: (child) ->
		for c, idx in @element.children
			if c == child
				return idx
		null

	move_element: (source_idx, dest_idx) ->
		$source = @element.children[source_idx]
		$dest = @element.children[dest_idx]
		if source_idx == dest_idx
			return

		if source_idx < dest_idx
			globalDrag.noClickKill = true
			CUI.DOM.insertAfter($dest, $source)
		else if source_idx > dest_idx
			globalDrag.noClickKill = true
			CUI.DOM.insertBefore($dest, $source)

		CUI.DOM.syncAnimatedClone(@element)
		@

	start_drag: (ev, $target, diff) ->
		globalDrag.sort_source = @__findClosestSon(globalDrag.$source)
		globalDrag.sort_source.classList.add("cui-sortable-placeholder")
		globalDrag.start_idx = @get_child_number(globalDrag.sort_source)

		CUI.DOM.initAnimatedClone(@element)

		# CUI.debug "INIT HELPER", globalDrag

	getSourceCloneForHelper: ->
		@__findClosestSon(globalDrag.$source).cloneNode(true)

	__findClosestSon: ($target) ->
		# find the closest child of the target
		parents = CUI.DOM.parentsUntil($target, null, @element)

		if parents[parents.length-1] == window
			return null

		switch parents.length
			when 0
				return null
			when 1
				return $target
			else
				return parents[parents.length - 2]

	do_drag: (ev, $target, diff) ->
		@position_helper(ev, $target, diff)

		target_child = @__findClosestSon($target)
		if not target_child
			return

		source_idx = @get_child_number(globalDrag.sort_source)
		dest_idx = @get_child_number(target_child)
		@move_element(source_idx, dest_idx)

	stop_drag: (ev) ->
		@__end_drag(ev, true)
		super(ev)

	end_drag: (ev) ->
		@__end_drag(ev, false)
		super(ev)

	__end_drag: (ev, stopped) ->
		# move dragged object into position
		globalDrag.sort_source.classList.remove("cui-sortable-placeholder")
		CUI.DOM.removeAnimatedClone(@element)
		curr_idx = @get_child_number(globalDrag.sort_source)

		if globalDrag.start_idx == curr_idx
			return

		if stopped
			@move_element(curr_idx, globalDrag.start_idx)
		else
			@_sorted(ev, globalDrag.start_idx, curr_idx)


Sortable = CUI.Sortable
