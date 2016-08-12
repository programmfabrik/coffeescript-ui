class DragDropSelectDemo extends Demo
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
			filter: ".drag-drop-select-demo-draggable-container-item"
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

		drop_container = $div("drag-drop-select-demo-droppable-container")

		drop_container_inner = $div("drag-drop-select-demo-droppable-container-inner henk").appendTo(drop_container)

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

		getLimitRect = =>
			width = drop_container.width()
			height = drop_container.height()
			min_x: 0
			min_y: 0
			min_w: 1
			min_h: 1
			max_x: width
			max_w: width
			max_y: height
			max_h: height

		new Movable
			helper_parent: "parent"
			element: drop_container_inner
			limitRect: getLimitRect

		new Resizable
			element: drop_container_inner
			limitRect: getLimitRect

		sort_container = $div("drag-drop-select-demo-sortable-container")

		for i in [0..10]
			sort_container.append($div("drag-drop-select-demo-sortable-container-item").append(new Label(text: ""+i).DOM))

		demo_table.addExample("Sortable", sort_container)

		new Sortable
			element: sort_container
			sorted: ->


		demo_table.table

Demo.register(new DragDropSelectDemo())