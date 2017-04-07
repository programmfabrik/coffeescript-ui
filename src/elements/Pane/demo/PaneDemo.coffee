###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class PaneDemo extends Demo
	display: ->


		@demo_table = new DemoTable('cui-demo-pane')

		pane = new Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new PaneHeader
						left:
							content:
								new Label
									text: "Pane"
						center:
							content:
								new Label
									text: "Header-Center"
						right:
							content:
								[
									new Button
										icon: "edit"
									new Button
										icon: "close"
								]



				,
					new PaneToolbar
						left:
							content:
								[
									new Button
										icon: "edit"
										text: "IconButton"
									new Button
										text: "Button"
									new Button
										appearance: "flat"
										text: "FlatButton"
									new Label
										text: "Buttonbar:"
									new Buttonbar
										buttons:
											[
												new Button
													group: "GroupA"
													text: "Grouped1"
												new Button
													group: "GroupA"
													text: "Grouped2"
											]
								]
						center:
							content:
								new Label
									text: "Toolbar-Center"
						right:
							content:
								new Label
									text: "Toolbar Right."
				]

			bottom:
				content: [
					new PaneToolbar
						left:
							content:
								new Label
									text: "Toolbar Left."
						center:
							content:
								new Label
									text: "centered center"
						right:
							content:
								new Label
									text: "Toolbar Right."
				,
					new PaneFooter
						left:
							content: "PaneFooter Left"
						right:
							content: "PaneFooter Right"
				]

			center:
				content: "center"

		@demo_table.addExample("standard pane with paneHeader,toolbar, center ,toolbar and paneFooter",pane)

		fillscreenPane = new Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new PaneHeader
						left:
							content:
								new Label
									text: "Pane with Fillscreen button"
						right:
							content: [
									Pane.getToggleFillScreenButton()
							]
				]
			bottom:
				content: [
					new PaneFooter
						left:
							content: "PaneFooter Left"
						right:
							content: "PaneFooter Right"
				]


		@demo_table.addExample("pane that can fill the screen",fillscreenPane )

		emptyPane = new Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new PaneHeader
					new PaneToolbar
				]
			bottom:
				content: [
					new PaneToolbar
					new PaneFooter
				]

		@demo_table.addExample("Pane with empty toolbars. Toolbars are automatically collapsed. TODO demo collapsing dynamically.",emptyPane)

		emptySimplePane = new SimplePane
			class: "cui-demo-pane-pane"
			header_left:
				new Label
					text: "Header left shortcut"
			content:
				new Label
					text: "Center content shortcut"
			footer_right:
				new Label
					text: "Footer right shortcut"

		@demo_table.addExample("SimplePane with shorthand options for adding header and footer elements.",emptySimplePane)


		pane = new Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new PaneHeader
					new PaneToolbar
						left:
							content: [
								new Button
									size: "big"
									text: "BigButton"
								new Button
									text: "NormalButton"
								new Label
									size: "bigger"
									text: "BiggerLabel"
								new Label
									text: "NormalLabel"
							]

				]
			bottom:
				content: [
					new PaneToolbar
					new PaneFooter
				]

		@demo_table.addExample("Pane with a toolbar that contains a mixture of buttons and labels in different sizes.",pane)


		@demo_table.table


Demo.register(new PaneDemo())