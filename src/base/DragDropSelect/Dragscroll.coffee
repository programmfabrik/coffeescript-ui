globalDrag = null

class Dragscroll extends Draggable

	do_drag: (ev, $target, diff) ->
		if not globalDrag.dragStarted
			@scrollPos =
				top: @element[0].scrollTop
				left: @element[0].scrollLeft
			# CUI.debug "started at", @scrollPos
		@element[0].scrollTop = Math.max(0, @scrollPos.top - diff.y)
		@element[0].scrollLeft = Math.max(0, @scrollPos.left - diff.x)
