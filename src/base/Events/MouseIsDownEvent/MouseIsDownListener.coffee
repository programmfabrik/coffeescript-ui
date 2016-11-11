class CUI.MouseIsDownListener extends CUI.Listener

	initOpts: ->
		super()
		@addOpts
			interval_ms:
				default: CUI.MouseIsDownListener.interval_ms
				check: (v) =>
					v > 10

	@interval_ms: 50

	readOpts: ->
		super()
		@__reset()

		Events.listen
			type: "mousedown"
			node: @getNode()
			instance: @
			capture: true
			call: (ev) =>
				if ev.isImmediatePropagationStopped()
					return

				@__reset()
				@__mousedown_event = ev

				listen = Events.listen
					type: "mouseup"
					node: window
					only_once: true
					capture: true
					call: (ev) =>
						@__reset()

				@__triggerEvent()
				return

	destroy: ->
		Events.ignore(instance: @)
		super()

	__reset: ->
		if @__mouseisdown_interval
			CUI.clearTimeout(@__mouseisdown_interval)
			@__mouseisdown_interval = null

		@__counter = 0
		@__mousedown_event = null
		@__last_triggered = null
		@

	__triggerEvent: ->
		if @__mousedown_event.isImmediatePropagationStopped()
			return

		if not CUI.DOM.isInDOM(@__mousedown_event.getNode())
			@__reset()
			return

		ev = CUI.Event.require
			node: @__mousedown_event.getNode()
			type: "mouseisdown"
			bubble: true
			ms: @__counter * @_interval_ms
			counter: @__counter
			mousedownEvent: @__mousedown_event

		CUI.Events.trigger(ev)
		@__last_triggered = ev
		@__scheduleNextEvent()


	__scheduleNextEvent: ->
		@__counter++
		if @__mouseisdown_interval
			CUI.clearTimeout(@__mouseisdown_interval)
		@__mouseisdown_interval = CUI.setTimeout((=> @__triggerEvent()), @_interval_ms, false)
		@



CUI.ready =>
	CUI.Events.registerEvent
		type: [	"mouseisdown"]
		bubble: true
		eventClass: CUI.MouseIsDownEvent
		listenerClass: CUI.MouseIsDownListener
