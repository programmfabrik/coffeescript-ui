###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.BoundingBoxDemo extends Demo
	getGroup: ->
		"Demo"

	display: ->
		@bb = CUI.dom.div("cui-bounding-box-demo-bounding-box")
		@bb_inner = CUI.dom.div("cui-bounding-box-demo-inner")

		@data =
			degrees: 20
			width: 400
			height: 200

		CUI.setTimeout =>
			@setDegrees()

		form = new CUI.Form
			data: @data
			onDataChanged: =>
				@setDegrees()
			fields: [
				form:
					label: "Degrees"
				type: CUI.NumberInput
				name: "degrees"
			,
				form:
					label: "Width"
				type: CUI.NumberInput
				min: 0
				name: "width"
			,
				form:
					label: "Height"
				type: CUI.NumberInput
				min: 0
				name: "height"
			]
		.start()

		[
			Demo.dividerLabel("bounding box")
		,
			new CUI.VerticalLayout
				top:
					content: form
				center:
					content: [@bb, @bb_inner]
		]

	rotateCorner: (x,y,degree) ->
		radian = degree / 180 * Math.PI
		x_out = Math.cos(radian) * x - Math.sin(radian) * y
		y_out = Math.cos(radian) * y + Math.sin(radian) * x

		out =
			x: Math.abs(x_out)
			y: Math.abs(y_out)



	setDegrees: ->
		deg = parseInt(@data.degrees)
		deg = ((deg % 360) + 360) % 360
		CUI.dom.setStyle(@bb_inner,
			width: parseInt(@data.width)
			height: parseInt(@data.height)
		)
		CUI.dom.setStyleOne(@bb_inner, "transform", "");

		dim = CUI.dom.getDimensions(@bb_inner)

		CUI.dom.empty(@bb_inner)
		CUI.dom.append(@bb_inner, CUI.dom.text(deg+"°"))

		w = dim.borderBoxWidth
		h = dim.borderBoxHeight

		corner1 = @rotateCorner(w,h,deg)
		corner2 = @rotateCorner(w,-h,deg)

		width = Math.max(corner1.x,corner2.x)
		height = Math.max(corner1.y,corner2.y)

		#console.debug("degrees:", deg, dim, w, h, width, height)

		CUI.dom.setStyle(@bb,
			width: width
			height: height
		)


		rect = CUI.dom.getRect(@bb_inner)
		console.debug(dim, rect)

		CUI.dom.setStyleOne(@bb_inner, "transform", "translate(-50%, -50%) rotateZ(-"+deg+"deg)")



Demo.register(new Demo.BoundingBoxDemo())