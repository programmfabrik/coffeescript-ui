class CUI.MouseIsDownEvent extends CUI.MouseEvent

	readOpts: ->
		super()
		@__preventNext = false

	initOpts: ->
		super()
		@addOpts
			ms:
				mandatory: true
				default: 0
				check: (v) ->
					v >= 0

			counter:
				mandatory: true
				check: (v) ->
					v >= 0

			mousedownEvent:
				mandatory: true
				# default to the "mousedown" event
				check: (v) ->
					v instanceof CUI.MouseEvent or v instanceof CUI.MouseIsDownEvent

		@mergeOpt("type", check: (v) -> v == "mouseisdown")

	getCounter: ->
		@_counter

	getMilliseconds: ->
		@_ms

	getMousedownEvent: ->
		@_mousedownEvent

	hasModifierKey: (includeShift=false) ->
		@_mousedownEvent.hasModifierKey(includeShift)

	getButton: ->
		@_mousedownEvent.getButton()

	keyCode: ->
		@_mousedownEvent.keyCode()

	metaKey: ->
		@_mousedownEvent.metaKey()

	ctrlKey: ->
		@_mousedownEvent.ctrlKey()

	altKey: ->
		@_mousedownEvent.altKey()

	shiftKey: ->
		@_mousedownEvent.shiftKey()

	wheelDeltaX: ->
		@_mousedownEvent.wheelDeltaX()

	wheelDeltaY: ->
		@_mousedownEvent.wheelDeltaY()

	clientX: ->
		@_mousedownEvent.clientX()

	clientY: ->
		@_mousedownEvent.clientY()

	pageX: ->
		@_mousedownEvent.pageX()

	pageY: ->
		@_mousedownEvent.pageY()

	toHtml: ->
		html = super()
		html += " <b>"+@getMilliseconds()+"</b>ms"