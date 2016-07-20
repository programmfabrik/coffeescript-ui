
class ListviewDemoTable extends DemoTable
	
	constructor: () ->
		super("demo-table")

	addListview: (description, listview) ->
		listview.addClass("cui-list-view-demo-frame")
		@addExample(description,listview.DOM)



class ListViewDemo extends Demo
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
		headerRow = new ListViewRow()

		if not options.listViewOptions.cols
			options.listViewOptions.cols = []
			for column in [0...options.num_columns]
				if column in options.maximize_column
					options.listViewOptions.cols.push( "maximize" )
				else
					options.listViewOptions.cols.push( "auto" )

		list_view = new ListView( options.listViewOptions )
		if options.listViewOptions.fixedRows > 0

			for column in [0...options.num_columns]
				name = "Column"
				sizing = options.listViewOptions.cols[column]
				if sizing == "maximize"
					name = "Max-Col"
				else if sizing == "fixed"
					name = "Fix-Col"
				headerRow.addColumn(
					new ListViewHeaderColumn
						label:
							text: name+column
							rotate_90: options.label_rotate90
				)


			list_view.appendRow(headerRow)

		for row in [0...options.num_rows] by 1
			dataRow = new ListViewRow()
			column = 0
			while column < options.num_columns
				index = column+row*options.num_columns
				text = "Cell "+index
				if index in options.oversized_cells
					text = "Oversized Oversized Oversized "+text

				colspan = options.colspans[row]?[column]
				custom = options.custom_cells[row]?[column]

				if custom
					dataRow.addColumn(new ListViewColumn(colspan: colspan, element: custom ))
				else
					if colspan > 1
						text += " (COLSPAN: "+colspan+")"
					dataRow.addColumn(new ListViewColumn(colspan: colspan, text: text ))

				if colspan > 1
					column += colspan - 1
				column++

			list_view.appendRow(dataRow)

		list_view.render()
		list_view

	display: ->


		tests = [
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
			console.time(txt)
			tabs.push
				text: test.text
				content: test.content.call(@)
			console.timeEnd(txt)

		tabs = new Tabs
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
		demo_table.addExample(dump(options),list_view)

		options = {
			listViewOptions:
				maximize: maximize
				cols: ["auto",max,"auto","auto"]
				fixedCols: 1
		}
		list_view = @createListView(options)
		demo_table.addExample(dump(options),list_view)

		options = {
			listViewOptions:
				maximize: maximize
				cols: ["auto","auto","auto","auto"]
				fixedCols: 1
		}
		list_view = @createListView(options)
		demo_table.addExample(dump(options),list_view)


	createTestsTab: ->
		demo_table = new ListviewDemoTable()

		@createTestsWithMaximizeOnOff(true,demo_table)
		@createTestsWithMaximizeOnOff(false,demo_table)

		options = {
			listViewOptions:
				cols: ["fixed","fixed","fixed","fixed"]
			oversized_cells: [6,8]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		#reduce amount of examples
		return demo_table.table


		options = {
			listViewOptions:
				cols: ["maximize","maximize","auto","auto"]
				fixedCols: 0
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)


		options = {
			listViewOptions:
				cols: ["auto","auto","maximize","maximize"]
				fixedCols: 2
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)


		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedCols: 3
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedRows: 3
				fixedCols: 3
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)


		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedRows: 2
				fixedCols: 2
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			listViewOptions:
				cols: ["auto","auto","auto","maximize"]
				fixedRows: 2
				fixedCols: 1
			num_rows: 1
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)


		demo_table.table



	createSimpleTab: ->
		demo_table = new ListviewDemoTable()

		if false
			options = {
				listViewOptions:
					fixedCols: 0
				oversized_cells: [2,4,14]
				colspans:
					# third regular row, second column gets a colspan of "2"
					2: 1: 2
				custom_cells:
					2: 1: new Label( text:"a very long text that should be copied from somewhere else.").DOM
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)


			options = {
			}

			list_view = @createListView()
			demo_table.addListview(dump(options),list_view)

			options = {
				maximize_column: [1]
				oversized_cells: [6,8]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)


		options = {
			maximize_column: [0]
			listViewOptions:
				fixedCols: 0
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			maximize_column: [0]
			listViewOptions:
				fixedCols: 0
				colClasses: [null, "list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100"]
				autoLayout: false
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			maximize_column: []
			listViewOptions:
				maximize: false
				autoLayout: false
				fixedCols: 0
				colClasses: ["list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100"]
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			maximize_column: []
			listViewOptions:
				maximize: false
				autoLayout: false
				fixedCols: 0
				colClasses: ["list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100", "list-view-demo-width-100"]
			label_rotate90: true
			oversized_cells: [4,10]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)



		if 1
			options = {
				# maximize_column: [0]
				listViewOptions:
					fixedCols: 2
				oversized_cells: [4,10]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)

			options = {
			# maximize_column: [0]
				listViewOptions:
					fixedCols: 2
					fixedRows: 2
				oversized_cells: [4,10]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)


			options = {
				listViewOptions:
					fixedCols: 2
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)

			options = {
				listViewOptions:
					fixedCols: 1
					rowMove: true
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview("Moveable rows with AutoLayout: "+dump(options),list_view)

			options = {
				listViewOptions:
					fixedCols: 1
					rowMove: true
					autoLayout: false
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview("Moveable rows in FixedColumn without Autolayout: !!Will never work cause fixed column and other columns are not syncing height when autolayout is false!!"+dump(options),list_view)

			options = {
				listViewOptions:
					fixedCols: 0
					rowMove: true
					autoLayout: false
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview("Moveable rows without Autolayout, No FixedCols: "+dump(options),list_view)

			options = {
				listViewOptions:
					fixedCols: 1
					rowMove: true
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)

			options = {
				listViewOptions:
					cols: ["auto","fixed","auto","auto"]
				oversized_cells: [2,4,14]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)


			options = {
				listViewOptions:
					fixedCols: 0
					fixedRows: 0
					cols: ["auto","maximize","auto","maximize"]
				# maximize_column: [0]
			}
			list_view = @createListView(options)
			demo_table.addListview(dump(options),list_view)

		demo_table.table


	createManyCellsTab: ->
		demo_table = new ListviewDemoTable()

		options = {
			num_columns: 100
			num_rows: 10
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)
		#return @__table

		options = {
			num_columns: 10
			num_rows: 20
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			num_columns: 10
			num_rows: 4
			maximize_column: [3]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)

		options = {
			num_columns: 4
			num_rows: 20
			maximize_column: [3]
		}
		list_view = @createListView(options)
		demo_table.addListview(dump(options),list_view)



		demo_table.table


	createLayoutsTab: ->

		demo_table = new ListviewDemoTable()


		# -------------------

		options = {
			num_columns: 3
			num_rows: 4
			listViewOptions:
				maximize: true
			maximize_column: [1]
			custom_cells:
				0: 1: $div().append($text("a very long text that should be copied from somewhere else."))

		}
		list_view = @createListView(options)

		vertical_layout = new HorizontalLayout
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
				4: $div().append($text("a very long text that should be copied from somewhere else."))

		}
		list_view = @createListView(options)

		vertical_layout = new HorizontalLayout
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

		vertical_layout = new VerticalLayout
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

		vertical_layout = new VerticalLayout
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

		vertical_layout = new HorizontalLayout
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

		vertical_layout = new HorizontalLayout
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
		demo_table = new ListviewDemoTable()


	# -------------- nested tabs

		optionsInnerListview =
			num_columns: 2
			num_rows: 2
			listViewOptions:
				maximize: false

		innerListview = @createListView( optionsInnerListview )

		tabs = new Tabs
			footer_right: "Right"
			footer_left: "Left"
			maximize: false
			tabs: [
				text: "testTab1"
				content: innerListview.DOM
			,
				text: "testTab2"
				content: new Label( text: "Tab 2: Very short test text. 1 2 3 4 5").DOM
			]

		options =
			num_columns: 4
			num_rows: 4
			custom_cells:
				0: 1: tabs.DOM


		list_view = @createListView(options)
		list_view.addClass("cui-list-view-demo-frame")

		demo_table.addListview(dump(options)+dump(options2),list_view)

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
		

		demo_table.addListview(dump(options)+dump(options2),list_view)


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
		demo_table.addListview(dump(options)+dump(options2),list_view)


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
		list_view.addClass("cui-list-view-demo-frame-y")

		demo_table.addListview(dump(options)+dump(options2)+dump(options3),list_view)


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
		list_view.addClass("cui-list-view-demo-frame-y")
		demo_table.addListview(dump(options),list_view)


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
		list_view.addClass("cui-list-view-demo-frame-y")
		demo_table.addListview(dump(options),list_view)


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
		list_view.addClass("cui-list-view-demo-frame-y")
		demo_table.addListview(dump(options),list_view)


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
		list_view.addClass("cui-list-view-demo-frame-y")

		demo_table.addListview(dump(options),list_view)



		# ---------------- table inside listview ------------------

		inner_table = $table("inner-table")
		inner_table.append( $tr_one_row( $div( ).append($text("innerTable"))  ) )

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

		demo_table.addListview(dump(options),list_view)


		demo_table.table

	createListviewInPanelTab: ()->

		demo_table = new ListviewDemoTable()


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


		p1 = new Panel
			text: "Panel with maximized Listview"
			content: list_view.DOM

		p2 = new Panel
			text: "Panel with non-maximized Listview"
			closed: true
			content: list_view2.DOM

		layout = $div("listview-in-panel-panels-container").append(p1.DOM).append(p2.DOM)

		demo_table.addListview("Listviews inside Panels",layout)

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


		horizontal_layout = new HorizontalLayout
			left:
				content: @createListView(options2)
			center:
				content:
					new VerticalLayout
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
		list_view.addClass("cui-list-view-demo-frame")


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
		list_view.addClass("cui-list-view-demo-frame")

		array.push(list_view.DOM)


		array




Demo.register(new ListViewDemo())