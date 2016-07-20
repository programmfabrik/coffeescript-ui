
#TODO add flexhandles to demo layouts

class VerticalLayoutDemo extends Demo


	__addDivider: (text) ->

		tr = $tr_one_row( $span("title cui-demo-title-3").text(text) )
		.addClass("cui-demo-divider")

		tr.append($tr())
		tr.append($tr())

		@__table.append( tr )

	#sample data for listview
	createDataTable: ->
		table = $table("")
		table.append(
				$tr_one_row(
						$div("cui-demo-cell-dummy-auto").append( $text("Content1") ),
						$div("cui-demo-cell-dummy").append( $text("Content2") )
				)
			);
		table

	display: ->
		@__table = $table("demo-table")

		content = "center<br> <br> here<br>you<br>can<br>place<br>content.<br><br> here<br>you<br>can<br>place<br>content.<br><br> here<br>you<br>can<br>place<br>contentEnd <span class = 'cui-demo-wide-span'>uoeuaotehudoahetudheduieui eoudieeuidteuhdioeuietuoidtenuideui otheduniheudhitndoeuidoehnuieieueu </span>"

		# --------------

		vertical_layout = new VerticalLayout
				top:
					content: "top"
					flexHandle:
						hidden: false
						closed: false
				center:
					content: content
				bottom:
					content: "bottom"
					flexHandle:
						hidden: false
						closed: false


		vertical_layout.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout, option = maximize: true", vertical_layout.DOM))

		vertical_layout2 = new VerticalLayout
			maximize: false
			top:
				content: "top"
			bottom:
				content: "bottom"
			center:
				content: content

		vertical_layout2.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout, option = maximize: false", vertical_layout2.DOM))

		# ----------- horizontal in vertical layout

		horizontal_layout = new HorizontalLayout
			left:
				content: "left"
			center:
				content: content
			right:
				content: "right"


		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: horizontal_layout
			bottom:
				content: "bottom"



		vertical_layout.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout contains Horizontal", vertical_layout.DOM))


		# --------- vertical in wertical -------------------

		inner_vertical_layout = new VerticalLayout
			top:
				content: "inner top"
			center:
				content: content
			bottom:
				content: "inner bottom"


		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: inner_vertical_layout
			bottom:
				content: "bottom"

		vertical_layout.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout contains Vertical", vertical_layout.DOM))

		# --------- vertical in wertical in vertical -------------------

		inner2_vertical_layout = new VerticalLayout
			top:
				content: "inner2 top"
			center:
				content: content
			bottom:
				content: "inner2 bottom"

		inner1_vertical_layout = new VerticalLayout
			top:
				content: "inner1 top"
			center:
				content: inner2_vertical_layout
			bottom:
				content: "inner1 bottom"



		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: inner1_vertical_layout
			bottom:
				content: "bottom"

		vertical_layout.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout contains Vertical in Vertical", vertical_layout.DOM))


		# --------- Maximized Layout inside Layout-bottom -------------------


		inner_bottom_vertical_layout = new VerticalLayout
			top:
				content: "inner2 top"
			center:
				content: content
			bottom:
				content: "inner2 bottom"

		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: "center"
			bottom:
				content: inner_bottom_vertical_layout

		vertical_layout.addClass("cui-demo-vertical-layout-big")
		@__table.append($tr_one_row("Maximized Layout inside Layout-Bottom", vertical_layout.DOM))

		# --------- Vertical inside Vertical Center and Bottom -------------------

		inner_vertical_layout = new VerticalLayout
			top:
				content: "inner top"
			center:
				content: content
			bottom:
				content: "inner bottom"

		inner_bottom_vertical_layout = new VerticalLayout
			top:
				content: "inner2 top"
			center:
				content: content
			bottom:
				content: "inner2 bottom"

		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: inner_vertical_layout
			bottom:
				content: inner_bottom_vertical_layout

		vertical_layout.addClass("cui-demo-vertical-layout-big")
		@__table.append($tr_one_row("Vertical inside Vertical Center and Bottom<br>ERROR: bottom has 0 height.", vertical_layout.DOM))

		# --------- vertical in horizontal in vertical -------------------

		inner2_vertical_layout = new VerticalLayout
			top:
				content: "inner2 top"
			center:
				content: content
			bottom:
				content: "inner2 bottom"

		inner1_horizontal_layout = new HorizontalLayout
			left:
				content: "inner1 left"
			center:
				content: inner2_vertical_layout
			right:
				content: "inner1 right"

		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: inner1_horizontal_layout
			bottom:
				content: "bottom"

		vertical_layout.addClass("cui-demo-vertical-layout-big")
		@__table.append($tr_one_row("vertical in horizontal in vertical layout", vertical_layout.DOM))


		# --------- pane layout -------------------

		pane_header_layout = new HorizontalLayout
			left:
				content: "header left"
			center:
				content: "header center"
			right:
				content: "header right"

		pane_layout = new VerticalLayout
			top:
				content: pane_header_layout
			center:
				content: "pane content"
			bottom:
				content: "pan footer"

		pane_layout.addClass("cui-demo-vertical-layout-big")
		@__table.append($tr_one_row("pane layout", pane_layout.DOM))


		# -----------------

		simple = new SimplePane
			header_left: "left"
			header_center: "center"
			header_right: "right"
			content: content

			footer_left: "left"
			footer_right: "right"

		simple.addClass("cui-demo-vertical-layout")

		@__table.append($tr_one_row("simple pane", simple.DOM))


		# --------- unmaximized verticals in vertical -------------------

		inner2_vertical_layout = new VerticalLayout
			maximize: false
			top:
				content: "inner2 top"
			center:
				content: content
			bottom:
				content: "inner2 bottom"

		inner1_vertical_layout = new VerticalLayout
			maximize: false
			top:
				content: "inner1 top"
			center:
				content: content
			bottom:
				content: "inner1 bottom"

		vertical_layout = new VerticalLayout
			top:
				content: "top"
			center:
				content: [
					inner1_vertical_layout
					#inner2_vertical_layout
				]
			bottom:
				content: "bottom"

		vertical_layout.addClass("cui-demo-vertical-layout-big")
		@__table.append($tr_one_row("unmaximized verticals in vertical layout<br>TODO use align-items: flex-start to avoid inner horizontal scrollbars.", vertical_layout.DOM))


		# ----------- horizontal in vertical layout with 100% content

		horizontal_layout = new HorizontalLayout
			left:
				content: $div("cui-demo-test-full-width-and-height")
			center:
				content: $div("cui-demo-test-full-width-and-height")
			right:
				content: $div("cui-demo-test-full-width-and-height")


		vertical_layout = new VerticalLayout
			top:
				content: $div("cui-demo-test-full-width-and-height")
			center:
				content: horizontal_layout
			bottom:
				content: $div("cui-demo-test-full-width-and-height")

		vertical_layout.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout contains Horizontal with 100% sized content.", vertical_layout.DOM))


		# ----------- vertical in vertical layout with 100% content

		inner_vertical_layout = new VerticalLayout
			top:
				content: $div("cui-demo-test-full-width-and-height")
			center:
				content: $div("cui-demo-test-full-width-and-height")
			bottom:
				content: $div("cui-demo-test-full-width-and-height")


		vertical_layout = new VerticalLayout
			top:
				content: $div("cui-demo-test-full-width-and-height")
			center:
				content: inner_vertical_layout
			bottom:
				content: $div("cui-demo-test-full-width-and-height")

		vertical_layout.addClass("cui-demo-vertical-layout")
		@__table.append($tr_one_row("Vertical Layout contains Vertical with 100% sized content.", vertical_layout.DOM))


		return @__table

Demo.register(new VerticalLayoutDemo())