globalDrag = null

class CUI.DragDropSelect extends CUI.Element
	constructor: (@opts={}) ->
		super(@opts)
		@init()

	initOpts: ->
		super()
		@addOpts
			element:
				mandatory: true
				check: (v) ->
					CUI.DOM.isNode(v)
		@

	readOpts: ->
		super()
		@cls = window[@__cls].cls
		assert(@cls, "new "+@__cls, @__cls+".cls is not set.", opts: @opts)

		@element = @_element
		DragDropSelect.getInstance(@element, @cls)?.destroy()
		DOM.data(@element, "drag-drop-select-"+@cls, @)
		DOM.addClass(@element, @__getClass())

	__getClass: ->
		"cui-drag-drop-select cui-drag-drop-select-"+@cls

	destroy: ->
		DOM.removeClass(@element, @__getClass())
		DOM.removeData(@element, "drag-drop-select-"+@cls)
		Events.ignore
			instance: @
		super()

	init: ->
		throw "overwrite Drag.init"

	# makeElementRelative: (ele) ->
	# 	if $elementIsInDOM(ele) and ele.css("position") not in ["absolute","fixed","relative"]
	# 		ele.css(position: "relative")

	@destroy: (node, cls=@cls) ->
		inst = @getInstance(node, cls)
		inst?.destroy()

	@getInstance: (node, cls=@cls) ->
		assert(cls != "DragDropSelect", "DragDropSelect.getInstance", "cls cannot be DragDropSelect")
		DOM.data(node, "drag-drop-select-"+cls)



CUI.ready =>
	Events.registerEvent
		type: "cui-drop"
		bubble: true

	Events.registerEvent
		type: "cui-dragenter"
		bubble: true

	Events.registerEvent
		type: "cui-dragend"
		bubble: true

	Events.registerEvent
		type: "cui-dragleave"
		bubble: true

	Events.registerEvent
		type: "cui-dragover"
		bubble: true

	Events.registerEvent
		type: "dragover-scroll"
		bubble: true


	# # FIXME: this does not work in Text input fields (chrome)
	# Events.listen
	# 	type: "selectstart"
	# 	node: document.documentElement
	# 	capture: true
	# 	call: (ev) =>
	# 		console.debug "selectstart"
	# 		$target = $(ev.getTarget())
	# 		if not globalDrag and $target.closest("span,input,textarea,pre,i").length and
	# 			not $target.closest(".btn,.drag-drop-select-cursor,.no-user-select").length
	# 				return
	# 		ev.preventDefault()
	# 		ev.stopPropagation()
	# 		return false

	Events.listen
		type: "dragover-scroll"
		node: document
		selector: "div.cui-drag-scroll,div.cui-drag-drop-select"
		call: (ev, info) =>
			scrollSpeed = info.mousemoveEvent._counter*0.1+0.9
			threshold = 30

			el = ev.getCurrentTarget()

			dim = CUI.DOM.getDimensions(el)

			if CUI.DOM.is(el, "body,html")
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
				clientX = info.mousemoveEvent.clientX()
				if 0 < (d = clientX-rect.left) < threshold
					scrollLeft = -(threshold-d)*scrollSpeed
				else if 0 < (d = rect.right-clientX-dim.verticalScrollbarWidth) < threshold
					scrollLeft = (threshold-d)*scrollSpeed
				ev.stopPropagation()

			if el.scrollHeight > rect.height
				scrollY = el.scrollTop
				clientY = info.mousemoveEvent.clientY()
				if 0 < (d = clientY-rect.top) < threshold
					scrollTop = -(threshold-d)*scrollSpeed
				else if 0 < (d = rect.bottom-clientY-dim.horizontalScrollbarHeight) < threshold
					scrollTop = (threshold-d)*scrollSpeed

			if scrollTop or scrollLeft
				oldScrollTop = el.scrollTop
				oldScrollLeft = el.scrollLeft

				if scrollTop
					el.scrollTop += scrollTop
				if scrollLeft
					el.scrollLeft += scrollLeft

				if is_body
					oe = info.mousemoveEvent
					if not oe.scrollPageY
						oe.scrollPageY = 0
					oe.scrollPageY += el.scrollTop-oldScrollTop

					if not oe.scrollPageX
						oe.scrollPageX = 0
					oe.scrollPageX += el.scrollLeft-oldScrollLeft

					# CUI.debug ev.mousemoveEvent.originalEvent.scrollPageY
				ev.stopPropagation()
