###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.DragDropSelectDemo extends Demo
	getName: ->
		"Drag & Drop"

	display: ->


		demo_table = new Demo.DemoTable('cui-drag-drop-select-demo-table')

		demo_table.addDivider("drag & drop")

		drag_container = CUI.dom.div("drag-drop-select-demo-draggable-container")

		for i in [0..400]
			CUI.dom.append(drag_container, CUI.dom.append(CUI.dom.div("drag-drop-select-demo-draggable-container-item"), new CUI.Label(text: ""+i).DOM))

		demo_table.addExample("Draggable, Lasso select", drag_container)

		new CUI.Draggable
			selector: ".drag-drop-select-demo-draggable-container-item"
			element: drag_container

		new CUI.Lasso
			selector: ".drag-drop-select-demo-draggable-container"
			# filter: ".drag-drop-select-demo-draggable-container-item"
			selected: (ev, info) =>
				for el in info.elements
					CUI.dom.addClass(el, "mark-lassoed")

				CUI.setTimeout
					ms: 500
					call: =>
						for el in info.elements
							CUI.dom.removeClass(el, "mark-lassoed")
				return

			element: drag_container

		drop_container = CUI.dom.div("drag-drop-select-demo-droppable-container", style: "position: relative;")

		drop_container_inner = CUI.dom.div("drag-drop-select-demo-droppable-container-inner", style: "position: absolute;")
		CUI.dom.append(drop_container, drop_container_inner)

		CUI.Events.listen
			type: "dblclick"
			node: drop_container_inner
			call: (ev) =>
				CUI.dom.setStyle(drop_container_inner,
					top: ""
					left: ""
					width: ""
					height: ""
				)

		demo_table.addExample("Droppable & Movable & Resizable", drop_container)

		new CUI.Droppable
			element: drop_container_inner

		new CUI.Droppable
			element: drop_container
			dropHelper: true

		dim_inner = null
		dim_outer = null

		getLimitRect = =>

			dim = CUI.dom.getDimensions(drop_container)

			width = CUI.dom.width(drop_container)
			height = CUI.dom.height(drop_container)

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

		new CUI.Movable
			element: drop_container_inner
			limitRect: getLimitRect

		new CUI.Resizable
			element: drop_container_inner
			limitRect: getLimitRect

		sort_container = CUI.dom.div("drag-drop-select-demo-sortable-container")

		for i in [0..10]
			CUI.dom.append(sort_container, CUI.dom.append(CUI.dom.div("drag-drop-select-demo-sortable-container-item item-"+i, item: ""+i), new CUI.Label(text: ""+i).DOM))

		sort_container2 = CUI.dom.div("drag-drop-select-demo-sortable-container2")

		for i in [0..100]
			CUI.dom.append(sort_container2, CUI.dom.append(CUI.dom.div("drag-drop-select-demo-sortable-container-item item-"+i, item: ""+i), new CUI.Label(text: ""+i).DOM))

		new CUI.Sortable
			element: sort_container
			axis: "y"
			sorted: (ev, from_idx, to_idx) =>
				@log("You sorted **"+from_idx+"** to **"+to_idx+"**.")

		new CUI.Sortable
			element: sort_container2
			sorted: (ev, from_idx, to_idx) =>
				@log("You sorted **"+from_idx+"** to **"+to_idx+"**.")

		new CUI.Sortable
			element: sort_container
			axis: "y"

		new CUI.Droppable
			element: sort_container2
			targetHelper: true
			dropHelper: true
			selector: ".drag-drop-select-demo-sortable-container-item"

		new CUI.Droppable
			element: sort_container
			targetHelper: true
			selector: ".drag-drop-select-demo-sortable-container-item"

		demo_table.addExample("Sortable & Droppable", [sort_container, sort_container2], null, "cui-demo-sortable")
		demo_table.table

Demo.register(new Demo.DragDropSelectDemo())