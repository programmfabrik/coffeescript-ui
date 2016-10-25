class DragDropSelectDemo extends Demo
	getName: ->
		"Drag & Drop"

	display: ->


		demo_table = new DemoTable('cui-drag-drop-select-demo-table')

		demo_table.addDivider("drag & drop")

		drag_container = $div("drag-drop-select-demo-draggable-container")

		for i in [0..400]
			drag_container.append($div("drag-drop-select-demo-draggable-container-item").append(new Label(text: ""+i).DOM))

		demo_table.addExample("Draggable, Lasso select", drag_container)

		new Draggable
			selector: ".drag-drop-select-demo-draggable-container-item"
			element: drag_container

		new Lasso
			selector: ".drag-drop-select-demo-draggable-container"
			# filter: ".drag-drop-select-demo-draggable-container-item"
			selected: (ev, info) =>
				for el in info.elements
					$(el).addClass("mark-lassoed")

				CUI.setTimeout
					ms: 500
					call: =>
						for el in info.elements
							$(el).removeClass("mark-lassoed")
				return

			element: drag_container

		drop_container = $div("drag-drop-select-demo-droppable-container", style: "position: relative;")

		drop_container_inner = $div("drag-drop-select-demo-droppable-container-inner", style: "position: absolute;").appendTo(drop_container)

		Events.listen
			type: "dblclick"
			node: drop_container_inner
			call: (ev) =>
				drop_container_inner.css
					top: ""
					left: ""
					width: ""
					height: ""

		demo_table.addExample("Droppable & Movable & Resizable", drop_container)

		new Droppable
			element: drop_container_inner

		new Droppable
			element: drop_container
			dropHelper: true

		dim_inner = null
		dim_outer = null

		getLimitRect = =>

			dim = DOM.getDimensions(drop_container)

			width = drop_container.width()
			height = drop_container.height()

			rect =
				min_x: dim.paddingLeft
				min_y: dim.paddingRight
				min_w: 10
				min_h: 10
				max_x: width + dim.paddingLeft
				max_w: width
				max_y: height + dim.paddingTop
				max_h: height

			rect

		new Movable
			element: drop_container_inner
			limitRect: getLimitRect

		new Resizable
			element: drop_container_inner
			limitRect: getLimitRect

		sort_container = $div("drag-drop-select-demo-sortable-container")

		for i in [0..10]
			sort_container.append($div("drag-drop-select-demo-sortable-container-item item-"+i, item: ""+i).append(new Label(text: ""+i).DOM))

		sort_container2 = $div("drag-drop-select-demo-sortable-container2")

		for i in [0..100]
			sort_container2.append($div("drag-drop-select-demo-sortable-container-item item-"+i, item: ""+i).append(new Label(text: ""+i).DOM))

		new Sortable
			element: sort_container
			axis: "y"
			sorted: (ev, from_idx, to_idx) =>
				@log("You sorted **"+from_idx+"** to **"+to_idx+"**.")

		new Sortable
			element: sort_container2
			sorted: (ev, from_idx, to_idx) =>
				@log("You sorted **"+from_idx+"** to **"+to_idx+"**.")

		new Sortable
			element: sort_container
			axis: "y"

		new Droppable
			element: sort_container2
			targetHelper: true
			dropHelper: true
			selector: ".drag-drop-select-demo-sortable-container-item"

		new Droppable
			element: sort_container
			targetHelper: true
			selector: ".drag-drop-select-demo-sortable-container-item"

		demo_table.addExample("Sortable & Droppable", [sort_container, sort_container2], null, "cui-demo-sortable")
		demo_table.table

Demo.register(new DragDropSelectDemo())