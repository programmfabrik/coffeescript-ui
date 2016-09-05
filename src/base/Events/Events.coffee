# Events Inter-"Process"-Communication for CUI
#
#
#
# @example How to listen to and trigger events
#
# Event.listen
#     type: [ "click", "dblclick" ]
#     node: jQuery Element or CUI DOM Element
#     call: (ev, info) ->
#     selector: jQuery like path selector to filter events
#
#
# Event.trigger
#     type: "content-resize"
#     node: jQuery Element or CUI DOM Element
#     bubble: set to yes if event should bubble up or down the DOM tree
#     info: info Map, contains eventsEvent for DOMElements and
#           the internal "waits" queue
#
# Event.ignore
#     type: "<type>"
#     node: jQuery or DOM Element
#
#
# CUIEvents bound to a node will be checked for the existance in the
# DOM tree prio execution. If they don't exist (after they
# have been inserted), the CUI.Listener will be deleted.
#
# All events need to be registered or a warning is output at the console.
#
# Events.registerEvent(options)
#    options are the default options for the event
#    type: <type>
#    bubble: true|false
#
#
class CUI.Events extends CUI.Element

	@defaults:
		maxWait: 1500

	@__listeners = []
	@__eventRegistry = {}

	@__getListenersForNode: (node) ->
		if node == document or node == window
			@__listeners
		else
			DOM.data(node, "listeners")

	@__registerListener: (listener) ->
		assert(listener instanceof CUI.Listener, "CUI.Events.__registerListener", "listener needs to be instance of Listener", listener: listener)

		node = listener.getNode()
		listeners = @__getListenersForNode(node)
		if not listeners
			listeners = []
			DOM.data(node, "listeners", listeners)

		listeners.push(listener)

		if node instanceof HTMLElement
			node.setAttribute("cui-events-listener-element", "cui-events-listener-element")
		@

	@getActiveListeners: ->
		listeners = @__listeners.slice(0)
		for el in CUI.DOM.matchSelector(document, "[cui-events-listener-element]")
			listeners.push.apply(listeners, DOM.data(el, "listeners"))
		listeners

	@unregisterListener: (listener) ->
		node = listener.getNode()
		arr = @__getListenersForNode(node)
		assert(arr, "CUI.Events.unregisterListeners", "Listeners not found for node.", node: node, listener: listener)
		# CUI.error "unregistring listeenr", listener.getUniqueId()
		removeFromArray(listener, arr)
		if arr.length == 0 and node instanceof HTMLElement
			node.removeAttribute("cui-events-listener-element")
			DOM.removeData(node, "listeners")
			# CUI.debug "removing listeners from node", node[0]
		@

	# wait for an event on a node
	@wait: (_opts) ->
		opts = CUI.Element.readOpts _opts, "Events.wait",
			# event type
			type:
				mandatory: true
				check: String
			node:
				mandatory: true
				check: (v) ->
					DOM.isNode(v)
			# optionally wait for a timeout
			# if set to <= 0, wait forever
			maxWait:
				default: CUI.defaults.class.Events.defaults.maxWait
				check: (v) ->
					i = parseInt(v)
					if isNaN(i)
						false
					else if i == -1
						true
					else if i >= 0
						true
					else
						false

		dfrs = []
		listeners = []

		_node = DOM.getNode(opts.node)

		dfr = new CUI.Deferred()
		listeners.push Events.listen
			type: opts.type
			node: _node
			call: ->
				dfr.resolve()
				return

		dfrs.push(dfr)

		master_dfr = new CUI.Deferred()
		master_dfr.always ->
			for listener in listeners
				listener.destroy()
			return

		CUI.when(dfrs)
		.fail ->
			master_dfr.reject()
		.done ->
			master_dfr.resolve()

		if opts.maxWait >= 0
			CUI.setTimeout ->
				for dfr in dfrs
					if dfr.state() == "pending"
						dfr.reject()
				return
			,
				opts.maxWait

		master_dfr.promise()


	# register a listener
	# @param listener PlainObject or CUI.Listener
	@listen: (_listener) ->
		listener = CUI.Listener.require(_listener, "CUI.Events.listen")

		@__registerListener(listener)

		listener

	@active: (type) ->
		llm = {}
		for ln in @getActiveListeners()
			types = ln.getTypes()
			for _type in types
				if not llm[_type]
					llm[_type] = []
				llm[_type].push(ln)

		if type
			for ln in llm[type]
				CUI.debug type, ln.getNode()[0]
			return
		else
			Object.keys(llm).sort()

	@trigger: (_event) ->
		event = CUI.Event.require(_event, "CUI.Events.trigger")

		# allwo event calls to return a promise
		# wait for all promises before
		# returning from this methos
		#
		info = event.getInfo()
		waits = []
		info.__waits = waits

		# use the standard event system for this kind of events
		bubble = event.isBubble()
		sink = event.isSink()
		exclude = event.isExcludeSelf()
		node = event.getNode()

		# CUI.debug "trigger event", event.getType(), info, event.getUniqueId(), bubble, sink, exclude, event.isInDOM()
		if bubble or not event.isInDOM()
			event.dispatch()
		else
			# dispatch sets a native event and through that, the event
			# gains a target. without the dispatch, we need to set
			# the target for this event
			event.setTarget(node)

		if exclude and not bubble and not sink
			assert(false, "CUI.Events.trigger", "Unable to trigger event with bubble == false, sink == false and exclude_self == true.", event: event)

		if sink or (not sink and not bubble and not exclude and event.isInDOM())
			# if event.getType() == "toolbox"
			# 	CUI.debug "sink event...", event.getType(), event.getNode()
			triggerListeners = []
			for listener, idx in @getActiveListeners()
				if event.getType() not in listener.getTypes()
					continue

				if listener.matchesEvent(event) == null
					continue

				# CUI.error "triggering...", event.getType()

				triggerListeners.push(listener)

			# if triggerListeners.length == 0
			# 	CUI.warn("Events.trigger: No listeners found for Event #{event.getType()}.", event: event, activeListeners: @active())

			triggerListeners.sort (a, b) ->
				compareIndex(a.getDepthFromLastMatchedEvent(), b.getDepthFromLastMatchedEvent())

			stopNodes = []
			ev_node = event.getNode()

			for listener in triggerListeners
				listener_node = listener.getNode()
				# CUI.debug "listener:", listener, listener.getDepthFromLastMatchedEvent()

				if listener_node and stopNodes.length > 0
					listener_node_parents = DOM.parents(listener_node)
					skip = false
					for stopNode in stopNodes
						for listener_node_parent in listener_node_parents
							if listener_node_parent == stopNode
								skip = true
								break

					if skip
						# node is below the stop node, skip
						continue

				event.setCurrentTarget(listener_node)
				listener.handleEvent(event, "sink")

				if event.isImmediatePropagationStopped()
					# CUI.debug "immediate stopped!"
					break

				# add to stop nodes if the depth is at least 0 meaning that
				# the listener has a node
				if event.isPropagationStopped() and listener_node
					# CUI.debug "adding stop node", listener_node[0]
					stopNodes.push(listener_node[0])

		return CUI.when(waits)


	@ignore: (filter) ->
		# CUI.debug "Events.ignore?", filter, listener.getTypes()
		for listener in @getActiveListeners()
			if not filter or CUI.isEmptyObject(filter) or listener.matchesFilter(filter)
				# CUI.info("Events.ignore", filter, listener.getTypes())
				listener.destroy()
		@

	@dump: (filter={}) ->
		for listener in @getActiveListeners()
			if listener.matchesFilter(filter)
				CUI.debug "Listener", listener.getTypes(), (if listener.getNode() then "NODE" else "-"), listener
		@

	@hasEventType: (type) ->
		!!@__eventRegistry[type]

	# returns event info by type
	@getEventType: (type) ->
		ev = @__eventRegistry[type]
		assert(ev, "Unknown event type \"#{type}\". Use Events.registerEvent to register this type.")
		return ev

	@getEventTypeAliases: (type) ->
		@getEventType(type).alias or [type]

	@registerEvent: (event, allow_array=true) ->
		if not CUI.isArray(event.type) or not allow_array
			assert(isString(event?.type) and event.type.length > 0, "CUI.Events.registerEvent", "event.type must be String.", event: event)

		register_other_type = (_type) =>
			_event = copyObject(event, true)
			_event.type = _type
			@registerEvent(_event, false)

		if CUI.isArray(event.type)
			for type in event.type
				register_other_type(type)
		else
			if event.hasOwnProperty("DOMEvent")
				CUI.error("event.DOMEvent is obsolete")
				delete(event.DOMEvent)

			if event.hasOwnProperty("CUIEvent")
				CUI.error("event.CUIEvent is obsolete")
				delete(event.CUIEvent)

			@__eventRegistry[event.type] = event

			if event.alias
				for type in event.alias
					if not @__eventRegistry[type]
						register_other_type(type)
		@

	@init: ->
		defaults =
			BrowserEvents:
				bubble: true

			DOM:
				bubble: true

			CUI:
				eventClass: CUI.CUIEvent
				sink: true

			KeyboardEvents:
				eventClass: CUI.KeyboardEvent
				bubble: true

			MouseEvents:
				eventClass: CUI.MouseEvent
				bubble: true

		for block, events of {
			MouseEvents:
				mousemove: {}
				mouseover: {}
				mouseout: {}
				mouseleave: {}
				mouseenter: {}
				mousewheel:
					bubble: false
				mousedown: {}
				mouseup: {}
				click: {}

			KeyboardEvents:
				input:
					bubble: false
				keyup: {}
				keydown: {}
				keypress: {}

			BrowserEvents:
				beforeunload: {}
				unload: {}
				load: {}
				error: {}
				close: {}
				contextmenu: {}
				dragstart: {}
				dragover: {}
				dragleave: {}
				dragenter: {}
				message: {}
				fullscreenchange:
					alias: "fullscreenchange mozfullscreenchange webkitfullscreenchange MSFullscreenChange".split(" ")
				hashchange:
					bubble: false
				change:
					bubble: false
				focus:
					bubble: false
				blur:
					bubble: false
				paste:
					bubble: false
				dragover:
					bubble: false
				drop:
					bubble: false
				dblclick: {}
				scroll:
					bubble: false
				selectstart:
					bubble: false
				animationstart:
					alias: "animationstart MSAnimationStart webkitAnimationStart".split(" ")
					bubble: false
				animationend:
					alias: "animationend MSAnimationEnd webkitAnimationEnd".split(" ")
					bubble: false
				transitionend:
					alias: "transitionend webkitTransitionEnd MSTransitionEnd".split(" ")
					bubble: false
				resize:
					bubble: false

			DOM:
				"content-resize":
					eventClass: CUI.CUIEvent

			CUI:
				# "load_server": {}
				# "unload_server": {}
				"viewport-resize": {}
		}
			for type, ev of events
				CUI.mergeMap(ev, defaults[block])
				ev.type = type
				@registerEvent(ev)

CUI.Events.init()
Events = CUI.Events
CUI.defaults.class.Events = CUI.Events
