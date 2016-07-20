


class ButtonbarDemo extends Demo


	display: ->

		@__demoTable = new DemoTable()
		@__table = @__demoTable.table
		@createButtonTable()


	__demoTable = null
	__table: null
	__toggle_enabled_state_button: null


	__addDivider: (text) ->
		@__demoTable.addDivider(text)

	createButtonTable: ->


		@__addDivider("buttonbars")

		buttons = [
			new Button(
				radio: "group",
				text: "1",
				active: true,
				disabled: true
				)

			#group2
			new Button
				radio: "group"
				icon_inactive: new Icon(class: "fa-bomb")
				icon_active: new Icon(class: "fa-bullhorn")
				group: "group2"
				text: "2"

			#no group
			new Button(radio: "group", text: "3")

			new Button(
				radio: "group"
				group: "group2"
				text: "4+5"
				onClick: (ev, btn) ->
					b = btn.getRadioButtons()[4]
					if b.isHidden()
						btn.setText("4-5")
						b.show()
					else
						btn.setText("4+5")
						b.hide()
			)

			#group single
			new Button(radio: "group", group: "single", text: "5", hidden: true)

			#group2
			new Button(
				radio: "group"
				group: "group2"
				text: "1?"
				onActivate: (btn) ->
					btn.getRadioButtons()[0].enable()
				onDeactivate: (btn) ->
					btn.getRadioButtons()[0].disable()
			)
		]

		@__table.append(
				$tr_one_row(
					"Radio",
					new Buttonbar(
						buttons: buttons
					).DOM
				)
			)

		c = (ev, btn) ->
			btn.hide()

		buttons = [
			new Button(text: "Tick", group: "ttt", onClick: c)
			new Button(text: "Trick", group: "ttt", onClick: c)
			new Button(text: "Track", group: "ttt", onClick: c)
			new Button(text: "Horst", group: "ttt2", onClick: c)
			new Button(text: "Torsten", group: "ttt2", onClick: c)
			new Button(text: "Henk", group: "ttt2", onClick: c)
		]

		bb = new Buttonbar(
			tooltip:
				text: "Keep clickin"
			buttons: buttons
		)

		rb = new Button
			text: "reset"
			onClick: ->
				for btn in bb._buttons
					btn.show()

		@__table.append($tr_one_row("Buttonbar FAILS needs last-visible-child-info", [	bb.DOM,	rb.DOM ]))

		@__addDivider("Horizontal Layout with mixed controls")

		bb = new Buttonbar(
			orientation: "horizontal"
			tooltip:
				text: "mixed buttons and labels"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Label(text: "Label")
				new Button(text: "groupB", group: "groupB")
			]
		)

		select = new Select
			empty_text: "- Pick an Option -"
			name: "select"
			group: "groupB"
			data:
				view_select: 0 # set view to the first in list
				view_data:
					"result-standard":
						variant_texts: 1


			options: -> [
				text: "Banana GroupB"
			,
				text: "Republic"
				value: "Republik"
			,
				divider: true
			,
				text: "Orange"
			]
		select.start()

		bb2 = new Buttonbar(
			orientation: "horizontal"
			tooltip:
				text: "mixed buttons and selects"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				select
				new Button(text: "groupB", group: "groupB")
			]
		)


		@__table.append($tr_one_row("Buttonbar", [	bb.DOM ]))
		@__table.append($tr_one_row("Buttonbar", [	bb2.DOM ]))

		@__addDivider("Horizontal Layout in different grouping Variations")

		bb = new Buttonbar(
			orientation: "horizontal"
			tooltip:
				text: "example 1"
			buttons: [
					new Button(text: "groupA", group: "groupA")
					new Button(text: "groupB-active", group: "groupB", active: true )
					new Button(text: "groupB", group: "groupB")
				]
		)

		@__table.append($tr_one_row("example 1", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))

		bb = new Buttonbar(
			tooltip:
				text: "example 2"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupB", group: "groupB")
			]
		)

		@__table.append($tr_one_row("example 2", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))

		bb = new Buttonbar(
			tooltip:
				text: "example 3"
			buttons: [
				new Button(text: "no group"  )
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupB", group: "groupB")
			]
		)

		@__table.append($tr_one_row("example 3", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))

		bb = new Buttonbar(
			tooltip:
				text: "example 4"
			buttons: [
				new Button(text: "no group"  )
				new Button(text: "groupA", group: "groupA")
				new Button(text: "no group")
			]
		)


		@__table.append($tr_one_row("example 4", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))

		bb = new Buttonbar(
			tooltip:
				text: "example 5"
			buttons: [
				new Button(text: "no group"  )
				new Button(text: "no group", group: "no group")
				new Button(text: "no group")
			]
		)

		@__table.append($tr_one_row("example 5", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))

		bb = new Buttonbar(
			tooltip:
				text: "example 6"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
			]
		)

		@__table.append($tr_one_row("example 6", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))


		@__addDivider("Vertical Layout in different grouping Variations")

		bb = new Buttonbar(
			orientation: "vertical"
			tooltip:
				text: "example 1"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupB", group: "groupB")
				new Button(text: "groupB", group: "groupB")
			]
		)

		@__table.append($tr_one_row("example 1", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))

		@__addDivider("Vertical Layout in with one group")

		bb = new Buttonbar(
			orientation: "vertical"
			tooltip:
				text: "example 1"
			buttons: [
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
				new Button(text: "groupA", group: "groupA")
			]
		)

		@__table.append($tr_one_row("example 1", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))


		@__addDivider("Using Styles on Buttons inside buttonbar")

		bb = new Buttonbar(
			tooltip:
				text: "example 1"
			buttons: [
				new Button(
					text: "groupA", group: "groupA",
					class: "cui-dialog"
				)
				new Button(
					text: "groupB", group: "groupB",
					class: "cui-dialog"
				)
				new Button(
					text: "groupB", group: "groupB",
					class: "cui-dialog"
				)
			]
		)

		@__table.append($tr_one_row("example 1", [ $div().append($div("cui-buttonbar-demo-margin-testers").append($text(">"))).append(bb.DOM).append($div("cui-buttonbar-demo-margin-testers").append($text("<")))] ))



Demo.register(new ButtonbarDemo())