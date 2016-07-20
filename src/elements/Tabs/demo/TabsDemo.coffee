class TabsDemo extends Demo

	display: ->
		_tabs = []
		for i, idx in ["Atlanta", "New York", "Chicago"]
			_tabs.push
				text: i
				content: i+": "+@getBlindText(idx*2+1)

		createButtonbar = (tabs) =>
			city_idx = 0
			new Buttonbar buttons: [
				new Button
					icon: new Icon(class: "fa-plus")
					group: "plus-minus"
					onClick: (ev, btn) =>
						tabs.addTab(
							new Tab
								text: TabsDemo.cities[city_idx]
								onActivate: (tab) ->
									minusButton.enable()
								onDeactivate: (tab) ->
									minusButton.disable()
								content: @getBlindText(Math.ceil(Math.random()*5))
						).activate()
						if not TabsDemo.cities[city_idx++]
							btn.disable()

				minusButton = new Button
					icon: new Icon(class: "fa-minus")
					group: "plus-minus"
					disabled: true
					onClick: (ev, btn) =>
						tabs.getActiveTab().destroy()
			]

		tabs = new Tabs
			footer_right: "Right"
			footer_left: "Left"
			tabs: _tabs

		tabs.setHeaderRight(createButtonbar(tabs))

		# --------- tab 2

		_tabs2 = []
		for i, idx in TabsDemo.cities
			_tabs2.push
				text: i
				content: i+": "+@getBlindText(idx*2+1)

		tabs2 = new Tabs
			maximize: true
			tabs: _tabs2
			footer_right: "Right"
			footer_left: "Left"

		tabs2.setHeaderRight(createButtonbar(tabs2))


		tabs3 = new Tabs
			footer_right: "Right"
			footer_left: "Left from not maximized"
			tabs: [
				text: "testTab1"
				content: new Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "testTab2"
				content: new Label(
					multiline: true
					text: """1 Very short test text.
Very very short. 2
Very very short. 2
Very very short. 2
Very very short. 2
"""
				).DOM
			]
			maximize: false

		tabs3.setHeaderRight(createButtonbar(tabs))

		@demo_elements = [
							new Label
								text: "Tabs with height by content"
							tabs
							new Label
								text: "Tabs with static height"
							tabs2
							new Label
								text: "Tabs not maximized"
							tabs3
						]

		return @demo_elements


	undisplay: ->
		for element in @demo_elements
			element.destroy()

TabsDemo.cities = [
		"Bladensburg"
		"Blackman"
		"Blackmont"
		"Blacksburg"
		"Blackshear"
		"Blackstock"
		"Blackstone"
		"Blacksville"
		"Blackton"
		"Blackwater"
		"Blackwell"
		"Blackwells"
		"Blackwood"
		"Bladen"
		"Blades"
		"Blain"
		"Blaine"
		"Blaine Hill"
		"Blair"
		"Blairs"
		"BlairsMills"
		"Blairsburg"
		"Blairsden"
		"Blairstown"
		"Blairsville"
		"Blairville"
		"Blaisdell"
		"Blakeley"
		"Blakely"
	]


Demo.register(new TabsDemo())