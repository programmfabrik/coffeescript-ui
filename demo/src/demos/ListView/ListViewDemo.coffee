###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.ListviewDemoTable extends Demo.DemoTable

	constructor: () ->
		super("demo-table")

	addListview: (description, listview, title = "Example") ->
		CUI.dom.addClass(listview.DOM, "cui-list-view-demo-frame")
		lvDemo = CUI.dom.append(CUI.dom.div("cui-demo-td-abs"), listview.DOM)
		lvDemoTitle = CUI.dom.append(CUI.dom.div("cui-demo-lv-title"), CUI.dom.text(title))
		@addExample(description, [lvDemoTitle, lvDemo])


class Demo.ListViewDemo extends Demo
	constructor: (@opts={}) ->
		super(@opts)

	createListView: ( options = {} ) ->
		options.num_columns ?=	4
		options.num_rows ?=	4
		options.maximize_column ?= []
		options.oversized_cells ?= []
		options.listViewOptions ?= {}
		options.listViewOptions.rowMove ?= false
		options.listViewOptions.fixedRows ?= 1
		options.listViewOptions.fixedCols ?= 1
		options.custom_cells ?= {}
		options.colspans ?= {}
		options.label_rotate90 ?= false

		#create the header row with the names of our columns
		headerRow = new CUI.ListViewRow()

		if not options.listViewOptions.cols
			options.listViewOptions.cols = []
			for column in [0...options.num_columns]
				if column in options.maximize_column
					options.listViewOptions.cols.push( "maximize" )
				else
					options.listViewOptions.cols.push( "auto" )

		list_view = new CUI.ListView( options.listViewOptions )
		if options.listViewOptions.fixedRows > 0

			for column in [0...options.num_columns]
				name = "Column"
				sizing = options.listViewOptions.cols[column]
				if sizing == "maximize"
					name = "Max-Col"
				else if sizing == "fixed"
					name = "Fix-Col"
				headerRow.addColumn(
					new CUI.ListViewHeaderColumn
						label:
							text: name+column
							rotate_90: options.label_rotate90
				)


			list_view.appendRow(headerRow)

		for row in [0...options.num_rows] by 1
			dataRow = new CUI.ListViewRow()
			column = 0
			while column < options.num_columns
				index = column+row*options.num_columns
				text = "Cell "+index
				if index in options.oversized_cells
					text = text+":\nOversized Oversized Oversized\nMore Text\nEven more\nYes!"

				colspan = options.colspans[row]?[column]
				custom = options.custom_cells[row]?[column]

				if custom
					dataRow.addColumn(new CUI.ListViewColumn(colspan: colspan, element: custom ))
				else
					if colspan > 1
						text += " (COLSPAN: "+colspan+")"
					dataRow.addColumn(new CUI.ListViewColumn(colspan: colspan, element: new CUI.Label(text: text, multiline: true)))

				if colspan > 1
					column += colspan - 1
				column++

			list_view.appendRow(dataRow)

		list_view.render()
		list_view

	display: ->


		tests = [
			text: "Ng Examples"
			content: @createNextGenTab
		,
			text: "Simple Examples"
			content: @createSimpleTab
		 ,
		   	text: "Many Cells"
		   	content: @createManyCellsTab
		 ,
		 	text: "Tests"
		 	content: @createTestsTab
		 ,
		  	text: "Listviews inside Layouts"
		  	content: @createLayoutsTab
		 ,
		 	text: "Nested Listviews"
		 	content: @createNestedTab
		 ,
		 	text: "Listview inside Panels"
		 	content: @createListviewInPanelTab
#		 ,
#		 	text: "Listview Layout Performance"
#		 	content: @createListviewLayoutPerformance
#		 ,
#		 	text: "Listview Flex Performance"
#		 	content: @createListviewFlexPerformance
#		 ,
#		 	text: "Isolation"
#		 	content: @createListviewIsolation
		]
		tabs = []

		console.time "ListViewDemo.display"

		for test in tests
			txt = "ListViewDemo.display[#{test.text}]"
			do (test) =>
				tabs.push
					text: test.text
					load_on_show: true
					content: =>
						test.content.call(@)

		tabs = new CUI.Tabs
			tabs: tabs

		console.timeEnd "ListViewDemo.display"
		tabs.DOM


#		options = {
#			num_columns: 100
#			num_rows: 100
#		}
#		list_view = @createListView(options)
#		list_view.DOM

	createTestsWithMaximizeOnOff: (maximize,demo_table) ->

		if maximize
			max = "maximize"
		else
			max = "auto"

		options = {
			listViewOptions:
				maximize: maximize
				cols: [max, "auto","auto","auto"]
				fixedCols: 0
		}
		list_view = @createListView(options)
		demo_table.addExample(CUI.util.dump(options),list_view)

		options = {
			listViewOptions:
				maximize: maximize
				cols: ["auto",max,"auto","auto"]
				fixedCols: 1
		}
		list_view = @createListView(options)
		demo_table.addExample(CUI.util.dump(options),list_view)

		options = {
			listViewOptions:
				maximize: maximize
				cols: ["auto","auto","auto","auto"]
				fixedCols: 1
		}
		list_view = @createListView(options)
		demo_table.addExample(CUI.util.dump(options),list_view)


	createTestsTab: ->
		demo_table = new Demo.ListviewDemoTable()

		@createTestsWithMaximizeOnOff(true,demo_table)
		@createTestsWithMaximizeOnOff(false,demo_table)

		options = {
			listViewOptions:
				cols: ["fixed","fixed","fixed","fixed"]
			oversized_cells: [6,8]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)

		#reduce amount of examples
		return demo_table.table


		options = {
			listViewOptions:
				cols: ["maximize","maximize","auto","auto"]
				fixedCols: 0
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)


		options = {
			listViewOptions:
				cols: ["auto","auto","maximize","maximize"]
				fixedCols: 2
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)


		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedCols: 3
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)

		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedRows: 3
				fixedCols: 3
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)


		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedRows: 2
				fixedCols: 2
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)

		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedRows: 2
				fixedCols: 1
			num_rows: 1
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)


		demo_table.table



	createNextGenTab: ->
		options = {
			maximize_column: [1]
			listViewOptions:
				fixedRows: 1
				fixedCols: 1
				colResize: true

			colspans:
				5: 2: 2

			custom_cells:
				10: 2: new CUI.Input(textarea: true, content_size: true).start().DOM
				13: 1: new CUI.Input(textarea: true).start().DOM
			num_rows: 30
			oversized_cells: [5,10]
		}
		list_view = @createListView(options)

	createSimpleTab: ->
		demo_table = new Demo.ListviewDemoTable()

		if false
			options = {
				listViewOptions:
					fixedCols: 0
				oversized_cells: [2,4,14]
				colspans:
					# third regular row, second column gets a colspan of "2"
					2: 1: 2
				custom_cells:
					2: 1: new CUI.Label( text:"a very long text that should be copied from somewhere else.").DOM
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view)


			options = {
			}

			list_view = @createListView()
			demo_table.addListview(CUI.util.dump(options),list_view)

			options = {
				maximize_column: [1]
				oversized_cells: [6,8]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view)


		options = {
			maximize_column: [0]
			listViewOptions:
				bordered: true
				fixedCols: 0
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view, "Example 1")

		options = {
			maximize_column: [0]
			listViewOptions:
				fixedCols: 0
				colClasses: [null, "list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100"]
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view, "Example 2")

		options = {
			maximize_column: []
			listViewOptions:
				maximize: false
				fixedCols: 0
				colClasses: ["list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100"]
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view, "Example 3")

		options = {
			maximize_column: []
			listViewOptions:
				maximize: false
				fixedCols: 0
				colClasses: ["list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100"]
			label_rotate90: true
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view, "Example 4")



		if 1
			options = {
				# maximize_column: [0]
				listViewOptions:
					fixedCols: 2
				oversized_cells: [4,10]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view, "Example 5")

			options = {
			# maximize_column: [0]
				listViewOptions:
					fixedCols: 2
					fixedRows: 2
				oversized_cells: [4,10]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view, "Example 6")


			options = {
				listViewOptions:
					fixedCols: 2
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view, "Example 7")

			options = {
				listViewOptions:
					fixedCols: 1
					rowMove: true
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview("Moveable rows:"+CUI.util.dump(options),list_view, "Example 8")

			options = {
				listViewOptions:
					fixedCols: 1
					rowMove: true
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview("Moveable rows:"+CUI.util.dump(options),list_view, "Example 9")

			options = {
				listViewOptions:
					fixedCols: 0
					rowMove: true
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview("Moveable rows, No FixedCols: "+CUI.util.dump(options),list_view, "Example 10")

			options = {
				listViewOptions:
					fixedCols: 1
					rowMove: true
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view, "Example 11")

			options = {
				listViewOptions:
					cols: ["auto","fixed","auto","auto"]
					rowMove: true
					fixedCols: 2
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view, "Example 12")


			options = {
				listViewOptions:
					fixedCols: 0
					fixedRows: 0
					cols: ["auto","maximize","auto","maximize"]
				# maximize_column: [0]
			}
			list_view = @createListView(options)
			demo_table.addListview(CUI.util.dump(options),list_view, "Example 13")

		demo_table.table


	createManyCellsTab: ->
		demo_table = new Demo.ListviewDemoTable()

		options = {
			num_columns: 100
			num_rows: 10
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)
		#return @__table

		options = {
			num_columns: 10
			num_rows: 20
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)

		options = {
			num_columns: 10
			num_rows: 4
			maximize_column: [3]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)

		options = {
			num_columns: 4
			num_rows: 20
			maximize_column: [3]
		}
		list_view = @createListView(options)
		demo_table.addListview(CUI.util.dump(options),list_view)



		demo_table.table


	createLayoutsTab: ->

		demo_table = new Demo.ListviewDemoTable()


		# -------------------

		options = {
			num_columns: 3
			num_rows: 4
			listViewOptions:
				maximize: true
			maximize_column: [1]
			custom_cells:
				0: 1: CUI.dom.append(CUI.dom.div(), CUI.dom.text("a very long text that should be copied from somewhere else."))

		}
		list_view = @createListView(options)

		vertical_layout = new CUI.HorizontalLayout
			class: "cui-list-view-demo-frame"
			left:
				flexHandle:
					hidden: false
					closed: false
				content: "left"
			right:
				flexHandle:
					hidden: false
					closed: false
				content: "right"
			center:
				content: list_view.DOM

		demo_table.addListview("maximized Listview inside HorizontalLayout",vertical_layout)


		# -------------------

		options = {
			num_columns: 3
			num_rows: 4
			listViewOptions:
				maximize: true
				fixedCols: 0
			maximize_column: [1]
			custom_cells:
				4: CUI.dom.append(CUI.dom.div(), CUI.dom.text("a very long text that should be copied from somewhere else."))

		}
		list_view = @createListView(options)

		vertical_layout = new CUI.HorizontalLayout
			class: "cui-list-view-demo-frame"
			left:
				flexHandle:
					hidden: false
					closed: false
				content: "left"
			right:
				flexHandle:
					hidden: false
					closed: false
				content: "right"
			center:
				content: list_view.DOM

		demo_table.addListview("maximized Listview inside HorizontalLayout",vertical_layout)

		# -----------------------

		options = {
			num_columns: 4
			num_rows: 10
		}
		list_view = @createListView(options)

		vertical_layout = new CUI.VerticalLayout
			class: "cui-list-view-demo-frame"
			top:
				flexHandle:
					hidden: false
					closed: false
				content: "top"
			bottom:
				flexHandle:
					hidden: false
					closed: false
				content: "bottom"
			center:
				content: list_view.DOM

		demo_table.addListview("maximized Listview inside VerticalLayout",vertical_layout)

		# -------------------

		options = {
			num_columns: 4
			num_rows: 10
			listViewOptions:
				maximize: false
		}
		list_view = @createListView(options)

		vertical_layout = new CUI.VerticalLayout
			class: "cui-list-view-demo-frame"
			top:
				flexHandle:
					hidden: false
					closed: false
				content: "top"
			bottom:
				flexHandle:
					hidden: false
					closed: false
				content: "bottom"
			center:
				content: list_view.DOM

		demo_table.addListview("maximized Listview inside VerticalLayout",vertical_layout)


		# -------------------

		options = {
			num_columns: 10
			num_rows: 10
			listViewOptions:
				maximize: false
		}
		list_view = @createListView(options)

		vertical_layout = new CUI.HorizontalLayout
			class: "cui-list-view-demo-frame"
			left:
				flexHandle:
					hidden: false
					closed: false
				content: "left"
			right:
				flexHandle:
					hidden: false
					closed: false
				content: "right"
			center:
				content: list_view.DOM

		demo_table.addListview("maximized Listview inside HorizontalLayout",vertical_layout)

		# -------------------

		options = {
			num_columns: 3
			num_rows: 10
			listViewOptions:
				maximize: true
			maximize_column: [1]
		}
		list_view = @createListView(options)

		vertical_layout = new CUI.HorizontalLayout
			class: "cui-list-view-demo-frame"
			left:
				flexHandle:
					hidden: false
					closed: false
				content: "left"
			right:
				flexHandle:
					hidden: false
					closed: false
				content: "right"
			center:
				content: list_view.DOM

		demo_table.addListview("maximized Listview inside HorizontalLayout",vertical_layout)


		demo_table.table

	createNestedTab: ->
		demo_table = new Demo.ListviewDemoTable()


	# -------------- nested tabs

		optionsInnerListview =
			num_columns: 2
			num_rows: 2
			listViewOptions:
				maximize: false

		innerListview = @createListView( optionsInnerListview )

		tabs = new CUI.Tabs
			footer_right: "Right"
			footer_left: "Left"
			maximize: false
			tabs: [
				text: "testTab1"
				content: innerListview.DOM
			,
				text: "testTab2"
				content: new CUI.Label( text: "Tab 2: Very short test text. 1 2 3 4 5").DOM
			]

		options =
			num_columns: 4
			num_rows: 4
			custom_cells:
				0: 1: tabs.DOM


		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame")

		demo_table.addListview(CUI.util.dump(options)+CUI.util.dump(options2),list_view)

		# -------------- nested inside fixed column

		options =
			num_columns: 2
			num_rows: 2
			listViewOptions:
				maximize: false

		child_list_view = @createListView(options)

		options2 =
			num_columns: 4
			num_rows: 4
			colspans:
				1: 2: 2
			custom_cells:
				0: 1: child_list_view.DOM

		list_view = @createListView(options2)


		demo_table.addListview(CUI.util.dump(options)+CUI.util.dump(options2),list_view)


		# -------------- nested inside fixed column with colspan

		options =
			num_columns: 2
			num_rows: 2
			listViewOptions:
				maximize: false
			oversized_cells: [1,2]

		child_list_view = @createListView(options)

		options2 =
			num_columns: 4
			num_rows: 4
			colspans:
				0: 1: 2
			custom_cells:
				0: 1: child_list_view.DOM


		list_view = @createListView(options2)
		demo_table.addListview(CUI.util.dump(options)+CUI.util.dump(options2),list_view)


		# -------------------------nested listview inside maxed column ----------------

		options = {
			num_columns: 2
			num_rows: 2
		}
		child_list_view = @createListView(options)

		options2 = {
			num_columns: 5
			num_rows: 5
			listViewOptions:
				fixedCols: 1
				rowMove: true
			maximize_column: [1]
		}
		child_list_view2 = @createListView(options2)

		options3 = {
			num_columns: 4
			num_rows: 4
			custom_cells: {
				1: 1: child_list_view.DOM
				3: 1: child_list_view2.DOM
			}
			maximize_column: [1]
		}
		list_view = @createListView(options3)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame-y")

		demo_table.addListview(CUI.util.dump(options)+CUI.util.dump(options2)+CUI.util.dump(options3),list_view)


		# ----------------------------nested listview inside non maxed column-------------

		options = {
			num_columns: 2
			num_rows: 2
		}
		child_list_view = @createListView(options)

		options2 = {
			num_columns: 5
			num_rows: 5
			listViewOptions:
				fixedCols: 1
				rowMove: true
			maximize_column: [1]
		}
		child_list_view2 = @createListView(options2)


		options = {
			num_columns: 4
			num_rows: 4
			custom_cells: {
				1: 3: child_list_view.DOM
				4: 2: child_list_view2.DOM
			}
			#maximize_column: [1]
		}
		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame-y")
		demo_table.addListview(CUI.util.dump(options),list_view)


		# ----------------------------maxed listview inside non maxed-x listview inside non maxed-x listview-------------

		options = {
			num_columns: 2
			num_rows: 2
		}
		child_list_view = @createListView(options)


		options3 = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				fixedCols: 1
				rowMove: true
			maximize_column: [1]
		}
		child_list_view3 = @createListView(options3)

		options2 = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				fixedCols: 1
				rowMove: true
			maximize_column: [2]
			custom_cells: {
				0: 1: child_list_view3.DOM
			}
		}
		child_list_view2 = @createListView(options2)



		options = {
			num_columns: 4
			num_rows: 4
			custom_cells: {
				0: 2: child_list_view.DOM
				2: 4: child_list_view2.DOM
			}
		#maximize_column: [1]
		}
		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame-y")
		demo_table.addListview(CUI.util.dump(options),list_view)


		# ----------------------------maxed listview inside non maxed-x listview inside non maxed-x listview- with fixedcols0------------

		options = {
			num_columns: 2
			num_rows: 2
		}
		child_list_view = @createListView(options)


		options3 = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				rowMove: true
			maximize_column: [1]
		}
		child_list_view3 = @createListView(options3)

		options2 = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				rowMove: true
			maximize_column: [2]
			custom_cells: {
				2: 3: child_list_view3.DOM
			}
		}
		child_list_view2 = @createListView(options2)



		options = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				fixedCols: 0
				rowMove: true
			custom_cells: {
				2: 3: child_list_view.DOM
				3: 3: child_list_view2.DOM
			}
		#maximize_column: [1]
		}
		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame-y")
		demo_table.addListview(CUI.util.dump(options),list_view)


		# ----------------------------maxed listview inside non maxed-x listview inside non maxed-x listview- with fixedcols0------------


		options2 = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				rowMove: true
			maximize_column: [2]

		}
		child_list_view2 = @createListView(options2)



		options = {
			num_columns: 4
			num_rows: 4
			listViewOptions:
				fixedCols: 0
				rowMove: true
			custom_cells: {
				9: child_list_view2.DOM
			}
		#maximize_column: [1]
		}
		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame-y")

		demo_table.addListview(CUI.util.dump(options),list_view)



		# ---------------- table inside listview ------------------

		inner_table = CUI.dom.table("inner-table")
		CUI.dom.append(inner_table, CUI.dom.append(CUI.dom.tr_one_row( CUI.dom.div( ), CUI.dom.text("innerTable"))))

		options = {
			listViewOptions:
				fixedCols: 0
			num_columns: 2
			num_rows: 2
			custom_cells: {
				0: inner_table

			}
		}
		list_view = @createListView(options)

		demo_table.addListview(CUI.util.dump(options),list_view)


		demo_table.table

	createListviewInPanelTab: ()->

		demo_table = new Demo.ListviewDemoTable()


		# --------------------------

		options = {
			listViewOptions:
				fixedCols: 1
			num_columns: 4
			num_rows: 4
			maximize_column: [3]
		}
		list_view = @createListView(options)

		options2 = {
			listViewOptions:
				fixedCols: 1
				maximize: false
			num_columns: 4
			num_rows: 4
		}
		list_view2 = @createListView(options2)


		p1 = new CUI.Panel
			text: "Panel with maximized Listview"
			content: list_view.DOM

		p2 = new CUI.Panel
			text: "Panel with non-maximized Listview"
			closed: true
			content: list_view2.DOM

		demo_table.addExample("Listviews inside Panels", [p1, p2])

		#----------------------

		demo_table.table

	createListviewLayoutPerformance: ()->


		options2 = {
			listViewOptions:
				fixedCols: 1
				maximize: true
			num_columns: 4
			num_rows: 10
		}


		horizontal_layout = new CUI.HorizontalLayout
			left:
				content: @createListView(options2)
			center:
				content:
					new CUI.VerticalLayout
						center:
							content: [
								@createListView(options2)
							,
								@createListView(options2)
							,
								@createListView(options2)
							]
			right:
				content: @createListView(options2)

		horizontal_layout.DOM

	createListviewFlexPerformance: ->

		array = []

		for i in [0..10]
			options = {
				listViewOptions:
					fixedCols: 1
					maximize: true
				num_columns: 4
				num_rows: 10
				maximize_column: [1]
			}

			list_view = @createListView(options)

			array.push(list_view.DOM)

		array

	createListviewIsolation: ->

		array = []

		options = {
			listViewOptions:
				fixedCols: 1
				maximize: true
			num_columns: 100
			num_rows: 100
			maximize_column: [1]
		}

		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame")


		array.push(list_view.DOM)

		options = {
			listViewOptions:
				fixedCols: 1
				maximize: true
			num_columns: 4
			num_rows: 10
			maximize_column: [1]
		}

		list_view = @createListView(options)
		CUI.dom.addClass(list_view.DOM, "cui-list-view-demo-frame")

		array.push(list_view.DOM)


		array




Demo.register(new Demo.ListViewDemo())
