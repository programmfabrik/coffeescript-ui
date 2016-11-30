class ButtonDemo extends Demo

	getName: () ->
		"Buttons"

	display: ->

		@__demo_table = new DemoTable("cui-button-demo")
		@createButtonDemo()
		@createProgressMeterExample()
		@createButtonbarDemo()
		@__demo_table.table


	__demo_table: null
	__table: null
	__buttons: []
	__toggle_enabled_state_button: null


	__setAllButtonsEnabledState: (enable) ->
		for button in @__buttons
			if @__toggle_enabled_state_button != button
				button.setEnabled(enable)

	__enableAllButtons:  ->
		@__setAllButtonsEnabledState(true)
		if @__toggle_enabled_state_button
			@__toggle_enabled_state_button.setText("Disable All Buttons")

	__disableAllButtons:  ->
		@__setAllButtonsEnabledState(false)
		if @__toggle_enabled_state_button
			@__toggle_enabled_state_button.setText("Enable All Buttons")


	__addLabel: (description, label) ->
		@__demo_table.addExample( description, label.DOM )


	__addButton: (kind, opts={}) ->
		# $pre().text(dump(opts))
		button = new Button(opts)
		@__demo_table.addExample(kind, button.DOM)
		@__buttons.push(button)
		return button


	__addDivider: (text) ->
		@__demo_table.addDivider(text)


	createButtonDemo: ->


		# ----------------- Buttons ---------------------------

		@__addDivider("button states")

		@__toggle_enabled_state_button = @__addButton("Disable/Enable Buttons",
			switch: true
			active: true
			text: "Disable All Buttons"
			onActivate: =>
				@__enableAllButtons()
			onDeactivate: =>
				@__disableAllButtons()
		)


		@__addDivider("button icons")

		@__addButton( "Icon Left",
				icon_left: new Icon(class: "fa-trash-o")
				text: "Trash"
				onClick: (evt,button) =>
					@log("Clicked: "+button.getText())

		)

		@__addButton( 	"Icon (with Tooltip)",
			icon_left: "trash"
			tooltip:
				text: "I am Trashy"
			text: "Trash"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton "Icons Left+Right",
			icon_left: new Icon(class: "fa-bolt")
			icon_right: new Icon(class: "fa-filter")
			text: "Caret"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addButton "With Picture & Content",
			left: $div("cui-button-demo-pic")
			center: $span().html("<big>Ce</big><b>n</b>t<i>e</i>r")
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())


		@__addDivider("button functionalities")

		btn = new ButtonHref
			text: "Open Google"
			target: "_blank"
			href: "http://www.google.com"
		@__buttons.push(btn)

		@__demo_table.addExample("ButtonHref", btn.DOM)

		@__addButton "With Small Tooltip & Confirm",
			icon_left: new Icon(class: "fa-lightbulb-o")
			left: true
			confirm_on_click: "Are you sure?"
			tooltip:
				text: "Small but beautiful!"

		@__addButton "With Huge Tooltip",
			text: "Hover to show a tooltip"
			tooltip:
				text: @getBlindText()
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addButton("Switch",
			switch: true
			text: "On/Off"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton "Button with text ellipsis",
			class: "cui-button-demo-limit-width"
			text: "Button with text ellipsis"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())


		@__addButton("Counter (use Shift)",
			text: "1"
			onClick: (ev, btn) ->
				if ev.shiftKey()
					inc = -1
				else
					inc = 1
				btn.setText(parseInt(btn.getText())+inc)
		)

		buttons = [
			new Button(
				radio: "group",
				text: "1",
				active: true,
				disabled: true
				)

			#group2
			new Button
				radio: "group"
				icon_inactive: new Icon(class: "fa-bomb")
				icon_active: new Icon(class: "fa-bullhorn")
				group: "group2"
				text: "2"

			#no group
			new Button(radio: "group", text: "3")

			new Button(
				radio: "group"
				group: "group2"
				text: "4+5"
				onClick: (ev, btn) ->
					b = btn.getRadioButtons()[4]
					if b.isHidden()
						btn.setText("4-5")
						b.show()
					else
						btn.setText("4+5")
						b.hide()
			)

			#group single
			new Button(radio: "group", group: "single", text: "5", hidden: true)

			#group2
			new Button(
				radio: "group"
				group: "group2"
				text: "1?"
				onActivate: (btn) ->
					btn.getRadioButtons()[0].enable()
				onDeactivate: (btn) ->
					btn.getRadioButtons()[0].disable()
			)
		]



		@__addButton("With Menu (try +Alt)",
			menu:
				active_item_idx: 0
				onHide: ->
					CUI.debug "playground hides menu"
				onShow: ->
					CUI.debug "playground shows menu"
				onClick: (ev, menu, item, idx) =>
					@log( "##{idx} - #{item.text} ")
				items: (ev) ->
					if ev and ev.altKey
						CUI.debug "HOOOORST"
					items = [
						text: "Starter"
						icon_right: new Icon(class: "fa-angle-double-down")
						menu:
							items: [
								text: "Soup"
							,
								text: "Bruscetta"
							]
					,
						text: "A really really really long Main Course"
						appearance: "important"
					,
						divider: true
					,
						text: "Desert"
						menu_on_hover: true
						menu:
							placement: "es"
							items: [
								text: "Sweet"
								onClick: =>
									alert "Strawberries"
							,
								text: "Sour"
								onClick: =>
									alert "Lemon Zest"
							]
					,
						text: "Unavailable"
						disabled: true
					]
					if ev and ev.altKey
						items.push
							divider: true
						,
							text: "The really good stuff was hidden..."
					items
			text: "What's for Dinner?"
		)


		@__addDivider("Button option: appearance ")

		@__addButton("appearance: \"normal\"",
			icon_left: new Icon(class: "fa-bank")
			appearance: "normal"
			text: "Normal Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance: \"flat\"",
			icon_left: new Icon(class: "fa-bank")
			appearance: "flat"
			text: "Flat Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance: \"link\"",
			icon_left: new Icon(class: "fa-bank")
			appearance: "link"
			text: "Link Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance: \"important\"",
			icon_left: new Icon(class: "fa-bank")
			appearance: "important"
			text: "Important Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addDivider("Button option: size ")

		@__addButton("size: \"normal\"",
			icon_left: new Icon(class: "fa-bank")
			size: "normal"
			text: "Normal Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"mini\"",
			icon_left: new Icon(class: "fa-bank")
			size: "mini"
			text: "Mini Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"big\"",
			icon_left: new Icon(class: "fa-bank")
			size: "big"
			text: "Big Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"bigger\"",
			icon_left: new Icon(class: "fa-bank")
			size: "bigger"
			text: "Bigger Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addDivider("Buttons with mixed options")
		@__addButton("size: \"big\", appearance: \"link\" ",
			icon_left: new Icon(class: "fa-bank")
			size: "big"
			appearance: "link"
			text: "Big Link Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)


		@__addDivider("Custom css classes")

		@__addButton "Centered, fixed width",
			text: "Centered, fixed width"
			class: "cui-button-demo-centered-fixed-width"
			icon_left: new Icon(class: "fa-bolt")
			icon_right: new Icon(class: "fa-filter")
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addButton "Custom color class",
			text: "My Colors A"
			size: "big"
			class: "cui-button-demo-custom-colors-a"
			switch: true
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addButton "Custom color class",
			text: "My Colors B"
			size: "big"
			class: "cui-button-demo-custom-colors-b"
			switch: true
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addButton "Custom color class",
			text: "My Colors C"
			size: "big"
			class: "cui-button-demo-custom-colors-c"
			switch: true
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addDivider("progress meter")



	createProgressMeterExample: ->
		@
		progress_meter = new ProgressMeter
			class: "cui-progress-meter-demo"
			onUpdate: (pm) ->
				console.info "update on progress meter", pm.getState()

				if pm.getState() == "spinning"
					spin_btn?.activate()

				if pm.getState() == "waiting"
					wait_btn?.activate()
				return

		stepMeter = (startover=false) ->
			state = progress_meter.getState()
			console.debug "stepMeter", startover, state
			next_timeout_ms = 20
			if Math.floor(state) == 100
				#finished 'loading'
				state = "spinning"
			else if startover
				#begin 'loading' by setting state as number
				state = 0
			else if state != "waiting" and state != "spinning"
				#means that state is now a number that we use to count the progress!
				next_timeout_ms = 5
				state = state + 0.1

			progress_meter.setState(state)
			if state == "spinning"
				CUI.setTimeout
					ms: 1000
					call: =>
						progress_meter.setState("waiting")
				return

			CUI.setTimeout(stepMeter, next_timeout_ms)

		parent_meter_container = $div("cui-progress-meter-demo-container").append(progress_meter.DOM)

		wait_btn = new Button
			text: "Waiting"
			active: true
			group: "a"
			radio: "progress"
			onClick: =>
				progress_meter.setState("waiting")


		spin_btn = new Button
			text: "Spinning"
			group: "a"
			radio: "progress"
			onClick: =>
				progress_meter.setState("spinning")

		controls = [
			new Buttonbar
				buttons: [
					wait_btn
				,
					new Button
						text: "Go!"
						group: "a"
						radio: "progress"
						onClick: =>
							stepMeter(true)
				,
					spin_btn
				]
			.DOM
		]

		@__demo_table.addExample( "Progress Meter", parent_meter_container, controls )


	createButtonbarDemo: ->


		@__addDivider("buttonbars")

		buttons = [
			new Button(
				radio: "group",
				text: "1",
				active: true,
				disabled: true
				)

			#group2
			new Button
				radio: "group"
				icon_inactive: new Icon(class: "fa-bomb")
				icon_active: new Icon(class: "fa-bullhorn")
				group: "group2"
				text: "2"

			#no group
			new Button(radio: "group", text: "3")

			new Button(
				radio: "group"
				group: "group2"
				text: "4+5"
				onClick: (ev, btn) ->
					b = btn.getRadioButtons()[4]
					if b.isHidden()
						btn.setText("4-5")
						b.show()
					else
						btn.setText("4+5")
						b.hide()
			)

			#group single
			new Button(radio: "group", group: "single", text: "5", hidden: true)

			#group2
			new Button(
				radio: "group"
				group: "group2"
				text: "1?"
				onActivate: (btn) ->
					btn.getRadioButtons()[0].enable()
				onDeactivate: (btn) ->
					btn.getRadioButtons()[0].disable()
			)
		]

		@__demo_table.addExample(
			"Radio",
			new Buttonbar(
				buttons: buttons
			).DOM
		)

		c = (ev, btn) ->
			btn.hide()

		buttons = [
			new Button(text: "Tick", group: "ttt", onClick: c)
			new Button(text: "Trick", group: "ttt", onClick: c)
			new Button(text: "Track", group: "ttt", onClick: c)
			new Button(text: "Horst", group: "ttt2", onClick: c)
			new Button(text: "Torsten", group: "ttt2", onClick: c)
			new Button(text: "Henk", group: "ttt2", onClick: c)
		]

		bb = new Buttonbar(
			tooltip:
				text: "Keep clickin"
			buttons: buttons
		)

		rb = new Button
			text: "reset"
			onClick: ->
				for btn in bb._buttons
					btn.show()

		@__demo_table.addExample("Buttonbar FAILS needs last-visible-child-info", [	bb.DOM,	rb.DOM ])

		@__addDivider("Buttonbar with mixed controls")

		bb = new Buttonbar(
			tooltip:
				text: "mixed buttons and labels"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Label(text: "Label")
				new Button(text: "groupB", group: "groupB")
			]
		)

		select = new Select
			empty_text: "- Pick an Option -"
			name: "select"
			group: "groupB"
			data:
				view_select: 0 # set view to the first in list
				view_data:
					"result-standard":
						variant_texts: 1


			options: -> [
				text: "Banana GroupB"
			,
				text: "Republic"
				value: "Republik"
			,
				divider: true
			,
				text: "Orange"
			]
		select.start()

		bb2 = new Buttonbar(
			tooltip:
				text: "mixed buttons and selects"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				select
				new Button(text: "groupB", group: "groupB")
			]
		)


		@__demo_table.addExample("Buttonbar", [	bb.DOM ])
		@__demo_table.addExample("Buttonbar", [	bb2.DOM ])

		@__addDivider("Buttonbar in different grouping Variations")

		bb = new Buttonbar(
			tooltip:
				text: "example 1"
			buttons: [
					new Button(text: "groupA", group: "groupA")
					new Button(text: "groupB-active", group: "groupB", active: true )
					new Button(text: "groupB", group: "groupB")
				]
		)

		@__demo_table.addExample("example 1", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )

		bb = new Buttonbar(
			tooltip:
				text: "example 2"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupB", group: "groupB")
			]
		)

		@__demo_table.addExample("example 2", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )

		bb = new Buttonbar(
			tooltip:
				text: "example 3"
			buttons: [
				new Button(text: "no group"  )
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupB", group: "groupB")
			]
		)

		@__demo_table.addExample("example 3", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )

		bb = new Buttonbar(
			tooltip:
				text: "example 4"
			buttons: [
				new Button(text: "no group"  )
				new Button(text: "groupA", group: "groupA")
				new Button(text: "no group")
			]
		)


		@__demo_table.addExample("example 4", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )

		bb = new Buttonbar(
			tooltip:
				text: "example 5"
			buttons: [
				new Button(text: "no group"  )
				new Button(text: "no group", group: "no group")
				new Button(text: "no group")
			]
		)

		@__demo_table.addExample("example 5", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )

		bb = new Buttonbar(
			tooltip:
				text: "example 6"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
			]
		)

		@__demo_table.addExample("example 6", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )

		@__addDivider("Using Styles on Buttons inside buttonbar")

		bb = new Buttonbar(
			tooltip:
				text: "example 1"
			buttons: [
				new Button(
					text: "groupA", group: "groupA",
					class: "cui-dialog"
				)
				new Button(
					text: "groupB", group: "groupB",
					class: "cui-dialog"
				)
				new Button(
					text: "groupB", group: "groupB",
					class: "cui-dialog"
				)
			]
		)

		@__demo_table.addExample("example 1", [ $div().append($div("cui-buttonbar-demo-margin-testers")).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers"))] )
		@




Demo.register(new ButtonDemo())