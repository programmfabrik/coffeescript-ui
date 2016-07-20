class ButtonDemo extends Demo

	getName: () ->
		"Buttons"

	display: ->

		@__demo_table = new DemoTable("cui-button-demo")
		@__table = @__demo_table.table
		@createButtonTable()

		@__table


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


	createButtonTable: ->




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

		@__table.append($tr_one_row("ButtonHref", btn.DOM))

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


		s = $span()
		btn = @__addButton("On Press",
			text: "Hold Button"
			onMouseisdown: (ev) ->
				s.text(ev.getMilliseconds()+"ms")

			onClick: ->
				s.text("")
		)
		btn.DOM.after(s)

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

		@__addButton("appearance: \"auto\", defaults to \"normal\". ",
			icon_left: new Icon(class: "fa-bank")
			appearance: "auto"
			text: "Auto Button stays normal"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)


		@__addButton("appearance: \"auto\", auto switch to \"important\"",
			icon_left: new Icon(class: "fa-bank")
			class: "cui-button-demo-auto-switch-to-important" #TODO make a better example , with a container class, just use the buttonDemo pane style !?
			appearance: "auto"
			text: "Auto Button gets important"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("appearance default is \"auto\", auto switch to \"important\"",
			icon_left: new Icon(class: "fa-bank")
			class: "cui-button-demo-auto-switch-to-important" #TODO make a better example , with a container class, just use the buttonDemo pane style !?
			text: "Auto Button gets important"
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

		@__addButton("size: \"auto\", defaults to \"normal\".",
			icon_left: new Icon(class: "fa-bank")
			size: "auto"
			text: "Auto Button stays Normal"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size: \"auto\", auto switch to \"big\".",
			icon_left: new Icon(class: "fa-bank")
			class: "cui-button-demo-auto-switch-to-big" #TODO make a better example , with a container class, just use the buttonDemo pane style !?
			size: "auto"
			text: "Auto Button gets Big"
			onClick: (evt,button) =>
				@log("Clicked: "+button.getText())
		)

		@__addButton("size default is \"auto\", auto switch to \"big\".",
			icon_left: new Icon(class: "fa-bank")
			class: "cui-button-demo-auto-switch-to-big" #TODO make a better example , with a container class, just use the buttonDemo pane style !?
			text: "Auto Button gets Big"
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

Demo.register(new ButtonDemo())