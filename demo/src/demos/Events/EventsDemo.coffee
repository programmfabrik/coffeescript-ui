###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./EventsDemo.html'));

class Demo.EventsDemo extends Demo
	getGroup: ->
		"Core"

	display: ->
		display = []

		tmpl = new CUI.Template
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

		console.debug "body: ", document.body

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
				node: tmpl.map["ring"+i]

		for k, v of element_by_node
			do (k, v) =>
				CUI.Events.listen
					type: "click"
					instance: @
					node: tmpl.map[k]
					call: (ev) =>
						console.debug "clicked on ", k, v
						data.node = k
						mark_node_ring()
						ev.stopPropagation()


		mark_node_ring = =>
			node = tmpl.map[data.node]
			CUI.dom.matchSelector(document, ".node-ring")[0]?.classList.remove("node-ring")
			CUI.dom.addClass(node, "node-ring")

		mark_node_ring()

		f = new CUI.Form
			data: data
			horizontal: true
			fields: [
				type: CUI.Checkbox
				name: "bubble"
				text: "Bubble"
			,
				type: CUI.Checkbox
				name: "exclude_self"
				text: "Exclude Self"
			,
				type: CUI.Checkbox
				name: "sink"
				text: "Sink"
			,
				type: CUI.Checkbox
				name: "listen_to_capture"
				text: "Listen to Capture"
			,
				type: CUI.FormButton
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

					console.debug "trigger", opts


					CUI.Events.trigger(opts)
			]
		.start()

		for capture in [true, false]
			do (capture) =>
				CUI.Events.listen
					type: "flash-ring"
					node: window
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "window ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.window)

				CUI.Events.listen
					type: "flash-ring"
					node: document
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "document ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.document)

				CUI.Events.listen
					type: "flash-ring"
					node: document.documentElement
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "documentElement ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.document_element)


				CUI.Events.listen
					type: "flash-ring"
					node: document.body
					instance: @
					capture: capture
					call: (ev) =>
						if capture and not data.listen_to_capture
							return
						log = "body ("+ev.getPhase()+")"
						@log(log)
						@flash(tmpl.map.body)

		for ring in [0..7]
			do (ring) =>
				node = tmpl.map["ring"+ring]
				CUI.Events.listen
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

				CUI.Events.listen
					type: "flash-ring"
					instance: @
					node: node
					call: (ev) =>
						@flash(node)
						log = "flash ring ("+ev.getPhase()+"): "+ring
						@log(log)

		tmpl.append(Demo.dividerLabel("events playground"), "buttons")

		tmpl.append(f, "buttons")

		node = tmpl.map.pointer_events

		data.listen = mousedown: true
		fields = []
		for k, idx in [
			"mousedown"
			"wheel"
			"mouseup"
			"click"
			"dblclick"
			"keydown"
			"keyup"
			"keypress"
			"touchstart"
			"touchend"
			"touchmove"
			"touchcancel"
			"touchforchange"

		]
			fields.push
				type: CUI.Checkbox
				name: k
				text: k

			CUI.Events.listen
				node: node
				type: k
				instance: @
				call: (ev) =>
					if ev.getTarget() != node
						return

					if ev.getType().startsWith("key")
						ev.preventDefault()
						ev.stopPropagation()

					if data.listen[ev.getType()]
						@flash(node)
						@log(ev.dump())
					return

		tmpl.map.pointer_events.before(Demo.dividerLabel("pointer events").DOM)

		tmpl.append(new CUI.Form(
			class: "cui-events-demo-form"
			maximize: false
			fields: fields
			data: data.listen
		).start(), "pointer_events")

		tmpl

	undisplay: ->
		CUI.Events.ignore(instance: @)

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



Demo.register(new Demo.EventsDemo())

CUI.ready =>
	CUI.Events.registerEvent
		type: "flash-ring"
		bubble: true
