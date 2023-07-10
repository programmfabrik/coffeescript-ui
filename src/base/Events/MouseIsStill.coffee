# new MouseIsStill calls the given function when the
# mouse is still for n seconds

class CUI.Events.MouseIsStill extends CUI.Element
	constructor: (opts) ->
		super(opts)
		@__timeout = null

		CUI.Events.listen
			type: "mouseenter"
			instance: @
			node: @_node
			call: =>
				@start()

		CUI.Events.listen
			type: "mouseleave"
			instance: @
			node: @_node
			call: =>
				@stop()

		return

	initOpts: ->
		super()
		@addOpts
			ms:
				check: (v) ->
					v >= 1
				mandatory: true

			call:
				check: Function
				mandatory: true

			node:
				mandatory: true
				check: (v) ->
					CUI.dom.isNode(v)

		return


	start: ->
		@__clickEvent = CUI.Events.listen
			type: ["click", "dblclick"]
			capture: true
			node: @_element
			only_once: true
			call: (ev) =>
				@stop()

		@__event = CUI.Events.listen
			type: ["mousemove"]
			node: @_node
			instance: @
			call: (ev) =>
				CUI.clearTimeout(@__timeout)
				@__timeout = CUI.setTimeout
					ms: @_ms
					call: =>
						@stop()
						@_call(ev)
		return

	stop: ->
		if @__timeout
			CUI.clearTimeout(@__timeout)
			@__timeout = null
		if @__event
			CUI.Events.ignore(@__event)
			CUI.Events.ignore(@__clickEvent)
			@__clickEvent = null
			@__event = null
		return

	destroy: ->
		@stop()
		CUI.Events.ignore(instance: @)
		super()
		return