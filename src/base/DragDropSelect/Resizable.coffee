###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Resizable extends CUI.Movable
	@cls = "resizable"

	initOpts: ->
		super()
		@removeOpt("selector")

	readOpts: ->
		super()
		@_selector = ".cui-resizable-handle"

	init: ->
		super()
		for d in ["ne","nw","se","sw","s","n","e","w"]
			CUI.DOM.append(@element, CUI.DOM.element("DIV", "cui-drag-drop-select-resizable": d, class: "cui-resizable-handle cui-resizable-handle-"+d))

	before_drag: (ev, $target) ->
		super(ev, $target)
		CUI.globalDrag.resize = $target.getAttribute("cui-drag-drop-select-resizable")

	init_drag: (ev, $target) ->
		#if $target.is(".cui-resizable-handle")
		Draggable::init_drag.call(@, ev, $target)
		# else
		# 	# ignore this
		# 	return

	start_drag: (ev, $target, diff) ->
		if @_start_drag
			return @_start_drag(ev, $target, diff, @)

	do_drag: (ev, $target, diff) ->
		if @_do_drag
			return @_do_drag(ev, $target, diff, @)

		@setElementCss(@getResizePos(@start, diff))


	# gets the new pos from start and diff depending
	# on the resize direction
	getResizePos: (start, diff, limitRect=@getLimitRect()) =>

		switch CUI.globalDrag.resize
			when "se"
				pos = w: start.w+diff.x, h: start.h+diff.y, fix: ["n","w"]
			when "sw"
				pos = w: start.w-diff.x, x: start.x+diff.x, h: start.h+diff.y, fix: ["n","e"]
			when "ne"
				pos = w: start.w+diff.x, y: start.y+diff.y, h: start.h-diff.y, fix: ["s","e"]
			when "nw"
				pos = w: start.w-diff.x, x: start.x+diff.x, y: start.y+diff.y, h: start.h-diff.y, fix: ["e","s"]
			when "s"
				pos = h: start.h+diff.y, fix: ["n"]
			when "n"
				pos = h: start.h-diff.y, y: start.y+diff.y,	fix: ["s"]
			when "e"
				pos = w: start.w+diff.x, fix: ["w"]
			when "w"
				pos = w: start.w-diff.x, x: start.x+diff.x, fix: ["e"]

		@limitRect(pos, start, limitRect)
