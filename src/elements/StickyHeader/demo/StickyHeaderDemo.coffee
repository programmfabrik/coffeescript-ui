class StickyHeaderDemo extends Demo
	display: ->

		Events.listen
			type: "keydown"
			node: document
			call: (ev) =>
				delta = 4
				CUI.debug(ev.keyCode(), ev.ctrlKey(), ev.altKey(), ev.shiftKey())
				if ev.ctrlKey()
					delta--
				if ev.altKey()
					delta--
				if ev.shiftKey()
					delta--
				if delta < 4
					switch ev.keyCode()
						when 40
							CUI.debug "delta:",delta
							@__pane.center()[0].scrollTop += delta
						when 38
							@__pane.center()[0].scrollTop -= delta
				else
					CUI.debug("no modifier")
				return false


		draw_pane = (level) =>
			@__pane.center().empty()
			shc = new StickyHeaderControl(element: @__pane.center())

			header_c = 0
			subheader_c = 0
			subsubheader_c = 0
			for i in [0...1000]

				if i%36 == 0
					header_c++
					sh = new StickyHeader
						control: shc
						text: "Header #{header_c}"
					subheader_c = 0
					subsubheader_c = 0
					sh.DOM.appendTo(@__pane.center())

				if i%12 == 0 and level > 0
					subheader_c++
					sh = new StickyHeader
						control: shc
						level: 1
						text: "Sub-Header #{header_c}.#{subheader_c}"
					sh.DOM.appendTo(@__pane.center())
					subsubheader_c = 0

				if (i+1)%4 == 0 and level > 1
					subsubheader_c++
					sh = new StickyHeader
						control: shc
						level: 2
						text: "Sub-Sub-Header #{header_c}.#{subheader_c}.#{subsubheader_c}"
					sh.DOM.appendTo(@__pane.center())

				@__pane.center().append($div().text("Row: #{i}"))


		pane_toolbar = new PaneToolbar
			left:
				content:
					new Label
						text:"Level:"
			right:
				content:
					new Label
						text: "Use CTRL/SHIFT/ALT + Cursor UP/DOWN for finer scrolling."

		@__pane = new Pane
			class: "cui-sticky-header-demo-pane"
			top:
				content:
					pane_toolbar
			center:
				content:
					new Label
						text:"Choose sticky header depth"

		buttonbar = new Buttonbar
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

		CUI.debug "adding buttonbar:", buttonbar
		pane_toolbar.append(buttonbar.DOM,"left")

		@__pane.DOM

	undisplay: ->



Demo.register(new StickyHeaderDemo())