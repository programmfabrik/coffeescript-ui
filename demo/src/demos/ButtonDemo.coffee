###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.ButtonDemo extends Demo

	getName: () ->
		"Buttons"

	display: ->

		@__demo_table = new Demo.DemoTable("cui-button-demo")
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
		# CUI.dom.pre().text(CUI.util.dump(opts))
		button = new CUI.Button(opts)
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
				icon_left: new CUI.Icon(class: "fa-trash-o")
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
			icon_left: new CUI.Icon(class: "fa-bolt")
			icon_right: new CUI.Icon(class: "fa-filter")
			text: "Caret"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		span = CUI.dom.span()
		span.innerHTML = "<big>Ce</big><b>n</b>t<i>e</i>r"
		@__addButton "With Picture & Content",
			left: CUI.dom.div("cui-button-demo-pic")
			center: span
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())


		@__addDivider("button functionalities")

		btn = new CUI.ButtonHref
			text: "Open Google"
			target: "_blank"
			href: "http://www.google.com"
		@__buttons.push(btn)

		@__demo_table.addExample("ButtonHref", btn.DOM)

		@__addButton "With Small Tooltip & Confirm",
			icon_left: new CUI.Icon(class: "fa-lightbulb-o")
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
			new CUI.Button(
				radio: "group",
				text: "1",
				active: true,
				disabled: true
				)

			#group2
			new CUI.Button
				radio: "group"
				icon_inactive: new CUI.Icon(class: "fa-bomb")
				icon_active: new CUI.Icon(class: "fa-bullhorn")
				group: "group2"
				text: "2"

			#no group
			new CUI.Button(radio: "group", text: "3")

			new CUI.Button(
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
			new CUI.Button(radio: "group", group: "single", text: "5", hidden: true)

			#group2
			new CUI.Button(
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
					console.debug "playground hides menu"
				onShow: ->
					console.debug "playground shows menu"
				onClick: (ev, menu, item, idx) =>
					@log( "##{idx} - #{item.text} ")
				items: (ev) ->
					if ev and ev.altKey
						console.debug "HOOOORST"
					items = [
						text: "Starter"
						icon_right: new CUI.Icon(class: "fa-angle-double-down")
						menu:
							items: [
								text: "Soup"
							,
								text: "Bruscetta"
							]
					,
						text: "A really really really long Main Course and even longer and longer"
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
			icon_left: new CUI.Icon(class: "fa-bank")
			appearance: "normal"
			text: "Normal Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance: \"flat\"",
			icon_left: new CUI.Icon(class: "fa-bank")
			appearance: "flat"
			text: "Flat Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance: \"link\"",
			icon_left: new CUI.Icon(class: "fa-bank")
			appearance: "link"
			text: "Link Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance: \"link\"",
			icon_right: new CUI.Icon(class: "fa-plus")
			appearance: "link"
			text: "Link Button Plus"
		)

		@__addButton("appearance: \"important\" (OBSOLETE ???)",
			icon_left: new CUI.Icon(class: "fa-bank")
			appearance: "important"
			text: "Important Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("primary button",
			primary: true
			text: "Primary Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("flat primary button (tbd, don't use in production)",
			primary: true
			appearance: "flat"
			text: "Flat Primary Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addDivider("Button option: size ")

		@__addButton("size: \"normal\"",
			icon_left: new CUI.Icon(class: "fa-bank")
			size: "normal"
			text: "Normal Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"mini\"",
			icon_left: new CUI.Icon(class: "fa-bank")
			size: "mini"
			text: "Mini Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"big\"",
			icon_left: new CUI.Icon(class: "fa-bank")
			size: "big"
			text: "Big Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"bigger\" (OBSOLETE ???)",
			icon_left: new CUI.Icon(class: "fa-bank")
			size: "bigger"
			text: "Bigger Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addDivider("Buttons with mixed options")
		@__addButton("size: \"big\", appearance: \"link\" ",
			icon_left: new CUI.Icon(class: "fa-bank")
			size: "big"
			appearance: "link"
			text: "Big Link Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)


		@__addDivider("Custom css classes OBSOLETE ???")

		@__addButton "Centered, fixed width",
			text: "Centered, fixed width"
			class: "cui-button-demo-centered-fixed-width"
			icon_left: new CUI.Icon(class: "fa-bolt")
			icon_right: new CUI.Icon(class: "fa-filter")
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
		progress_meter = new CUI.ProgressMeter
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

		parent_meter_container = CUI.dom.append(CUI.dom.div("cui-progress-meter-demo-container"), progress_meter.DOM)

		wait_btn = new CUI.Button
			text: "Waiting"
			active: true
			group: "a"
			radio: "progress"
			onClick: =>
				progress_meter.setState("waiting")


		spin_btn = new CUI.Button
			text: "Spinning"
			group: "a"
			radio: "progress"
			onClick: =>
				progress_meter.setState("spinning")

		controls = [
			new CUI.Buttonbar
				buttons: [
					wait_btn
				,
					new CUI.Button
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
			new CUI.Button(
				radio: "group",
				text: "1",
				active: true,
				disabled: true
				)

			#group2
			new CUI.Button
				radio: "group"
				icon_inactive: new CUI.Icon(class: "fa-bomb")
				icon_active: new CUI.Icon(class: "fa-bullhorn")
				group: "group2"
				text: "2"

			#no group
			new CUI.Button(radio: "group", text: "3")

			new CUI.Button(
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
			new CUI.Button(radio: "group", group: "single", text: "5", hidden: true)

			#group2
			new CUI.Button(
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
			new CUI.Buttonbar(
				buttons: buttons
			).DOM
		)

		c = (ev, btn) ->
			btn.hide()

		buttons = [
			new CUI.Button(text: "Tick", group: "ttt", onClick: c)
			new CUI.Button(text: "Trick", group: "ttt", onClick: c)
			new CUI.Button(text: "Track", group: "ttt", onClick: c)
			new CUI.Button(text: "Horst", group: "ttt2", onClick: c)
			new CUI.Button(text: "Torsten", group: "ttt2", onClick: c)
			new CUI.Button(text: "Henk", group: "ttt2", onClick: c)
		]

		bb = new CUI.Buttonbar(
			tooltip:
				text: "Keep clickin"
			buttons: buttons
		)

		rb = new CUI.Button
			text: "reset"
			onClick: ->
				for btn in bb._buttons
					btn.show()

		@__demo_table.addExample("Buttonbar FAILS needs last-visible-child-info", [	bb.DOM,	rb.DOM ])

		@__addDivider("Buttonbar with mixed controls")

		bb = new CUI.Buttonbar(
			tooltip:
				text: "mixed buttons and labels"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Label(text: "Label")
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)

		select = new CUI.Select
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

		bb2 = new CUI.Buttonbar(
			tooltip:
				text: "mixed buttons and selects"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				select
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)


		@__demo_table.addExample("Buttonbar", [	bb.DOM ])
		@__demo_table.addExample("Buttonbar", [	bb2.DOM ])

		@__addDivider("Buttonbar in different grouping Variations")

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 1"
			buttons: [
					new CUI.Button(text: "groupA", group: "groupA")
					new CUI.Button(text: "groupB-active", group: "groupB", active: true )
					new CUI.Button(text: "groupB", group: "groupB")
				]
		)

		@__demo_table.addExample("example 1", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 2"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)

		@__demo_table.addExample("example 2", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 3"
			buttons: [
				new CUI.Button(text: "no group"  )
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)

		@__demo_table.addExample("example 3", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 4"
			buttons: [
				new CUI.Button(text: "no group"  )
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "no group")
			]
		)


		@__demo_table.addExample("example 4", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 5"
			buttons: [
				new CUI.Button(text: "no group"  )
				new CUI.Button(text: "no group", group: "no group")
				new CUI.Button(text: "no group")
			]
		)

		@__demo_table.addExample("example 5", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 6"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
			]
		)
		@__demo_table.addExample("example 6", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			stack: "vertical"
			buttons: [
				new CUI.Button(text: "groupA")
				new CUI.Button(text: "groupA")
				new CUI.Button(text: "groupA")
			]
		)
		@__demo_table.addExample("example 7, vertical stack", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 1 flat"
			buttons: [
				new CUI.Button(text: "1", group: "groupA", appearance: "flat", active: true)
				new CUI.Button(text: "2", group: "groupA", appearance: "flat")
				new CUI.Button(text: "3", group: "groupA", appearance: "flat")
				new CUI.Button(text: "4", group: "groupA", appearance: "flat")
			]
		)

		@__demo_table.addExample("example 1 flat", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 2 flat, no group"
			buttons: [
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-lightbulb-o"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"))
			]
		)
		@__demo_table.addExample("example 2 flat, no group", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 2 flat, with border"
			buttons: [
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-lightbulb-o")
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-cog")
				)
				new CUI.Button(
					text: "Download"
					icon_left: new CUI.Icon(class: "fa-download")
					appearance: "flat"
					bordered: true
				)
				new CUI.Button(
					text: "Hinzufügen"
					icon_left: new CUI.Icon(class: "fa-plus")
					appearance: "flat"
					bordered: true
				)
			]
		)
		@__demo_table.addExample("example 2 flat, with border", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 3 flat, mixed"
			buttons: [
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"))
				new CUI.Button(text: "Eins", group: "groupA", appearance: "flat", bordered: true)
				new CUI.Button(text: "Zwei", group: "groupA", appearance: "flat", bordered: true)
				new CUI.Button(text: "Drei", group: "groupA", appearance: "flat", bordered: true)
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-share"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-refresh"))
			]
		)
		@__demo_table.addExample("example 3 flat, mixed", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			buttons: [
				new CUI.Button(text: "Eins", group: "groupA", appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"), bordered: true)
				new CUI.Button(text: "Zwei", group: "groupA", appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"), bordered: true)
				new CUI.Button(text: "Drei", group: "groupA", appearance: "flat", icon_left: new CUI.Icon(class: "fa-plus"), bordered: true)
				new CUI.Button(text: "Eins", group: "groupB", appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"), bordered: true)
				new CUI.Button(text: "Zwei", group: "groupB", appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"), bordered: true)
				new CUI.Button(text: "Drei", group: "groupB", appearance: "flat", icon_left: new CUI.Icon(class: "fa-plus"), bordered: true)
			]
		)
		@__demo_table.addExample("example 3 flat, two group with icon", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			buttons: [
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
					text: "Nested"
				)
			]
		)
		@__demo_table.addExample("example 4 flat, icon and optional text", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			buttons: [
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
					size: "mini"
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
					size: "mini",
					text: "Nested"
				)
			]
		)
		@__demo_table.addExample("example 4 flat, icon and optional text, mini", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		bb = new CUI.Buttonbar(
			stack: "vertical"
			buttons: [
				new CUI.Button(
					text: "Vertical"
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					text: "Stack"
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					text: "Hinzufügen"
					appearance: "flat",
					bordered: true
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					text: "Stack"
					appearance: "flat",
					bordered: true
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-cog"),
				)
				new CUI.Button(
					appearance: "flat",
					bordered: true
					icon_left: new CUI.Icon(class: "fa-cog"),
				)
			]
		)
		@__demo_table.addExample("example 5, vertically stacked buttonbar", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )


		@__addDivider("Using Styles on Buttons inside buttonbar")

		bb = new CUI.Buttonbar(
			tooltip:
				text: "example 1"
			buttons: [
				new CUI.Button(
					text: "groupA", group: "groupA",
					class: "cui-dialog"
				)
				new CUI.Button(
					text: "groupB", group: "groupB",
					class: "cui-dialog"
				)
				new CUI.Button(
					text: "groupB", group: "groupB",
					class: "cui-dialog"
				)
			]
		)

		@__demo_table.addExample("example 1", [ CUI.dom.append(CUI.dom.append(CUI.dom.append(CUI.dom.div(), CUI.dom.div("cui-buttonbar-demo-margin-testers")), bb.DOM), CUI.dom.div("cui-buttonbar-demo-margin-testers"))] )
		@




Demo.register(new Demo.ButtonDemo())
