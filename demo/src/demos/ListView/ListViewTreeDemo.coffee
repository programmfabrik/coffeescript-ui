###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.ListViewTreeDemo extends Demo

	#load filesystem tree, used as example content for list views
	loadFiles: ->
		dfr = new CUI.Deferred()

		data = require('./files.txt')

		@files = []
		for line in data.split("\n")
			if line.trim() == ""
				continue
			spl = line.split(" ")
			type = spl[2]
			if type not in ["f", "d"]
				continue
			parts = spl[0].match("^(.*)\/(.*)$")
			if not parts
				path = spl[0]
				name = spl[0]
			else
				path = parts[1]
				name = parts[2]
			file =
				path: spl[0]
				name: name
				depth: parseInt(spl[1])
				type: type
				size: spl[3]
				date: new Date(Math.floor(spl[4]*1000))
			@files.push(file)

		dfr.resolve()
		dfr.promise()

	display: ->


		get_footer = (pane_footer) =>

			#get the parent listviewtree
			_lv = CUI.dom.closest(pane_footer.DOM, ".cui-list-view-tree").__dom_data["element"]

			minusButton = new CUI.Button
				icon: new CUI.Icon(class: "fa-minus")
				group: "plus-minus"
				disabled: true
				onClick: ->
					CUI.dom.remove(_lv.getSelectedNode())

			bb = (new CUI.Buttonbar
				buttons: [
					new CUI.Button
						group: "plus-minus"
						icon: new CUI.Icon(class: "fa-plus")
						onClick: =>
							_lv.addNode(new Demo.ListViewTreeDemoDummyNode(demo: @, date: new Date()))
					new CUI.Button
						group: "plus-minus"
						icon: new CUI.Icon(class: "fa-plus")
						text: "Nested"
						onClick: =>
							_lv.addNode(new Demo.ListViewNestedNode(demo: @, cols: 6))
					minusButton
				]
			)

			CUI.Events.listen
				node: _lv
				type: ["row_selected","row_deselected"]
				call: (ev, info) ->
					if _lv.getSelectedNode()
						minusButton.enable()
					else
						minusButton.disable()
			bb

		first_list_viewOptions =
			class: "cui-tree-list-view-demo-first-list-view"
			cols: ["auto", "maximize", "auto", "auto"]
			fixedRows: 1
			fixedCols: 1

		unmaximized_list_viewOptions = CUI.util.copyObject(first_list_viewOptions, true)
		connected_list_view1_option = CUI.util.copyObject(first_list_viewOptions, true)
		connected_list_view2_option = CUI.util.copyObject(first_list_viewOptions, true)
		connected_list_view3_option = CUI.util.copyObject(first_list_viewOptions, true)
		maximized_list_viewOptions = CUI.util.copyObject(first_list_viewOptions, true)
		plaintableListviewOptions = CUI.util.copyObject(first_list_viewOptions, true)

		first_list_viewOptions.root = new Demo.ListViewTreeDemoNode(demo: @)
		first_list_viewOptions.selectable = true
		first_list_viewOptions.header_center = "Fill Space ListView:"
		first_list_viewOptions.footer_left = get_footer

		@root_layout = new CUI.HorizontalLayout
			class: "cui-tree-list-view-demo-root-layout"
			left:
				content: CUI.dom.div()
			right:
				content: CUI.dom.div()


		connected_list_view1_option.root = new Demo.ListViewTreeDemoNode(demo: @)
		connected_list_view1_option.cols = ["auto", "auto", "auto", "auto"]
		connected_list_view1_option.class = "list-view-demo-fixed-width"
		connected_list_view1_option.header_left = "1:"
		connected_list_view1_option.maximize = false

		connected_list_view2_option.root = new Demo.ListViewTreeDemoNode(demo: @)
		connected_list_view2_option.class = "list-view-demo-fixed-width"
		connected_list_view2_option.header_left = "2:"
		connected_list_view2_option.cols = ["auto", "auto", "auto", "auto"]
		connected_list_view2_option.maximize = false

		connected_list_view3_option.root = new Demo.ListViewTreeDemoNode(demo: @)
		connected_list_view3_option.class = "list-view-demo-fixed-width"
		connected_list_view3_option.header_left = "3:"
		connected_list_view3_option.cols = ["auto", "auto", "auto", "auto"]
		connected_list_view3_option.maximize = false

		unmaximized_list_viewOptions.root = new Demo.ListViewTreeDemoNode(demo: @)
		unmaximized_list_viewOptions.cols = ["auto", "auto", "auto", "auto"]
		unmaximized_list_viewOptions.maximize = false
		#unmaximized_list_viewOptions.header_center = "Unmaximized ListView"
		unmaximized_list_viewOptions.selectable = true
		unmaximized_list_viewOptions.footer_left = get_footer

		maximized_list_viewOptions.root = new Demo.ListViewTreeDemoNode(demo: @)
		maximized_list_viewOptions.class = "list-view-demo-fixed-width"
		#maximized_list_viewOptions.header_center = "Maximized ListView"
		maximized_list_viewOptions.selectable = true
		maximized_list_viewOptions.footer_left = get_footer
		unmaximized_list_viewOptions.maximize = true

		first_list_view = new CUI.ListViewTree(first_list_viewOptions)

		connected_list_view1 = new CUI.ListViewTree(connected_list_view1_option)
		connected_list_view2 = new CUI.ListViewTree(connected_list_view2_option)
		connected_list_view3 = new CUI.ListViewTree(connected_list_view3_option)
		unmaximized_list_view = new CUI.ListViewTree(unmaximized_list_viewOptions)
		maximized_list_view = new CUI.ListViewTree(maximized_list_viewOptions)

		tabs = new CUI.Tabs
			class: "cui-tree-list-view-demo-tabs"
			footer_left: "This Footer belongs to the Tabs"
			tabs: [
				text: "ListView not maximized"
				content: unmaximized_list_view.render()
#			,
#				text: "ListView maximized"
#				content: maximized_list_view.render()
			]

		unmaximized_list_view.root.open()

		connected_list_view_layout = new CUI.VerticalLayout
			class: "cui-tree-list-view-demo-connected-layout"
			maximize: true
			center:
				content: [
					connected_list_view1.render()
					connected_list_view2.render()
					connected_list_view3.render()
				]

		connected_list_view1.root.open()
		connected_list_view2.root.open()
		connected_list_view3.root.open()


		@root_layout.getLayout().replace(first_list_view.render(),"left")
		first_list_view.appendRow(new Demo.ListViewTreeDemoHeaderNode())
		first_list_view.root.open()
		return @root_layout.DOM

		CUI.dom.append(@root_layout.getLayout().map.center, connected_list_view_layout.DOM)
		@root_layout.getLayout().replace(tabs.DOM,"right")


		connected_list_view1.appendRow(new Demo.ListViewTreeDemoHeaderNode())
		connected_list_view2.appendRow(new Demo.ListViewTreeDemoHeaderNode())
		connected_list_view3.appendRow(new Demo.ListViewTreeDemoHeaderNode())
		unmaximized_list_view.appendRow(new Demo.ListViewTreeDemoHeaderNode())
		#maximized_list_view.appendRow(new ListViewTreeDemoHeaderNode())

		@root_layout.DOM


class Demo.ListViewTreeDemoDummyNode extends CUI.ListViewTreeNode
	constructor: (@opts={}) ->
		@demo = @opts.demo
		super(@opts)

	initOpts: ->
		super()
		@addOpts
			demo:
				check: Demo.ListViewTreeDemo
			date:
				check: (v) ->
					v instanceof Date

	renderContent: =>
		@columns.splice(0,0, new CUI.ListViewColumn(text: @getNodeId()))

		d = CUI.dom.div()
		btn = new CUI.Button(
			text: "More Content"
			onClick: ->
				b = new CUI.Button
					text: ""+Math.random()
					onClick: ->
						CUI.DOM.remove(@DOM.parent())
						@destroy()
						CUI.Events.trigger
							type: "content-resize"
							node: d

				CUI.dom.append(d, CUI.dom.append(CUI.dom.div(), b.DOM))
				CUI.Events.trigger
					type: "content-resize"
					node: d
		)
		CUI.dom.append(d, CUI.dom.append(CUI.dom.div(), btn.DOM))

		@addColumn(new CUI.ListViewColumn(element: d, colspan: 2))
		# @addColumn(new CUI.ListViewColumn(text: dateToString(@opts.date)))
		new CUI.Label(text: "Added Manually")

class Demo.ListViewTreeDemoHeaderNode extends CUI.ListViewRow
	constructor: ->
		super()
		@addColumn(new CUI.ListViewColumn(text: "Node"))
		@addColumn(new CUI.ListViewColumn(text: "File"))
		@addColumn(new CUI.ListViewColumn(text: "Size"))
		@addColumn(new CUI.ListViewColumn(text: "Date"))


class Demo.ListViewTreeDemoNode extends CUI.ListViewTreeNode
	constructor: (@opts={}) ->

		@demo = @opts.demo
		@file = @opts.file
		super(@opts)

	initOpts: ->
		super()
		@addOpts
			demo:
				check: Demo.ListViewTreeDemo
			file:
				check: "PlainObject"
			leaf:
				check: Boolean


	getChildren: =>
		dfr = new CUI.Deferred()
		children = []

		push_file = (file) =>
			children.push(new Demo.ListViewTreeDemoNode(demo: @demo, file: file, leaf: file.type == "f"))

		if not @file
			@demo.loadFiles()
			.done =>
				for file in @demo.files
					if file.depth > 1
						continue
					push_file(file)

				# children.push(new ListViewNestedNode(demo: @demo, cols: 3))
				dfr.resolve(children)
		else
			for file in @demo.files
				if file.depth != @file.depth+1
					continue
				if file.path.substr(0, @file.path.length) != @file.path
					continue
				push_file(file)
			dfr.resolve(children)
		dfr.promise()

	renderContent: =>
		@columns.splice(0,0, new CUI.ListViewColumn(text: @getNodeId()))
		@addColumn(new CUI.ListViewColumn(text: @file.size))
		@addColumn(new CUI.ListViewColumn(text: dateToString(@file.date)))
		new CUI.Label(text: @file.name)

class Demo.ListViewNestedNode extends Demo.ListViewTreeDemoNode
	constructor: (@opts={}) ->
		@cols = @opts.cols
		@opts.leaf = true
		super(@opts)

	initOpts: ->
		super()
		@addOpts
			cols:
				check: "Integer"


	renderContent: ->
		@columns.splice(0,0,new CUI.ListViewColumn(text: @getNodeId()))

		__getColumns = (textFunc = (i) -> ""+i) =>
			columns = []
			columns.push(new CUI.ListViewColumn(text: String.fromCharCode(65+(lv?.rowsCount or 0))))
			for i in [0...@cols]
				columns.push(new CUI.ListViewColumn(text: textFunc(i)))
			columns

		columns = __getColumns()

		lv = new CUI.ListView
			cols: ((if idx == 1 then "auto" else "auto") for c, idx in columns)
			footer_left: new CUI.Buttonbar buttons: [
				new CUI.Button
					group: "plus-minus"
					icon: new CUI.Icon(class: "fa-plus")
					onClick: ->
						columns = __getColumns(-> ""+Math.floor(Math.random()*1000))
						lv.appendRow(new CUI.ListViewRow(columns: columns))
						#lv.layout()
						lb.enable()

				lb = new CUI.Button
					group: "plus-minus"
					disabled: true
					icon: new CUI.Icon(class: "fa-minus")
					text: "Last"
					onClick: ->
						if lv.rowsCount > 1
							lv.removeRow(lv.getRowIdx(lv.rowsCount-1))
							#lv.layout()
						if lv.rowsCount == 1
							lb.disable()

			]
			fixedRows: 1
			fixedCols: 1

		@addColumn(new CUI.ListViewColumn(colspan: 2, element: lv.render()))
		lv.appendRow(new CUI.ListViewRow(columns: columns))

		new CUI.Label(text: "Nested")



dateToString = (d) ->
	d.toLocaleDateString()+" "+d.toLocaleTimeString()


Demo.register(new Demo.ListViewTreeDemo())