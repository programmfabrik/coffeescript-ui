class BorderLayoutDemo extends Demo
	display: ->
		opts =
			class: "cui-border-layout-demo"
			east:
				flexHandle: {}
				content: "East"
			west:
				flexHandle: {}
				content: "West"
			center:
				content: "Center"
			south:
				flexHandle: {}
				content: [
					"South"
					FlexHandle.getStretchButton
						direction: "north"
				]
			north:
				flexHandle: {}
				content: [
					"North"
				,
					FlexHandle.getStretchButton
						direction: "south"
				,
					new Label
						text: "North Label"
				]


		opts_inner =
			class: "border-layout-demo-inner"
			east:
				flexHandle: {}
				content: [
					"East"
				,
					new Label
						text: "Horst Label"
						icon: "bolt"
				]
			west:
				flexHandle: {}
				content: "West"
			center:
				content: "Center"
			north:
				flexHandle: {}
				content: "North"


		@border_layout_inner = new BorderLayout(opts_inner)

		opts.center.content = @border_layout_inner.DOM

		@borderLayout = new BorderLayout(opts)

		flex_handle_west = @border_layout_inner.getFlexHandle("west")

		flex_handle_east = @border_layout_inner.getFlexHandle("east")

		show_hide_west_button = new Button
			text: "West"
			active: flex_handle_west.isShown()
			radio: "hideme"
			onClick: =>
				if not show_hide_west_button.isActive()
					flex_handle_west.hide()
				else
					flex_handle_west.show()

		show_hide_east_button = new Button
			class: "big-button"
			text: "Close East"
			onClick: =>
				if flex_handle_east.isOpen()
					flex_handle_east.close()
					show_hide_east_button.setText("Open East")
				else
					flex_handle_east.open()
					show_hide_east_button.setText("Close East")

		stretch_east_button = FlexHandle.getStretchButton
			flexHandle: flex_handle_east
			direction: "west"
			text: "East"

		stretch_west_button = FlexHandle.getStretchButton
			flexHandle: flex_handle_west
			direction: "east"
			text: "West"


		@border_layout_inner.replace(new Buttonbar(buttons: [
			show_hide_west_button
			show_hide_east_button
			stretch_east_button
			stretch_west_button
		]), "north")
		@annotate()

		@borderLayout.DOM

	annotate: ->
		for d in @borderLayout.DOM.find("[cui-flex-handle]")
			$d = $(d)
			t = []
			for k in [
				"min-width"
				"width"
				"max-width"
				"min-height"
				"height"
				"max-height"
			]
				t.push("#{k}: #{$d.css(k)}")

			$d.prop(title: t.join("\n"))

	undisplay: ->
		@borderLayout.destroy()

Demo.register(new BorderLayoutDemo())