###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.TabsDemo extends Demo

	display: ->
		_tabs = []
		for i, idx in ["Atlanta", "New York", "Chicago"]
			_tabs.push
				text: i
				content: i+": "+@getBlindText(idx*2+1)

		createButtonbar = (tabs) =>
			city_idx = 0
			new CUI.Buttonbar buttons: [
				new CUI.Button
					icon: new CUI.Icon(class: "fa-plus")
					group: "plus-minus"
					onClick: (ev, btn) =>
						tabs.addTab(
							new CUI.Tab
								text: Demo.TabsDemo.cities[city_idx]
								onActivate: (tab) ->
									minusButton.enable()
								onDeactivate: (tab) ->
									minusButton.disable()
								content: @getBlindText(Math.ceil(Math.random()*5))
						).activate()
						if not Demo.TabsDemo.cities[city_idx++]
							btn.disable()

				minusButton = new CUI.Button
					icon: new CUI.Icon(class: "fa-minus")
					group: "plus-minus"
					disabled: true
					onClick: (ev, btn) =>
						tabs.getActiveTab().destroy()
			]

		tabs = new CUI.Tabs
			footer_right: "Right"
			footer_left: "Left"
			tabs: _tabs

		tabs.setFooterRight(createButtonbar(tabs))

		# --------- tab 2

		_tabs2 = []
		for i, idx in Demo.TabsDemo.cities
			_tabs2.push
				text: i
				content: i+": "+@getBlindText(idx*2+1)

		tabs2 = new CUI.Tabs
			maximize: true
			tabs: _tabs2
			footer_right: "Right"
			footer_left: "Left"

		tabs2.setFooterRight(createButtonbar(tabs2))


		tabs3 = new CUI.Tabs
			footer_right: "Right"
			footer_left: "Left from not maximized"
			tabs: [
				text: "testTab1"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "testTab2"
				content: new CUI.Label(
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

		tabs3.setFooterRight(createButtonbar(tabs))

		# Small tab buttons
		tabsSmall = new CUI.Tabs
			class: "cui-demo-tabs-small"
			tabs: [
				text: "Atlanta"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "New York"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Chicago"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Minneapolis"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			]
			maximize: true

		tabsSmall.setFooterRight(createButtonbar(tabs))

		# Vertical tabs
		tabsVertical = new CUI.Tabs
			class: "cui-demo-tabs-vertical"
			tabs: [
				text: "Atlanta"
				# content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
				content: @getBlindText(idx*2+1)
			,
				text: "New York"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Chicago"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "San Fransisco"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Detroit"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Minneapolis"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			]
			maximize: true

		# Vertical tabs
		tabsVerticalSmall = new CUI.Tabs
			class: "cui-demo-tabs-vertical-small"
			tabs: [
				text: "Atlanta"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "New York"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Chicago"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "San Fransisco"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Detroit"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			,
				text: "Minneapolis"
				content: new CUI.Label( text: "1 Very short test text. Very very short. 1").DOM
			]
			maximize: true

		@demo_elements = [
							new CUI.Label
								text: "Tabs with height by content"
							tabs
							new CUI.Label
								text: "Small Tab Buttons"
							tabsSmall
							new CUI.Label
								text: "Tabs with static height"
							tabs2
							new CUI.Label
								text: "Tabs not maximized"
							tabs3
							new CUI.Label
								text: "Vertical Tabs"
							tabsVertical
							new CUI.Label
								text: "Vertical Tabs"
							tabsVerticalSmall
						]

		return @demo_elements


	undisplay: ->
		for element in @demo_elements
			element.destroy()

Demo.TabsDemo.cities = [
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


Demo.register(new Demo.TabsDemo())
