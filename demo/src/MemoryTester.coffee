class MemoryTester extends Demo

	display: ->
		@vl = new VerticalLayout(top: {})
		buttons = [
			@getButton("Template")
			@getButton("SimplePane", 200)
			@getButton("Layer", 1)
			@getButton("Tooltip")
			@getButton("TooltipCreate", 1)
			@getButton("DOMCreate")
		]

		$(document.body).on "click", ".cui-vertical-layout-top", (ev) =>
			CUI.debug "filtered", ev.target, ev.currentTarget

		$(document.body).on "click", (ev) =>
			CUI.debug "not filtered", ev.target, ev.currentTarget

		Events.listen
			type: "click"
			node: document.body
			call: (ev) =>
				CUI.debug "CUI not filtered", ev.getTarget(), ev.getCurrentTarget()

		Events.listen
			type: "click"
			node: document.body
			selector: ".cui-vertical-layout-top"
			call: (ev) =>
				CUI.debug "CUI filtered", ev.getTarget(), ev.getCurrentTarget()


		@vl.append(new Buttonbar(buttons: buttons), "top")
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

			if isPromise(ret)
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
		btn = new Button
			text: "#{name} (#{count}x)"
			_test: "Template"
			onClick: =>
				@runTest(btn, name, count)
				.done =>
					@vl.empty("center")
		@initTest(btn, name, count)
		btn

	testTemplate: (i) ->
		tl = new Template
			name: "memory-tester"
			map:
				txt: ".txt"

		tl.replace($text("Template Run:"+(i+1)), "txt")
		tl

	# create DOM nodes
	testDOMCreate: (i) ->
		d = $div("dom-node-#{i}")
		document.body.appendChild(d[0])
		d.detach()
		CUI.debug "creating dom node", i



	testSimplePane: (i) ->
		local = new VerticalLayout() #

		sp = new SimplePane
			header_left: new Label(text: "Simple Pane")
			# content: new SimplePane
			# 	header_left: new Label(text: "Inner Pain")
			# 	footer_right: new Label(text: "Outer Pain")
			footer_right: new Label(text: "Run "+i)
		sp

	initTooltip: (i) ->
		@__tooltip = new Tooltip
			element: @vl
			on_hover: false
			text: =>
				"Horst"


	testLayer: (i, tooltip = @__tooltip) ->
		l = new Layer
			element: $(document.body)
			placement: "c"

		l.append($text("horst"))
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
		tooltip = new Tooltip
			element: @vl
			on_hover: false
			text: =>
				"Created Tooltip"

		@testTooltip(null, tooltip)
		.done =>
			CUI.debug "destroying tooltip"
			tooltip.destroy()


	runSimpleTemplate: (txt) ->

class MemTest extends DOM
	readOpts: ->
		super()
		d = $div()
		# DOM.setElement(d, @, false)
		@registerDOMElement(d)



Demo.register(new MemoryTester())