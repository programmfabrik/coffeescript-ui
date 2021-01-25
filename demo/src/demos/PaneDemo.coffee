###
 * coffeescript-ui - Coffeescript User Interface System (CUI)
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Demo.PaneDemo extends Demo
	display: ->


		@demo_table = new Demo.DemoTable('cui-demo-pane')

		pane = new CUI.Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new CUI.PaneHeader
						left:
							content:
								new CUI.Label
									text: "Pane"
						center:
							content:
								new CUI.Label
									text: "Header-Center"
						right:
							content:
								[
									new CUI.Button
										icon: "edit"
									new CUI.Button
										icon: "close"
								]



				,
					new CUI.PaneToolbar
						left:
							content:
								[
									new CUI.Button
										icon: "edit"
										text: "IconButton"
									new CUI.Button
										text: "Button"
									new CUI.Button
										appearance: "flat"
										text: "FlatButton"
									new CUI.Label
										text: "Buttonbar:"
									new CUI.Buttonbar
										buttons:
											[
												new CUI.Button
													group: "GroupA"
													text: "Grouped1"
												new CUI.Button
													group: "GroupA"
													text: "Grouped2"
											]
								]
						center:
							content:
								new CUI.Label
									text: "Toolbar-Center"
						right:
							content:
								new CUI.Label
									text: "Toolbar Right."
				]

			bottom:
				content: [
					new CUI.PaneToolbar
						left:
							content:
								new CUI.Label
									text: "Toolbar Left."
						center:
							content:
								new CUI.Label
									text: "centered center"
						right:
							content:
								new CUI.Label
									text: "Toolbar Right."
				,
					new CUI.PaneFooter
						left:
							content: "PaneFooter Left"
						right:
							content: "PaneFooter Right"
				]

			center:
				content: "center"

		@demo_table.addExample("standard pane with paneHeader,toolbar, center ,toolbar and paneFooter",pane)

		fillscreenPane = new CUI.Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new CUI.PaneHeader
						left:
							content:
								new CUI.Label
									text: "Pane with Fillscreen button"
						right:
							content: [
									CUI.Pane.getToggleFillScreenButton()
							]
				]
			bottom:
				content: [
					new CUI.PaneFooter
						left:
							content: "PaneFooter Left"
						right:
							content: "PaneFooter Right"
				]


		@demo_table.addExample("pane that can fill the screen",fillscreenPane )

		emptyPane = new CUI.Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new CUI.PaneHeader
					new CUI.PaneToolbar
				]
			bottom:
				content: [
					new CUI.PaneToolbar
					new CUI.PaneFooter
				]

		@demo_table.addExample("Pane with empty toolbars. Toolbars are automatically collapsed. TODO demo collapsing dynamically.",emptyPane)

		emptySimplePane = new CUI.SimplePane
			class: "cui-demo-pane-pane"
			header_left:
				new CUI.Label
					text: "Header left shortcut"
			content:
				new CUI.Label
					text: "Center content shortcut"
			footer_right:
				new CUI.Label
					text: "Footer right shortcut"

		@demo_table.addExample("SimplePane with shorthand options for adding header and footer elements.",emptySimplePane)


		pane = new CUI.Pane
			class: "cui-demo-pane-pane"
			top:
				content: [
					new CUI.PaneHeader
					new CUI.PaneToolbar
						left:
							content: [
								new CUI.Button
									size: "big"
									text: "BigButton"
								new CUI.Button
									text: "NormalButton"
								new CUI.Label
									size: "bigger"
									text: "BiggerLabel"
								new CUI.Label
									text: "NormalLabel"
							]

				]
			bottom:
				content: [
					new CUI.PaneToolbar
					new CUI.PaneFooter
				]

		@demo_table.addExample("Pane with a toolbar that contains a mixture of buttons and labels in different sizes.",pane)


		@demo_table.table


Demo.register(new Demo.PaneDemo())