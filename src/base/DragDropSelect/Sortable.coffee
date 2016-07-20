globalDrag = null

class Sortable extends Draggable
	@cls = "sortable"

	initOpts: ->
		super()
		@addOpts
			ignoreClass:
				default: "cui-sortable-ignore"
				check: String

			sorted:
				mandatory: true
				default: (ev, from_idx, to_idx) ->
					alert("You sorted item #{from_idx} to #{to_idx}.")
				check: Function

		@removeOpt("helper_parent")
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
		@_helper_parent = "parent"
		@_helper_remove_always = true

	get_child_number: (child) ->
		for c, idx in @element.children()
			if c == child
				return idx
		null

	move_element: (source_idx, dest_idx) ->
		$source = @element.children(":nth-child(#{source_idx+1})")
		$dest = @element.children(":nth-child(#{dest_idx+1})")
		# CUI.debug "moving from", source_idx, $source[0], "to", dest_idx, $dest[0]
		if source_idx < dest_idx
			$dest.after($source)
		else if source_idx > dest_idx
			$dest.before($source)

	do_drag: (ev, $target, diff) ->
		if not globalDrag.dragStarted
			@init_helper()
			globalDrag.start_idx = @get_child_number(globalDrag.$source[0])
			# CUI.debug "INIT HELPER", globalDrag

		@position_helper(ev)

		# find the closest child of the target
		if $target.closest(@element).length
			target_child = $target[0]
			while target_child != @element[0]
				if target_child.parentNode == @element[0]
					if globalDrag.$source[0] != target_child  and not $(target_child).hasClass(@_ignoreClass)

						source_idx = @get_child_number(globalDrag.$source[0])
						dest_idx = @get_child_number(target_child)

						@move_element(source_idx, dest_idx)
					break
				target_child = target_child.parentNode


	end_drag: (ev) ->
		# move dragged object into position
		@element.children(".drag-drop-select-transparent").remove()
		curr_idx = @get_child_number(globalDrag.$source[0])
		if ev.getType() == "mouseup"
			globalDrag.helperNode.remove()
			globalDrag.helperNode = null
			if @_sorted
				if globalDrag.start_idx != curr_idx
					@_sorted(ev, globalDrag.start_idx, curr_idx)
		else
			curr_idx = @get_child_number(globalDrag.$source[0])
			@move_element(curr_idx, globalDrag.start_idx)
			# super will animate the helper class back to
			# its origin
		super(ev)
