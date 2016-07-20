
class LabelDemo extends Demo

	getName: () ->
		"Labels"

	display: ->

		@__demo_table = new DemoTable("cui-label-demo")
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

		label = new Label
			text: "Label Text"
		@__addLabel("normal label",label)

		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
		@__addLabel("normal label+icon",label)

		label = new Label
			text: "Label Rotated by 90deg"
			icon: "rotate_right"
			size: "big"
			rotate_90: true
		@__addLabel("rotated+icon",label)

		label = new Label
			text: "Label Rotated by 90deg"
			size: "big"
			rotate_90: true
		@__addLabel("rotated",label)


		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "mini"
		@__addLabel("size: mini",label)

		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "normal"
		@__addLabel("size: normal",label)

		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "big"
		@__addLabel("size: big",label)

		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
			size: "bigger"
		@__addLabel("size: bigger",label)

		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
			appearance: "important"
		@__addLabel("apperance: important",label)

		label = new Label
			text: "Label with Icon"
			icon: "rotate_right"
			appearance: "title"
			size: "bigger"
		@__addLabel("apperance: title, size: bigger",label)

		div = $div("cui-label-demo-centered-label-parent").append(
			new Label
				centered: true
				text: "Centered"
				icon: "rotate_right"
			.DOM
		)

		label = new EmptyLabel
			text: "Empty Label with Icon"
			icon: "rotate_right"
		@__addLabel("empty label",label)

		@__demo_table.addExample("centered: true",div)

		@__addDivider("Multiline labels")

		label = new Label
			multiline: true
			text: "First line\nfollowed by a second."
		@__addLabel("multiline: true",label)

		label = new Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			text: "A very long text that includes a veryverysuperlongword to show that it can break into lines."
			icon: "rotate_left"
		@__addLabel("multiline: true, Icon",label)


		label = new Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			manage_overflow: true
			text: """
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			"""
			icon: "rotate_left"
		@__addLabel("multiline: true, manage_overflow: true, Icon", label)

		label = new Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			manage_overflow:
				active_css_class: ""
				text_inactive: "More..."
				icon_inactive: "down"
				text_active: "Less..."
				icon_active: "up"
			text: """
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			A very long text that includes a veryverysuperlongword to show that it can break into lines.
			"""
		@__addLabel("multiline: true, manage_overflow: text", label)

		label = new Label
			class: "cui-label-demo-multiline-with-limited-width"
			multiline: true
			manage_overflow: true
			text: """Not so long text."""
		@__addLabel("multiline: true, manage_overflow: true, Icon", label)

		label = new Label
			multiline: true
			text: "First line\nfollowed by a second.\nPlus an Icon"
			icon: "rotate_left"
			size: "big"
		@__addLabel("multiline: true, size: big",label)

		label = new Label
			multiline: true
			text: "First line\nfollowed by a second.\nPlus an Icon"
			icon: "rotate_left"
			appearance: "important"
		@__addLabel("multiline: true, apperance: important",label)




Demo.register(new LabelDemo())