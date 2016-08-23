class CUI.Event extends Element

	constructor: (@opts={}) ->
		super(@opts)

		if @_require_node_in_dom
			console.debug "require node in dom", @isInDOM(), @__node
			assert(@isInDOM(), "new Event", "node is not in DOM, unable to create event.", opts: @opts)

		@__propagationStopped = false
		@__propagationImmediateStopped = false
		@__preventDefault = false
		@__dragPrevented = false

	initOpts: ->
		super()
		@addOpts
			type:
				mandatory: true
				check: (v) ->
					isString(v) and not isEmpty(v) and v.split(/\s+/).length == 1
			# node to start from
			node:
				default: document.documentElement
				mandatory: true
				check: (v) ->
					DOM.isNode(v)

			require_node_in_dom:
				default: false
				mandatory: true
				check: Boolean

			bubble:
				default: false
				check: Boolean

			sink:
				default: false
				check: Boolean

			# trigger skips the start node
			exclude_self:
				default: false
				check: Boolean

			# info to pass alongside the event
			info:
				default: {}
				check: "PlainObject"

			prevent_default:
				default: false
				check: Boolean

			onProgress:
				check: Function


	readOpts: ->
		super()

		@__node = DOM.getNode(@_node)

		# if @_exclude_self
		# 	assert(@_bubble != false, "new EventsEvent", "opts.exclude_self can only be set if bubble is set to true.", opts: @opts)

		if @_preventDefault
			@preventDefault()

		@__listenerClass = null
		@__progress_counter = 0

		@__isInDOM = null

		# assert(not @isDOMEvent() or @_bubble, "DOMEvent needs opts.bubble set.", opts: @opts)

	setListener: (listener) ->
		if not @__listenerClass
			@__listenerClass = listener.getElementClass()
		else
			assert(@__listenerClass == listener.getElementClass(), "Event.setListener", "listener class cannot change during an events life cycle.", listener: listener, listenerClass: @__listenerClass)
		@

	progress: (listener, ret) ->
		@__progress_counter++
		@_onProgress?(listener, ret, @__progress_counter)
		@__progress_counter

	isExcludeSelf: ->
		@_exclude_self

	setPhase: (@__phase) ->

	getPhase: ->
		@__phase

	getType: ->
		@_type

	getDebug: ->
		@_type+"["+@getUniqueId()+"#"+@__progress_counter+"]"

	getInfo: ->
		@_info

	getNode: ->
		@__node

	getElement: ->
		DOM.data(@getNode(), "element")

	isBubble: ->
		@_bubble

	isSink: ->
		@_sink

	isInDOM: ->
		if @__isInDOM != null
			# cached result
			@__isInDOM
		else if @__node == document or @__node == window
			@__isInDOM  = true
		else
			@__isInDOM = DOM.isInDOM(@__node)

	setNativeEvent: (NativeEvent) ->
		assert(NativeEvent instanceof window.Event, "CUI.Event.setNativeEvent", "Event needs to be instanceof Event", Event: NativeEvent)
		@__NativeEvent = NativeEvent
		@

	getNativeEvent: ->
		@__NativeEvent

	getPointTarget: ->
		document.elementFromPoint(@clientX(), @clientY())

	getTarget: ->
		@__target or @getNativeEvent()?.target

	setTarget: (tg) ->
		@__target = tg

	getCurrentTarget: ->
		@__currentTarget or @getTarget()

	setCurrentTarget: (ct) ->
		@__currentTarget = ct

	hasModifierKey: (includeShift=false) ->
		@metaKey() or
			@ctrlKey() or
			@altKey() or
			(includeShift and @shiftKey())

	getButton: ->
		@getNativeEvent()?.button

	keyCode: ->
		@getNativeEvent()?.which

	metaKey: ->
		@getNativeEvent()?.metaKey

	ctrlKey: ->
		@getNativeEvent()?.ctrlKey

	altKey: ->
		@getNativeEvent()?.altKey

	shiftKey: ->
		@getNativeEvent()?.shiftKey

	wheelDeltaX: ->
		@getNativeEvent()?.wheelDeltaX

	wheelDeltaY: ->
		@getNativeEvent()?.wheelDeltaY

	clientX: ->
		@getNativeEvent()?.clientX

	clientY: ->
		@getNativeEvent()?.clientY

	pageX: ->
		@getNativeEvent()?.pageX

	pageY: ->
		@getNativeEvent()?.pageY

	stopImmediatePropagation: ->
		@__propagationImmediateStopped = true
		@getNativeEvent()?.stopImmediatePropagation()
		@

	stopPropagation: ->
		@__propagationStopped = true
		@getNativeEvent()?.stopPropagation()
		@

	preventDefault: ->
		@__defaultPrevented = true
		@getNativeEvent()?.preventDefault()
		@

	isImmediatePropagationStopped: ->
		@__propagationImmediateStopped

	isPropagationStopped: ->
		@__propagationStopped

	isDefaultPrevented: ->
		@__defaultPrevented

	dispatch: ->
		# CUI.info "CUI.Events.trigger jQuery DOMEvent", event.getType()
		assert(not @getNativeEvent(), "CUI.Event.dispatch", "Can only dispatch once.", event: @)
		ev = document.createEvent("Event")
		ev.initEvent(@getType(), @isBubble(), true)
		ev.__cui_event = @

		if @isExcludeSelf() # or @isSink()
			# when sinking, we touch the node while sinking, so
			# its ok to start with the parent to not trigger
			# it twice
			node = DOM.parent(@getNode())
		else
			# even is event.isBubble() === false
			# we trigger here using the bubble mechanism,
			# handleEvent takes care of the bubble check
			node = @getNode()

		if @isDefaultPrevented()
			ev.preventDefault()

		# if the dom event is not set yet on this
		# we set it now
		@setNativeEvent(ev)

		# CUI.error "dispatch event on node:", @getType(), node, @getUniqueId(), ev
		node.dispatchEvent(ev)
		ev

	dump: ->
		txt = @__cls+": **"+@getType()+"**"
		for k in ["altKey", "ctrlKey", "shiftKey", "metaKey", "keyCode"]
			txt += " **"+k+"**: "+@[k]()
		txt

	stop: ->
		@preventDefault()
		@stopPropagation()
		@stopImmediatePropagation()
		false

	@require: (event, func) ->
		if $.isPlainObject(event)
			ev_info = Events.getEventType(event.type)
			if ev_info.eventClass
				eventClass = ev_info.eventClass
			else
				eventClass = CUI.Event

			CUI.mergeMap(event, ev_info)
			delete(event.eventClass)
			delete(event.listenerClass)
			ev = new eventClass(event)
		else
			ev = event
		assert(ev instanceof CUI.Event, "#{func}", "event needs to be PlainObject or instance of CUI.Event.")
		ev

	# cr
	@createFromDOMEvent: (event, eventClass) ->
		ev_info = CUI.Events.getEventType(event.type)

		if not eventClass
			if ev_info.eventClass
				eventClass = ev_info.eventClass
			else
				eventClass = CUI.Event


		ev = new eventClass
			type: event.type
			bubble: event.bubbles
			node: event.target

		# CUI.debug "Event.createFromDOMEvent", event.type, eventClass.name, ev.getUniqueId()
		ev.setNativeEvent(event)
		ev