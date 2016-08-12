class BoundingBoxDemo extends Demo
	display: ->
		@bb = $div("cui-bounding-box-demo-bounding-box")
		@bb_inner = $div("cui-bounding-box-demo-inner")

		@data =
			degrees: 20
			width: 400
			height: 200

		CUI.setTimeout =>
			@setDegrees()

		form = new Form
			data: @data
			onDataChanged: =>
				@setDegrees()
			fields: [
				form:
					label: "Degrees"
				type: NumberInput
				name: "degrees"
			,
				form:
					label: "Width"
				type: NumberInput
				min: 0
				name: "width"
			,
				form:
					label: "Height"
				type: NumberInput
				min: 0
				name: "height"
			]
		.start()

		[
			Demo.dividerLabel("bounding box")
		,
			new VerticalLayout
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
		@bb_inner.css
			width: parseInt(@data.width)
			height: parseInt(@data.height)
		@bb_inner.css("transform", "");

		dim = DOM.getDimensions(@bb_inner[0])

		@bb_inner.empty().append($text(deg+"°"))

		w = dim.borderBoxWidth
		h = dim.borderBoxHeight

		corner1 = @rotateCorner(w,h,deg)
		corner2 = @rotateCorner(w,-h,deg)

		width = Math.max(corner1.x,corner2.x)
		height = Math.max(corner1.y,corner2.y)

		#CUI.debug("degrees:", deg, dim, w, h, width, height)

		@bb.css
			width: width
			height: height


		rect = DOM.getRect(@bb_inner[0])
		CUI.debug(dim, rect)

		@bb_inner.css("transform", "translate(-50%, -50%) rotateZ(-"+deg+"deg)")



Demo.register(new BoundingBoxDemo())