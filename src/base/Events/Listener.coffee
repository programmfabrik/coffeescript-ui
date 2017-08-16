###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CUI.Listener extends CUI.Element

	initOpts: ->
		super()
		@addOpts
			# the type of the event(s) to listen to
			type:
				mandatory: true
				check: (v) ->
					isString(v) or CUI.isArray(v)

			# an optional element to bind this listener to
			# if given, the event will only be triggered
			node:
				default: document.documentElement
				mandatory: true
				check: (v) ->
					DOM.isNode(v)

			# call this function when event is triggered
			call:
				mandatory: true
				check: (v) ->
					CUI.isFunction(v)

			# if set only listen once
			only_once:
				check: Boolean

			# passthru for jquery selector
			selector:
				check: (v) ->
					isString(v) or CUI.isFunction(v)

			# abritrary object to match when "ignore" is called
			instance: {}

			# catch during capture phase
			capture:
				default: false
				check: Boolean

	readOpts: ->
		super()
		if isString(@_type)
			@__types = @_type.split(/\s+/)
		else
			@__types = @_type

		@__node = CUI.DOM.getNode(@_node)

		for type in @__types
			ev = Events.getEventType(type)

		if isString(@_selector)
			assert(@__node instanceof HTMLElement or @__node == document, "new CUI.Listener", "opts.selector requires the node to be instance of HTMLElement.", opts: @opts)

		@__handleDOMEvent = (ev) =>
			# CUI.debug "handleDOMEvent", ev.type, @getUniqueId(), @
			@__handleDOMEventInternal(ev)

		if @_selector
			if isString(@_selector)
				@__selector = (target, node) =>
					DOM.closestUntil(target, @_selector, node)
			else
				@__selector = @_selector

		@__registerDOMEvent()
		@

	isCapture: ->
		@_capture

	getNode: ->
		@__node

	getTypes: ->
		@__types

	__registerDOMEvent: ->
		for _type in @getTypes()
			# @__node.addClass("cui-debug-listen-#{type}")
			for type in Events.getEventTypeAliases(_type)
				@__node.addEventListener(type, @__handleDOMEvent, @isCapture())
		@

	__handleDOMEventInternal: (ev) ->

		if @__selector
			# filter this by the selector
			# check if from the target up, we match a selector
			currentTarget = @__selector(ev.target, @__node)
			# CUI.debug "handleDOMEvent.selector", ev.type, ev.__eventsEvent, ev.target, currentTarget, @_call
			if not currentTarget
				return false
		else
			currentTarget = @__node

		# this event was synthecially created by Events.trigger
		# or previously handled by an CUI.Listener
		# or dispatched by Event.dispatch
		if ev.__cui_event
			event = ev.__cui_event
			# CUI.error "use event from eventsevent", ev, eventsEvent.getType(), eventsEvent.getUniqueId()
		else
			event = CUI.Event.createFromDOMEvent(ev)

			# store this for the bubble phase, so that this events stays
			# the same, throughout its livetime
			ev.__cui_event = event

			# CUI.error "create event from DOM event", ev, eventsEvent.getType(), eventsEvent.getUniqueId()

		event.setCurrentTarget(currentTarget)

		# CUI.debug "handleDOMEvent", @__cls, ev.type, eventsEvent.__cls
		if @isCapture()
			ret = @handleEvent(event, "capture")
		else
			ret = @handleEvent(event, "bubble")
		return ret

	isOnlyOnce: ->
		@_only_once


	destroy: ->
		if @isDestroyed()
			return

		Events.unregisterListener(@)

		for _type in @getTypes()
			# @__node.removeClass("cui-debug-listen-#{type}")
			#
			for type in Events.getEventTypeAliases(_type)
				@__node.removeEventListener(type, @__handleDOMEvent, @isCapture())
		super()

	# returns the distance of the listener node
	# to the events node. with no node, return -1
	# returns null if no match
	matchesEvent: (event) ->
		assert(event instanceof CUI.Event, "CUI.Listener.matchesEvent", "event needs to be instance of CUI.Event.")
		delete(@__depth)

		if event.getType() not in @getTypes()
			return null

		# if not @__node
		# 	@__depth = -1
		# 	return @__depth

		ev_node = event.getNode()
		@__depth = 0

		if @isCapture()
			# ignore sink events
			return null

		# if bubble is set to false the event needs to happen inside DOM
		# tree in order for us to consider ourselves. if it happened outside
		# the DOM tree, our node has already been triggered by the native
		# event
		if not event.isExcludeSelf() and not event.isBubble() and event.isInDOM()
			# if the event bubbles, we are touched by the native event already
			# so we can ignore us
			if @__node == ev_node
				return @__depth

		# if @getNode() == document
		#  	CUI.debug "listener", @getNode(), DOM.parents(@__node), ev_node

		if event.isSink()
			for parent in DOM.parents(@__node)
				@__depth++
				if parent == ev_node
					return @__depth

		delete(@__depth)
		return null

	getDepthFromLastMatchedEvent: ->
		@__depth

	# if the calls return promises, we
	# return a promise, otherwise we return the last ret
	# nothing
	handleEvent: (event, phase) ->
		assert(event instanceof CUI.Event, "CUI.Listener.handleEvent", "event needs to be instance of CUI.Event", event: event)
		event.__setPhase(phase)
		event.__setListener(@)

		if @isOnlyOnce()
			# CUI.debug "destroying one time event listener...", event, @
			@destroy()
			# this calls "destroy" on us

		inst = @getInstance()
		if inst and inst instanceof CUI.Element and inst.isDestroyed()
			console.error "inst destroyed already.."
			@destroy()
			return

		# try
		ret = @_call.call(@, event, event.getInfo())
		# catch ex
		# 	CUI.error("Handle Event error  \"#{ex}\". Type: ", event.getType(), @)
		# 	throw(ex)

		# CUI.debug "CUI.Listener.handleEvent", event, info
		if isPromise(ret)
			info = event.getInfo()
			if not info.__waits
				assert(false, "CUI.Listener.handleEvent", "Event \"#{event.getType()}\" to handle was not triggered by CUI.Events.trigger, but instead by a regular DOMEvent.\n\nMake sure that, if your handler returns a Promise, the event is triggered by Events.trigger.", event: event, listener: @, return: ret)
			info.__waits.push(ret)

		ret

	getInstance: ->
		@_instance

	matchesFilter: (filter) ->

		if filter instanceof CUI.Listener
			return filter == @

		assert(CUI.isPlainObject(filter), "CUI.Listener.matchesFilter", "filter needs to be PlainObject.")
		match = true
		filtered = false

		if filter.node
			filter_node = DOM.getNode(filter.node)
			filtered = true
			match = !!DOM.closestUntil(@__node, filter_node)

		if match and filter.type
			filtered = true
			if CUI.isArray(filter.type)
				match = false
				for _type in filter.type
					match = _type in @__types
					if match
						break
			else
				match = filter.type in @__types

		if match and filter.call
			filtered = true
			match = filter.call == @_call

		if match and filter.instance
			filtered = true
			match = filter.instance == @getInstance()

		assert(filtered, "Listener.matchesFilter", "Filter did not filter anything, make sure you have 'node', 'type', 'call', or 'instance' set.", filter: filter)

		return match


	@require: (listener, func) ->
		if CUI.isPlainObject(listener)
			listenerFunc = null
			if listener.type not instanceof Array
				types = [listener.type]
			else
				types = listener.type

			for type in types
				ev = Events.getEventType(type)
				assert(ev, "#{func}", "listener.type needs to be registered", listener: listener)

				if ev.listenerClass
					assert(not listenerFunc or listenerFunc == ev.listenerClass, "#{func}", "listenerFunction differs for different listener types.", listener: listener)
					listenerFunc = ev.listenerClass
				else
					assert(not listenerFunc or listenerFunc == CUI.Listener, "#{func}", "listenerFunction differs for different listener types.", listener: listener)
					listenerFunc = CUI.Listener

			listen = new listenerFunc(listener)
		else
			listen = listener
		assert(listen instanceof CUI.Listener, "#{func}", "listener needs to be PlainObject or instance of CUI.Listener.")
		listen
