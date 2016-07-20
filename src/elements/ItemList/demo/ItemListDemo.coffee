class ItemListDemo extends Demo
	display: ->
		items = [
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
			label: "yoho i'am a label."
		,
			label: "me too!"
		,
			divider: true
		,
			text: "Desert"
			menu_on_hover: true
			# icon_right: new Icon(class: "fa-angle-double-down")
			menu:
				placement: "es"
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
			text: "Unavailable"
			disabled: true
		]

		il = new ItemList
			onClick: (ev, btn) ->
				alert(btn.getText())
			items: items


		il.render()
		il


Demo.register(new ItemListDemo())