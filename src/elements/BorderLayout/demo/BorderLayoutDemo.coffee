class BorderLayoutDemo extends Demo
	display: ->
		opts =
			class: "cui-border-layout-demo"
			east:
				flexHandle: {}
				content: new Label(text: "East")
			west:
				flexHandle: {}
				content: new Label(text: "West")
			center:
				content: new Label(text: "Center")
			south:
				flexHandle:
					label:
						text: "South"
				content: [
					new Label(text: "South")
					FlexHandle.getStretchButton
						direction: "north"
				]
			north:
				flexHandle: {}
				content: [
					new Label(text: "North")
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
				flexHandle:
					label:
						text: "East"
				content: [
					new Label(text: "East")
				,
					new Label
						text: "Horst Label"
						icon: "bolt"
				]
			west:
				flexHandle: {}
				content: new Label(text: "West")
			center:
				content: new Label(text: "Center")
			north:
				flexHandle: {}
				content: new Label(text: "North")


		@border_layout_inner = new BorderLayout(opts_inner)

		opts.center.content = @border_layout_inner.DOM

		@borderLayout = new BorderLayout(opts)

		flex_handle_south = @borderLayout.getFlexHandle("south")

		flex_handle_west = @border_layout_inner.getFlexHandle("west")

		flex_handle_east = @border_layout_inner.getFlexHandle("east")

		show_hide_west_button = new Button
			text: "West"
			switch: true
			active: flex_handle_west.isShown()
			onClick: =>
				if not show_hide_west_button.isActive()
					flex_handle_west.close()
					flex_handle_west.hide()
				else
					flex_handle_west.open()
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


		show_hide_south_button = new Button
			class: "big-button"
			text: "Close South"
			onClick: =>
				if flex_handle_south.isOpen()
					flex_handle_south.close()
					show_hide_south_button.setText("Open South")
				else
					flex_handle_south.open()
					show_hide_south_button.setText("Close South")


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
			show_hide_south_button
			stretch_east_button
			stretch_west_button
		]), "north")

		@annotate()

		[
			Demo.dividerLabel("borderlayout")
		,
			@borderLayout
		]

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