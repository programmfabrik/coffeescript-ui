globalDrag = null

class DragDropSelect extends Element
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

		@element = $(@_element)
		DragDropSelect.getInstance(@element[0], @cls)?.destroy()
		DOM.data(@element[0], "drag-drop-select-"+@cls, @)
		@element.addClass(@__getClass())


	__getClass: ->
		"cui-drag-drop-select cui-drag-drop-select-"+@cls

	destroy: ->
		@element.removeClass(@__getClass())
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



# scroller
CUI.ready =>
	Events.registerEvent
		type: "cui-drop"
		bubble: true

	Events.registerEvent
		type: "cui-dragenter"
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
		selector: ".auto-drag-scroll,.cui-drag-drop-select"
		call: (ev, info) =>
			scrollSpeed = info.mousemoveEvent._counter*0.1+0.9
			threshold = 30

			$el = $(ev.getCurrentTarget())

			if $el.is("body,html")
				rect =
					top: 0
					left: 0
					height: $(window).height()
					bottom: $(window).height()
					width: $(window).width()
					right: $(window).width()
			else
				rect = $el[0].getBoundingClientRect()

			scrollTop = 0
			scrollLeft = 0
			if $el[0].scrollWidth > rect.width
				scrollbarVertical = $el.width()-$el[0].clientWidth
				scrollX = $el[0].scrollLeft
				clientX = info.mousemoveEvent.clientX()
				if 0 < (d = clientX-rect.left) < threshold
					scrollLeft = -(threshold-d)*scrollSpeed
				else if 0 < (d = rect.right-clientX-scrollbarVertical) < threshold
					scrollLeft = (threshold-d)*scrollSpeed
				ev.stopPropagation()

			if $el[0].scrollHeight > rect.height
				scrollbarHorizontal = $el.height()-$el[0].clientHeight
				scrollY = $el[0].scrollTop
				clientY = info.mousemoveEvent.clientY()
				if 0 < (d = clientY-rect.top) < threshold
					scrollTop = -(threshold-d)*scrollSpeed
				else if 0 < (d = rect.bottom-clientY-scrollbarHorizontal) < threshold
					scrollTop = (threshold-d)*scrollSpeed

			if scrollTop or scrollLeft
				oldScrollTop = $el[0].scrollTop
				oldScrollLeft = $el[0].scrollLeft
				if scrollTop
					$el[0].scrollTop += scrollTop
				if scrollLeft
					$el[0].scrollLeft += scrollLeft
				if $el.is("body,html")
					oe = info.mousemoveEvent
					if not oe.scrollPageY
						oe.scrollPageY = 0
					oe.scrollPageY += $el[0].scrollTop-oldScrollTop

					if not oe.scrollPageX
						oe.scrollPageX = 0
					oe.scrollPageX += $el[0].scrollLeft-oldScrollLeft

					# CUI.debug ev.mousemoveEvent.originalEvent.scrollPageY
				ev.stopPropagation()


