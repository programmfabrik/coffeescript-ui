###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.MemoryTester extends Demo
	getGroup: ->
		"Test"

	display: ->
		@vl = new CUI.VerticalLayout(top: {})
		buttons = [
			@getButton("Template")
			@getButton("SimplePane", 200)
			@getButton("Layer", 1)
			@getButton("Tooltip")
			@getButton("TooltipCreate", 1)
			@getButton("DOMCreate")
		]

		$(document.body).on "click", ".cui-vertical-layout-top", (ev) =>
			console.debug "filtered", ev.target, ev.currentTarget

		$(document.body).on "click", (ev) =>
			console.debug "not filtered", ev.target, ev.currentTarget

		CUI.Events.listen
			type: "click"
			node: document.body
			call: (ev) =>
				console.debug "CUI not filtered", ev.getTarget(), ev.getCurrentTarget()

		CUI.Events.listen
			type: "click"
			node: document.body
			selector: ".cui-vertical-layout-top"
			call: (ev) =>
				console.debug "CUI filtered", ev.getTarget(), ev.getCurrentTarget()


		@vl.append(new CUI.Buttonbar(buttons: buttons), "top")
		@vl


	runTest: (btn, name, count) ->
		dfr = new CUI.Deferred()
		i = 0
		next_i = =>
			if i == count
				# btn.setText("#{name} (#{i}x)")
				dfr.resolve()
				return

			# btn.setText("#{name} (#{i})")
			fill = (content) =>
				@vl.replace(content, "center")

				CUI.setTimeout
					call: =>
						i = i+1
						next_i()
					ms: 10

			ret = @["test#{name}"](i)

			if CUI.util.isPromise(ret)
				ret.done (content) =>
					fill(content)
			else
				fill(ret)

		next_i()
		dfr.promise()

	initTest: (btn, name, count) ->
		@["init#{name}"]?(count)
		@

	getButton: (name, count=100) ->
		btn = new CUI.Button
			text: "#{name} (#{count}x)"
			_test: "Template"
			onClick: =>
				@runTest(btn, name, count)
				.done =>
					@vl.empty("center")
		@initTest(btn, name, count)
		btn

	testTemplate: (i) ->
		tl = new CUI.Template
			name: "memory-tester"
			map:
				txt: ".txt"

		tl.replace(CUI.dom.text("Template Run:"+(i+1)), "txt")
		tl

	# create DOM nodes
	testDOMCreate: (i) ->
		d = CUI.dom.div("dom-node-#{i}")
		document.body.appendChild(d[0])
		CUI.dom.remove(d)
		console.debug "creating dom node", i



	testSimplePane: (i) ->
		local = new CUI.VerticalLayout() #

		sp = new CUI.SimplePane
			header_left: new CUI.Label(text: "Simple Pane")
			# content: new CUI.SimplePane
			# 	header_left: new CUI.Label(text: "Inner Pain")
			# 	footer_right: new CUI.Label(text: "Outer Pain")
			footer_right: new CUI.Label(text: "Run "+i)
		sp

	initTooltip: (i) ->
		@__tooltip = new CUI.Tooltip
			element: @vl
			on_hover: false
			text: =>
				"Horst"


	testLayer: (i, tooltip = @__tooltip) ->
		l = new CUI.Layer
			element: document.body
			placement: "c"

		CUI.dom.append(l, CUI.dom.text("horst"))
		l.show()
		CUI.setTimeout
			ms: 2
			call: =>
				l.destroy()
				l = null
				dfr.resolve()

		dfr = new CUI.Deferred()
		dfr.promise()


	testTooltip: (i, tooltip = @__tooltip) ->

		tooltip.show()
		CUI.setTimeout
			ms: 2
			call: =>
				tooltip.hide()
				dfr.resolve()

		dfr = new CUI.Deferred()
		dfr.promise()

	testTooltipCreate: (i) ->
		tooltip = new CUI.Tooltip
			element: @vl
			on_hover: false
			text: =>
				"Created Tooltip"

		@testTooltip(null, tooltip)
		.done =>
			console.debug "destroying tooltip"
			tooltip.destroy()


	runSimpleTemplate: (txt) ->

class Demo.MemTest extends CUI.DOMElement
	readOpts: ->
		super()
		d = CUI.dom.div()
		# DOM.setElement(d, @, false)
		@registerDOMElement(d)


# this needs fixing, so disable it for now
# Demo.register(new MemoryTester())