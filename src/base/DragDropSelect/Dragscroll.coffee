globalDrag = null

class Dragscroll extends Draggable

	initOpts: ->
		super()
		@removeOpt("helper")
		@addOpts
			scroll_element:
				check: (v) ->
					isElement(v)

	readOpts: ->
		super()
		if @_scroll_element
			@__scroll_element = @_scroll_element
		else
			@__scroll_element = @_element

	start_drag: ->
		@__scroll =
			top: @__scroll_element.scrollTop
			left: @__scroll_element.scrollLeft

	do_drag: (ev, $target, diff) ->
		scrollTop = @__scroll.top - diff.bare_y
		scrollLeft = @__scroll.left - diff.bare_x
		@__scroll_element.scrollTop = scrollTop
		@__scroll_element.scrollLeft = scrollLeft
