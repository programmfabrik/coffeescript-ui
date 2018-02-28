###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

imgSchmetterling = require('./Schmetterling.jpg')

class Demo.MenuDemo extends Demo

	display: ->

		demoLabel = CUI.dom.img("", src: imgSchmetterling)
		@demo_table = new Demo.DemoTable('cui-menu-demo')
		@listenOnNode(demoLabel)
		@demo_table.addExample("Context Menu (Use ALT for blurry background)", demoLabel)
		@demo_table.table


	listenOnNode: (node) ->
		CUI.Events.listen
			type: "contextmenu"
			node: node

			call: (ev) ->
				if ev.ctrlKey()
					return

				ev.preventDefault()
				mouse_coordinates = CUI.util.getCoordinatesFromEvent(ev)
				console.debug "mouse coordinates", mouse_coordinates

				menu_items = [
					icon_left: "play"
					text: "Starter"
					icon_right: new CUI.Icon(class: "fa-angle-double-down")
					menu:
						items: [
							text: "Soup"
							onClick: ->
								alert("Soup")
						,
							text: "Bruscetta"
							onClick: ->
								alert("Bruscetta")
						]
				,
					text: "A really really really long Main Course"
				,
					icon: "trash"
					text: "Trash"
				,
					divider: true
				,
					text: "Desert"
					menu_on_hover: true
					# icon_right: new CUI.Icon(class: "fa-angle-double-down")
					menu:
						items: [
							text: "Sweet"
							onClick: ->
								alert "Strawberries"
						,
							text: "Sour"
							onClick: ->
								alert "Lemon Zest"
						]
				,
					text: "disabled menu item"
					disabled: true
				,
					divider: true
				,
					text: "Eggs"
				,
					label: "label menu item"
				,
					text: "Caesar"
				,
					text: "Thousand Islands"
				,
					new CUI.Label
						text: "raw label as item 3"
				,
					new CUI.Button
						text: "raw button as item 1"
				,
					new CUI.Button
						text: "raw button as item 2"

				]

				(new CUI.Menu
					backdrop:
						policy: "click"
						blur: ev.altKey()
					show_at_position:
						top: mouse_coordinates.pageY
						left: mouse_coordinates.pageX
					itemList:
						onClick: (ev, btn) ->
							alert(btn.getText())
						items: menu_items

				).show(ev)
				return


CUI.Events.listen
	node: document
	type: "contextmenu"
	call: (ev) =>
		if ev.ctrlKey()
			return
		ev.preventDefault()


Demo.register(new Demo.MenuDemo())