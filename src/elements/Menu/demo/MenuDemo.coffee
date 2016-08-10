class MenuDemo extends Demo
	display: ->

		demoLabel = $img("", src: "css/pics/Schmetterling.jpg")

		@demo_table = new DemoTable('cui-menu-demo')

		Events.listen
			type: "contextmenu"
			node: demoLabel

			call: (ev) ->
				if ev.ctrlKey()
					return

				ev.preventDefault()
				mouse_coordinates = getCoordinatesFromEvent(ev)
				CUI.debug "mouse coordinates", mouse_coordinates


				menu_items = [
					text: "Starter"
					icon_right: new Icon(class: "fa-angle-double-down")
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
					text: "A shorty."
				,
					divider: true
				,
					text: "Desert"
					menu_on_hover: true
					# icon_right: new Icon(class: "fa-angle-double-down")
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
					new Label
						text: "raw label as item 3"
				,
					new Button
						text: "raw button as item 1"
				,
					new Button
						text: "raw button as item 2"

				]

				(new Menu
					backdrop:
						policy: "click"
						blur: true
					itemList:
						onClick: (ev, btn) ->
							alert(btn.getText())
						items: menu_items

				).show(
					new Positioner(
						top: mouse_coordinates.pageY
						left: mouse_coordinates.pageX
						width: 0
						height: 0
					)
				)
				return

		@demo_table.addExample("Context Menu", demoLabel)
		@demo_table.table



Events.listen
	node: document
	type: "contextmenu"
	call: (ev) =>
		if ev.ctrlKey()
			return
		ev.preventDefault()


Demo.register(new MenuDemo())