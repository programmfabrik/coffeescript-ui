class EventsDemo extends Demo
	getGroup: ->
		"Core"

	display: ->
		display = []

		tmpl = new Template
			name: "events-demo"
			map:
				ring0: true
				ring1: true
				ring2: true
				ring3: true
				ring4: true
				ring5: true
				ring6: true
				ring7: true
				buttons: true
				window: true
				document: true
				document_element: true
				body: true
				pointer_events: true

		data =
			node: "ring3"
			listen_to_capture: false

		CUI.debug "body: ", document.body

		element_by_node =
			window:
				node: window
			document:
				node: document
			document_element:
				text: "documentElement"
				node: document.documentElement
			body:
				node: document.body

		for i in [0..7]
			element_by_node["ring"+i] =
				text: "Ring "+i
				node: tmpl.map["ring"+i][0]

		for k, v of element_by_node
			do (k, v) =>
				Events.listen
					type: "click"
					instance: @
					node: tmpl.map[k][0]
					call: (ev) =>
						CUI.debug "clicked on ", k, v
						data.node = k
						mark_node_ring()
						ev.stopPropagation()


		mark_node_ring = =>
			node = tmpl.map[data.node][0]
			DOM.matchSelector(document, ".node-ring")[0]?.classList.remove("node-ring")
			node.classList.add("node-ring")

		mark_node_ring()

		f = new Form
			data: data
			horizontal: true
			fields: [
				type: Checkbox
				name: "bubble"
				text: "Bubble"
			,
				type: Checkbox
				name: "exclude_self"
				text: "Exclude Self"
			,
				type: Checkbox
				name: "sink"
				text: "Sink"
			,
				type: Checkbox
				name: "listen_to_capture"
				text: "Listen to Capture"
			,
				type: FormButton
				text: "Trigger"
				onClick: =>
					opts =
						node: element_by_node[data.node].node
						type: "flash-ring"

					for k in ["bubble", "exclude_self", "sink"]
						if data[k]
							opts[k] = true
						else
							opts[k] = false

					CUI.debug "trigger", opts


					Events.trigger(opts)
			]
		.start()

		for capture in [true, false]
			do (capture) =>
				Events.listen
					type: "flash-ring"
					node: window
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "window ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.window[0])

				Events.listen
					type: "flash-ring"
					node: document
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "document ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.document[0])

				Events.listen
					type: "flash-ring"
					node: document.documentElement
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "documentElement ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.document_element[0])


				Events.listen
					type: "flash-ring"
					node: document.body
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "body ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.body[0])

		for ring in [0..7]
			do (ring) =>
				node = tmpl.map["ring"+ring][0]
				Events.listen
					type: "flash-ring"
					capture: true
					instance: @
					node: node
					call: (ev) =>
						if not data.listen_to_capture
							return
						@flash(node)
						log = "flash ring ("+ev.getPhase()+"): "+ring
						@log(log)

				Events.listen
					type: "flash-ring"
					instance: @
					node: node
					call: (ev) =>
						@flash(node)
						log = "flash ring ("+ev.getPhase()+"): "+ring
						@log(log)

		tmpl.append(Demo.dividerLabel("events playground"), "buttons")

		tmpl.append(f, "buttons")

		node = tmpl.map.pointer_events[0]
		data.listen = mousedown: true
		fields = []
		for k, idx in ["mousedown", "mouseup", "click", "dblclick", "mouseisdown", "keydown", "keyup", "keypress"]
			fields.push
				type: Checkbox
				name: k
				text: k

			Events.listen
				node: node
				type: k
				instance: @
				capture: true
				call: (ev) =>
					if data.listen[ev.getType()]
						@flash(node)
						@log(ev.dump())
					return

		tmpl.map.pointer_events.before(Demo.dividerLabel("pointer events").DOM)

		tmpl.append(new Form(
			maximize: false
			fields: fields
			data: data.listen
		).start(), "pointer_events")

		tmpl

	undisplay: ->
		Events.ignore(instance: @)

	flashQueue: []

	flash: (node) ->
		@flashQueue.push(node)
		if @flashQueue.length == 1
			@flashNext()

	flashNext: ->
		if @flashQueue.length == 0
			return

		node = @flashQueue[0]
		node.classList.add("flash-ring")
		CUI.setTimeout
			ms: 200
			call: =>
				@flashQueue.shift()
				node.classList.remove("flash-ring")
				@flashNext()
		return



Demo.register(new EventsDemo())

CUI.ready =>
	Events.registerEvent
		type: "flash-ring"
		bubble: true
