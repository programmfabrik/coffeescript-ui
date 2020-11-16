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

	__addButtonPair: (description, opts={}, extraClass="") ->
		opts2 = CUI.util.copyObject(opts, true)
		pair = [ new CUI.Button(opts), new CUI.Button(opts2) ]

		for btn in pair
			@__buttons.push(btn)

		wrap = new CUI.Buttonbar(
			buttons: pair
			class: "cui-demo-button-pair"
		)
		if extraClass
			CUI.dom.addClass(wrap, extraClass)

		@__demo_table.addExample(description, [ wrap.DOM ])
		return wrap

	__addButtonbar: (description, opts={}) ->
		bb = new CUI.Buttonbar(opts)
		@__demo_table.addExample(description, [ bb.DOM ])

	__addButtonbarPair: (description, opts={}, extraClass="") ->
		bb1 = new CUI.Buttonbar(opts).DOM
		bb2 = bb1.cloneNode(true)
		@__demo_table.addExample(description, [ CUI.dom.append(CUI.dom.div("cui-demo-buttonbar-pair " + extraClass ? extraClass : ""), [bb1, bb2]) ])	
	

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

		@__addButtonPair( "Icon Left",
			icon_left: new CUI.Icon(class: "fa-trash-o")
			text: "Trash"
		)

		@__addButtonPair( "Icon (with Tooltip)",
			icon_left: "trash"
			tooltip:
				text: "I am Trashy"
			text: "Trash"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButtonPair("Icons Left+Right",
			icon_left: new CUI.Icon(class: "fa-bolt")
			icon_right: new CUI.Icon(class: "fa-filter")
			text: "Caret"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		span = CUI.dom.span()
		span.innerHTML = "<big>Ce</big><b>n</b>t<i>e</i>r"
		@__addButtonPair("With Picture & Content",
			left: CUI.dom.div("cui-button-demo-pic")
			center: span
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)


		@__addDivider("button functionalities")

		btn = new CUI.ButtonHref
			text: "Open Google"
			target: "_blank"
			href: "http://www.google.com"
		@__buttons.push(btn)
		@__demo_table.addExample("ButtonHref", btn.DOM)

		btn = new CUI.ButtonHref
			text: "Open Google"
			target: "_blank"
			appearance: "link"
			href: "http://www.google.com"
		@__buttons.push(btn)
		@__demo_table.addExample("ButtonHref with appearance: link", btn.DOM)

		@__addButtonPair "With Small Tooltip & Confirm",
			icon_left: new CUI.Icon(class: "fa-lightbulb-o")
			left: true
			confirm_on_click: "Are you sure?"
			tooltip:
				text: "Small but beautiful!"

		@__addButtonPair "With Huge Tooltip",
			text: "Hover to show a tooltip"
			tooltip:
				text: @getBlindText()
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())

		@__addButtonPair("Switch",
			switch: true
			text: "On/Off"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButtonPair "Button with text ellipsis",
			class: "cui-button-demo-limit-width"
			text: "Button with text ellipsis"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())


		@__addButtonPair("Counter (use Shift)",
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

		@__addButtonPair("With Menu (try +Alt)",
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

		@__addButtonPair("appearance: \"normal\"",
			icon_left: new CUI.Icon(class: "fa-cloud")
			appearance: "normal"
			text: "Normal Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButtonPair("appearance: \"flat\"",
			icon_left: new CUI.Icon(class: "fa-cloud")
			appearance: "flat"
			text: "Flat Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButtonPair("appearance: \"link\"",
			icon_left: new CUI.Icon(class: "fa-cloud")
			appearance: "link"
			text: "Link Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButtonPair("appearance: \"link\"",
			icon_right: new CUI.Icon(class: "fa-plus")
			appearance: "link"
			text: "Link Button Plus"
		)

		@__addButtonPair("appearance: \"important\" (OBSOLETE ???)",
			icon_left: new CUI.Icon(class: "fa-cloud")
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

		@__addButton("secondary button",
			secondary: true
			text: "Secondary Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addDivider("Button option: size ")

		@__addButtonPair("size: \"base\"",
			icon_left: new CUI.Icon(class: "fa-cloud")
			size: "normal"
			text: "Normal Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButtonPair("size: \"sm\"",
			icon_left: new CUI.Icon(class: "fa-cloud")
			size: "mini"
			text: "Mini Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		, "cui-demo-button-size-small")

		@__addButtonPair("size: \"lg\"",
			icon_left: new CUI.Icon(class: "fa-cloud")
			size: "big"
			text: "Big Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		, "cui-demo-button-size-large")

		@__addButton("size: \"Icon\"",
			icon_left: new CUI.Icon(class: "fa-file")
			text: ""
			class: "cui-demo-button-size-icon"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)		

		@__addButton("size: \"Ellipsis\"",
			icon_left: new CUI.Icon(class: "fa-ellipsis-v")
			text: ""
			class: "cui-demo-button-size-ellipsis"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)	

		@__addButton("\"Info Icon\"",
			icon_left: "info"
			text: ""
			class: "cui-demo-button-size-info"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)						
		

		@__addDivider("Buttons Inverted")	
		inverted = new CUI.Button(
			icon_left: new CUI.Icon(class: "fa-trash-o")
			text: "Remove"
		)
		invertedBorder = new CUI.Button(
			icon_left: new CUI.Icon(class: "fa-trash-o")
			text: "Remove"
			class: "is-plain-button"
		)	
		invertedClose = new CUI.Button(
			icon_left: "close"
			text: ""
			class: "small"
		)	
		invertedDive = new CUI.Button(
			icon_left: new CUI.Icon(class: "fa-angle-right")
			text: ""
			class: "is-plain-button small"
		)						
		@__demo_table.addExample("Buttons Inverted", [
			inverted.DOM, 
			invertedBorder.DOM, 
			invertedClose.DOM, 
			invertedDive.DOM
			], 
			null, 
			"cui-demo-button-inverted"
		)

		@__addDivider("Buttons on Image")	
		inverted = new CUI.Button(
			icon_left: new CUI.Icon(class: "fa-trash-o")
			text: "Remove"
		)
		invertedBorder = new CUI.Button(
			icon_left: new CUI.Icon(class: "fa-trash-o")
			text: "Remove"
			class: "is-plain-button"
		)	
		invertedClose = new CUI.Button(
			icon_left: "close"
			text: ""
			class: "small"
		)	
		invertedDive = new CUI.Button(
			icon_left: new CUI.Icon(class: "fa-angle-right")
			text: ""
			class: "is-plain-button small"
		)	
		invertedNavigation = new CUI.Buttonbar(
			class: "cui-demo-buttonbar-navigation-border"
			buttons: [
				new CUI.Button(icon: "fa-angle-left", group: "navi")
				new CUI.Label(text: "1/3", group: "navi")
				new CUI.Button(icon: "fa-angle-right", group: "navi")
			]
		)
		invertedButtonbarGroup = new CUI.Buttonbar(
			class: "cui-demo-buttonbar-group-inverted"
			buttons: [
				new CUI.Button(icon: "fa-trash", group: "trash")
				new CUI.Button(icon: "fa-trash", group: "trash")
				new CUI.Button(icon: "fa-trash", group: "trash")
			]
		)										
		@__demo_table.addExample("Buttons on Image", [
			inverted.DOM, 
			invertedBorder.DOM, 
			invertedClose.DOM, 
			invertedDive.DOM,
			invertedNavigation.DOM,
			invertedButtonbarGroup.DOM
			], 
			null, 
			"cui-demo-button-on-image cui-demo-button-inverted"
		)		

		@__addDivider("Buttons with mixed options")
		@__addButton("Big link button",
			icon_left: new CUI.Icon(class: "fa-cloud")
			size: "big"
			appearance: "link"
			class: "cui-demo-button-size-large-link "
			text: "Big Link Button"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)


		# @__addDivider("Custom css classes OBSOLETE ???")

		# @__addButtonPair "Centered, fixed width",
		# 	text: "Centered, fixed width"
		# 	class: "cui-button-demo-centered-fixed-width"
		# 	icon_left: new CUI.Icon(class: "fa-bolt")
		# 	icon_right: new CUI.Icon(class: "fa-filter")
		# 	onClick: (evt,button) =>
		# 		@log("Clicked: "+button.getText())

		# @__addButtonPair "Custom color class",
		# 	text: "My Colors A"
		# 	size: "big"
		# 	class: "cui-button-demo-custom-colors-a"
		# 	switch: true
		# 	onClick: (evt,button) =>
		# 		@log("Clicked: "+button.getText())

		# @__addButtonPair "Custom color class",
		# 	text: "My Colors B"
		# 	size: "big"
		# 	class: "cui-button-demo-custom-colors-b"
		# 	switch: true
		# 	onClick: (evt,button) =>
		# 		@log("Clicked: "+button.getText())

		# @__addButtonPair "Custom color class",
		# 	text: "My Colors C"
		# 	size: "big"
		# 	class: "cui-button-demo-custom-colors-c"
		# 	switch: true
		# 	onClick: (evt,button) =>
		# 		@log("Clicked: "+button.getText())

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

		@__addButtonbar("Radio",
			buttons: buttons
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

		@__addButtonbar("Buttonbar 1",
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

		@__addButtonbar("Buttonbar 2",
			tooltip:
				text: "mixed buttons and selects"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				select
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)

		@__addDivider("Buttonbar in different grouping Variations")

		@__addButtonbar("Example 1",
			tooltip:
				text: "example 1"
			buttons: [
					new CUI.Button(text: "groupA", group: "groupA")
					new CUI.Button(text: "groupB-active", group: "groupB", active: true )
					new CUI.Button(text: "groupB", group: "groupB")
				]
		)

		@__addButtonbar("Example 2",
			tooltip:
				text: "example 2"
			buttons: [
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)

		@__addButtonbar("Example 3",
			tooltip:
				text: "example 3"
			buttons: [
				new CUI.Button(text: "no group"  )
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "groupB", group: "groupB")
			]
		)

		@__addButtonbar("Example 4",
			tooltip:
				text: "example 4"
			buttons: [
				new CUI.Button(text: "no group"  )
				new CUI.Button(text: "groupA", group: "groupA")
				new CUI.Button(text: "no group")
			]
		)

		@__addButtonbar("Example 5",
			tooltip:
				text: "example 5"
			buttons: [
				new CUI.Button(text: "no group"  )
				new CUI.Button(text: "no group", group: "no group")
				new CUI.Button(text: "no group")
			]
		)

		@__addButtonbar("Example 6",
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

		@__addButtonbarPair("example 7, vertical stack, no group !",
			# stack: "vertical"
			buttons: [
				new CUI.Button(text: "some")
				new CUI.Button(text: "button")
				new CUI.Button(text: "here")
			]
		, "cui-demo-buttonbar-stack-vertical")

		@__addButtonbar("example 1, group",
			tooltip:
				text: "example 1"
			buttons: [
				new CUI.Button(text: "Eins", group: "groupA", active: true)
				new CUI.Button(text: "Zwei", group: "groupA")
				new CUI.Button(text: "Dreizehn", group: "groupA")
				new CUI.Button(text: "Vierzig", group: "groupA")
			]
		)

		@__addButtonbarPair("example 1, no group, packed 'tight'",
			tooltip:
				text: "example 1"
			buttons: [
				new CUI.Button(text: "Eins", active: true)
				new CUI.Button(text: "Zwei")
				new CUI.Button(text: "Dreizehn")
				new CUI.Button(text: "Vierzig")
			]
		, "cui-demo-buttonbar-tight")


		@__addButtonbar("navigation toolbar no border (default)",
			class: "cui-demo-buttonbar-navigation"
			buttons: [
				new CUI.Button(icon: "fa-angle-left", group: "navi")
				new CUI.Label(text: "1/3", group: "navi")
				new CUI.Button(icon: "fa-angle-right", group: "navi")
			]
		)

		@__addButtonbar("navigation toolbar with border",
			class: "cui-demo-buttonbar-navigation-border"
			buttons: [
				new CUI.Button(icon: "fa-angle-left", group: "navi", disabled: true)
				new CUI.Label(text: "1/3", group: "navi")
				new CUI.Button(icon: "fa-angle-right", group: "navi")
			]
		)	

		@__addButtonbar("navigation toolbar with border and number input",
			class: "cui-demo-buttonbar-navigation-border"
			buttons: [
				new CUI.Button(icon: "fa-angle-left", group: "navi")
				new CUI.Input(
					class: "cui-number-input"
					data: value: ""
					group: "navi"
				)
				new CUI.Button(icon: "fa-angle-right", group: "navi")
			]
		)

		@__addButtonbar("small navigation toolbar with border",
			class: "cui-demo-buttonbar-navigation-border-small"
			buttons: [
				new CUI.Button(icon: "fa-angle-left", group: "navi")
				new CUI.Label(text: "1/3", group: "navi")
				new CUI.Button(icon: "fa-angle-right", group: "navi")
			]
		)					


		@__addButtonbar("example 1, group, vertical",
			class: "cui-demo-buttonbar-stack-vertical"
			tooltip:
				text: "example 1"
			buttons: [
				new CUI.Button(text: "1", group: "groupA", active: true)
				new CUI.Button(text: "2", group: "groupA")
				new CUI.Button(text: "3", group: "groupA")
				new CUI.Button(text: "4", group: "groupA")
			]
		)

		@__addButtonbarPair("example 2, no group, packed tight",
			tooltip:
				text: "example 2, no group"
			buttons: [
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-lightbulb-o"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"))
			]
		, "cui-demo-buttonbar-tight")

		@__addButtonbarPair("example 3 flat, mixed, packed tight",
			tooltip:
				text: "example 3 flat, mixed"
			buttons: [
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"))
				new CUI.Button(text: "Eins", group: "groupA", appearance: "flat")
				new CUI.Button(text: "Zwei", group: "groupA", appearance: "flat")
				new CUI.Button(text: "Drei", group: "groupA", appearance: "flat")
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-share"))
				new CUI.Button(appearance: "flat", icon_left: new CUI.Icon(class: "fa-refresh"))
			]
		, "cui-demo-buttonbar-tight")

		@__addButtonbar("example 3 flat, two group with icon",
			buttons: [
				new CUI.Button(text: "Eins", group: "groupA", appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"))
				new CUI.Button(text: "Zwei", group: "groupA", appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"))
				new CUI.Button(text: "Drei", group: "groupA", appearance: "flat", icon_left: new CUI.Icon(class: "fa-plus"))
				new CUI.Button(text: "Eins", group: "groupB", appearance: "flat", icon_left: new CUI.Icon(class: "fa-cog"))
				new CUI.Button(text: "Zwei", group: "groupB", appearance: "flat", icon_left: new CUI.Icon(class: "fa-download"))
				new CUI.Button(text: "Drei", group: "groupB", appearance: "flat", icon_left: new CUI.Icon(class: "fa-plus"))
			]
		)

		@__addButtonbarPair("example 4 flat, icon and optional text",
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

		@__addButtonbarPair("example 4 flat, icon and optional text, small",
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
		,"cui-demo-buttonbar-small-buttons")

		@__addButtonbarPair("example 4 flat, icon and optional text, large",
			buttons: [
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
					size: "big"
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
					size: "big",
					text: "Nested"
				)
			]
		,"cui-demo-buttonbar-large-buttons")

		@__addButtonbarPair("example 5, vertically stacked buttonbar",
			# stack: "vertical"
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
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					text: "Stack"
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-cog"),
				)
				new CUI.Button(
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-cog"),
				)
			]
		, "cui-demo-buttonbar-stack-vertical")

		@__addButtonbar("example 5, vertically stacked buttonbar, packed tight",
			class: "cui-demo-buttonbar-stack-vertical cui-demo-buttonbar-tight cui-demo-buttonbar-plain"
			buttons: [
				new CUI.Button(
					text: "Stack"
					appearance: "flat",
					icon_left: new CUI.Icon(class: "fa-plus"),
				)
				new CUI.Button(
					appearance: "flat",
					text: "Now"
					icon_left: new CUI.Icon(class: "fa-cog"),
				)
				new CUI.Button(
					appearance: "flat",
					text: "Stack"
					icon_left: new CUI.Icon(class: "fa-cog"),
				)
			]
		)

		@




Demo.register(new Demo.ButtonDemo())
