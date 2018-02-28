###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.Template.loadTemplateText(require('./StickyHeaderDemo.html'));

class Demo.StickyHeaderDemo extends Demo
	display: ->

		CUI.Events.listen
			type: "keydown"
			node: document
			call: (ev) =>
				delta = 4
				# console.debug(ev.keyCode(), ev.ctrlKey(), ev.altKey(), ev.shiftKey())
				if ev.ctrlKey()
					delta--
				if ev.altKey()
					delta--
				if ev.shiftKey()
					delta--
				if delta < 4
					switch ev.keyCode()
						when 40
							@__pane.center().scrollTop += delta
						when 38
							@__pane.center().scrollTop -= delta
				else
					console.debug("no modifier")
				return false


		draw_pane = (level) =>
			@__pane.empty("center")
			shc = new CUI.StickyHeaderControl(element: @__pane.center())

			header_c = 0
			subheader_c = 0
			subsubheader_c = 0
			for i in [0...1000]
				if i%36 == 0
					header_c++
					sh = new CUI.StickyHeader
						control: shc
						text: "Header #{header_c}"
					subheader_c = 0
					subsubheader_c = 0
					CUI.dom.append(@__pane.center(), sh.DOM)

				if i%12 == 0 and level > 0
					subheader_c++
					sh = new CUI.StickyHeader
						control: shc
						level: 1
						text: "Sub-Header #{header_c}.#{subheader_c}"
					CUI.dom.append(@__pane.center(), sh.DOM)
					subsubheader_c = 0

				if (i+1)%4 == 0 and level > 1
					subsubheader_c++
					sh = new CUI.StickyHeader
						control: shc
						level: 2
						text: "Sub-Sub-Header #{header_c}.#{subheader_c}.#{subsubheader_c}"
					CUI.dom.append(@__pane.center(), sh.DOM)

				@__pane.append(new CUI.Label(text: "Row: #{i}"), "center")
			shc.position()


		pane_toolbar = new CUI.PaneToolbar
			left:
				content:
					new CUI.Label
						text:"Level:"
			right:
				content:
					new CUI.Label
						text: "Use CTRL/SHIFT/ALT + Cursor UP/DOWN for finer scrolling."

		@__pane = new CUI.Pane
			class: "cui-sticky-header-demo-pane"
			top:
				content:
					pane_toolbar
			center:
				content:
					new CUI.Label
						text:"Choose sticky header depth"

		buttonbar = new CUI.Buttonbar
			buttons: [
				group: "level"
				text: "0"
				active: true
				radio: "level"
				onActivate: ->
					draw_pane(0)
			,
				group: "level"
				radio: "level"
				text: "1"
				onActivate: ->
					draw_pane(1)
			,
				group: "level"
				radio: "level"
				text: "2"
				onActivate: ->
					draw_pane(2)
			]

		console.debug "adding buttonbar:", buttonbar
		pane_toolbar.append(buttonbar.DOM,"left")

		@__pane.DOM

	undisplay: ->



Demo.register(new Demo.StickyHeaderDemo())