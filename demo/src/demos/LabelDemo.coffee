###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###


class Demo.LabelDemo extends Demo

	getName: () ->
		"Labels"

	display: ->

		@__demo_table = new Demo.DemoTable("cui-label-demo")
		@__table = @__demo_table.table
		@createButtonTable()

		@__table


	__demo_table: null
	__table: null
	__buttons: []
	__toggle_enabled_state_button: null


	__addLabel: (description, label) ->
		@__demo_table.addExample( description, label.DOM )


	__addDivider: (text) ->
		@__demo_table.addDivider(text)


	createButtonTable: ->

		# ---------------- Labels --------------------------
		@__addDivider("Labels")

		label = new CUI.Label
			text: "Label Text"
		@__addLabel("normal label",label)

		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
		@__addLabel("normal label+icon",label)

		label = new CUI.Label
			text: "Label Rotated by 90deg"
			icon: "rotate_right"
			size: "big"
			rotate_90: true
		@__addLabel("rotated+icon",label)

		label = new CUI.Label
			text: "Label Rotated by 90deg"
			size: "big"
			rotate_90: true
		@__addLabel("rotated",label)


		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "mini"
		@__addLabel("size: mini",label)

		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "normal"
		@__addLabel("size: normal",label)

		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "big"
		@__addLabel("size: big",label)

		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "bigger"
		@__addLabel("size: bigger",label)

		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
			appearance: "secondary"
		@__addLabel("apperance: secondary",label)

		label = new CUI.Label
			text: "Label with Icon"
			icon: "rotate_right"
			appearance: "title"
			size: "bigger"
		@__addLabel("apperance: title, size: bigger",label)

		div = CUI.dom.append(CUI.dom.div("cui-label-demo-centered-label-parent"),
			new CUI.Label
				centered: true
				text: "Centered"
				icon: "rotate_right"
			.DOM
		)

		label = new CUI.EmptyLabel
			text: "Empty Label with Icon"
			icon: "rotate_right"
		@__addLabel("empty label",label)

		@__demo_table.addExample("centered: true",div)

		@__addDivider("Multiline labels")

		label = new CUI.Label
			multiline: true
			text: "First line\nfollowed by a second."
		@__addLabel("multiline: true",label)

		label = new CUI.Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			text: "A very long text that includes a veryverysuperlongword to show that it can break into lines."
			icon: "rotate_left"
		@__addLabel("multiline: true, Icon",label)


		label = new CUI.Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			manage_overflow: true
			text: """
			A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines. A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			"""
			icon: "rotate_left"
		@__addLabel("multiline: true, manage_overflow: true, Icon", label)

		label = new CUI.Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			manage_overflow:
				active_css_class: ""
				text_inactive: "More..."
				icon_inactive: "down"
				text_active: "Less..."
				icon_active: "up"
			text: """
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			A good and long text that includes a veryverysuperlongword to show that it can break into lines.
			"""
		@__addLabel("multiline: true, manage_overflow: text", label)

		label = new CUI.Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			manage_overflow: true
			text: """Not so long text."""
		@__addLabel("multiline: true, manage_overflow: true, Icon", label)

		label = new CUI.Label
			multiline: true
			text: "First line\nfollowed by a second.\nPlus an Icon"
			icon: "rotate_left"
			size: "big"
		@__addLabel("multiline: true, size: big",label)

		label = new CUI.Label
			multiline: true
			text: "First line\nfollowed by a second.\nPlus an Icon"
			icon: "rotate_left"
			appearance: "muted"
		@__addLabel("multiline: true, apperance: muted",label)

		@__addDivider("Markdown Label")
		label = new CUI.Label
			multiline: true
			markdown: true
			text: "# Markdown Test\n**Markdown List:**\n\n* 1\n* 2\* 3"
		@__addLabel("markdown: true", label)



Demo.register(new Demo.LabelDemo())
