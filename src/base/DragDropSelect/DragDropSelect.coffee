###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.DragDropSelect extends CUI.Element
	constructor: (opts) ->
		super(opts)
		@init()

	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					CUI.dom.isNode(v)
		@

	readOpts: ->
		super()
		@cls = CUI[@__cls].cls
		CUI.util.assert(@cls, "new "+@__cls, @__cls+".cls is not set.", opts: @opts)

		@element = @_element
		CUI.DragDropSelect.getInstance(@element, @cls)?.destroy()
		CUI.dom.data(@element, "drag-drop-select-"+@cls, @)
		CUI.dom.addClass(@element, @getClass())

	getClass: ->
		"cui-drag-drop-select cui-drag-drop-select-"+@cls

	destroy: ->
		CUI.dom.removeClass(@element, @getClass())
		CUI.dom.removeData(@element, "drag-drop-select-"+@cls)
		CUI.Events.ignore
			instance: @
		super()

	init: ->
		throw "overwrite Drag.init"

	@destroy: (node, cls=@cls) ->
		inst = @getInstance(node, cls)
		inst?.destroy()

	@getInstance: (node, cls=@cls) ->
		CUI.util.assert(cls != "DragDropSelect", "DragDropSelect.getInstance", "cls cannot be DragDropSelect")
		CUI.dom.data(node, "drag-drop-select-"+cls)



CUI.ready =>
	CUI.Events.registerEvent
		type: "cui-drop"
		bubble: true

	CUI.Events.registerEvent
		type: "cui-dragenter"
		bubble: true

	CUI.Events.registerEvent
		type: "cui-dragend"
		bubble: true

	CUI.Events.registerEvent
		type: "cui-dragleave"
		bubble: true

	CUI.Events.registerEvent
		type: "cui-dragover"
		bubble: true

	CUI.Events.registerEvent
		type: "dragover-scroll"
		bubble: true
		eventClass: CUI.DragoverScrollEvent



	# # FIXME: this does not work in Text input fields (chrome)
	# CUI.Events.listen
	# 	type: "selectstart"
	# 	node: document.documentElement
	# 	capture: true
	# 	call: (ev) =>
	# 		console.debug "selectstart"
	# 		$target = $(ev.getTarget())
	# 		if not CUI.globalDrag and $target.closest("span,input,textarea,pre,i").length and
	# 			not $target.closest(".btn,.drag-drop-select-cursor,.no-user-select").length
	# 				return
	# 		ev.preventDefault()
	# 		ev.stopPropagation()
	# 		return false

	CUI.Events.listen
		type: "dragover-scroll"
		node: document
		selector: "div.cui-drag-scroll,div.cui-drag-drop-select"
		call: (ev, info) =>

			originalEvent = ev.getOriginalEvent()

			scrollSpeed = ev.getCount()*0.01+0.9
			threshold = 30

			el = ev.getCurrentTarget()

			dim = CUI.dom.getDimensions(el)

			if CUI.dom.is(el, "body,html")
				is_body = true
				rect =
					top: 0
					left: 0
					bottom: 0
					right: 0
					height: dim.height
					width: dim.width
			else
				rect = dim.clientBoundingRect

			scrollTop = 0
			scrollLeft = 0

			if el.scrollWidth > rect.width
				scrollX = el.scrollLeft
				clientX = originalEvent.clientX()
				if 0 < (d = clientX-rect.left) < threshold
					scrollLeft = -(threshold-d)*scrollSpeed
				else if 0 < (d = rect.right-clientX-dim.verticalScrollbarWidth) < threshold
					scrollLeft = (threshold-d)*scrollSpeed
				ev.stopPropagation()

			if el.scrollHeight > rect.height
				scrollY = el.scrollTop
				clientY = originalEvent.clientY()
				if 0 < (d = clientY-rect.top) < threshold
					scrollTop = -(threshold-d)*scrollSpeed
				else if 0 < (d = rect.bottom-clientY-dim.horizontalScrollbarHeight) < threshold
					scrollTop = (threshold-d)*scrollSpeed

			if not (scrollTop or scrollLeft)
				return

			oldScrollTop = el.scrollTop
			oldScrollLeft = el.scrollLeft

			if scrollTop
				el.scrollTop += scrollTop
			if scrollLeft
				el.scrollLeft += scrollLeft

			if is_body
				# FIXME: this is used in getCoordinatesFromEvent
				if not originalEvent.scrollPageY
					originalEvent.scrollPageY = 0
				originalEvent.scrollPageY += el.scrollTop-oldScrollTop

				if not originalEvent.scrollPageX
					originalEvent.scrollPageX = 0
				originalEvent.scrollPageX += originalEvent.scrollLeft-oldScrollLeft

				# console.debug ev.mousemoveEvent.originalEvent.scrollPageY
			ev.stopPropagation()
