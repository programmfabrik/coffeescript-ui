###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

CUI.__ng__ = true

CUI.ready => 
	#CUI.alert text:"Hallo"





	# *********************************
	# Icons
	# *********************************
	
	# Table HEAD
	dataFields = [ # Columns
		type: Output
		name: "text_col"
	,
		type: Output
		name: "icon_col"
		getValue: (value) ->
			new Icon (icon: value)
	]

	# Table BODY / DATA
	icon = new Icon
	icon_map = icon.icon_map()

	data =
		Icons: [] # Must match Table-Name

	for key, value of icon_map
		tmp =
			text_col: "#{key}"
			icon_col: "#{value}"
			###icon_col:
				new Label
					icon: "#{value}"###

		data.Icons.push(tmp)


	# Table - Output
	myDataTable = new DataTable
		name: "Icons"
		fields: dataFields #columns
		data: data #data
		maximize: true

	myDataTable.start()	# => DOM-Element



	# *********************************
	# Blocks
	# *********************************
	
	myBlock = new Block
		text: "Recipe"
		content: [
			new Label
				text: "Cookies"
		,
			new Block
				text: "Ingredients"
				level: 2
				content:
					new Label
						text: "Flour, Sugar, Butter, Chocolate"
		,
			new Block
				text: "Instructions"
				level: 2
				content:
					new Label
						text: "Mix, Bake, Taste :)"
		]


	
	# *********************************
	# ListView
	# *********************************

	class testNode extends ListViewTreeNode
		getChildren: ->
			children = []
			for i in [0..10]
				children.push(new testNode())
			children
		renderContent: ->
			"tobias"


	myListViewTree = new ListViewTree
		cols: ["auto"]
		root: new testNode()

	myListViewTree.root.open()

	

	# *********************************
	# Layout
	# *********************************

	myLayout = new VerticalLayout
		top:
			content: "top"
		center:
			content: "center"
		bottom:
			content: "bottom"
		maximize_vertical: true
		

	
	# *********************************
	# Buttons
	# *********************************

	# Dropdown
	itemsInList =
		items: [
			text: "Icons"
			icon: new Icon(class: "fa-lightbulb-o")
			onClick: ->
				mySimplePane.replace(myDataTable,"center")
				mySimplePane.replace(new Label(text: "Icons"),"header_center")
		,
			text: "Cookies"
			icon: "calendar"
			onClick: ->
				mySimplePane.replace(myBlock,"center")
				mySimplePane.replace(new Label(text: "Cookies Recipe"),"header_center")
		,
			divider: true
		,
			text: "Layouts"
			icon_right: new Icon(class: "fa-angle-double-right")
			icon_left: "no_right"
			menu:
				items: [
					text: "VerticalLayouts"
					icon: "no_right"
					onClick: ->
						mySimplePane.replace(myLayout,"center")
						mySimplePane.replace(new Label(text: "Layouts"),"header_center")
				,
					text: "Themes"
				,
					new ButtonHref
						text: "Search the web"
						appearance: "auto"
						href: "https://duckduckgo.com/"
						target: "_blank"
				]
		,
			
		
		]

	# Switch
	menu =
		itemList: itemsInList

	# Buttonbar: light, dark
	myButtonbar = new Buttonbar
		buttons: [
			new Button
				text: "light"
				group: "group1"
				active: true
				onClick: ->
					btn_dark = @.getGroupButtons("group1")[1] # get dark button
					if @.isActive() == false
						@.setActive(true)
						btn_dark.setActive(false)
		,
			new Button
				text: "dark"
				group: "group1"
				active: false
				onClick: ->
					btn_light = @.getGroupButtons("group1")[0] # get dark button
					if @.isActive() == false
						@.setActive(true)
						btn_light.setActive(false)
		]



	# *********************************
	# Simple Pane
	# *********************************

	mySimplePane = new SimplePane
		header_left:
			new Button
				menu: menu
				text: "Menu"
		header_right:
			myButtonbar
		content:
			new Label
				text: "Willkommen"
				centered: true
		footer_right:
			new Button
				text: "Say Hello"
				appearnce: "normal"
				size: "big"
				onClick: (ev, btn) ->
					alert("Hello")
				click_type: "dblclick"



	#mySimplePane.append("leeeftee","footer_left")
	#mySimplePane.replace("riiightee","footer_left")
	#mySimplePane.empty("footer_left")


	document.body.appendChild(mySimplePane.DOM)


	
