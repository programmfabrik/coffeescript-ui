###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Movable extends CUI.Draggable
	@cls = "movable"

	initOpts: ->
		super()
		@addOpts
			limitRect:
				default: {}
				check: (v) ->
					CUI.isPlainObject(v) or v instanceof Function
			onPositioned:
				check: Function
			onPosition:
				check: Function
			start_drag:
				check: Function
			do_drag:
				check: Function

		@removeOpt("helper")

	readOpts: ->
		super()
		@_helper = null

	getLimitRect: ->
		if CUI.isFunction(@_limitRect)
			@_limitRect()
		else
			@_limitRect

	setElementCss: (pos) ->
		assert(CUI.isPlainObject(pos), getObjectClass(@), "opts.position must return a PlainObject containing any of x, y, w, h", pos: pos)
		setCss = {}
		if not isEmpty(pos.x)
			setCss.left = pos.x
		if not isEmpty(pos.y)
			setCss.top = pos.y
		if not isEmpty(pos.w)
			setCss.marginBoxWidth = pos.w
		if not isEmpty(pos.h)
			setCss.marginBoxHeight = pos.h

		CUI.DOM.setDimensions(@element[0], setCss)
		@_onPositioned?(pos)


	init_drag: (ev, $target) ->
		# CUI.debug "init_drag target", ev.getTarget(), $target[0]
		if CUI.DOM.closest(ev.getTarget(), ".cui-resizable-handle")
			return
		# CUI.debug "init_drag on #{@cls}", ev, $target[0]
		super(ev, $target)


	before_drag: ->
		dim = CUI.DOM.getDimensions(@element[0])
		@start =
			x: dim.left or 0
			y: dim.top or 0
			w: dim.marginBoxWidth
			h: dim.marginBoxHeight
		@

	start_drag: (ev, $target, diff) ->
		if @_start_drag
			@_start_drag(ev, $target, diff, @)
		@

	do_drag: (ev, $target, diff) ->
		if @_do_drag
			@_do_drag(ev, $target, diff, @)
			return @

		pos =
			x: diff.x+@start.x
			y: diff.y+@start.y
			w: @start.w
			h: @start.h

		if @_onPosition
			[pos.x, pos.y] = @_onPosition(pos.x, pos.y, @start, diff)
		else
			@limitRect(pos, @start)

		@setElementCss(pos)
		@

	limitRect: (pos, defaults={}, limitRect = @getLimitRect()) ->
		# !!! The order in Draggable.limitRect is different, but better
		Draggable.limitRect(pos, limitRect, defaults)

